#!/bin/bash

# Script de inicio para Raspberry Pi
# Este script optimiza la configuración del sistema para NestJS

echo "🍓 Iniciando Betty Server en Raspberry Pi..."

# Verificar recursos del sistema
echo "📊 Recursos del sistema:"
echo "CPU: $(nproc) núcleos"
echo "RAM: $(free -h | awk '/^Mem:/{print $2}')"
echo "Temperatura: $(vcgencmd measure_temp 2>/dev/null || echo 'N/A')"

# Crear directorio de logs si no existe
mkdir -p logs

# Configurar límites de memoria para Node.js en ARM
export NODE_OPTIONS="--max-old-space-size=512"
export UV_THREADPOOL_SIZE=4

# Configurar zona horaria
export TZ=America/Mexico_City

# Función para verificar la salud del servidor
health_check() {
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null)
    if [ "$response" = "200" ]; then
        echo "✅ Servidor saludable"
        return 0
    else
        echo "❌ Servidor no responde correctamente"
        return 1
    fi
}

# Función para monitorear recursos
monitor_resources() {
    while true; do
        # Obtener uso de CPU y memoria
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        memory_usage=$(free | awk '/^Mem:/{printf "%.1f", $3/$2 * 100.0}')
        temp=$(vcgencmd measure_temp 2>/dev/null | cut -d'=' -f2 | cut -d"'" -f1 || echo "N/A")
        
        echo "$(date): CPU: ${cpu_usage}%, RAM: ${memory_usage}%, Temp: ${temp}°C" >> logs/system.log
        
        # Alerta si la temperatura es muy alta (>70°C en RPi)
        if [ "$temp" != "N/A" ] && [ "${temp%.*}" -gt 70 ]; then
            echo "⚠️  ALERTA: Temperatura alta: ${temp}°C" >> logs/system.log
        fi
        
        sleep 300 # Monitorear cada 5 minutos
    done
}

# Iniciar monitoreo en segundo plano
monitor_resources &
MONITOR_PID=$!

# Manejar señales para limpieza
cleanup() {
    echo "🛑 Deteniendo Betty Server..."
    kill $MONITOR_PID 2>/dev/null
    pkill -f "node.*betty" 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Verificar si PM2 está instalado
if command -v pm2 >/dev/null 2>&1; then
    echo "🚀 Iniciando con PM2..."
    pm2 start ecosystem.config.js --env production
    pm2 logs betty-server
else
    echo "🚀 Iniciando directamente..."
    node dist/apps/betty/main.js
fi