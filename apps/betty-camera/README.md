# Betty Camera

Rust service that captures video from a USB camera on the Raspberry Pi, streams MJPEG frames over HTTP, and runs ONNX-based person detection to trigger the alarm on [Betty Server](../betty-server/README.md).

## Features

- **MJPEG streaming** — live camera feed at `/camera`
- **Person detection** — YOLO-style ONNX model inference on captured frames
- **Alarm integration** — automatically triggers the server alarm when a person is detected
- **Health endpoint** — `/health` for service monitoring

## Requirements

- Rust (edition 2021)
- Linux with V4L2-compatible USB camera
- ONNX model file for person detection

## Setup

```bash
cd apps/betty-camera

# Create a .env file with the variables listed below
```

Environment variables:

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8001` | HTTP server port |
| `BACKEND_URL` | — | Betty Server base URL (e.g. `http://localhost:3000/api`) |

## Commands

Run these from the **monorepo root**:

| Command | Description |
|---|---|
| `npm run camera:dev` | Run with hot-reload (requires `cargo-watch`) |
| `npm run camera:test` | Run tests |

Or from `apps/betty-camera` directly:

| Command | Description |
|---|---|
| `cargo run` | Start the camera service |
| `cargo test` | Run tests |
| `cargo build --release` | Production build |

## Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | Service info |
| `GET` | `/camera` | MJPEG video stream |
| `GET` | `/health` | Health check |

## Docker

A `Dockerfile` is included for containerized deployment on the Raspberry Pi.
