#!/bin/sh

# delete files older than x days
# 2 days = 48 hours
DAYS="1"
ARCHIVE_DIR="/home/radioplanton/Audios/acervo"

find ${ARCHIVE_DIR}/* -mtime +${DAYS} -exec rm {} \; &> /dev/null 2>&1
