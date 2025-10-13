#!/bin/sh
set -e

# Variables de entorno
DB_HOST="betty-db"
DB_PORT="5432"
DB_USER="${POSTGRES_USER}"
DB_NAME="${POSTGRES_DB}"
BACKUP_DIR="/backups"
BACKUP_FILE="${BACKUP_DIR}/betty_backup_latest.sql"

echo "=== Iniciando backup de base de datos ==="
echo "Fecha: $(date)"
echo "Host: ${DB_HOST}"
echo "Base de datos: ${DB_NAME}"

# Crear directorio de backups si no existe
mkdir -p ${BACKUP_DIR}

# Realizar backup (sobrescribe el archivo anterior)
echo "Creando backup..."
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} > ${BACKUP_FILE}

# Comprimir backup (sobrescribe el archivo anterior)
echo "Comprimiendo backup..."
gzip -f ${BACKUP_FILE}

# Verificar que el backup se creó correctamente
if [ -f "${BACKUP_FILE}.gz" ]; then
    SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    echo "✅ Backup completado exitosamente: ${BACKUP_FILE}.gz (${SIZE})"
    echo "Última actualización: $(date)"
else
    echo "❌ Error: El backup no se creó correctamente"
    exit 1
fi

echo "=== Backup finalizado ==="
