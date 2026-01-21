---
description: Start the development server
---

# Start Development Server

This workflow starts the Betty server in development mode with hot-reload.

## Steps

// turbo

1. Start the development server:

```bash
npm run betty-server:dev
```

The server will be available at:

- Local: http://localhost:3000/api
- Network: http://192.168.1.232:3000/api

## Health Check

After starting, verify the server is running:

```bash
curl http://localhost:3000/api/health
```
