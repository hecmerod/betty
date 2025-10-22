#!/bin/bash

# Script para probar la cámara USB y los comandos del adapter
# Asegúrate de tener fswebcam instalado: sudo apt-get install fswebcam

LOG_FILE="/tmp/betty-camera-test.log"
DEVICE="${USB_CAMERA_DEVICE:-/dev/video0}"
OUTPUT_DIR="/tmp/betty-camera"
PHOTO_PATH="$OUTPUT_DIR/test-photo-$(date +%s).jpg"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log "${YELLOW}🔍 Probando adaptador de cámara USB${NC}"
log "=================================="

# Crear directorio temporal si no existe
log "\n📁 Creando directorio temporal..."
mkdir -p "$OUTPUT_DIR"
if [ $? -eq 0 ]; then
    log "${GREEN}✅ Directorio creado: $OUTPUT_DIR${NC}"
else
    log "${RED}❌ Error creando directorio${NC}"
    exit 1
fi

# 1. Verificar disponibilidad del dispositivo
log "\n1️⃣ Verificando disponibilidad del dispositivo..."
log "   Dispositivo: $DEVICE"

if [ -e "$DEVICE" ]; then
    log "${GREEN}✅ Dispositivo existe${NC}"
    
    if [ -r "$DEVICE" ]; then
        log "${GREEN}✅ Dispositivo es legible${NC}"
    else
        log "${RED}❌ Dispositivo no es legible. ¿Permisos?${NC}"
        log "   Intenta: sudo chmod 666 $DEVICE"
        exit 1
    fi
else
    log "${RED}❌ Dispositivo no encontrado${NC}"
    log "   Dispositivos de video disponibles:"
    ls -la /dev/video* 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

# 2. Verificar que fswebcam esté instalado
log "\n2️⃣ Verificando instalación de fswebcam..."
if command -v fswebcam &> /dev/null; then
    FSWEBCAM_VERSION=$(fswebcam --version 2>&1 | head -1)
    log "${GREEN}✅ fswebcam instalado: $FSWEBCAM_VERSION${NC}"
else
    log "${RED}❌ fswebcam no está instalado${NC}"
    log "   Instala con: sudo apt-get install fswebcam"
    exit 1
fi

# 3. Listar dispositivos de video disponibles
log "\n3️⃣ Listando dispositivos de video..."
v4l2-ctl --list-devices 2>&1 | tee -a "$LOG_FILE"

# 4. Obtener información del dispositivo
log "\n4️⃣ Información del dispositivo..."
if command -v v4l2-ctl &> /dev/null; then
    v4l2-ctl -d "$DEVICE" --all 2>&1 | tee -a "$LOG_FILE"
else
    log "${YELLOW}⚠️ v4l2-ctl no instalado (opcional)${NC}"
    log "   Instala con: sudo apt-get install v4l-utils"
fi

# 5. Capturar foto de prueba
log "\n5️⃣ Capturando foto de prueba..."
log "   Guardando en: $PHOTO_PATH"

fswebcam -d "$DEVICE" -r 1280x720 --no-banner "$PHOTO_PATH" 2>&1 | tee -a "$LOG_FILE"

if [ $? -eq 0 ] && [ -f "$PHOTO_PATH" ]; then
    PHOTO_SIZE=$(du -h "$PHOTO_PATH" | cut -f1)
    log "${GREEN}✅ Foto capturada exitosamente${NC}"
    log "   Tamaño: $PHOTO_SIZE"
    log "   Ubicación: $PHOTO_PATH"
    
    # Mostrar información de la imagen
    if command -v file &> /dev/null; then
        FILE_INFO=$(file "$PHOTO_PATH")
        log "   Info: $FILE_INFO"
    fi
else
    log "${RED}❌ Error capturando foto${NC}"
    exit 1
fi

# 6. Capturar otra foto con diferentes resoluciones
log "\n6️⃣ Probando diferentes resoluciones..."

RESOLUTIONS=("640x480" "800x600" "1920x1080")

for RES in "${RESOLUTIONS[@]}"; do
    TEST_PHOTO="$OUTPUT_DIR/test-${RES}-$(date +%s).jpg"
    log "   Probando $RES..."
    
    if fswebcam -d "$DEVICE" -r "$RES" --no-banner "$TEST_PHOTO" 2>&1 | grep -q "Writing JPEG"; then
        if [ -f "$TEST_PHOTO" ]; then
            SIZE=$(du -h "$TEST_PHOTO" | cut -f1)
            log "${GREEN}   ✅ $RES: OK ($SIZE)${NC}"
        else
            log "${YELLOW}   ⚠️ $RES: Comando exitoso pero archivo no encontrado${NC}"
        fi
    else
        log "${YELLOW}   ⚠️ $RES: No soportada o error${NC}"
    fi
done

# 7. Limpiar archivos de prueba (opcional)
log "\n7️⃣ Limpieza..."
read -p "¿Deseas eliminar las fotos de prueba? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    rm -f "$OUTPUT_DIR"/test-*.jpg
    log "${GREEN}✅ Fotos de prueba eliminadas${NC}"
else
    log "${YELLOW}📸 Fotos guardadas en: $OUTPUT_DIR${NC}"
fi

log "\n${GREEN}✨ Prueba completada${NC}"
log "Log guardado en: $LOG_FILE"

exit 0
