FROM node:20-alpine AS builder

WORKDIR /app

# Instalar dependencias de compilación para módulos nativos de Node.js
RUN apk add --no-cache python3 make g++

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

FROM node:20-alpine AS production

WORKDIR /app

# Instalar Python 3, libgpiod para control de GPIO y bluez para Bluetooth
RUN apk add --no-cache python3 py3-libgpiod bluez bluez-deprecated

COPY apps/betty-server/package.json apps/betty-server/package-lock.json* ./
COPY --from=builder /app/apps/betty-server/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY apps/betty-server/prisma ./prisma
COPY apps/betty-server/scripts ./scripts
COPY apps/betty-server/src/gpio/infrastructure/config/pins.config.json ./dist/out-tsc/apps/betty-server/src/gpio/infrastructure/config/pins.config.json

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1

CMD ["node", "dist/out-tsc/apps/betty-server/src/main.js"]