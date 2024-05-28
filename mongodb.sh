#!/bin/bash

# Variables
BACKUP_DIR="/path/to/backup" 
NEW_DB_NAME="new_backup_store" 
MONGO_URI="mongodb+srv://ippostorebuser:Z6dF2aB5NV7r0Sn7@store-backup.zpcie.mongodb.net/?retryWrites=true&w=majority&appName=store-backup"  

# Step 1: Create a new MongoDB database
# MongoDB does not require explicit database creation, it will be created during the restore process

# Step 2: Identify the latest snapshot
# Assuming your backups are named with a timestamp, e.g., backup-YYYYMMDD.tar.gz or backup-YYYYMMDD
LATEST_BACKUP=$(ls -t ${BACKUP_DIR} | head -n 1)

# Check if a backup was found
if [ -z "$LATEST_BACKUP" ]; then
  echo "No backup found in ${BACKUP_DIR}"
  exit 1
fi

# Extract backup if it is a compressed file
if [[ $LATEST_BACKUP == *.tar.gz ]]; then
  tar -xzf "${BACKUP_DIR}/${LATEST_BACKUP}" -C "${BACKUP_DIR}"
  LATEST_BACKUP_DIR="${BACKUP_DIR}/$(basename ${LATEST_BACKUP} .tar.gz)"
else
  LATEST_BACKUP_DIR="${BACKUP_DIR}/${LATEST_BACKUP}"
fi

# Step 3: Restore the latest snapshot to the new database
mongorestore --uri="${MONGO_URI}" --db="${NEW_DB_NAME}" --drop "${LATEST_BACKUP_DIR}"

# Check if the restore was successful
if [ $? -eq 0 ]; then
  echo "Database restored successfully to ${NEW_DB_NAME}"
else
  echo "Failed to restore the database"
  exit 1
fi
