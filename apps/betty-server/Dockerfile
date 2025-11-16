FROM node:20-slim AS builder

WORKDIR /app

# Instalar dependencias de compilación para módulos nativos de Node.js
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY tsconfig.base.json ./
COPY apps/betty-server/package.json apps/betty-server/package-lock.json ./apps/betty-server/
COPY apps/betty-server/tsconfig.json apps/betty-server/tsconfig.app.json ./apps/betty-server/
COPY apps/betty-server/prisma ./apps/betty-server/prisma

RUN cd apps/betty-server \
    && npm ci \
    && npx prisma generate --schema=prisma/schema.prisma \
    && npm cache clean --force

COPY apps/betty-server/src/ ./apps/betty-server/src/

RUN cd apps/betty-server && npm run build

FROM node:20-slim AS production

WORKDIR /app

# Instalar dependencias del sistema para Raspberry Pi
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-libgpiod \
    libgpiod2 \
    gpiod \
    bluez \
    libcap2-bin \
    wget \
    ffmpeg \
    v4l-utils \
    lsof \
    procps \
    && pip3 install --break-system-packages gpiod \
    && npm install -g localtunnel \
    && rm -rf /var/lib/apt/lists/*

# Configurar capacidades BLE para Node.js (permite acceso a Bluetooth sin sudo)
RUN setcap cap_net_raw+eip $(which node)

COPY apps/betty-server/package.json apps/betty-server/package-lock.json* ./
COPY --from=builder /app/apps/betty-server/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY apps/betty-server/prisma ./prisma
COPY apps/betty-server/scripts ./scripts
COPY apps/betty-server/models ./models
COPY apps/betty-server/src/gpio/infrastructure/config/pins.config.json ./dist/out-tsc/apps/betty-server/src/gpio/infrastructure/config/pins.config.json

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000
ENV ENABLE_TUNNEL_HEALTH_CHECK=false

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1

CMD ["node", "dist/out-tsc/apps/betty-server/src/main.js"]