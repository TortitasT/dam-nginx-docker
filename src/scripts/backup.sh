#!/bin/sh

DATE=$(date +%Y-%m-%d-%H%M%S)
BACKUP_DIR="/media/backup"

tar -cf "${BACKUP_DIR}/${DATE}.tar" /usr/share/nginx/html


