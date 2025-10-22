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

# Verificar si localtunnel está instalado
if ! command -v lt &> /dev/null; then
    log "⚠️ localtunnel no está instalado. Instalando..."
    
    # Instalar localtunnel globalmente con npm
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

# Subdominio personalizado difícil de replicar pero siempre el mismo
# Cambia este valor por algo único y seguro para tu instalación
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
    
    # Verificar que el túnel esté funcionando
    if curl -s --head --request GET "$LT_URL" | grep "200\|301\|302" > /dev/null; then
        log "🌍 URL pública de localtunnel: $LT_URL"
        
    else
        log "⚠️ El túnel puede tardar un poco más en estar listo. URL: $LT_URL"
        
        # Intentar obtener la URL desde los logs como respaldo
        sleep 3
        LT_URL_LOG=$(tail -20 "$LOG_FILE" | grep -o 'https://[a-z0-9-]*\.loca\.lt' | tail -1)
        if [ -n "$LT_URL_LOG" ]; then
            log "🌍 URL confirmada desde logs: $LT_URL_LOG"
        fi
    fi
else
    log "❌ Error iniciando localtunnel"
fi

log "✨ Proceso de inicio completado"
log "📊 Estado de los servicios:"
docker compose ps >> "$LOG_FILE" 2>&1

exit 0
