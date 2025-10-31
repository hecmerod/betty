#!/bin/bash
# Script para configurar permisos BLE en Linux sin necesidad de sudo
# Esto permite que Node.js acceda al adaptador Bluetooth sin ejecutar como root
# También activa y desbloquea los adaptadores Bluetooth necesarios

set -e

echo "=========================================="
echo "  Configurando permisos BLE para Node.js"
echo "=========================================="
echo ""

# Encontrar la ruta de Node.js
NODE_PATH=$(which node)
echo "📍 Node.js encontrado en: $NODE_PATH"

# Verificar si el binario ya tiene las capacidades
echo ""
echo "🔍 Verificando capacidades actuales..."
CURRENT_CAPS=$(getcap "$NODE_PATH" 2>/dev/null || echo "ninguna")
echo "Capacidades actuales: $CURRENT_CAPS"

# Dar capacidades CAP_NET_RAW y CAP_NET_ADMIN al binario de Node.js
echo ""
echo "🔧 Configurando capacidades BLE..."
echo "Se requiere sudo para modificar las capacidades del binario de Node.js"
sudo setcap cap_net_raw+eip "$NODE_PATH"

# Verificar que se aplicaron correctamente
echo ""
echo "✅ Verificando nuevas capacidades..."
getcap "$NODE_PATH"

# Desbloquear y activar adaptadores Bluetooth
echo ""
echo "=========================================="
echo "  Configurando adaptadores Bluetooth"
echo "=========================================="
echo ""

echo "🔓 Desbloqueando adaptadores Bluetooth..."
sudo rfkill unblock bluetooth

echo ""
echo "📡 Verificando adaptadores disponibles..."
hciconfig -a | grep -E "^hci[0-9]" || echo "No se encontraron adaptadores"

echo ""
echo "🔌 Activando adaptadores..."

# Activar hci0 (Bluetooth integrado)
if hciconfig hci0 > /dev/null 2>&1; then
    echo "  - Activando hci0 (Bluetooth integrado)..."
    sudo hciconfig hci0 up
    echo "    ✅ hci0 activado"
else
    echo "  ⚠️  hci0 no encontrado"
fi

# Activar hci1 (Dongle USB)
if hciconfig hci1 > /dev/null 2>&1; then
    echo "  - Activando hci1 (Dongle USB)..."
    sudo hciconfig hci1 up
    echo "    ✅ hci1 activado"
else
    echo "  ⚠️  hci1 no encontrado"
fi

echo ""
echo "📊 Estado final de los adaptadores:"
hciconfig -a | grep -E "^hci[0-9]|UP RUNNING|DOWN" | sed 's/^/  /'

# Información adicional
echo ""
echo "=========================================="
echo "  ✓ Configuración completada"
echo "=========================================="
echo ""
echo "Ahora Node.js puede acceder a los adaptadores BLE sin sudo."
echo ""
echo "Configuración de baterías:"
echo "  - Batería 1 (A5:C2:37:2F:23:CE): hci0"
echo "  - Batería 2 (A5:C2:37:40:48:56): hci1"
echo ""
echo "Reinicia el servidor de Betty para aplicar los cambios:"
echo ""
echo "  npm start"
echo ""
echo "NOTA: Si actualizas Node.js, deberás ejecutar este script nuevamente."
echo ""
