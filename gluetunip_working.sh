#!/bin/bash

# Define container names
CONTAINERS=("gluetun")

# Discord Webhook URL
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# Store previous IPs
declare -A LAST_IPS

# Function to get IP info using a temporary Alpine container
get_ip_info() {
    local container=$1
    docker run --rm --network=container:$container alpine:3.20 sh -c "apk add wget > /dev/null 2>&1 && wget -qO- https://ipinfo.io"
}

# Function to send a Discord notification
send_discord_notification() {
    local container=$1
    local ip_info=$2
    local message="🚨 **Gluetun IP Changed** 🚨 **Container:** $container **New IP Info:** \`\`\`$ip_info\`\`\`"

    # Escape and send JSON payload
    json_payload=$(jq -n --arg content "$message" '{content: $content}')

    curl -H "Content-Type: application/json" \
         -X POST \
         -d "$json_payload" \
         "$DISCORD_WEBHOOK_URL"
}

# Monitor loop
while true; do
    for container in "${CONTAINERS[@]}"; do
        if ! docker ps --format '{{.Names}}' | grep -q "^$container$"; then
            echo "[$(date)] WARNING: $container is not running!"
            continue
        fi

        NEW_IP_INFO=$(get_ip_info "$container")

        if [[ -z "$NEW_IP_INFO" ]]; then
            echo "[$(date)] ERROR: Failed to fetch IP info for $container"
            continue
        fi

        # Extract the IP address
        NEW_IP=$(echo "$NEW_IP_INFO" | jq -r '.ip')

        if [[ "${LAST_IPS[$container]}" != "$NEW_IP" ]]; then
            echo "[$(date)] IP changed for $container: $NEW_IP"
            send_discord_notification "$container" "$NEW_IP_INFO"
            LAST_IPS[$container]=$NEW_IP
        fi
    done
    sleep 180  # Check every 30 seconds
done
