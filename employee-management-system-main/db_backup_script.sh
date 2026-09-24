#!/bin/bash

set -e

# ----------------------------
# Variables
# ----------------------------
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DB_NAME=""
DB_USER=""
DB_PASSWORD=""

BACKUP_DIR="/opt/mysql-backups"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

S3_BUCKET="s3://ems-db-backups-raja62533/mysql"

echo "==================================="
echo "Starting MySQL Backup"
echo "==================================="

# ----------------------------
# Create Backup
# ----------------------------
echo "Creating database backup..."

mysqldump \
    --no-tablespaces \
    -u ${DB_USER} \
    -p${DB_PASSWORD} \
    ${DB_NAME} > "${BACKUP_FILE}"

# Verify backup file
if [ ! -s "${BACKUP_FILE}" ]; then
    echo "Backup file is empty."
    exit 1
fi

echo "Backup created successfully."

# ----------------------------
# Compress Backup
# ----------------------------
echo "Compressing backup..."

gzip "${BACKUP_FILE}"

# Verify compressed file
if [ ! -f "${COMPRESSED_FILE}" ]; then
    echo "Compression failed."
    exit 1
fi

echo "Compression successful."

# ----------------------------
# Upload to S3
# ----------------------------
echo "Uploading backup to S3..."

aws s3 cp "${COMPRESSED_FILE}" "${S3_BUCKET}/"

echo "Upload successful."

# ----------------------------
# Remove Local Backup
# ----------------------------
rm -f "${COMPRESSED_FILE}"

echo "Local backup deleted."

echo "==================================="
echo "Backup completed successfully."
echo "==================================="
