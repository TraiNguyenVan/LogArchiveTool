#!/bin/bash

# Log Archive Tool
# Compresses logs from a specified directory into a timestamped tar.gz archive

set -e

if [ $# -ne 1 ]; then
    echo "Usage: log-archive <log-directory>"
    exit 1
fi

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

ARCHIVE_DIR="$(pwd)/log_archives"
mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"
LOG_FILE="$ARCHIVE_DIR/archive.log"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Archived '$LOG_DIR' to '$ARCHIVE_PATH'" >> "$LOG_FILE"

echo "Archive created: $ARCHIVE_PATH"
