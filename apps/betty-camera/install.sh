#!/bin/bash

# Script para instalar dependencias y ejecutar Betty Camera
# Para Raspberry Pi

set -e

echo "🍓 Instalando Betty Camera..."

# Verificar que estamos en el directorio correcto
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: No se encuentra requirements.txt"
    echo "   Ejecute este script desde el directorio betty-camera"
    exit 1
fi

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "📦 Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
echo "🔄 Activando entorno virtual..."
source venv/bin/activate

# Actualizar pip
echo "⬆️  Actualizando pip..."
pip install --upgrade pip

# Instalar dependencias
echo "📥 Instalando dependencias..."
pip install -r requirements.txt

echo "✅ Instalación completada!"
echo ""
echo "📋 Para ejecutar Betty Camera:"
echo "   source venv/bin/activate"
echo "   python src/main.py"
echo ""
echo "📋 Para ejecutar en modo desarrollo:"
echo "   source venv/bin/activate"
echo "   python src/main.py --debug"
echo ""
echo "📋 Para ejecutar tests:"
echo "   source venv/bin/activate"
echo "   pytest"