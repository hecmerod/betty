FROM node:20-alpine AS builder

WORKDIR /app

COPY tsconfig.base.json ./
COPY apps/betty-server/package.json apps/betty-server/package-lock.json ./apps/betty-server/
COPY apps/betty-server/tsconfig.json apps/betty-server/tsconfig.app.json ./apps/betty-server/

RUN cd apps/betty-server && npm ci && npm cache clean --force

COPY apps/betty-server/src/ ./apps/betty-server/src/

RUN cd apps/betty-server && npm run build

FROM node:20-alpine AS production

WORKDIR /app

COPY apps/betty-server/package.json apps/betty-server/package-lock.json* ./

RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app/dist ./dist

# Debug: verificar qué se copió
RUN echo "=== Contenido final de dist ===" && ls -la dist/
RUN echo "=== Archivos JS disponibles ===" && find dist -name "*.js" -type f

RUN groupadd -g 1001 betty && \
    useradd -u 1001 -g betty -s /bin/bash -m betty && \
    chown -R betty:betty /app

USER betty

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "dist/out-tsc/apps/betty-server/src/main.js"]