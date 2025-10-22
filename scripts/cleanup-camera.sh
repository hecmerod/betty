#!/bin/bash

# Script para limpiar procesos FFmpeg que bloquean el dispositivo de cámara USB

DEVICE="${USB_CAMERA_DEVICE:-/dev/video8}"

echo "🧹 Limpiando procesos que usan $DEVICE..."

# Buscar y matar procesos ffmpeg usando el dispositivo
PIDS=$(lsof "$DEVICE" 2>/dev/null | grep ffmpeg | awk '{print $2}' | sort -u)

if [ -z "$PIDS" ]; then
    echo "✅ No se encontraron procesos usando $DEVICE"
else
    echo "🔍 Procesos encontrados:"
    lsof "$DEVICE" 2>/dev/null | grep ffmpeg
    
    echo ""
    echo "🛑 Matando procesos..."
    for PID in $PIDS; do
        echo "  Matando proceso $PID"
        kill -9 "$PID" 2>/dev/null
    done
    
    sleep 0.5
    
    # Verificar si se limpiaron
    REMAINING=$(lsof "$DEVICE" 2>/dev/null | grep ffmpeg | wc -l)
    if [ "$REMAINING" -eq 0 ]; then
        echo "✅ Dispositivo $DEVICE liberado"
    else
        echo "⚠️ Aún hay procesos usando el dispositivo"
        lsof "$DEVICE" 2>/dev/null
    fi
fi

# También limpiar cualquier proceso ffmpeg huérfano
echo ""
echo "🔍 Buscando procesos ffmpeg huérfanos..."
ORPHAN_PIDS=$(pgrep -f "ffmpeg.*video" || true)

if [ -z "$ORPHAN_PIDS" ]; then
    echo "✅ No hay procesos ffmpeg huérfanos"
else
    echo "🛑 Limpiando procesos ffmpeg huérfanos:"
    echo "$ORPHAN_PIDS" | while read PID; do
        if [ -n "$PID" ]; then
            echo "  Matando proceso $PID"
            kill -9 "$PID" 2>/dev/null || true
        fi
    done
    echo "✅ Procesos huérfanos limpiados"
fi

echo ""
echo "✨ Limpieza completada"
