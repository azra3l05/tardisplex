import requests
import xml.etree.ElementTree as ET

# Replace with your Plex token
PLEX_TOKEN = "ePwSj6tdmh36xdqYPoV7"

# Plex API URLs
BASE_URL = "https://plex.tv/api/resources"
INVITE_URL_TEMPLATE = "https://plex.tv/api/servers/{server_id}/shared_servers"

HEADERS = {
    "X-Plex-Token": PLEX_TOKEN,
    "Accept": "application/json",
    "Content-Type": "application/json"
}


def get_server_id():
    """Fetches the Plex Server ID (clientIdentifier) from Plex API."""
    response = requests.get(BASE_URL, headers=HEADERS)

    if response.status_code != 200:
        print(f"❌ Failed to fetch Plex server ID. Status: {response.status_code}")
        return None

    try:
        root = ET.fromstring(response.text)
        for device in root.findall("./Device"):
            if device.attrib.get("provides") == "server":
                server_id = device.attrib.get("clientIdentifier")
                print(f"✅ Found Plex Server: {device.attrib.get('name')} (ID: {server_id})")
                return server_id
    except ET.ParseError:
        print("❌ Failed to parse XML response.")
        return None

    print("❌ No valid Plex Server ID found.")
    return None


def invite_user(server_id, email):
    """Invites a user to the Plex server."""
    url = INVITE_URL_TEMPLATE.format(server_id=server_id)

    payload = {
        "shared_server": {
            "invited_email": email,
            "library_section_ids": [],  # Specify library sections if needed
            "allowSync": False,
            "allowCameraUpload": False,
            "allowChannels": False,
            "filterMovies": "",
            "filterTelevision": "",
            "filterMusic": ""
        }
    }

    response = requests.post(url, headers=HEADERS, json=payload)

    if response.status_code == 201:
        print(f"✅ Successfully invited {email}")
    else:
        print(f"❌ Failed to invite {email}: {response.text}")


def main():
    """Main function to retrieve the server ID and invite users."""
    server_id = get_server_id()
    if not server_id:
        return

    # List of emails to invite (change these to actual email addresses)
    users_to_invite = [
        "admin@thearchive.dev"
    ]

    for email in users_to_invite:
        invite_user(server_id, email)


if __name__ == "__main__":
    main()
