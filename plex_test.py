import requests

PLEX_TOKEN = "UcP6QRZSiW_pX4PqmNsL"
PLEX_CLIENT_ID = "MyPlexInviteScript"  # Any unique string

def debug_plex_resources():
    headers = {
        "Accept": "application/json",
        "X-Plex-Token": PLEX_TOKEN,
        "X-Plex-Client-Identifier": PLEX_CLIENT_ID  # REQUIRED
    }

    url = "https://plex.tv/api/v2/resources"
    response = requests.get(url, headers=headers)

    print(f"Status Code: {response.status_code}")
    print(f"Response Text:\n{response.text}")

if __name__ == "__main__":
    debug_plex_resources()
