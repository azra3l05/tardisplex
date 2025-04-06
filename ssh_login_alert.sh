#!/bin/bash

# Discord Webhook URL (Replace with your actual webhook URL)
WEBHOOK_URL="https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# Ensure required environment variables are set, fallback to "Unknown"
USER=${PAM_USER:-"Unknown"}
RHOST=${PAM_RHOST:-"Unknown"}
SERVICE=${PAM_SERVICE:-"Unknown"}
TTY=${PAM_TTY:-"Unknown"}
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Detect whether this is a login success or failure
if [[ "$PAM_TYPE" == "open_session" ]]; then
    EVENT="🟢 Successfully Logged In"
    COLOR=65280  # Green color
else
    EVENT="🔴 Failed Login Attempt"
    COLOR=16711680  # Red color
    echo "[$DATE] Failed login attempt by $USER from $RHOST" >> /var/log/ssh_failed_attempts.log
fi

# Check if the user is suspicious (root, unknown users)
if [[ "$USER" == "root" || "$USER" == "Unknown" ]]; then
    ALERT="⚠️ **Suspicious Login Attempt!**"
else
    ALERT=""
fi

# Get Geolocation Info (only if RHOST is not local)
if [[ "$RHOST" != "Unknown" && "$RHOST" != "127.0.0.1" && "$RHOST" != "localhost" ]]; then
    GEO_INFO=$(curl -s "https://ipinfo.io/$RHOST/json" | jq -r '.city, .region, .country, .org' | paste -sd ', ')
else
    GEO_INFO="Localhost / Private Network"
fi

# Capture Running Processes on Failed Login
if [[ "$PAM_TYPE" != "open_session" ]]; then
    PROCESSES=$(ps -u "$USER" -o pid,cmd --no-headers | head -n 5)
else
    PROCESSES="N/A"
fi

# JSON Payload for Discord
PAYLOAD=$(cat <<EOF
{
  "username": "SSH Alert",
  "embeds": [
    {
      "title": "SSH Login Alert",
      "color": $COLOR,
      "fields": [
        {
          "name": "User",
          "value": "$USER",
          "inline": true
        },
        {
          "name": "Event",
          "value": "$EVENT",
          "inline": true
        },
        {
          "name": "Remote Host",
          "value": "$RHOST",
          "inline": true
        },
        {
          "name": "Geolocation",
          "value": "$GEO_INFO",
          "inline": true
        },
        {
          "name": "Service",
          "value": "$SERVICE",
          "inline": true
        },
        {
          "name": "TTY",
          "value": "$TTY",
          "inline": true
        },
        {
          "name": "Hostname",
          "value": "$HOSTNAME",
          "inline": true
        },
        {
          "name": "Date",
          "value": "$DATE",
          "inline": true
        },
        {
          "name": "Running Processes (Failed Login Only)",
          "value": "$PROCESSES",
          "inline": false
        }
      ]
    }
  ]
}
EOF
)

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "/var/log/ssh_alert.log"
}

# Debugging Mode (Enable by setting DEBUG_MODE=1)
DEBUG_MODE=0
if [ "$DEBUG_MODE" -eq 1 ]; then
    log_message "DEBUG: Payload being sent to Discord:"
    echo "$PAYLOAD" | tee -a "/var/log/ssh_alert.log"
fi

# Validate Webhook URL
if [[ -z "$WEBHOOK_URL" ]]; then
    log_message "ERROR: Webhook URL is empty. Cannot send notification."
    exit 1
fi

# Send the alert to Discord
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' -d "$PAYLOAD" "$WEBHOOK_URL")

# Check HTTP response status
if [ "$RESPONSE" -eq 204 ]; then
    log_message "SUCCESS: SSH alert sent to Discord."
else
    log_message "ERROR: Failed to send SSH alert. HTTP Status: $RESPONSE"
    exit 1
fi
