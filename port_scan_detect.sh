#!/bin/bash

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# 📌 Log File for Debugging
LOG_FILE="/home/azra3l/codebase/tardisplex/port_scan.log"
DEBUG_LOG="/home/azra3l/codebase/tardisplex/port_scan_debug.log"

# Ensure log files exist
touch "$LOG_FILE" "$DEBUG_LOG"

# 🕵️ Get recent firewall logs (adjust interface if needed)
echo "[$(date)] Checking for port scan activity..." | tee -a "$DEBUG_LOG"
journalctl -k --no-pager -n 10 | grep "DPT=" > "$LOG_FILE"

# Check if log contains any activity
if [ -s "$LOG_FILE" ]; then
  MESSAGE="🚨 Port scan detected on $(hostname)! Check logs: $LOG_FILE"
  
  echo "[$(date)] Port scan detected! Sending alert..." | tee -a "$DEBUG_LOG"
  echo "[$(date)] Log contents: $(cat $LOG_FILE)" | tee -a "$DEBUG_LOG"
  
  # Send notification to Discord
  RESPONSE=$(curl -s -o /tmp/discord_response.txt -w "%{http_code}" -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$DISCORD_WEBHOOK_URL")
  
  # Log response from Discord
  if [ "$RESPONSE" -eq 204 ]; then
    echo "[$(date)] ✅ Alert sent successfully!" | tee -a "$DEBUG_LOG"
  else
    echo "[$(date)] ❌ Failed to send alert. HTTP Response: $RESPONSE" | tee -a "$DEBUG_LOG"
    echo "[$(date)] Discord Response: $(cat /tmp/discord_response.txt)" | tee -a "$DEBUG_LOG"
  fi
else
  echo "[$(date)] No port scan activity detected." | tee -a "$DEBUG_LOG"
fi
