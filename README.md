<div align="center">

<img src="frontend/blinkit_app/logo/shopit_applogo.png" alt="ShopIt Logo" width="180"/>

# ShopIt

### A Full-Stack Quick Commerce App

[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![MongoDB](https://img.shields.io/badge/MongoDB_Atlas-Cloud-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![Render](https://img.shields.io/badge/Render-Deployed-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)

A production-ready quick-commerce clone inspired by Blinkit, featuring a **microservices backend** (Python/FastAPI), a **cross-platform Flutter frontend** (Android + Web), **MongoDB Atlas** for cloud persistence, **Cloudinary** for optimized product images, **Render** for live deployment, and full **Docker Compose** & **Kubernetes** support.

[Features](#-features) · [Live Demo](#-live-demo) · [Video Demo](#-video-demo) · [Screenshots](#-screenshots) · [Architecture](#-architecture) · [Quick Start](#-quick-start) · [API Reference](#-api-reference) · [Deployment](#-deployment)

</div>

---

## 🌐 Live Demo

The backend microservices are **deployed and live** on Render (free tier):

| Service | Live URL |
|---------|----------|
| User Service | `https://shopit-user-service.onrender.com` |
| Product Service | `https://shopit-product-service.onrender.com` |
| Cart & Order Service | `https://shopit-cart-order-service.onrender.com` |
| Delivery Service | `https://shopit-delivery-service.onrender.com` |

> **Note:** Free-tier Render services spin down after 15 minutes of inactivity. The first request may take ~30-60 seconds while the service cold-starts.

**Quick test:**
```bash
# Check if product service is live
curl https://shopit-product-service.onrender.com/health

# Browse products
curl https://shopit-product-service.onrender.com/products
```

---

## 🎬 Video Demo

<div align="center">

[![Watch the Demo](https://img.shields.io/badge/▶_Watch_Demo-Google_Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1XEW79pRq-L_oNKO-_MECTozJ2fwZwe7r/view?usp=sharing)

> Click the button above to watch a full walkthrough of the ShopIt app — browsing products, adding to cart, placing orders, and tracking delivery.

</div>

---

## 📸 Screenshots

<div align="center">

| Login Screen | Home Screen |
|:---:|:---:|
| <img src="https://drive.google.com/uc?export=view&id=18z8EZECIIiUL2_4RJaNizRJXu13mXujd" width="300"/> | <img src="https://drive.google.com/uc?export=view&id=1i7KcpZrDI1B0sKhSwABGJxIFH22wbDd5" width="300"/> |

| Cart Screen | My Orders |
|:---:|:---:|
| <img src="https://drive.google.com/uc?export=view&id=1MKaORN58aQfTFDTh3xSumnacanAVVJfD" width="300"/> | <img src="https://drive.google.com/uc?export=view&id=1rOHVvn986wijOQYWGa8nrZtzG4zczEro" width="300"/> |

</div>

---

## ✨ Features

- **User Authentication** — Register, login, JWT-based session management, OTP verification
- **Product Catalog** — Browse 24 products across 6 categories with search & pagination
- **Shopping Cart** — Add, remove, update quantities with real-time price calculation
- **Order Management** — Place orders, view order history, track delivery status
- **Delivery Tracking** — Real-time order status pipeline: Placed → Packed → Out for Delivery → Delivered
- **Responsive UI** — Adaptive layout for mobile (Android) and web browsers
- **Microservices** — 4 independently deployable backend services communicating via REST
- **API Gateway** — Optional single entry point for local development
- **Cloud Deployed** — Live on Render with MongoDB Atlas (zero-cost hosting)
- **Cloudinary Images** — Product images hosted on Cloudinary with 800×800 auto-optimization
- **Custom App Icon** — Branded ShopIt launcher icon with adaptive icon support
- **Local/Cloud Toggle** — Single flag in `api_config.dart` to switch between local and cloud backends
- **Auto Seed Data** — Product catalog auto-seeds on first startup (no manual setup needed)
- **Containerized** — One-command deployment with Docker Compose
- **K8s Ready** — Kubernetes manifests included for cloud deployment

---

## 🏗 Architecture

### Cloud Mode (Production — Render + MongoDB Atlas)

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                                │
│                                                                      │
│    ┌─────────────────┐              ┌─────────────────┐              │
│    │  Flutter Mobile  │              │   Flutter Web   │              │
│    │    (Android)     │              │    (Chrome)     │              │
│    └────────┬─────────┘              └────────┬────────┘              │
│             │         HTTPS (Render URLs)     │                      │
└─────────────┼─────────────────────────────────┼──────────────────────┘
              │                                 │
              ▼                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    RENDER CLOUD (Free Tier)                          │
│                                                                      │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐       │
│  │   User     │ │  Product   │ │ Cart+Order │ │  Delivery  │       │
│  │  Service   │ │  Service   │ │  Service   │ │  Service   │       │
│  │            │ │            │ │            │ │            │       │
│  │ • Register │ │ • Catalog  │ │ • Cart     │ │ • Status   │       │
│  │ • Login    │ │ • Search   │ │ • Orders   │ │ • Tracking │       │
│  │ • JWT Auth │ │ • Category │ │ • Checkout │ │ • History  │       │
│  │ • Profile  │ │ • Paginate │ │ • History  │ │ • Advance  │       │
│  └─────┬──────┘ └─────┬──────┘ └──┬───┬─────┘ └─────┬──────┘       │
│        │              │           │   │              │              │
│        │              │           │   └──────────────┘              │
│        │              │           │   (inter-service calls)         │
└────────┼──────────────┼───────────┼─────────────────────────────────┘
         │              │           │
         ▼              ▼           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     MongoDB Atlas (Cloud)                            │
│                                                                      │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│   │user_service_db│  │product_svc_db│  │cart_order_db │  ...         │
│   └──────────────┘  └──────────────┘  └──────────────┘              │
└──────────────────────────────────────────────────────────────────────┘
```

### Local Mode (Development — Docker / localhost)

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                                │
│                                                                      │
│    ┌─────────────────┐              ┌─────────────────┐              │
│    │  Flutter Mobile  │              │   Flutter Web   │              │
│    │    (Android)     │              │    (Chrome)     │              │
│    └────────┬─────────┘              └────────┬────────┘              │
└─────────────┼─────────────────────────────────┼──────────────────────┘
              │                                 │
              ▼                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   API GATEWAY (optional) :8000                       │
│            Routes /api/* requests to backend services                │
└──────┬──────────────┬──────────────┬──────────────┬──────────────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐
│   User     │ │  Product   │ │ Cart+Order │ │  Delivery  │
│  Service   │ │  Service   │ │  Service   │ │  Service   │
│   :8001    │ │   :8002    │ │   :8003    │ │   :8004    │
└─────┬──────┘ └─────┬──────┘ └─────┬───────┘ └─────┬──────┘
      │              │              │                │
      ▼              ▼              ▼                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    MongoDB 7.0 (Docker) :27017                       │
└──────────────────────────────────────────────────────────────────────┘
```

> **Toggle between modes:** Set `useLocalBackend` in `lib/config/api_config.dart` to `true` (local) or `false` (cloud).

---

## 📦 Project Structure

```
shopit-backend/
│
├── backend/
│   ├── api-gateway/                # Reverse proxy & request router
│   │   ├── main.py                 # FastAPI gateway with route mapping
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── user-service/               # Authentication & user management
│   │   ├── main.py                 # Register, login, JWT, profile
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── product-service/            # Product catalog & categories
│   │   ├── main.py                 # CRUD, search, pagination, auto-seed
│   │   ├── seed_data.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── cart-order-service/         # Shopping cart & order processing
│   │   ├── main.py                 # Cart ops, order creation, history
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   └── delivery-service/           # Delivery tracking & status management
│       ├── main.py                 # Status pipeline, tracking, history
│       ├── Dockerfile
│       └── requirements.txt
│
├── frontend/
│   └── blinkit_app/                # Flutter cross-platform app
│       ├── lib/
│       │   ├── main.dart           # App entry point, theme, routing
│       │   ├── config/
│       │   │   └── api_config.dart # Platform-aware API URL config
│       │   ├── models/
│       │   │   ├── user_model.dart
│       │   │   ├── product_model.dart
│       │   │   ├── cart_model.dart
│       │   │   └── order_model.dart
│       │   ├── providers/          # State management (Provider pattern)
│       │   │   ├── auth_provider.dart
│       │   │   ├── product_provider.dart
│       │   │   ├── cart_provider.dart
│       │   │   └── order_provider.dart
│       │   ├── services/           # HTTP API service layer
│       │   │   ├── auth_service.dart
│       │   │   ├── product_service.dart
│       │   │   ├── cart_service.dart
│       │   │   └── order_service.dart
│       │   └── screens/            # UI screens
│       │       ├── login_screen.dart
│       │       ├── signup_screen.dart
│       │       ├── home_screen.dart
│       │       ├── product_detail_screen.dart
│       │       ├── cart_screen.dart
│       │       ├── order_tracking_screen.dart
│       │       └── order_confirmation_screen.dart
│       ├── logo/
│       │   └── shopit_applogo.png  # App launcher icon source
│       ├── android/                # Android platform config
│       ├── web/                    # Web platform config
│       └── pubspec.yaml
│
├── k8s/                            # Kubernetes deployment manifests
│   ├── mongodb-deployment.yaml
│   ├── user-service-deployment.yaml
│   ├── product-service-deployment.yaml
│   ├── cart-order-service-deployment.yaml
│   ├── delivery-service-deployment.yaml
│   └── api-gateway-deployment.yaml
│
├── docker-compose.yaml             # One-command full stack deployment
├── render.yaml                     # Render Blueprint (cloud deployment)
└── README.md
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.0+, Dart | Cross-platform UI (Android + Web) |
| **State Mgmt** | Provider | Reactive state management |
| **Backend** | Python 3.11+, FastAPI | Async REST microservices |
| **Database** | MongoDB Atlas (Cloud) | Managed NoSQL document store |
| **Image CDN** | Cloudinary | Optimized product image hosting (800×800, auto-format) |
| **DB (Local)** | MongoDB 7.0 (Docker) | Local development database |
| **DB Driver** | Motor (async), dnspython | Non-blocking MongoDB operations + SRV resolution |
| **Auth** | JWT (PyJWT), bcrypt | Token-based authentication |
| **HTTP Client** | httpx | Async inter-service communication |
| **Gateway** | FastAPI + httpx | API routing & proxying (local dev) |
| **Cloud Hosting** | Render (Free Tier) | Live backend deployment |
| **Containers** | Docker, Docker Compose | Containerization & orchestration |
| **Orchestration** | Kubernetes | Production deployment manifests |

---

## 🚀 Quick Start

### Prerequisites

| Tool | Version | Required For |
|------|---------|-------------|
| [Docker](https://docs.docker.com/get-docker/) & Docker Compose | Latest | Backend services |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | >= 3.0.0 | Frontend app |
| [Python](https://python.org) | >= 3.11 | Local development (optional) |

---

### Option 1: Docker Compose (Recommended)

Spin up the entire backend stack with a single command:

```bash
# Clone the repository
git clone https://github.com/rookiecoder910/shopit-backend.git
cd shopit-backend

# Start all services (MongoDB + 5 microservices)
docker-compose up --build
```

Services will be available at:
| Service | URL |
|---------|-----|
| API Gateway | http://localhost:8000 |
| User Service | http://localhost:8001 |
| Product Service | http://localhost:8002 |
| Cart & Order Service | http://localhost:8003 |
| Delivery Service | http://localhost:8004 |

> Products and categories are **auto-seeded** on first startup — no manual seeding needed.

---

### Option 2: Local Development (Without Docker)

#### 1. Start MongoDB

```bash
docker run -d -p 27017:27017 --name mongodb mongo:7
```

#### 2. Set up Python environment

```bash
python -m venv .myenv

# Windows
.myenv\Scripts\Activate.ps1

# macOS/Linux
source .myenv/bin/activate

pip install fastapi uvicorn motor pymongo pydantic python-multipart httpx PyJWT bcrypt dnspython "pydantic[email]"
```

#### 3. Start each microservice (in separate terminals)

```bash
# Terminal 1 — User Service
cd backend/user-service
uvicorn main:app --host 0.0.0.0 --port 8001 --reload

# Terminal 2 — Product Service
cd backend/product-service
uvicorn main:app --host 0.0.0.0 --port 8002 --reload

# Terminal 3 — Cart & Order Service
cd backend/cart-order-service
uvicorn main:app --host 0.0.0.0 --port 8003 --reload

# Terminal 4 — Delivery Service
cd backend/delivery-service
uvicorn main:app --host 0.0.0.0 --port 8004 --reload

# Terminal 5 — API Gateway (optional, for unified access)
cd backend/api-gateway
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

#### 4. Verify all services

```bash
# Quick health check
curl http://localhost:8001/health   # User Service
curl http://localhost:8002/health   # Product Service
curl http://localhost:8003/health   # Cart & Order Service
curl http://localhost:8004/health   # Delivery Service
```

---

### Run the Flutter App

#### Web (Chrome)

```bash
cd frontend/blinkit_app
flutter pub get
flutter run -d chrome
```

#### Android (Emulator)

```bash
cd frontend/blinkit_app
flutter pub get

# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_name>

# Run the app
flutter run -d <device_id>
```

> **Local vs Cloud Backend:** The app has a `useLocalBackend` toggle in `lib/config/api_config.dart`:
> - **`useLocalBackend = false`** (default) → Connects to live Render cloud services (HTTPS)
> - **`useLocalBackend = true`** → Connects to `localhost` for local development
> - For **Android Emulator** local dev: run `adb reverse tcp:800X tcp:800X` for each service port

---

## 🗄 Services Overview

### User Service (`:8001`)

Handles authentication and user management with bcrypt password hashing and JWT tokens.

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/register` | POST | No | Create new account |
| `/login` | POST | No | Authenticate & get JWT |
| `/verify-otp` | POST | No | OTP verification (hardcoded: `1234`) |
| `/profile` | GET | JWT | Get user profile |
| `/verify-token` | GET | JWT | Validate JWT token |
| `/health` | GET | No | Service health check |

**Register Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword",
  "phone": "9876543210"
}
```

**Login Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user_id": "uuid-here",
  "name": "John Doe",
  "email": "john@example.com"
}
```

---

### Product Service (`:8002`)

Manages the product catalog with 6 categories and 24 pre-seeded products with Cloudinary-hosted images. Auto-seeds on first startup. Supports force re-seeding via `/reseed`.

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/products` | GET | No | List products (paginated) |
| `/products/{product_id}` | GET | No | Get product details |
| `/categories` | GET | No | List all categories |
| `/reseed` | POST | No | Force re-seed all products & categories |
| `/health` | GET | No | Service health check |

**Query Parameters for `/products`:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `category` | string | — | Filter by category name |
| `search` | string | — | Search by product name (regex) |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |

**Product Categories:**
| Category | Products |
|----------|----------|
| Fruits & Vegetables | Banana, Apple, Tomato, Onion, Potato (5) |
| Dairy & Bread | Amul Milk, White Bread, Eggs, Amul Butter, Amul Curd (5) |
| Snacks | Lays Classic, Oreo, Kurkure Masala, Dark Fantasy Choco Fills (4) |
| Beverages | Coca Cola, Minute Maid, Bisleri Water, Red Bull (4) |
| Instant Food | Maggi Noodles, Cup Noodles, Poha Mix (3) |
| Personal Care | Dove Soap, Head & Shoulders, Colgate Toothpaste (3) |

---

### Cart & Order Service (`:8003`)

Manages shopping carts and complete order lifecycle. Communicates with Product Service for product details and Delivery Service for order initialization.

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/cart` | GET | JWT | View current cart |
| `/cart/add` | POST | JWT | Add item to cart |
| `/cart/remove` | POST | JWT | Remove item from cart |
| `/order/create` | POST | JWT | Place order from cart |
| `/orders` | GET | JWT | List order history |
| `/orders/{order_id}` | GET | JWT | Get order details |
| `/health` | GET | No | Service health check |

**Add to Cart:**
```json
{
  "product_id": "prod-1",
  "quantity": 2
}
```

**Create Order:**
```json
{
  "delivery_address": "123 Main Street, City"
}
```

---

### Delivery Service (`:8004`)

Tracks order delivery status through a defined pipeline. Supports both manual and auto-advance status updates.

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/order/{order_id}/init` | POST | No | Initialize delivery for new order |
| `/order/{order_id}/status` | GET | No | Get current delivery status |
| `/order/{order_id}/update-status` | POST | No | Update delivery status |
| `/order/{order_id}/advance` | POST | No | Auto-advance to next status |
| `/health` | GET | No | Service health check |

**Status Pipeline:**
```
PLACED  →  PACKED  →  OUT_FOR_DELIVERY  →  DELIVERED
```

---

### API Gateway (`:8000`)

Single entry point that proxies all client requests to the appropriate microservice.

| Route Pattern | Target Service |
|---------------|---------------|
| `/api/auth/*` | User Service (:8001) |
| `/api/products/*` | Product Service (:8002) |
| `/api/categories` | Product Service (:8002) |
| `/api/cart/*` | Cart & Order Service (:8003) |
| `/api/order/*` | Cart & Order Service (:8003) |
| `/api/orders/*` | Cart & Order Service (:8003) |
| `/api/delivery/*` | Delivery Service (:8004) |

---

## 📱 Frontend Screens

| Screen | Description |
|--------|-------------|
| **Login** | Email & password authentication |
| **Sign Up** | New user registration with name, email, phone |
| **Home** | Product grid with category filters, responsive layout (2-6 columns) |
| **Product Detail** | Full product info with add-to-cart functionality |
| **Cart** | View cart items, adjust quantities, proceed to checkout |
| **Order Confirmation** | Order placed success with order ID |
| **Order Tracking** | Real-time delivery status with progress pipeline |

**Responsive Design:**
- Mobile: 2-column product grid
- Tablet: 3-4 column grid
- Desktop/Web: 5-6 column grid with max-width constraints

---

## 🐳 Deployment

### Option 1: Render (Cloud — Recommended for Production)

The project includes a `render.yaml` Blueprint for one-click cloud deployment:

1. **Fork/push** this repo to your GitHub account
2. **Create a [MongoDB Atlas](https://www.mongodb.com/atlas)** free cluster (M0)
   - Create a database user with password
   - Add `0.0.0.0/0` to Network Access (IP whitelist)
   - Copy the `mongodb+srv://...` connection string
3. *Option 3: *Go to [Render Dashboard](https://dashboard.render.com)** → New → Blueprint
   - Connect your GitHub repo
   - Render will detect `render.yaml` and create 4 services
4. **Set environment variables** on each service in the Render dashboard:
   - `MONGO_URL` = your MongoDB Atlas connection string
   - For cart-order-service, also set:
     - `DELIVERY_SERVICE_URL` = `https://shopit-delivery-service.onrender.com`
     - `PRODUCT_SERVICE_URL` = `https://shopit-product-service.onrender.com`
5. **Deploy** — services will build and start automatically
6. Products auto-seed on first startup

> **Free tier note:** Services spin down after 15 min of inactivity. First request after idle takes ~30-60s.

---

### Option 2: Docker Compose (Local)

```bash
docker-compose up --build -d    # Start in background
docker-compose logs -f          # Follow logs
docker-compose down             # Stop all services
docker-compose down -v          # Stop & remove volumes
```

### Kubernetes

Pre-built manifests are included for all services:

```bash
# Deploy everything
kubectl apply -f k8s/

# Verify pods(use Atlas `mongodb+srv://...` for cloud) |
| `JWT_SECRET` | User, Cart-Order | `shopit-secret-key-2024` | JWT signing secret |
| `USER_SERVICE_URL` | API Gateway | `http://localhost:8001` | User service URL |
| `PRODUCT_SERVICE_URL` | API Gateway, Cart-Order | `http://localhost:8002` | Product service URL (Render URL for cloud) |
| `CART_ORDER_SERVICE_URL` | API Gateway | `http://localhost:8003` | Cart & order service URL |
| `DELIVERY_SERVICE_URL` | API Gateway, Cart-Order | `http://localhost:8004` | Delivery service URL (Render URL for cloud) |
| `PORT` | All (Render) | — | Auto-set by Render; used in `uvicorn --port $PORT`
# View logs
kubectl logs -f deployment/user-service
```

### Cloud (Render)

```bash
# Health check
curl https://shopit-product-service.onrender.com/health

# Browse products
curl https://shopit-product-service.onrender.com/products

# Search products
curl "https://shopit-product-service.onrender.com/products?search=milk"

# Register a new user
curl -X POST https://shopit-user-service.onrender.com/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"pass123","phone":"9876543210"}'

# Login
curl -X POST https://shopit-user-service.onrender.com/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'
```

### Local Development

**K8s Resources included:**
- `mongodb-deployment.yaml` — MongoDB with persistent volume
- `user-service-deployment.yaml`
- `product-service-deployment.yaml`
- `cart-order-service-deployment.yaml`
- `delivery-service-deployment.yaml`
- `api-gateway-deployment.yaml`

---

## ⚙️ Environment Variables

| Variable | Service | Default | Description |
|----------|---------|---------|-------------|
| `MONGO_URL` | All backend | `mongodb://localhost:27017` | MongoDB connection string |
| `JWT_SECRET` | User, Cart-Order | `shopit-secret-key-2024` | JWT signing secret |
| `USER_SERVICE_URL` | API Gateway | `http://localhost:8001` | User service URL |
| `PRODUCT_SERVICE_URL` | API Gateway, Cart-Order | `http://localhost:8002` | Product service URL |
| `CART_ORDER_SERVICE_URL` | API Gateway | `http://localhost:8003` | Cart & order service URL |
| `DELIVERY_SERVICE_URL` | API Gateway, Cart-Order | `http://localhost:8004` | Delivery service URL |

---

## 🧪 Testing the APIs

```bash
# Register a new user
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"pass123","phone":"9876543210"}'
, MongoDB Atlas & Render
# Login
curl -X POST http://localhost:8001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'

# Browse products
curl http://localhost:8002/products

# Search products
curl "http://localhost:8002/products?search=milk"

# Filter by category
curl "http://localhost:8002/products?category=Snacks"

# Get categories
curl http://localhost:8002/categories

# Add to cart (replace TOKEN with JWT from login)
curl -X POST http://localhost:8003/cart/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"product_id":"prod-1","quantity":2}'

# View cart
curl -H "Authorization: Bearer TOKEN" http://localhost:8003/cart

# Place order
curl -X POST http://localhost:8003/order/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"delivery_address":"123 Main St, City"}'

# Track delivery (replace ORDER_ID)
curl http://localhost:8004/order/ORDER_ID/status

# Advance delivery status
curl -X POST http://localhost:8004/order/ORDER_ID/advance
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ using FastAPI, Flutter, MongoDB & Cloudinary**

</div>
