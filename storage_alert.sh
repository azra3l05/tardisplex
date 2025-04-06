#!/bin/bash

# Set threshold percentage
THRESHOLD=75

# Discord webhook URL (set as environment variable)
WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"

# Debug: Print webhook URL
echo "Webhook URL: $WEBHOOK_URL"

# Ensure the webhook URL is set
if [[ -z "$WEBHOOK_URL" ]]; then
    echo "Error: DISCORD_WEBHOOK_URL is not set."
    exit 1
fi

# Get disk usage details for /mnt/local
disk_info=$(df -h /mnt/local | awk 'NR==2 {print $1, $2, $3, $5}' | tr -d '%')

# Debug: Print raw disk info
echo "Raw Disk Info: $disk_info"

# Parse disk usage
read -r filesystem size used percent <<< "$disk_info"

# Debug: Print extracted values
echo "Filesystem: $filesystem"
echo "Total Size: $size"
echo "Used: $used"
echo "Used Percentage: $percent%"

# Check if usage exceeds threshold
if (( percent >= THRESHOLD )); then
    message_content="🚨 **Disk Usage Alert!** 🚨\n\n"
    message_content+="🔹 **Filesystem:** $filesystem\n"
    message_content+="🔹 **Total Size:** $size\n"
    message_content+="🔹 **Used:** $used ($percent% used)\n\n"
    message_content+="⚠️ Warning: Disk usage has exceeded ${THRESHOLD}%."

    # Debug: Print message before sending
    echo "Sending message: $message_content"

    # Send the message to Discord
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$message_content\"}" \
         "$WEBHOOK_URL")

    # Debug: Print HTTP response
    echo "Discord Response Code: $response"

    # Check if the message was sent successfully
    if [[ "$response" -ne 204 ]]; then
        echo "Error: Failed to send message to Discord. HTTP response code: $response"
    else
        echo "Notification sent successfully."
    fi
else
    echo "Disk usage is below threshold (${percent}% < ${THRESHOLD}%), no alert sent."
fi
