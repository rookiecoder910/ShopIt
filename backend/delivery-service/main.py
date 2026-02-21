from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import os

app = FastAPI(title="Delivery & Order Status Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")

client = AsyncIOMotorClient(MONGO_URL)
db = client["delivery_service_db"]
delivery_collection = db["deliveries"]

VALID_STATUSES = ["PLACED", "PACKED", "OUT_FOR_DELIVERY", "DELIVERED"]
STATUS_FLOW = {
    "PLACED": "PACKED",
    "PACKED": "OUT_FOR_DELIVERY",
    "OUT_FOR_DELIVERY": "DELIVERED",
    "DELIVERED": None,
}


class OrderInit(BaseModel):
    order_id: str
    user_id: str


class StatusUpdate(BaseModel):
    status: Optional[str] = None  # If None, auto-advance to next status


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "delivery-service"}


@app.post("/order/{order_id}/init")
async def init_order_delivery(order_id: str, data: OrderInit):
    existing = await delivery_collection.find_one({"order_id": order_id})
    if existing:
        return {"message": "Delivery already initialized"}

    delivery = {
        "order_id": order_id,
        "user_id": data.user_id,
        "status": "PLACED",
        "status_history": [
            {"status": "PLACED", "timestamp": datetime.utcnow().isoformat()}
        ],
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }

    await delivery_collection.insert_one(delivery)
    return {"message": "Delivery initialized", "order_id": order_id, "status": "PLACED"}


@app.get("/order/{order_id}/status")
async def get_order_status(order_id: str):
    delivery = await delivery_collection.find_one({"order_id": order_id}, {"_id": 0})
    if not delivery:
        raise HTTPException(status_code=404, detail="Order not found in delivery system")

    return {
        "order_id": delivery["order_id"],
        "status": delivery["status"],
        "status_history": delivery.get("status_history", []),
        "updated_at": delivery["updated_at"],
    }


@app.post("/order/{order_id}/update-status")
async def update_order_status(order_id: str, data: StatusUpdate):
    delivery = await delivery_collection.find_one({"order_id": order_id})
    if not delivery:
        raise HTTPException(status_code=404, detail="Order not found in delivery system")

    current_status = delivery["status"]

    if current_status == "DELIVERED":
        raise HTTPException(status_code=400, detail="Order already delivered")

    if data.status:
        # Manual status set
        if data.status not in VALID_STATUSES:
            raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of {VALID_STATUSES}")
        new_status = data.status
    else:
        # Auto-advance
        new_status = STATUS_FLOW.get(current_status)
        if not new_status:
            raise HTTPException(status_code=400, detail="No next status available")

    status_history = delivery.get("status_history", [])
    status_history.append({
        "status": new_status,
        "timestamp": datetime.utcnow().isoformat(),
    })

    await delivery_collection.update_one(
        {"order_id": order_id},
        {
            "$set": {
                "status": new_status,
                "status_history": status_history,
                "updated_at": datetime.utcnow().isoformat(),
            }
        },
    )

    return {
        "order_id": order_id,
        "previous_status": current_status,
        "current_status": new_status,
        "updated_at": datetime.utcnow().isoformat(),
    }


@app.post("/order/{order_id}/advance")
async def advance_order_status(order_id: str):
    """Convenience endpoint to advance status to next step"""
    return await update_order_status(order_id, StatusUpdate())


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8004))
    uvicorn.run(app, host="0.0.0.0", port=port)