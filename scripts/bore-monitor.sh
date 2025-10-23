#!/bin/bash

# Script de monitoreo para controlar Bore desde el contenedor Docker
# Este script se ejecuta en el HOST (fuera del contenedor)
# Lee comandos del archivo de control escrito por el contenedor

PROJECT_DIR="/home/hecmerod/Projects/betty"
CONTROL_FILE="$PROJECT_DIR/tmp/bore-control.txt"
BORE_URL_FILE="$PROJECT_DIR/tmp/bore-ssh-url.txt"
BORE_PID_FILE="$PROJECT_DIR/tmp/bore-ssh.pid"
BORE_LOG_FILE="$PROJECT_DIR/tmp/bore-ssh.log"
MONITOR_LOG="$PROJECT_DIR/logs/bore-monitor.log"

# Crear directorios si no existen
mkdir -p "$PROJECT_DIR/tmp"
mkdir -p "$PROJECT_DIR/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MONITOR_LOG"
}

start_bore() {
    log "📡 Starting Bore SSH tunnel..."
    
    # Verificar si ya está corriendo
    if [ -f "$BORE_PID_FILE" ]; then
        PID=$(cat "$BORE_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            log "⚠️  Bore is already running with PID: $PID"
            return 0
        fi
    fi
    
    # Cargar entorno de Cargo/Rust
    source "$HOME/.cargo/env"
    
    # Iniciar Bore en background
    nohup bore local 22 --to bore.pub > "$BORE_LOG_FILE" 2>&1 &
    BORE_PID=$!
    
    # Guardar PID
    echo "$BORE_PID" > "$BORE_PID_FILE"
    log "✅ Bore started with PID: $BORE_PID"
    
    # Esperar a que genere la URL (máximo 10 segundos)
    for i in {1..10}; do
        sleep 1
        if grep -q "listening at bore.pub:" "$BORE_LOG_FILE" 2>/dev/null; then
            BORE_URL=$(grep -o "listening at bore.pub:[0-9]*" "$BORE_LOG_FILE" | head -1)
            BORE_PORT=$(echo "$BORE_URL" | grep -o "[0-9]*$")
            SSH_CMD="ssh hecmerod@bore.pub -p $BORE_PORT"
            echo "$SSH_CMD" > "$BORE_URL_FILE"
            log "🔐 SSH command saved: $SSH_CMD"
            return 0
        fi
    done
    
    log "⚠️  Could not get Bore URL after 10 seconds"
    return 1
}

stop_bore() {
    log "🛑 Stopping Bore SSH tunnel..."
    
    # Intentar matar por PID
    if [ -f "$BORE_PID_FILE" ]; then
        PID=$(cat "$BORE_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID" 2>/dev/null
            log "✅ Killed Bore process: $PID"
        else
            log "⚠️  PID $PID not found"
        fi
        rm -f "$BORE_PID_FILE"
    fi
    
    # Matar por nombre de proceso (backup)
    pkill -f "bore local 22" 2>/dev/null
    
    # Limpiar archivos
    rm -f "$BORE_URL_FILE"
    log "✅ Bore tunnel stopped and cleaned up"
}

log "🚀 Bore monitor started"

# Loop principal: monitorear archivo de control cada 2 segundos
while true; do
    if [ -f "$CONTROL_FILE" ]; then
        COMMAND=$(cat "$CONTROL_FILE")
        log "📨 Received command: $COMMAND"
        
        case "$COMMAND" in
            START)
                start_bore
                ;;
            STOP)
                stop_bore
                ;;
            *)
                log "⚠️  Unknown command: $COMMAND"
                ;;
        esac
        
        # Borrar archivo de control después de procesarlo
        rm -f "$CONTROL_FILE"
    fi
    
    sleep 2
done
