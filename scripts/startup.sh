#!/bin/bash

# Script de inicio automático para Betty
# Se ejecuta al arrancar la Raspberry Pi

LOG_FILE="/home/hecmerod/Projects/betty/logs/startup.log"
PROJECT_DIR="/home/hecmerod/Projects/betty"

# Crear directorio de logs si no existe
mkdir -p "$(dirname "$LOG_FILE")"

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🚀 Iniciando servicios de Betty..."

# Esperar a que la red esté disponible
log "⏳ Esperando conexión de red..."
while ! ping -c 1 google.com &> /dev/null; do
    sleep 5
done
log "✅ Red disponible"

# Ir al directorio del proyecto
cd "$PROJECT_DIR" || exit 1

# Iniciar Docker Compose
log "🐳 Iniciando contenedores Docker..."
docker compose up -d --build >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    log "✅ Contenedores Docker iniciados correctamente"
else
    log "❌ Error iniciando contenedores Docker"
fi

# Esperar a que los servicios estén listos
log "⏳ Esperando a que los servicios estén listos..."
sleep 10

# ========================================
# CONFIGURACIÓN DE TÚNELES
# ========================================

LT_URL_FILE="$PROJECT_DIR/tmp/localtunnel-url.txt"
ENV_FILE="$PROJECT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    set -o allexport
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +o allexport
fi
CLOUDFLARED_LOG="$PROJECT_DIR/logs/cloudflared.log"
nohup cloudflared tunnel run --token "$CLOUDFLARED_TOKEN"

# Crear directorio tmp si no existe
mkdir -p "$PROJECT_DIR/tmp"

# ========================================
# 1. INICIAR BORE MONITOR
# ========================================

log "🔌 Iniciando monitor de Bore SSH..."

# Verificar si el monitor ya está corriendo
if pgrep -f "bore-monitor.sh" > /dev/null; then
    log "⚠️ Bore monitor ya está en ejecución"
else
    # Iniciar bore-monitor en background
    nohup "$PROJECT_DIR/scripts/bore-monitor.sh" > /dev/null 2>&1 &
    MONITOR_PID=$!
    log "✅ Bore monitor iniciado con PID: $MONITOR_PID"
    log "📝 Para ver logs: tail -f $PROJECT_DIR/logs/bore-monitor.log"
    log "� Para iniciar túnel SSH: curl -X POST http://localhost:3000/api/ssh/start"
fi

log "✨ Proceso de inicio completado"
log "📊 Estado de los servicios:"
docker compose ps >> "$LOG_FILE" 2>&1

exit 0
