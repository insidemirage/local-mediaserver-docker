# 🎬 Home Media Server on Docker  
[Russian version](./README_RU.MD)   
**Stream, store, share — all in one box!**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://docker.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/insidemirage/local-mediaserver-docker/graphs/commit-activity)
[![GitHub issues](https://img.shields.io/github/issues/insidemirage/local-mediaserver-docker)](https://github.com/insidemirage/local-mediaserver-docker/issues)

> ✨ **Forget about headaches** — set up your personal media server, photo gallery, and file manager on any machine in 5 minutes.

---

## 🚀 One Command — And You're Done

Just copy-paste this into your terminal and watch the magic happen:

### With curl
```bash
curl -sSL https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

### With wget
```bash
wget -qO- https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

**What happens next?**  
The script automatically installs Docker, Docker Compose, and Git (if missing), clones the repository, and starts your media server. You won't even finish your coffee ☕.

---

## 📦 What's Inside?

| Service | What it does | Port |
|--------|-------------|------|
| **QBittorrent** 🧲 | Downloads files | 8080 |
| **Jellyfin** 🎞️ | Your personal Netflix for your home collection | 8096 |
| **Piwigo** 📸 | Modern photo gallery manager | 8082 |
| **FileBrowser** 📁 | Web-based file explorer | 8083 |
| **MariaDB** 🐬 | Database backend for photos (quietly does its job) | — |

---

## 🖥️ How to Use It?

After startup, the server will display your local IP (something like `192.168.1.xxx`).  
Just open a browser on any device in your network and enter:

```
QBittorrent → http://192.168.1.xxx:8080
Jellyfin    → http://192.168.1.xxx:8096
Piwigo      → http://192.168.1.xxx:8082
FileBrowser → http://192.168.1.xxx:8083
```

**Default login everywhere:** `admin`  
**Password:** randomly generated and shown in the terminal (write it down or take a photo before closing the terminal!).

---

## 🔧 Manual Installation (For Perfectionists)

If you prefer to do things yourself:

```bash
git clone https://github.com/insidemirage/local-mediaserver-docker.git
cd local-mediaserver-docker
chmod +x start_docker.sh
./start_docker.sh
```

---

## 🔧 System Requirements

- **Operating System**: Ubuntu 20.04+, Debian 11+, CentOS 7+, or any Linux distribution with Docker support
- **RAM**: 
  - **Minimum**: 1 GB (tested on Orange Pi Zero 3 with 2 GB total, using ~530 MB at idle)
  - **Recommended**: 2 GB+ for smooth operation with multiple concurrent users or transcoding
- **Storage**: Depends on your media collection (at least 10 GB free for Docker images and basic data)
- **Architecture**: x86_64 (AMD64) or ARM64 (Raspberry Pi, Orange Pi, etc.)

---

## 📁 Folder Structure

```
📂 local-mediaserver-docker/
├── 📀 films/               # Put your videos here (Jellyfin picks them up)
├── 📥 downloads/           # QBittorrent downloads go here
├── 🖼️ storage/              # Photos for Piwigo
├── ⚙️ piwigo/               # Photo gallery settings
├── 🗄️ mariadb/data/         # Database files
├── 📂 filebrowser/          # File manager data
├── ⚙️ qbittorrent/config/   # Torrent client configs
├── ⚙️ jellyfin/config/      # Media server configs
├── 🐳 docker-compose.yml     # Container definitions
├── 🚀 start_docker.sh        # Launcher script
└── 📦 install.sh             # One-line installer
```

---

## 💡 Why This is Awesome?

✅ **Full control** — everything runs on your hardware  
✅ **Privacy first** — your photos and watch history stay with you  
✅ **Dead simple** — even if you've never heard of Docker, the script does it all  
✅ **Extendable** — want to add Nextcloud or Plex? Easy with Docker!  
✅ **Runs on anything** — Pentium, Raspberry Pi, old laptop — all good  

---

## ⚠️ Important Details

- 🔒 **Make your IP static** — set DHCP reservation in your router so the address doesn't change after reboot
- 🔥 **Open ports** in your firewall (8080, 8096, 8082, 8083) if you want access from the internet (but be careful with security)
- 👥 **Docker group** — if Docker was just installed, log out and back in, or run `newgrp docker` to avoid typing sudo

---

## 🛠️ Useful Commands

```bash
# View all container logs
docker-compose logs -f

# Stop everything
docker-compose down

# Restart all services
docker-compose restart

# Update to latest versions
git pull
docker-compose pull
docker-compose up -d
```

---

## 🆘 Troubleshooting

**…getting "permission denied"?**  
→ Run `newgrp docker` or log out and back in.

**…ports already in use?**  
→ Edit `docker-compose.yml` and change the left port (e.g., `8080:8080` → `8085:8080`).

**…can't access from other devices?**  
→ Check IP address, firewall, and make sure devices are on the same network.

**…installation failed halfway?**  
→ It happens — just run `./start_docker.sh` again.

---

## 📝 License

MIT License — do whatever you want with it, even sell it (but sharing with a friend is cooler).

---

## 🤗 Want to Contribute?

A GitHub star, a pull request, or just a kind word — all welcome!  
[GitHub Repository](https://github.com/insidemirage/local-mediaserver-docker)

---

*Note: This project is intended for legal use only. The author does not endorse or support piracy. Users are responsible for complying with applicable laws.*

**Enjoy your movie night!** 🍿📽️