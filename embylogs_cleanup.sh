#!/bin/bash

# ─────────────────────────────
# 🚧 CONFIGURATION
# ─────────────────────────────

# Log directories (Add as many as needed)
LOG_DIRS=(
  "/opt/emby/logs"
  "/opt/moflix/logs"
)

# Metadata directories
METADATA_DIRS=(
  "/opt/emby/metadata"
  "/opt/moflix/metadata"
  "/opt/moflix/transcoding-temp"
)

# Days configuration
DAYS_TO_KEEP=1
COMPRESSED_DAYS_TO_KEEP=7
METADATA_DAYS_TO_KEEP=3

# Cleanup log path
CLEANUP_LOG="/home/azra3l/codebase/tardisplex/logs/emby_cleanup.log"

# Enable gzip compression
SHOULD_COMPRESS=true

# Discord webhook URL
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# ─────────────────────────────
# 📢 SEND DISCORD MESSAGE
# ─────────────────────────────
send_discord_message() {
    local message=$1
    curl -s -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$message\"}" \
         "$DISCORD_WEBHOOK_URL" > /dev/null
}

# ─────────────────────────────
# 🕒 Start Time
# ─────────────────────────────
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "🕒 $TIMESTAMP - Starting Emby maintenance..." | tee -a "$CLEANUP_LOG"
send_discord_message "🧹 Starting Emby maintenance tasks at $TIMESTAMP..."

# ─────────────────────────────
# 🧾 LOG CLEANUP LOOP
# ─────────────────────────────
for LOG_DIR in "${LOG_DIRS[@]}"; do
    echo "🔍 Processing log directory: $LOG_DIR" | tee -a "$CLEANUP_LOG"

    if [ -d "$LOG_DIR" ]; then
        if [ "$SHOULD_COMPRESS" = true ]; then
            echo "📦 Compressing .txt logs..." | tee -a "$CLEANUP_LOG"
            find "$LOG_DIR" -type f -name "*.txt" -mtime +1 -mtime -"$DAYS_TO_KEEP" -exec gzip -f {} \;
        fi

        TXT_DELETED=$(find "$LOG_DIR" -type f -name "*.txt" -mtime +$DAYS_TO_KEEP -print -delete | wc -l)
        GZ_DELETED=$(find "$LOG_DIR" -type f -name "*.gz" -mtime +$COMPRESSED_DAYS_TO_KEEP -print -delete | wc -l)

        MESSAGE="✅ Emby Log Cleanup for \`$LOG_DIR\` completed:\n• 🧾 Deleted: $TXT_DELETED raw logs\n• 📦 Deleted: $GZ_DELETED compressed logs"
        echo "$MESSAGE" | tee -a "$CLEANUP_LOG"
        send_discord_message "$MESSAGE"
    else
        ERR_MSG="❌ Log directory not found: $LOG_DIR"
        echo "$ERR_MSG" | tee -a "$CLEANUP_LOG"
        send_discord_message "$ERR_MSG"
    fi
done

# ─────────────────────────────
# 🗃️ METADATA CLEANUP LOOP
# ─────────────────────────────
for METADATA_DIR in "${METADATA_DIRS[@]}"; do
    echo "🧪 Processing metadata directory: $METADATA_DIR" | tee -a "$CLEANUP_LOG"

    if [ -d "$METADATA_DIR" ]; then
        METADATA_DELETED=$(find "$METADATA_DIR" -type f -mtime +$METADATA_DAYS_TO_KEEP -print -delete | wc -l)
        MESSAGE="📂 Metadata Cleanup for \`$METADATA_DIR\` completed:\n🗑️ Files Deleted: $METADATA_DELETED (older than $METADATA_DAYS_TO_KEEP days)"
        echo "$MESSAGE" | tee -a "$CLEANUP_LOG"
        send_discord_message "$MESSAGE"
    else
        ERR_MSG="❌ Metadata directory not found: $METADATA_DIR"
        echo "$ERR_MSG" | tee -a "$CLEANUP_LOG"
        send_discord_message "$ERR_MSG"
    fi
done

# ─────────────────────────────
# 🏁 DONE
# ─────────────────────────────
echo "✅ $TIMESTAMP - Emby maintenance completed." | tee -a "$CLEANUP_LOG"
