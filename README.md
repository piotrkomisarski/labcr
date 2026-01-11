# LabCR

Fullstack application with Kotlin/Spring Boot backend and Angular frontend.

## Requirements

- **Java 23** (for backend)
- **Docker Desktop** (for MongoDB)
- **Bun** (for frontend)

## Quick Start

### 1. Backend

```bash
cd backend
./gradlew bootRun
```

MongoDB starts automatically via Docker Compose integration.

Backend runs on: http://localhost:8080

### 2. Frontend

```bash
cd frontend
bun install
bun start
```

Frontend runs on: http://localhost:4200

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/items | List all items |
| GET | /api/items/{id} | Get single item |
| POST | /api/items | Create item |
| PUT | /api/items/{id} | Update item |
| DELETE | /api/items/{id} | Delete item |

## Tech Stack

**Backend:**
- Kotlin 2.1 + Spring Boot 4.0
- Spring Data MongoDB
- Gradle 8.14

**Frontend:**
- Angular 21 with Signals
- Tailwind CSS + DaisyUI
- Bun
