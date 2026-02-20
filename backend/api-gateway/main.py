# backend/api-gateway/main.py
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import httpx
import os

app = FastAPI(title="API Gateway", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Service URLs
USER_SERVICE = os.getenv("USER_SERVICE_URL", "http://localhost:8001")
PRODUCT_SERVICE = os.getenv("PRODUCT_SERVICE_URL", "http://localhost:8002")
CART_ORDER_SERVICE = os.getenv("CART_ORDER_SERVICE_URL", "http://localhost:8003")
DELIVERY_SERVICE = os.getenv("DELIVERY_SERVICE_URL", "http://localhost:8004")

ROUTE_MAP = {
    "/api/auth": USER_SERVICE,
    "/api/products": PRODUCT_SERVICE,
    "/api/categories": PRODUCT_SERVICE,
    "/api/cart": CART_ORDER_SERVICE,
    "/api/order": CART_ORDER_SERVICE,
    "/api/orders": CART_ORDER_SERVICE,
    "/api/delivery": DELIVERY_SERVICE,
}


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "api-gateway"}


@app.get("/api/health/all")
async def health_all():
    services = {
        "user-service": USER_SERVICE,
        "product-service": PRODUCT_SERVICE,
        "cart-order-service": CART_ORDER_SERVICE,
        "delivery-service": DELIVERY_SERVICE,
    }
    results = {}
    async with httpx.AsyncClient(timeout=5.0) as client:
        for name, url in services.items():
            try:
                resp = await client.get(f"{url}/health")
                results[name] = resp.json()
            except Exception as e:
                results[name] = {"status": "unhealthy", "error": str(e)}
    return results


async def proxy_request(request: Request, target_url: str, path: str):
    async with httpx.AsyncClient(timeout=30.0) as client:
        url = f"{target_url}{path}"

        headers = dict(request.headers)
        headers.pop("host", None)

        body = await request.body()

        try:
            response = await client.request(
                method=request.method,
                url=url,
                headers=headers,
                content=body,
                params=dict(request.query_params),
            )
            return JSONResponse(
                content=response.json(),
                status_code=response.status_code,
            )
        except httpx.ConnectError:
            raise HTTPException(status_code=503, detail="Service unavailable")
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))


# Auth routes
@app.api_route("/api/auth/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def auth_proxy(request: Request, path: str):
    return await proxy_request(request, USER_SERVICE, f"/{path}")


# Product routes
@app.api_route("/api/products/{path:path}", methods=["GET"])
async def products_proxy(request: Request, path: str):
    return await proxy_request(request, PRODUCT_SERVICE, f"/products/{path}")


@app.api_route("/api/products", methods=["GET"])
async def products_list_proxy(request: Request):
    return await proxy_request(request, PRODUCT_SERVICE, "/products")


@app.api_route("/api/categories", methods=["GET"])
async def categories_proxy(request: Request):
    return await proxy_request(request, PRODUCT_SERVICE, "/categories")


# Cart routes
@app.api_route("/api/cart/{path:path}", methods=["GET", "POST"])
async def cart_proxy(request: Request, path: str):
    return await proxy_request(request, CART_ORDER_SERVICE, f"/cart/{path}")


@app.api_route("/api/cart", methods=["GET"])
async def cart_get_proxy(request: Request):
    return await proxy_request(request, CART_ORDER_SERVICE, "/cart")


# Order routes
@app.api_route("/api/order/{path:path}", methods=["GET", "POST"])
async def order_proxy(request: Request, path: str):
    return await proxy_request(request, CART_ORDER_SERVICE, f"/order/{path}")


@app.api_route("/api/orders/{path:path}", methods=["GET"])
async def orders_detail_proxy(request: Request, path: str):
    return await proxy_request(request, CART_ORDER_SERVICE, f"/orders/{path}")


@app.api_route("/api/orders", methods=["GET"])
async def orders_proxy(request: Request):
    return await proxy_request(request, CART_ORDER_SERVICE, "/orders")


# Delivery routes
@app.api_route("/api/delivery/{path:path}", methods=["GET", "POST"])
async def delivery_proxy(request: Request, path: str):
    return await proxy_request(request, DELIVERY_SERVICE, f"/order/{path}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)