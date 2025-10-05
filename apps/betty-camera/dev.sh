#!/bin/bash

# Script de desarrollo para Betty Camera
# Ejecuta el servidor en modo desarrollo con hot-reload

set -e

cd "$(dirname "$0")"

# Verificar que el entorno virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Entorno virtual no encontrado"
    echo "   Ejecute primero: ./install.sh"
    exit 1
fi

# Activar entorno virtual
source venv/bin/activate

# Crear directorio de salida si no existe
mkdir -p output

echo "🚀 Iniciando Betty Camera en modo desarrollo..."
echo "📱 Servidor disponible en: http://localhost:8001"
echo "📚 Documentación API: http://localhost:8001/docs"
echo "🛑 Presiona Ctrl+C para detener"
echo ""

# Ejecutar con hot-reload
python src/main.py --debug --host 0.0.0.0 --port 8001