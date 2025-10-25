#!/bin/bash
# Script para configurar permisos BLE en Linux sin necesidad de sudo
# Esto permite que Node.js acceda al adaptador Bluetooth sin ejecutar como root

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

# Información adicional
echo ""
echo "=========================================="
echo "  ✓ Configuración completada"
echo "=========================================="
echo ""
echo "Ahora Node.js puede acceder al adaptador BLE sin sudo."
echo "Reinicia el servidor de Betty para aplicar los cambios:"
echo ""
echo "  npm start"
echo ""
echo "NOTA: Si actualizas Node.js, deberás ejecutar este script nuevamente."
echo ""
