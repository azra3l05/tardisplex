#!/bin/bash

# Discord Webhook URL
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# Log file for debugging
LOG_FILE="/home/azra3l/codebase/tardisplex/docker_debug.log"

# Function to send a notification to Discord
notify_discord() {
  local title="$1"
  local description="$2"
  local color="$3"

  echo "$(date '+%Y-%m-%d %H:%M:%S') - Sending Notification: $title" | tee -a "$LOG_FILE"

  JSON_PAYLOAD=$(cat <<EOF
{
  "username": "Docker Monitor",
  "embeds": [
    {
      "title": "$title",
      "description": "$description",
      "color": $color
    }
  ]
}
EOF
  )

  RESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$DISCORD_WEBHOOK_URL" \
    -s -o /dev/null -w "%{http_code}")

  echo "$(date '+%Y-%m-%d %H:%M:%S') - Discord Response: $RESPONSE" | tee -a "$LOG_FILE"
}

# Start Logging
echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Checking for Exited Containers" | tee -a "$LOG_FILE"

# Get all exited containers
EXITED_CONTAINERS=$(docker ps -aq --filter "status=exited")

# Debug output
echo "📝 Found Exited Containers: $EXITED_CONTAINERS" | tee -a "$LOG_FILE"

# If no exited containers, exit silently
if [[ -z "$EXITED_CONTAINERS" ]]; then
  echo "✅ No exited containers found." | tee -a "$LOG_FILE"
  exit 0
fi

# Notify for each exited container
for CONTAINER_ID in $EXITED_CONTAINERS; do
  CONTAINER_NAME=$(docker inspect --format '{{.Name}}' "$CONTAINER_ID" | sed 's/\///')
  EXIT_CODE=$(docker inspect --format '{{.State.ExitCode}}' "$CONTAINER_ID")
  EXIT_REASON=$(docker inspect --format '{{.State.Error}}' "$CONTAINER_ID")
  EXIT_TIME=$(docker inspect --format '{{.State.FinishedAt}}' "$CONTAINER_ID")

  # Format Discord message with Markdown
  MESSAGE="📦 **Container:** \`$CONTAINER_NAME\` (\`$CONTAINER_ID\`)\n🔴 **Status:** \`Exited\` ❌\n💥 **Exit Code:** \`$EXIT_CODE\`\n🕒 **Exited At:** \`$EXIT_TIME\`\n⚠️ **Reason:** \`$EXIT_REASON\`"

  notify_discord "🚨 **Docker Alert: Exited Container**" "$MESSAGE" 16711680
done

echo "✅ $(date '+%Y-%m-%d %H:%M:%S') - Check Completed" | tee -a "$LOG_FILE"
