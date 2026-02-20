# ShopIt - Blinkit Clone

A full-stack quick-commerce clone built with **FastAPI** microservices, **Flutter** frontend, **MongoDB**, and **Kubernetes** deployment manifests.

## Architecture

```
┌─────────────┐       ┌──────────────────┐
│  Flutter App │──────▶│   API Gateway    │ :8000
└─────────────┘       └────────┬─────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                     ▼
  ┌──────────────┐  ┌──────────────────┐  ┌─────────────────┐
  │ User Service │  │ Product Service  │  │ Cart+Order Svc  │
  │    :8001     │  │     :8002        │  │     :8003       │
  └──────┬───────┘  └───────┬──────────┘  └────────┬────────┘
         │                  │                       │
         │                  │               ┌───────▼────────┐
         │                  │               │ Delivery Svc   │
         │                  │               │    :8004       │
         ▼                  ▼               └───────┬────────┘
  ┌─────────────────────────────────────────────────▼────────┐
  │                     MongoDB :27017                       │
  └──────────────────────────────────────────────────────────┘
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| **API Gateway** | 8000 | Routes all client requests to microservices |
| **User Service** | 8001 | Authentication, signup/login, profile, JWT |
| **Product Service** | 8002 | Product catalog, categories, search, CRUD |
| **Cart & Order Service** | 8003 | Shopping cart, order placement, order history |
| **Delivery Service** | 8004 | Delivery assignment, tracking, status simulation |

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (for mobile app)

### 1. Start Backend Services

```bash
docker-compose up --build
```

This starts MongoDB + all 5 microservices.

### 2. Seed Product Data

```bash
curl -X POST http://localhost:8000/api/seed
```

### 3. Test APIs

```bash
# Health check
curl http://localhost:8000/api/health

# Signup
curl -X POST http://localhost:8000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"123456","phone":"9876543210"}'

# Browse products
curl http://localhost:8000/api/products

# Get categories
curl http://localhost:8000/api/categories
```

### 4. Run Flutter App

```bash
cd frontend/blinkit_app
flutter pub get
flutter run
```

> **Note:** Update `lib/config/api_config.dart` with your machine's IP if running on a physical device.

## Kubernetes Deployment

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check status
kubectl get pods
kubectl get services
```

## Project Structure

```
shopit-backend/
├── backend/
│   ├── user-service/         # Auth & user management
│   ├── product-service/      # Product catalog
│   ├── cart-order-service/   # Cart & orders
│   ├── delivery-service/     # Delivery tracking
│   └── api-gateway/          # Request routing
├── frontend/
│   └── blinkit_app/          # Flutter mobile app
├── k8s/                      # Kubernetes manifests
├── docker-compose.yaml
└── README.md
```

## API Endpoints

### Auth
- `POST /api/auth/signup` — Register new user
- `POST /api/auth/login` — Login, returns JWT

### Products
- `GET /api/products` — List products (supports `?category=`, `?search=`)
- `GET /api/products/{id}` — Product details
- `GET /api/categories` — List categories
- `POST /api/seed` — Seed sample data

### Cart
- `GET /api/cart?token=` — View cart
- `POST /api/cart/add?token=` — Add item `{product_id, qty}`
- `POST /api/cart/remove?token=` — Remove item `{product_id}`
- `DELETE /api/cart/clear?token=` — Clear cart

### Orders
- `POST /api/orders?token=` — Place order `{delivery_address, payment_method}`
- `GET /api/orders?token=` — List orders
- `GET /api/orders/{id}?token=` — Order details

### Delivery
- `GET /api/delivery/track/{order_id}` — Track delivery status

## Tech Stack

- **Backend:** Python, FastAPI, Motor (async MongoDB driver)
- **Database:** MongoDB 7.0
- **Frontend:** Flutter, Provider state management
- **Infra:** Docker, Docker Compose, Kubernetes
- **Auth:** JWT (python-jose), bcrypt
