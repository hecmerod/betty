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

# ========================================
# 2. INICIAR LOCALTUNNEL HTTP
# ========================================

# Verificar si localtunnel está instalado
if ! command -v lt &> /dev/null; then
    log "⚠️ localtunnel no está instalado. Instalando..."
    sudo npm install -g localtunnel
    
    if [ $? -eq 0 ]; then
        log "✅ localtunnel instalado"
    else
        log "❌ Error instalando localtunnel"
        exit 1
    fi
fi

# Verificar si localtunnel ya está corriendo
if pgrep -f "lt --port" > /dev/null; then
    log "⚠️ localtunnel ya está en ejecución. Deteniendo proceso anterior..."
    pkill -f "lt --port"
    sleep 2
fi

# Subdominio personalizado
SUBDOMAIN="betty-la-fragoneta-mas-guarra-del-mundo"

# Iniciar localtunnel con subdominio personalizado
log "🌐 Iniciando localtunnel en puerto 3000 con subdominio: $SUBDOMAIN..."
nohup lt --port 3000 --subdomain "$SUBDOMAIN" >> "$LOG_FILE" 2>&1 &
LT_PID=$!

if [ $? -eq 0 ]; then
    log "✅ localtunnel iniciado con PID: $LT_PID"
    
    # Esperar a que localtunnel esté listo
    sleep 5
    
    # Construir la URL con el subdominio conocido
    LT_URL="https://${SUBDOMAIN}.loca.lt"
    
    # Guardar URL en archivo
    echo "$LT_URL" > "$LT_URL_FILE"
    log "✅ URL de LocalTunnel guardada en: $LT_URL_FILE"
    
    # Verificar que el túnel esté funcionando
    if curl -s --head --request GET "$LT_URL" | grep "200\|301\|302" > /dev/null; then
        log "🌍 URL pública de localtunnel: $LT_URL"
    else
        log "⚠️ El túnel puede tardar un poco más en estar listo. URL: $LT_URL"
    fi
else
    log "❌ Error iniciando localtunnel"
    echo "ERROR: LocalTunnel no se inició" > "$LT_URL_FILE"
fi

log "✨ Proceso de inicio completado"
log "📊 Estado de los servicios:"
docker compose ps >> "$LOG_FILE" 2>&1

exit 0
