Вот обновленный README.md с правильным синтаксисом установки:

# Local Media Server Docker Stack

A complete, self-hosted media server solution powered by Docker. Transform any machine into a powerful home media center with media downloading, streaming, photo management, and file sharing capabilities.

## 🚀 One-Line Installation

Install everything with a single command:

### Using curl
```bash
curl -sSL https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

### Using wget
```bash
wget -qO- https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

The installer will automatically:
- Check for Docker and Docker Compose (install if missing)
- Check for Git (install if missing)
- Clone the repository
- Start all services immediately

## 📦 Manual Installation

If you prefer to install manually:

```bash
git clone https://github.com/insidemirage/local-mediaserver-docker.git
cd local-mediaserver-docker
chmod +x start_docker.sh
./start_docker.sh
```

## 🔧 System Requirements

- **Operating System**: Ubuntu 20.04+, Debian 11+, CentOS 7+, or any Linux distribution with Docker support
- **RAM**: Minimum 2GB (4GB+ recommended)
- **Storage**: Depends on your media collection
- **Architecture**: x86_64 (AMD64) or ARM64

## 📋 Services Included

| Service | Description | Port |
|---------|-------------|------|
| **QBittorrent** | BitTorrent client for downloading | 8080 |
| **Jellyfin** | Media streaming server | 8096 |
| **Piwigo** | Photo gallery management | 8082 |
| **FileBrowser** | Web-based file manager | 8083 |
| **MariaDB** | Database for Piwigo | Internal |

## 🌐 Access After Installation

Once the installation completes, you can access your services at:

```
QBittorrent: http://YOUR_SERVER_IP:8080
Jellyfin:    http://YOUR_SERVER_IP:8096
Piwigo:      http://YOUR_SERVER_IP:8082
FileBrowser: http://YOUR_SERVER_IP:8083
```

The installer will display your actual IP address and these URLs at the end of the installation process.

## 🔒 First-Time Login Credentials

During the first run, the system generates random passwords for all services. These credentials are displayed only once in the terminal. **Save them in a secure place!**

Default login for all services: `admin`

## ⚠️ Important Notes

- **Network Configuration**: Make sure your server has a static IP or DHCP reservation in your router to prevent address changes after reboot
- **Firewall**: Ensure the required ports are open if you have a firewall enabled
- **Storage**: Media files are stored in the `films/` and `downloads/` directories
- **Docker Group**: If Docker was just installed, you may need to log out and back in for group changes to take effect, or run `newgrp docker`

## 📁 Directory Structure

```
local-mediaserver-docker/
├── films/              # Media files for Jellyfin
├── downloads/          # Download directory for QBittorrent
├── storage/            # Photo storage for Piwigo
├── piwigo/             # Piwigo configuration
├── mariadb/
│   └── data/          # Database files
├── filebrowser/
│   ├── data/          # FileBrowser database
│   └── config/        # FileBrowser settings
├── qbittorrent/
│   └── config/        # QBittorrent configuration
├── jellyfin/
│   └── config/        # Jellyfin configuration
├── docker-compose.yml  # Docker services configuration
├── start_docker.sh     # Main startup script
└── install.sh         # One-line installer
```

## 🛠️ Useful Commands

```bash
# View logs
docker-compose logs -f

# Stop all containers
docker-compose down

# Restart all containers
docker-compose restart

# Check container status
docker-compose ps

# Update to latest versions
git pull
docker-compose pull
docker-compose up -d
```

## ❓ Troubleshooting

**Docker permission denied?**
```bash
# Log out and log back in, or run:
newgrp docker
```

**Ports already in use?**
Change the port mappings in `docker-compose.yml` before starting.

**Can't access services from other devices?**
- Check firewall settings
- Verify the IP address is correct
- Ensure devices are on the same network

**Installation script fails?**
- Make sure curl or wget is installed
- Try manual installation method
- Check your internet connection

## 📝 License

This project is open-source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

**Enjoy your personal media server!** 🎬📸🎵