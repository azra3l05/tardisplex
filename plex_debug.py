import requests
import xml.etree.ElementTree as ET

PLEX_TOKEN = "ePwSj6tdmh36xdqYPoV7"

def get_server_id():
    """Retrieve the Plex Server ID (clientIdentifier)"""
    headers = {
        "Accept": "application/xml",  # 🔧 Request XML explicitly
        "X-Plex-Token": PLEX_TOKEN
    }

    url = "https://plex.tv/api/resources?includeHttps=1"
    response = requests.get(url, headers=headers)

    print(f"Response Status: {response.status_code}")
    print(f"Response Text: {response.text}")

    if response.status_code == 200 and response.text:
        try:
            root = ET.fromstring(response.text)  # ✅ Parse XML
            for device in root.findall("Device"):
                if device.get("provides") == "server":
                    server_id = device.get("clientIdentifier")  # ✅ Extract Plex Server ID
                    print(f"✅ Found Plex Server: {device.get('name')} (ID: {server_id})")
                    return server_id
        except ET.ParseError:
            print("❌ Failed to parse XML. Response is invalid.")

    print("❌ No valid Plex Server ID found. Check your Plex Token or API status.")
    return None

server_id = get_server_id()
