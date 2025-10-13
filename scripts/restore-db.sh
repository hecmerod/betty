#!/bin/sh
# Script para restaurar el último backup de la base de datos
# Uso: ./restore-db.sh [archivo_backup.sql.gz]
# Si no se especifica archivo, usa el último backup disponible

set -e

BACKUP_FILE="${1:-backups/db/betty_backup_latest.sql.gz}"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: El archivo '$BACKUP_FILE' no existe"
    echo ""
    echo "Backups disponibles:"
    ls -lh backups/db/*.sql.gz 2>/dev/null || echo "No hay backups disponibles"
    exit 1
fi

echo "=== Restaurando backup de base de datos ==="
echo "Archivo: $BACKUP_FILE"
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Tamaño: $SIZE"
echo "⚠️  ADVERTENCIA: Esto sobrescribirá todos los datos actuales de la base de datos"
echo ""
read -p "¿Estás seguro? (escribe 'SI' para continuar): " confirm

if [ "$confirm" != "SI" ]; then
    echo "❌ Restauración cancelada"
    exit 0
fi

echo "Descomprimiendo y restaurando backup..."
gunzip -c "$BACKUP_FILE" | docker exec -i betty-db psql -U betty -d betty

echo "✅ Restauración completada exitosamente"
