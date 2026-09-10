# Betty Server

NestJS backend that runs on a Raspberry Pi and coordinates the Betty camper van systems. It exposes a REST API consumed by the mobile app and IoT devices.

## Features

- **Alarm** — sensor management, activation/deactivation, and event triggers
- **GPS** — location tracking
- **Batteries (BMS)** — BLE readings from multiple battery packs
- **GPIO** — control of physical pins (lights, relays, etc.)
- **Notifications** — push notifications via Firebase Cloud Messaging
- **SSH tunnel** — remote access through a Bore tunnel
- **OBD-II** — vehicle diagnostics over Bluetooth
- **Health** — system health and resource monitoring

## Requirements

- Node.js 20+
- PostgreSQL (via Prisma)
- Redis
- Raspberry Pi with Debian/Ubuntu (production target)

## Setup

```bash
# From the monorepo root
npm run server:install

# Copy and configure environment variables
cp apps/betty-server/.env.example apps/betty-server/.env

# Run database migrations
cd apps/betty-server && npm run prisma:migrate
```

## Commands

Run these from the **monorepo root**:

| Command | Description |
|---|---|
| `npm run server:dev` | Development server with hot-reload |
| `npm run server:build` | Production build |
| `npm run server` | Start compiled production server |
| `npm run server:test` | Run unit tests |

Or from `apps/betty-server` directly:

| Command | Description |
|---|---|
| `npm run prisma:generate` | Generate Prisma client |
| `npm run prisma:migrate:dev` | Create/apply migrations (dev) |
| `npm run prisma:studio` | Open Prisma Studio |

## API

The server listens on port `3000` by default. Key endpoints:

- `GET /api/health` — health check and metrics
- `GET /api/system` — system and hardware info
- `/api/alarm/*` — alarm control
- `/api/sensors/*` — sensor events (used by ESP32 devices)
- `/api/trips/*` — trip management
- `/api/gps/*` — current location
- `/api/bms/*` — battery readings
- `/api/gpio/*` — GPIO pin control
- `/api/notifications/*` — push notification tokens

See `.postman/` for Postman collections and environment files.

## Configuration

All settings are managed through environment variables. See [`.env.example`](./.env.example) for the full list, including JWT, Redis, Firebase, GPIO paths, and camera service URL.
