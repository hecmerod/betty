---
applyTo: '**'
---

# Betty Project Overview

Betty is a comprehensive IoT monitoring system designed for Raspberry Pi environments. This monorepo contains three main applications that work together to provide camera monitoring, GPS tracking, and notification services.

## 🏗️ Monorepo Structure

This is an Nx-powered monorepo with three main applications:

### 📱 `/apps/betty_app/` - Flutter Mobile App

- **Purpose**: Mobile client for monitoring and controlling the Betty system
- **Technology**: Flutter 3.9.0+
- **Features**:
  - Real-time camera streaming (MJPEG)
  - GPS tracking with OpenStreetMap integration
  - Push notifications via Firebase
  - Clean Architecture with hexagonal pattern
- **Key Modules**:
  - `camera/`: Camera control and streaming
  - `gps/`: Location tracking with map visualization
  - `notification/`: Firebase Cloud Messaging integration
  - `primary/`: Main dashboard page
  - `bottom_navigator_bar/`: Navigation system

### 🖥️ `/apps/betty-server/` - NestJS Backend API

- **Purpose**: Main backend API server
- **Technology**: NestJS (Node.js + TypeScript)
- **Features**:
  - RESTful API with JWT authentication
  - Camera proxy and control endpoints
  - Push notification management
  - Rate limiting and security middleware
- **Key Modules**:
  - `auth/`: JWT authentication system
  - `camera/`: Camera service integration
  - `notifications/`: Firebase admin for push notifications
  - `alarm/`: Alert and monitoring system

### 📷 `/apps/betty-camera/` - Python Camera Service

- **Purpose**: Raspberry Pi camera service
- **Technology**: FastAPI (Python)
- **Features**:
  - MJPEG video streaming
  - Photo capture and management
  - Hardware camera integration (PiCamera2)
  - RESTful endpoints for camera control

## 📁 Key Directories

```
betty/
├── apps/
│   ├── betty_app/          # Flutter mobile app
│   │   ├── lib/
│   │   │   ├── camera/     # Camera module (Clean Architecture)
│   │   │   ├── gps/        # GPS module (Hexagonal Architecture)
│   │   │   ├── notification/ # Push notification system
│   │   │   ├── core/       # Shared utilities and config
│   │   │   └── shared/     # Common services and models
│   │   └── android/        # Android platform files
│   ├── betty-server/       # NestJS backend API
│   │   └── src/
│   │       ├── auth/       # JWT authentication
│   │       ├── camera/     # Camera proxy service
│   │       └── notifications/ # Firebase admin
│   └── betty-camera/       # Python camera service
│       └── src/
│           ├── camera/     # Camera management
│           └── routes/     # FastAPI endpoints
├── .github/                # GitHub workflows and configs
├── docs/                   # Project documentation
└── tools/                  # Build and development tools
```

## 🎯 Coding Standards

### Flutter (Dart)

- Use **Clean Architecture** with clear separation of Domain/Infrastructure/Presentation
- Follow **Hexagonal Architecture** for every module (like GPS)
- Use **Provider pattern** for state management
- Prefer **StatelessWidget** when possible
- Use **const constructors** for performance
- Apply **Material Design 3** guidelines
- Don't use **barrel exports**.

### NestJS (TypeScript)

- Use **Clean Architecture** with clear separation of Domain/Infrastructure/Presentation
- Follow **Hexagonal Architecture** for every module
- Use **DTOs** for request/response validation
- Implement **guards** for authentication/authorization
- Follow **NestJS best practices** and conventions
- Use **Swagger** for API documentation

### Python (FastAPI)

- Use **type hints** for all function parameters and returns
- Follow **PEP 8** style guide
- Use **dependency injection** with FastAPI's Depends()
- Implement **Pydantic models** for request/response validation
- Use **async/await** for I/O operations
- Follow **RESTful API** design principles
- Use **Swagger** for API documentation

### General Standards

- Use **semicolons** at the end of statements (TypeScript/JavaScript)
- Use **single quotes** for strings (unless interpolation needed)
- Use **arrow functions** for callbacks and small functions
- Use **async/await** instead of Promises.then()

## 🔐 Security Considerations

- **JWT tokens** for API authentication
- **Firebase security rules** for push notifications
- **HTTPS only** for production deployments
- **Rate limiting** on all public endpoints
- **Input validation** on all user inputs
- **Error handling** without exposing sensitive information

## 📊 Monitoring & Logging

- **Structured logging** across all services
- **Error tracking** and crash reporting
- **Performance monitoring** for critical paths
- **Health check endpoints** for service monitoring
