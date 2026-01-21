# Betty Server - Project Context

## Overview

Betty Server is a NestJS-based backend optimized for Raspberry Pi, built with Nx monorepo tooling.

## Technology Stack

- **Framework**: NestJS (Node.js)
- **Build Tool**: Nx Monorepo
- **Language**: TypeScript
- **Runtime**: Node.js 20+
- **Target Platform**: Raspberry Pi (ARM architecture)
- **Process Manager**: PM2 (production)

## Project Structure

```
betty/
├── apps/
│   ├── betty-server/          # Main NestJS application
│   │   ├── src/
│   │   │   ├── core/          # Core modules (logger, config, etc.)
│   │   │   ├── main.ts        # Application entry point
│   │   │   └── app/           # App module
│   │   └── package.json
│   └── betty_app/             # Flutter mobile app (separate)
├── .agent/                    # Antigravity workflows
│   └── workflows/
├── ecosystem.config.js        # PM2 configuration
├── docker-compose.yml         # Docker setup
└── nx.json                    # Nx workspace config
```

## Key Features

- Health check endpoints (`/api/health`)
- System monitoring (`/api/system`)
- Optimized for ARM architecture
- Production-ready with PM2
- Rate limiting, CORS, and Helmet security
- External access configured (port 3000)

## Development Workflow

1. **Start dev server**: `npm run betty-server:dev` or use `/start-dev` workflow
2. **Run tests**: `npm run betty-server:test` or use `/test` workflow
3. **Build**: `npm run betty-server:build`
4. **Deploy**: Use `/deploy-rpi` workflow

## Network Configuration

- **Local**: http://localhost:3000/api
- **Network**: http://192.168.1.232:3000/api
- **Port**: 3000 (firewall configured)
- **Host**: 0.0.0.0 (all interfaces)

## Common Commands

- Generate module: Use `/generate-module` workflow
- Start dev: `/start-dev`
- Run tests: `/test`
- Deploy: `/deploy-rpi`

## Important Files

- `ecosystem.config.js` - PM2 process configuration
- `apps/betty-server/src/main.ts` - Application bootstrap
- `apps/betty-server/src/core/logger/` - Custom logging
- `.env` - Environment variables (3450 bytes, check for sensitive data)

## Notes for AI Assistant

- This is an Nx monorepo, use `nx` commands for builds/tests
- Target is Raspberry Pi, be mindful of ARM architecture
- PM2 is used for production process management
- The project has both a server (NestJS) and mobile app (Flutter)
- Current file open: custom-logger.ts (logger implementation)
