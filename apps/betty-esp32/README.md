# Betty ESP32

PlatformIO firmware for an ESP32 that monitors a door/skylight sensor and reports state changes to [Betty Server](../betty-server/README.md).

## How it works

1. Reads a magnetic/reed sensor on GPIO 4 (with internal pull-up)
2. Drives an indicator LED on GPIO 2 based on open/closed state
3. On state change, sends an HTTP POST to the server's sensor trigger endpoint
4. Connects to WiFi on boot and retries on failure

## Requirements

- [PlatformIO](https://platformio.org/) (VS Code extension or CLI)
- ESP32 dev board (configured for `esp32dev`)

## Setup

Before flashing, copy `.env.example` to `.env` and set:

- `WIFI_SSID` / `WIFI_PASSWORD` — WiFi credentials
- `SERVER_URL` — Betty Server API base URL
- `JWT_SECRET` — shared secret used to sign request JWTs (must match Betty Server)

## Commands

From `apps/betty-esp32`:

| Command | Description |
|---|---|
| `pio run` | Build firmware |
| `pio run --target upload` | Flash to device |
| `pio device monitor` | Serial monitor (115200 baud) |

## Hardware

| Pin | Function |
|---|---|
| GPIO 4 | Door sensor input (INPUT_PULLUP, LOW = open) |
| GPIO 2 | Status LED output |

## API payload

When the sensor state changes, the device sends:

```json
{ "state": "OPENED" }
```

or

```json
{ "state": "CLOSED" }
```

to the configured sensor trigger endpoint on Betty Server.
