#!/bin/bash

# Log Archive Tool
# Compresses logs from a specified directory into a timestamped tar.gz archive
# Optionally sends an email notification via SMTP

set -e

# --- Load .env file if present ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    . "$SCRIPT_DIR/.env"
    set +a
fi

# --- Defaults ---
EMAIL=""
FROM=""
SMTP_HOST="${SMTP_HOST:-localhost}"
SMTP_PORT="${SMTP_PORT:-25}"
SMTP_USER="${SMTP_USER:-}"
SMTP_PASS="${SMTP_PASS:-}"

# --- Usage ---
usage() {
    echo "Usage: log-archive <log-directory> [-e <email>] [--from <sender>]"
    echo ""
    echo "Options:"
    echo "  -e <email>       Send archive notification to this email address"
    echo "  --from <sender>  Sender email address (required with -e)"
    echo ""
    echo "Environment variables (for authenticated SMTP):"
    echo "  SMTP_HOST   SMTP server host (default: localhost)"
    echo "  SMTP_PORT   SMTP server port (default: 25)"
    echo "  SMTP_USER   SMTP username (optional)"
    echo "  SMTP_PASS   SMTP password (optional)"
    echo ""
    echo "Env vars can also be set in a .env file in the project root."
    echo ""
    echo "Examples:"
    echo "  ./log-archive.sh /var/log"
    echo "  ./log-archive.sh /var/log -e admin@example.com --from noreply@example.com"
    echo "  SMTP_HOST=smtp.gmail.com SMTP_PORT=587 SMTP_USER=me@gmail.com SMTP_PASS=secret \\"
    echo "    ./log-archive.sh /var/log -e admin@example.com --from me@gmail.com"
    exit 1
}

# --- Parse args ---
LOG_DIR=""
while [ $# -gt 0 ]; do
    case "$1" in
        -e)
            EMAIL="$2"
            shift 2
            ;;
        --from)
            FROM="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            LOG_DIR="$1"
            shift
            ;;
    esac
done

if [ -z "$LOG_DIR" ]; then
    echo "Error: No log directory specified."
    usage
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

if [ -n "$EMAIL" ] && [ -z "$FROM" ]; then
    echo "Error: --from <sender> is required when using -e <email>."
    exit 1
fi

# --- Create archive ---
ARCHIVE_DIR="$(pwd)/log_archives"
mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"
LOG_FILE="$ARCHIVE_DIR/archive.log"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Archived '$LOG_DIR' to '$ARCHIVE_PATH'" >> "$LOG_FILE"

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
echo "Archive created: $ARCHIVE_PATH ($ARCHIVE_SIZE)"

# --- Send email if requested ---
if [ -n "$EMAIL" ]; then
    TIMESTAMP_DISPLAY=$(date '+%Y-%m-%d %H:%M:%S')
    SUBJECT="Log Archive Complete - $TIMESTAMP_DISPLAY"

    python3 << PYEOF
import smtplib
import ssl
from email.mime.text import MIMEText

host = "$SMTP_HOST"
port = int("$SMTP_PORT")
user = "$SMTP_USER"
password = "$SMTP_PASS"
from_addr = "$FROM"
to_addr = "$EMAIL"
subject = """$SUBJECT"""
body = """Archive created successfully.

  Source:      $LOG_DIR
  Archive:     $ARCHIVE_NAME
  Path:        $ARCHIVE_PATH
  Size:        $ARCHIVE_SIZE
  Timestamp:   $TIMESTAMP_DISPLAY
"""

msg = MIMEText(body)
msg["Subject"] = subject
msg["From"] = from_addr
msg["To"] = to_addr

try:
    context = ssl.create_default_context()
    with smtplib.SMTP(host, port) as server:
        if port == 587:
            server.starttls(context=context)
        if user:
            server.login(user, password)
        server.sendmail(from_addr, to_addr, msg.as_string())
    print(f"Email sent to {to_addr}")
except Exception as e:
    print(f"Warning: Failed to send email: {e}")
PYEOF
fi
