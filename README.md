# 🛠️ Media Server & Utility Toolkit

This repository contains a comprehensive collection of tools, scripts, Docker Compose templates, and utility YAMLs for managing a self-hosted media server environment, monitoring system health, and automating various DevOps tasks. 
It is curated for advanced users running services like Plex, Emby, Tautulli, Dashy, Speedtest, and more.

---

## 🛆 What's Inside

### ⚙️ Core Docker Compose & Templates
- `docker-compose.yml`  
  Main Compose file to manage your service stack.
- `dashy_compose.yaml`  
  Compose file for [Dashy](https://github.com/Lissy93/dashy), your self-hosted dashboard.
- `embylogs_cleanup.sh`  
  Script to rotate and clean Emby logs.
- `hlsproxy_compose.yaml`, `joplin_compose.yaml`, `kitchen_owl_compose.yaml`, `speedtest_compose.yaml`  
  Compose files for specific apps and utilities.
- `container_template.yaml`, `docker_container.yml`  
  Base templates for Docker container configurations.

### 🧪 Media & Monitoring Scripts
- `plex_debug.py`, `plex_test.py`, `plex_invite.py`  
  Tools to debug Plex issues, test configurations, and send out server invites.
- `export_emby_data.py`  
  Export data from Emby for analysis or backup.
- `nowplaying_tautulli.txt`, `recently_tautulli`  
  Output/log files related to current playback and recent activity on Tautulli.
- `yt_rips.txt`, `ytrips.sh`  
  For managing and documenting YouTube rips/downloads.

### 🛡️ System Monitoring & Security
- `check_docker_status.sh`  
  Script to monitor running Docker containers.
- `port_scan_detect.sh`, `port_scan.log`, `port_scan_debug.log`  
  Port scan detection and logging utilities.
- `ssh_login_alert.sh`  
  Alert system for unauthorized SSH logins.
- `storage_alert.sh`  
  Monitors disk space and alerts when thresholds are exceeded.
- `update.sh`  
  Master script to update all containers and services.

### 🧰 Utilities & Logs
- `docker_debug.log`  
  Debugging output for Docker-related issues.
- `gluetunip_working.sh`  
  Troubleshooting or confirming Gluetun VPN IP status.
- `ystemctl list-units --type=service`  
  Systemd service status output.
- `reference_code.txt`, `reddit_ad.txt`  
  Miscellaneous notes or saved snippets for reference or promotions.

### 🗃️ HTML & Archive
- `archive_wiki.html`, `wip.html`  
  Static HTML files used for internal documentation, WIP notes, or archiving.

---

## 📅 Last Major Update

**April 7, 2025**  
Multiple files were updated including Docker Compose files, monitoring scripts, and Python utilities. Older files like `docker_container.yml`, `nowplaying_tautulli.txt`, and `reference_code.txt` have been retained for compatibility or archival purposes.

---

## 🧑‍💻 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/media-server-toolkit.git
   cd media-server-toolkit
   ```

2. Run the main services:
   ```bash
   docker-compose up -d
   ```

3. Customize templates (`*.yaml`, `*.sh`, `*.py`) as per your setup.

---

## 📝 Notes

- Ensure Docker and Docker Compose are installed and configured.
- Some scripts assume systemd-based services (tested on Debian/Ubuntu).
- Use at your own risk. Contributions are welcome!

---

## 📜 License

MIT License – feel free to modify and share.

