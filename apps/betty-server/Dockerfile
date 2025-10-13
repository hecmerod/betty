FROM node:20-alpine AS builder

WORKDIR /app

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

COPY apps/betty-server/package.json apps/betty-server/package-lock.json* ./
COPY --from=builder /app/apps/betty-server/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY apps/betty-server/prisma ./prisma

# Debug: verificar qué se copió
RUN echo "=== Contenido final de dist ===" && ls -la dist/
RUN echo "=== Archivos JS disponibles ===" && find dist -name "*.js" -type f

RUN addgroup -g 1001 betty && \
    adduser -u 1001 -G betty -s /bin/sh -D betty && \
    chown -R betty:betty /app

USER betty

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1

CMD ["node", "dist/out-tsc/apps/betty-server/src/main.js"]