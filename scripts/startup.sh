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

# Verificar si ngrok está instalado
if ! command -v ngrok &> /dev/null; then
    log "⚠️ ngrok no está instalado. Instalando..."
    
    # Descargar e instalar ngrok para ARM64
    cd /tmp
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
    tar xvzf ngrok-v3-stable-linux-arm64.tgz
    sudo mv ngrok /usr/local/bin/
    rm ngrok-v3-stable-linux-arm64.tgz
    
    log "✅ ngrok instalado"
    
    # Nota: El usuario debe configurar el authtoken manualmente con:
    # ngrok config add-authtoken <tu-token>
fi

# Verificar si ngrok ya está corriendo
if pgrep -x "ngrok" > /dev/null; then
    log "⚠️ ngrok ya está en ejecución. Deteniendo proceso anterior..."
    pkill -x ngrok
    sleep 2
fi

# Iniciar ngrok
log "🌐 Iniciando ngrok en puerto 3000..."
nohup ngrok http 3000 >> "$LOG_FILE" 2>&1 &
NGROK_PID=$!

if [ $? -eq 0 ]; then
    log "✅ ngrok iniciado con PID: $NGROK_PID"
    
    # Esperar a que ngrok esté listo
    sleep 5
    
    # Obtener la URL pública de ngrok
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4)
    
    if [ -n "$NGROK_URL" ]; then
        log "🌍 URL pública de ngrok: $NGROK_URL"
        echo "$NGROK_URL" > "$PROJECT_DIR/ngrok_url.txt"
    else
        log "⚠️ No se pudo obtener la URL de ngrok. Verifica tu authtoken."
        log "   Configura con: ngrok config add-authtoken <tu-token>"
    fi
else
    log "❌ Error iniciando ngrok"
fi

log "✨ Proceso de inicio completado"
log "📊 Estado de los servicios:"
docker compose ps >> "$LOG_FILE" 2>&1

exit 0
