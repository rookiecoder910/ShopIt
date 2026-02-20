# backend/product-service/main.py
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import os
import uuid

app = FastAPI(title="Product Catalog Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")

client = AsyncIOMotorClient(MONGO_URL)
db = client["product_service_db"]
products_collection = db["products"]
categories_collection = db["categories"]


# Models
class Product(BaseModel):
    product_id: str
    name: str
    description: str
    price: float
    category: str
    image_url: str
    availability: bool = True
    unit: str = "1 pc"
    discount_percent: float = 0


class Category(BaseModel):
    category_id: str
    name: str
    image_url: str
    description: str = ""


# Seed data
SEED_CATEGORIES = [
    {"category_id": "cat-1", "name": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/2153/2153786.png", "description": "Fresh fruits and vegetables"},
    {"category_id": "cat-2", "name": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/3050/3050158.png", "description": "Milk, bread, eggs and more"},
    {"category_id": "cat-3", "name": "Snacks", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "description": "Chips, biscuits and more"},
    {"category_id": "cat-4", "name": "Beverages", "image_url": "https://cdn-icons-png.flaticon.com/512/2405/2405479.png", "description": "Juices, soft drinks, water"},
    {"category_id": "cat-5", "name": "Instant Food", "image_url": "https://cdn-icons-png.flaticon.com/512/1046/1046747.png", "description": "Noodles, ready to eat meals"},
    {"category_id": "cat-6", "name": "Personal Care", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553642.png", "description": "Soaps, shampoos, skincare"},
]

SEED_PRODUCTS = [
    # Fruits & Vegetables
    {"product_id": "prod-1", "name": "Banana", "description": "Fresh yellow bananas, rich in potassium", "price": 40.0, "category": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/2909/2909761.png", "availability": True, "unit": "1 dozen", "discount_percent": 10},
    {"product_id": "prod-2", "name": "Apple", "description": "Crisp and juicy red apples", "price": 150.0, "category": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/415/415682.png", "availability": True, "unit": "1 kg", "discount_percent": 5},
    {"product_id": "prod-3", "name": "Tomato", "description": "Farm fresh red tomatoes", "price": 30.0, "category": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/1202/1202125.png", "availability": True, "unit": "500 g", "discount_percent": 0},
    {"product_id": "prod-4", "name": "Onion", "description": "Fresh onions for daily cooking", "price": 35.0, "category": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/1202/1202083.png", "availability": True, "unit": "1 kg", "discount_percent": 0},
    {"product_id": "prod-5", "name": "Potato", "description": "Premium quality potatoes", "price": 25.0, "category": "Fruits & Vegetables", "image_url": "https://cdn-icons-png.flaticon.com/512/1652/1652077.png", "availability": True, "unit": "1 kg", "discount_percent": 15},

    # Dairy & Bread
    {"product_id": "prod-6", "name": "Amul Milk 1L", "description": "Amul full cream toned milk", "price": 65.0, "category": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/3050/3050158.png", "availability": True, "unit": "1 L", "discount_percent": 0},
    {"product_id": "prod-7", "name": "White Bread", "description": "Soft and fresh white bread", "price": 45.0, "category": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/3348/3348089.png", "availability": True, "unit": "1 pack", "discount_percent": 5},
    {"product_id": "prod-8", "name": "Eggs (6 pcs)", "description": "Farm fresh eggs pack of 6", "price": 55.0, "category": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/1864/1864514.png", "availability": True, "unit": "6 pcs", "discount_percent": 0},
    {"product_id": "prod-9", "name": "Amul Butter 100g", "description": "Amul pasteurized butter", "price": 56.0, "category": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/5765/5765092.png", "availability": True, "unit": "100 g", "discount_percent": 0},
    {"product_id": "prod-10", "name": "Curd 400g", "description": "Fresh thick curd", "price": 40.0, "category": "Dairy & Bread", "image_url": "https://cdn-icons-png.flaticon.com/512/3050/3050159.png", "availability": True, "unit": "400 g", "discount_percent": 10},

    # Snacks
    {"product_id": "prod-11", "name": "Lays Classic Salted", "description": "Crunchy potato chips", "price": 20.0, "category": "Snacks", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "availability": True, "unit": "52 g", "discount_percent": 0},
    {"product_id": "prod-12", "name": "Oreo Biscuits", "description": "Chocolate cream biscuits", "price": 30.0, "category": "Snacks", "image_url": "https://cdn-icons-png.flaticon.com/512/541/541732.png", "availability": True, "unit": "1 pack", "discount_percent": 5},
    {"product_id": "prod-13", "name": "Kurkure Masala Munch", "description": "Spicy puffed corn snack", "price": 20.0, "category": "Snacks", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "availability": True, "unit": "75 g", "discount_percent": 0},
    {"product_id": "prod-14", "name": "Dark Fantasy", "description": "Choco filled cookies", "price": 40.0, "category": "Snacks", "image_url": "https://cdn-icons-png.flaticon.com/512/541/541732.png", "availability": True, "unit": "1 pack", "discount_percent": 10},

    # Beverages
    {"product_id": "prod-15", "name": "Coca Cola 750ml", "description": "Chilled cola drink", "price": 40.0, "category": "Beverages", "image_url": "https://cdn-icons-png.flaticon.com/512/2405/2405479.png", "availability": True, "unit": "750 ml", "discount_percent": 0},
    {"product_id": "prod-16", "name": "Minute Maid Juice", "description": "Mixed fruit juice", "price": 25.0, "category": "Beverages", "image_url": "https://cdn-icons-png.flaticon.com/512/2405/2405479.png", "availability": True, "unit": "200 ml", "discount_percent": 0},
    {"product_id": "prod-17", "name": "Bisleri Water 1L", "description": "Packaged drinking water", "price": 20.0, "category": "Beverages", "image_url": "https://cdn-icons-png.flaticon.com/512/2405/2405388.png", "availability": True, "unit": "1 L", "discount_percent": 0},
    {"product_id": "prod-18", "name": "Red Bull 250ml", "description": "Energy drink", "price": 125.0, "category": "Beverages", "image_url": "https://cdn-icons-png.flaticon.com/512/2405/2405479.png", "availability": True, "unit": "250 ml", "discount_percent": 5},

    # Instant Food
    {"product_id": "prod-19", "name": "Maggi Noodles", "description": "2-minute masala noodles", "price": 14.0, "category": "Instant Food", "image_url": "https://cdn-icons-png.flaticon.com/512/1046/1046747.png", "availability": True, "unit": "1 pack", "discount_percent": 0},
    {"product_id": "prod-20", "name": "Cup Noodles", "description": "Ready to eat cup noodles", "price": 45.0, "category": "Instant Food", "image_url": "https://cdn-icons-png.flaticon.com/512/1046/1046747.png", "availability": True, "unit": "1 cup", "discount_percent": 10},
    {"product_id": "prod-21", "name": "Poha Mix", "description": "Instant poha ready mix", "price": 55.0, "category": "Instant Food", "image_url": "https://cdn-icons-png.flaticon.com/512/1046/1046747.png", "availability": True, "unit": "200 g", "discount_percent": 0},

    # Personal Care
    {"product_id": "prod-22", "name": "Dove Soap", "description": "Moisturizing beauty soap", "price": 55.0, "category": "Personal Care", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553642.png", "availability": True, "unit": "100 g", "discount_percent": 5},
    {"product_id": "prod-23", "name": "Head & Shoulders Shampoo", "description": "Anti-dandruff shampoo", "price": 180.0, "category": "Personal Care", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553642.png", "availability": True, "unit": "180 ml", "discount_percent": 10},
    {"product_id": "prod-24", "name": "Colgate Toothpaste", "description": "Cavity protection toothpaste", "price": 95.0, "category": "Personal Care", "image_url": "https://cdn-icons-png.flaticon.com/512/2553/2553642.png", "availability": True, "unit": "150 g", "discount_percent": 0},
]


@app.on_event("startup")
async def seed_database():
    # Seed categories
    cat_count = await categories_collection.count_documents({})
    if cat_count == 0:
        await categories_collection.insert_many(SEED_CATEGORIES)
        print("Categories seeded successfully")

    # Seed products
    prod_count = await products_collection.count_documents({})
    if prod_count == 0:
        await products_collection.insert_many(SEED_PRODUCTS)
        print("Products seeded successfully")


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "product-service"}


@app.get("/categories")
async def get_categories():
    categories = await categories_collection.find({}, {"_id": 0}).to_list(100)
    return {"categories": categories}


@app.get("/products")
async def get_products(
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    query = {}
    if category:
        query["category"] = category
    if search:
        query["name"] = {"$regex": search, "$options": "i"}

    skip = (page - 1) * limit
    products = await products_collection.find(query, {"_id": 0}).skip(skip).limit(limit).to_list(limit)
    total = await products_collection.count_documents(query)

    return {
        "products": products,
        "total": total,
        "page": page,
        "limit": limit,
    }


@app.get("/products/{product_id}")
async def get_product(product_id: str):
    product = await products_collection.find_one({"product_id": product_id}, {"_id": 0})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8002))
    uvicorn.run(app, host="0.0.0.0", port=port)