import subprocess
import sqlite3
import csv
import os
import datetime
import requests

# Configuration
CONTAINER_NAME = "emby"
DB_PATH = "/config/data/library.db"
HOST_DB_PATH = "./library_copy.db"
SAFE_DB_PATH = "./library_safe_copy.db"  # Read-only copy
DATA_DIR = "./emby_logs"
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1258254521847648307/Iv09McljWEsLr-EHk7XMQTJ7Fgl5J5NPpGudNbubaXME7-QIBn80Guo01e0iU3c8eUPa"

# Ensure the directory exists
os.makedirs(DATA_DIR, exist_ok=True)

# Generate filenames with dates
today = datetime.date.today()
yesterday = today - datetime.timedelta(days=1)

today_file = os.path.join(DATA_DIR, f"playback_activity_{today}.csv")
yesterday_file = os.path.join(DATA_DIR, f"playback_activity_{yesterday}.csv")

# SQL Query
SQL_QUERY = """
SELECT DISTINCT UserId, DeviceName, RemoteAddress, AppName
FROM PlaybackActivity
GROUP BY UserId, DeviceName, AppName;
"""

try:
    # Copy database from container to host
    subprocess.run(f"docker cp {CONTAINER_NAME}:{DB_PATH} {HOST_DB_PATH}", shell=True, check=True)

    # Create a safe read-only copy
    conn = sqlite3.connect(HOST_DB_PATH)
    safe_conn = sqlite3.connect(SAFE_DB_PATH)
    conn.backup(safe_conn)  # This avoids the "database is locked" error
    conn.close()
    safe_conn.close()

    # Run the query safely on the copy
    conn = sqlite3.connect(SAFE_DB_PATH)
    cursor = conn.cursor()
    cursor.execute(SQL_QUERY)
    data = cursor.fetchall()

    # Write to CSV
    if data:
        with open(today_file, "w", newline="") as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(["UserId", "DeviceName", "RemoteAddress", "AppName"])  # Header
            writer.writerows(data)
        print(f"✅ Data exported to {today_file}")

    else:
        print("⚠️ No data found.")
        exit()

    conn.close()

except subprocess.CalledProcessError as e:
    print(f"❌ Error copying database: {e}")
    exit()

except sqlite3.Error as e:
    print(f"❌ SQLite error: {e}")
    exit()

# Compare new vs old data for newly added devices
new_devices = []
if os.path.exists(yesterday_file):
    with open(yesterday_file, "r") as old_file, open(today_file, "r") as new_file:
        old_devices = {tuple(row) for row in csv.reader(old_file)}
        new_devices_list = [row for row in csv.reader(new_file) if tuple(row) not in old_devices]

        if new_devices_list:
            new_devices = new_devices_list[1:]  # Skip the header row

# Send notification to Discord
if new_devices:
    device_list = "\n".join([f"**User:** {d[0]} | **Device:** {d[1]} | **App:** {d[3]} | **IP:** {d[2]}" for d in new_devices])
    discord_message = {
        "content": f"🚀 **New Devices Detected on Emby** 🚀\n\n{device_list}"
    }

    response = requests.post(DISCORD_WEBHOOK_URL, json=discord_message)

    if response.status_code == 204:
        print("✅ Successfully sent notification to Discord!")
    else:
        print(f"❌ Failed to send Discord message: {response.status_code}")

else:
    print("✅ No new devices detected.")