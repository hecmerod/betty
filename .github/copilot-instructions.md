# Betty Server - NestJS + Nx + Raspberry Pi 🍓

Servidor NestJS en monorepo Nx optimizado para Raspberry Pi con arquitectura ARM.

## Configuración del Proyecto

- **Framework**: NestJS con TypeScript
- **Monorepo**: Nx workspace con herramientas avanzadas
- **Plataforma**: Raspberry Pi (ARM architecture)
- **Características**: API REST, Health checks, Monitoreo de sistema, PM2, Docker
- **Optimizaciones**: ARM, memoria limitada (512MB heap), gestión eficiente de recursos

## Estructura del Monorepo

```
betty/
├── package.json                  # Dependencias Nx + tooling global
├── apps/
│   ├── betty/                    # Aplicación NestJS principal
│   │   ├── package.json          # Dependencias específicas de Betty
│   │   ├── node_modules/         # Módulos propios de Betty
│   │   ├── project.json          # Configuración Nx de la app
│   │   └── src/
│   │       ├── app/              # Módulos, controladores, servicios
│   │       ├── config/           # Configuración (throttler, etc.)
│   │       └── main.ts           # Punto de entrada
│   └── betty-e2e/               # Tests end-to-end
├── scripts/
│   ├── start-rpi.sh             # Script optimizado para RPi
│   └── start-prod-secure.sh     # Script producción con seguridad
├── ecosystem.config.js          # Configuración PM2
├── Dockerfile.rpi              # Docker para ARM
└── test-api.http              # Tests REST Client
```

## Comandos Principales

### Desarrollo

- `npm run start:dev` - Desarrollo con hot-reload (Nx serve)
- `npm run build` - Compilar con Nx
- `npm run test` - Ejecutar tests con Jest
- `npm run lint` - ESLint + Prettier

### Producción Raspberry Pi

- `npm run start:prod` - Producción optimizada ARM
- `npm run start:rpi` - Script completo con monitoreo
- `npm run pm2:start` - Gestión con PM2 (recomendado)
- `npm run docker:build:rpi` - Imagen Docker ARM

## APIs Disponibles

- `GET /api` - Info del servidor
- `GET /api/health` - Estado y métricas de memoria
- `GET /api/system` - Info del sistema y temperatura RPi

## Gestión de Dependencias - REGLAS IMPORTANTES 📦

⚠️ **CRITICAL**: Cada aplicación debe gestionar sus propias dependencias por separado:

### Dependencias por App (apps/[app-name]/package.json)

- **NestJS**: `@nestjs/core`, `@nestjs/common`, `@nestjs/platform-express`
- **Funcionalidades específicas**: `@nestjs/throttler`, `helmet`, `rxjs`
- **Librerías de la app**: Cualquier dependencia específica de la aplicación
- **Archivo**: `apps/betty/package.json` con sus propias dependencias

### Dependencias Globales (package.json raíz)

- **Solo herramientas Nx**: `@nx/nest`, `@nx/webpack`, `@nx/eslint`
- **Tooling general**: `eslint`, `prettier`, `jest`, `typescript`
- **NO incluir**: Dependencias específicas de aplicaciones (NestJS, etc.)

### Comandos de Instalación

- `npm run install:all` - Instala workspace + todas las apps
- `nx run [app]:install` - Instala dependencias de app específica
- Build automático ejecuta instalación de dependencias de cada app

## Configuración ARM/Raspberry Pi

- Límite heap Node.js: 512MB (`--max-old-space-size=512`)
- PM2 configurado para 1 instancia (fork mode)
- Monitoreo de temperatura CPU con `vcgencmd`
- Reinicio automático si excede 200MB de RAM
- Logs estructurados en directorio `logs/`

## Generadores Nx Disponibles

- `npx nx g @nx/nest:resource [name]` - Recurso REST completo
- `npx nx g @nx/nest:service [name]` - Servicio
- `npx nx g @nx/nest:controller [name]` - Controlador
- `npx nx g @nx/nest:module [name]` - Módulo

## Herramientas Configuradas

- **ESLint + Prettier**: Formato de código automático
- **Jest**: Testing framework
- **SWC**: Compilación rápida (reemplaza ts-loader)
- **Webpack**: Bundling optimizado
- **PM2**: Gestión de procesos en producción
- **Docker**: Contenización para ARM
