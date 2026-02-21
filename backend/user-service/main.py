from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
import bcrypt
from datetime import datetime, timedelta
import jwt
import os
import uuid

app = FastAPI(title="User Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
JWT_SECRET = os.getenv("JWT_SECRET", "shopit-secret-key-2024")
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24
HARDCODED_OTP = "1234"

# Database
client = AsyncIOMotorClient(MONGO_URL)
db = client["user_service_db"]
users_collection = db["users"]

# Password hashing helpers
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

security = HTTPBearer()


# Models
class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    phone: str = ""


class UserLogin(BaseModel):
    email: str
    password: str


class OTPVerify(BaseModel):
    email: str
    otp: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    name: str
    email: str


# Helper functions
def create_token(user_id: str, email: str) -> str:
    payload = {
        "user_id": user_id,
        "email": email,
        "exp": datetime.utcnow() + timedelta(hours=JWT_EXPIRATION_HOURS),
        "iat": datetime.utcnow(),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    payload = verify_token(credentials.credentials)
    user = await users_collection.find_one({"user_id": payload["user_id"]})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# Routes
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "user-service"}


@app.post("/register", status_code=201)
async def register(user: UserRegister):
    # Check if user exists
    existing = await users_collection.find_one({"email": user.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_id = str(uuid.uuid4())
    hashed_password = hash_password(user.password)

    user_doc = {
        "user_id": user_id,
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
        "password": hashed_password,
        "created_at": datetime.utcnow().isoformat(),
    }

    await users_collection.insert_one(user_doc)

    token = create_token(user_id, user.email)

    return {
        "message": "Registration successful",
        "access_token": token,
        "token_type": "bearer",
        "user_id": user_id,
        "name": user.name,
        "email": user.email,
    }


@app.post("/login")
async def login(user: UserLogin):
    db_user = await users_collection.find_one({"email": user.email})
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(user.password, db_user["password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_token(db_user["user_id"], db_user["email"])

    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": db_user["user_id"],
        "name": db_user["name"],
        "email": db_user["email"],
    }


@app.post("/verify-otp")
async def verify_otp(data: OTPVerify):
    if data.otp != HARDCODED_OTP:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    return {"message": "OTP verified successfully", "verified": True}


@app.get("/profile")
async def get_profile(current_user: dict = Depends(get_current_user)):
    return {
        "user_id": current_user["user_id"],
        "name": current_user["name"],
        "email": current_user["email"],
        "phone": current_user.get("phone", ""),
        "created_at": current_user["created_at"],
    }


@app.get("/verify-token")
async def verify_token_endpoint(credentials: HTTPAuthorizationCredentials = Depends(security)):
    payload = verify_token(credentials.credentials)
    return {"valid": True, "user_id": payload["user_id"], "email": payload["email"]}


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8001))
    uvicorn.run(app, host="0.0.0.0", port=port)