from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import httpx
import jwt
import os
import uuid

app = FastAPI(title="Cart & Order Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
JWT_SECRET = os.getenv("JWT_SECRET", "shopit-secret-key-2024")
JWT_ALGORITHM = "HS256"
DELIVERY_SERVICE_URL = os.getenv("DELIVERY_SERVICE_URL", "http://localhost:8004")
PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://localhost:8002")

client = AsyncIOMotorClient(MONGO_URL)
db = client["cart_order_service_db"]
carts_collection = db["carts"]
orders_collection = db["orders"]

security = HTTPBearer()


# Models
class CartItem(BaseModel):
    product_id: str
    quantity: int = 1
    name: Optional[str] = None
    price: Optional[float] = None
    image_url: Optional[str] = None
    unit: Optional[str] = None


class CartRemoveItem(BaseModel):
    product_id: str


class OrderCreate(BaseModel):
    delivery_address: str = "123 Main Street, City"


# Auth helper
def get_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    try:
        payload = jwt.decode(credentials.credentials, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload["user_id"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


# Routes
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "cart-order-service"}


@app.post("/cart/add")
async def add_to_cart(item: CartItem, user_id: str = Depends(get_user_id)):
    # Try to fetch product details if not provided
    if not item.name or not item.price:
        try:
            async with httpx.AsyncClient() as client_http:
                resp = await client_http.get(f"{PRODUCT_SERVICE_URL}/products/{item.product_id}")
                if resp.status_code == 200:
                    product = resp.json()
                    item.name = product.get("name", "Unknown")
                    item.price = product.get("price", 0)
                    item.image_url = product.get("image_url", "")
                    item.unit = product.get("unit", "1 pc")
        except Exception:
            pass

    # Find or create cart
    cart = await carts_collection.find_one({"user_id": user_id})

    if not cart:
        cart = {
            "user_id": user_id,
            "items": [],
            "updated_at": datetime.utcnow().isoformat(),
        }
        await carts_collection.insert_one(cart)

    # Check if item already in cart
    existing_item = None
    items = cart.get("items", [])
    for i, ci in enumerate(items):
        if ci["product_id"] == item.product_id:
            existing_item = i
            break

    if existing_item is not None:
        items[existing_item]["quantity"] += item.quantity
        if items[existing_item]["quantity"] <= 0:
            items.pop(existing_item)
    else:
        if item.quantity > 0:
            items.append({
                "product_id": item.product_id,
                "quantity": item.quantity,
                "name": item.name or "Unknown",
                "price": item.price or 0,
                "image_url": item.image_url or "",
                "unit": item.unit or "1 pc",
            })

    await carts_collection.update_one(
        {"user_id": user_id},
        {"$set": {"items": items, "updated_at": datetime.utcnow().isoformat()}},
    )

    return {"message": "Cart updated", "cart_items": len(items)}


@app.post("/cart/remove")
async def remove_from_cart(item: CartRemoveItem, user_id: str = Depends(get_user_id)):
    cart = await carts_collection.find_one({"user_id": user_id})
    if not cart:
        raise HTTPException(status_code=404, detail="Cart not found")

    items = [i for i in cart.get("items", []) if i["product_id"] != item.product_id]

    await carts_collection.update_one(
        {"user_id": user_id},
        {"$set": {"items": items, "updated_at": datetime.utcnow().isoformat()}},
    )

    return {"message": "Item removed from cart"}


@app.get("/cart")
async def get_cart(user_id: str = Depends(get_user_id)):
    cart = await carts_collection.find_one({"user_id": user_id}, {"_id": 0})
    if not cart:
        return {"user_id": user_id, "items": [], "total": 0}

    items = cart.get("items", [])
    total = sum(item.get("price", 0) * item.get("quantity", 1) for item in items)

    return {
        "user_id": user_id,
        "items": items,
        "total": round(total, 2),
        "item_count": len(items),
    }


@app.post("/order/create")
async def create_order(order_data: OrderCreate, user_id: str = Depends(get_user_id)):
    cart = await carts_collection.find_one({"user_id": user_id})
    if not cart or not cart.get("items"):
        raise HTTPException(status_code=400, detail="Cart is empty")

    items = cart["items"]
    total = sum(item.get("price", 0) * item.get("quantity", 1) for item in items)

    order_id = f"ORD-{str(uuid.uuid4())[:8].upper()}"

    order = {
        "order_id": order_id,
        "user_id": user_id,
        "items": items,
        "total": round(total, 2),
        "delivery_address": order_data.delivery_address,
        "status": "PLACED",
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }

    await orders_collection.insert_one(order)

    # Clear cart
    await carts_collection.update_one(
        {"user_id": user_id},
        {"$set": {"items": [], "updated_at": datetime.utcnow().isoformat()}},
    )

    # Notify delivery service
    try:
        async with httpx.AsyncClient() as client_http:
            await client_http.post(
                f"{DELIVERY_SERVICE_URL}/order/{order_id}/init",
                json={"order_id": order_id, "user_id": user_id},
            )
    except Exception as e:
        print(f"Failed to notify delivery service: {e}")

    return {
        "message": "Order placed successfully",
        "order_id": order_id,
        "total": round(total, 2),
        "status": "PLACED",
    }


@app.get("/orders")
async def get_orders(user_id: str = Depends(get_user_id)):
    orders = await orders_collection.find(
        {"user_id": user_id}, {"_id": 0}
    ).sort("created_at", -1).to_list(50)

    # Fetch latest status from delivery service (best-effort, short timeout)
    for order in orders:
        try:
            async with httpx.AsyncClient(timeout=3.0) as client_http:
                resp = await client_http.get(
                    f"{DELIVERY_SERVICE_URL}/order/{order['order_id']}/status"
                )
                if resp.status_code == 200:
                    status_data = resp.json()
                    order["status"] = status_data.get("status", order["status"])
        except Exception:
            pass

    return {"orders": orders}


@app.post("/order/{order_id}/advance")
async def advance_order_status(order_id: str, user_id: str = Depends(get_user_id)):
    """Advance order to next status: PLACED→PACKED→OUT_FOR_DELIVERY→DELIVERED"""
    STATUS_FLOW = {
        "PLACED": "PACKED",
        "PACKED": "OUT_FOR_DELIVERY",
        "OUT_FOR_DELIVERY": "DELIVERED",
    }

    order = await orders_collection.find_one({"order_id": order_id, "user_id": user_id})
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    current = order["status"]
    next_status = STATUS_FLOW.get(current)
    if not next_status:
        raise HTTPException(status_code=400, detail="Order already delivered")

    await orders_collection.update_one(
        {"order_id": order_id},
        {"$set": {"status": next_status, "updated_at": datetime.utcnow().isoformat()}},
    )

    # Also try to update delivery service (best-effort)
    try:
        async with httpx.AsyncClient(timeout=3.0) as client_http:
            await client_http.post(f"{DELIVERY_SERVICE_URL}/order/{order_id}/advance")
    except Exception:
        pass

    return {
        "order_id": order_id,
        "previous_status": current,
        "current_status": next_status,
    }


@app.get("/orders/{order_id}")
async def get_order(order_id: str, user_id: str = Depends(get_user_id)):
    order = await orders_collection.find_one(
        {"order_id": order_id, "user_id": user_id}, {"_id": 0}
    )
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Fetch latest status (best-effort, short timeout)
    try:
        async with httpx.AsyncClient(timeout=3.0) as client_http:
            resp = await client_http.get(
                f"{DELIVERY_SERVICE_URL}/order/{order_id}/status"
            )
            if resp.status_code == 200:
                status_data = resp.json()
                order["status"] = status_data.get("status", order["status"])
                order["status_updated_at"] = status_data.get("updated_at", "")
    except Exception:
        pass

    return order


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8003))
    uvicorn.run(app, host="0.0.0.0", port=port)