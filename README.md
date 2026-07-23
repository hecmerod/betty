# Betty

Monorepo for the Betty camper van IoT platform — a Raspberry Pi backend, mobile app, camera service, and ESP32 sensors working together to monitor and control the vehicle remotely.

Built with [Nx](https://nx.dev) for the Node.js workspace, plus Flutter, Rust, and PlatformIO for the other apps.

## Apps

| App | Stack | Description |
|---|---|---|
| [betty-server](./apps/betty-server/README.md) | NestJS, Prisma, Redis | Central API running on the Raspberry Pi. Handles alarm, GPS, trips, batteries, GPIO, notifications, and more. |
| [betty_app](./apps/betty_app/README.md) | Flutter | Mobile app for monitoring battery status, controlling lights, viewing cameras, managing the alarm, and accessing a remote terminal. |
| [betty-camera](./apps/betty-camera/README.md) | Rust, Axum, ONNX | USB camera service with MJPEG streaming and person detection that triggers the alarm. |
| [betty-esp32](./apps/betty-esp32/README.md) | PlatformIO, Arduino | ESP32 firmware for door/skylight sensors that report state changes to the server. |

## Quick start

```bash
# Install monorepo dependencies
npm install

# Start the backend (development)
npm run server:dev

# Run the mobile app
npm run betty-app

# Run the camera service (development)
npm run camera:dev
```

## Architecture

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│  betty_app  │──────▶│ betty-server │◀──────│  betty-esp32 │
│  (Flutter)  │       │   (NestJS)   │       │   (ESP32)    │
└─────────────┘       └──────┬───────┘       └─────────────┘
                             │
                      ┌──────▼───────┐
                      │ betty-camera │
                      │    (Rust)    │
                      └──────────────┘
```

## Requirements

- Node.js 20+ and npm 9+
- Flutter SDK 3.9+ (for the mobile app)
- Rust (for the camera service)
- PlatformIO (for ESP32 firmware)
- PostgreSQL and Redis (for the server)

## License

MIT
