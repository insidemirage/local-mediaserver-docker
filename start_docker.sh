#!/bin/bash

# Function to get local IP address (без -P)
get_local_ip() {
    if command -v ip &> /dev/null; then
        # ip route get default может дать точнее, но проще взять первый не-local IP
        ip -4 addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -v '^127\.' | head -n1
    elif command -v ifconfig &> /dev/null; then
        ifconfig | awk '/inet / {print $2}' | grep -v '^127\.' | head -n1
    elif command -v hostname &> /dev/null; then
        hostname -I | awk '{print $1}'
    else
        echo "Unknown"
    fi
}


# Get local IP
LOCAL_IP=$(get_local_ip)

# Show network info
echo "📡 Network Information:"
echo "================================="
echo "Local IP Address: $LOCAL_IP"
if [ "$LOCAL_IP" != "Unknown" ] && [ -n "$LOCAL_IP" ]; then
    echo ""
    echo "⚠️  WARNING: Don't forget to make this IP permanent in your router!"
    echo "   - Set DHCP reservation or static IP for: $LOCAL_IP"
    echo "   - Otherwise the IP might change after reboot"
fi
echo "================================="
echo ""

# Create all necessary folders in the current directory
echo "Creating folders in $(pwd)..."

# Main folders
mkdir -pv films
mkdir -pv downloads
mkdir -pv storage
mkdir -pv piwigo

# MariaDB folder
mkdir -pv mariadb/data

# FileBrowser folders
mkdir -pv filebrowser/data
mkdir -pv filebrowser/config

# QBittorrent folder (if needed)
mkdir -pv qbittorrent/config

# Jellyfin folder (if needed)
mkdir -pv jellyfin/config

# Set permissions (just in case)
chmod -R 777 films downloads storage piwigo mariadb filebrowser qbittorrent jellyfin

echo "Done! All folders created."

# Create .env file only if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file with passwords..."

    # Generate random passwords (10 characters)
    DB_ROOT_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 10)
    DB_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 10)

    # Create .env file
    cat > .env << EOF
# Database credentials
DB_ROOT_PASS=$DB_ROOT_PASS
DB_PASS=$DB_PASS
DB_LOGIN=piwigo
DB_NAME=piwigo

# Timezone
TZ=Europe/Moscow
EOF

    echo "✅ .env file created with random passwords"

else
    echo "⚠️  .env file already exists. Using existing settings."

    # Check if variables exist
    if ! grep -q "DB_ROOT_PASS" .env; then
        echo "⚠️ DB_ROOT_PASS not found in .env"
    fi

    if ! grep -q "DB_PASS" .env; then
        echo "⚠️ DB_PASS not found in .env"
    fi

fi

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo "❌ Error: docker-compose.yml not found!"
    exit 1
fi

# Check if docker and docker-compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    exit 1
fi

# Start containers
echo ""
echo "🚀 Starting Docker containers..."
docker-compose up -d

echo "Waiting for containers to initialize..."
sleep 3

echo "Getting qbittorrent password from logs..."

# Get password from docker qbittorrent logs
QBITTORRENT_PASSWORD=$(docker-compose logs qbittorrent 2>/dev/null | grep "The WebUI administrator password was not set" | tail -n1 | sed 's/.*session: //')

QBITTORRENT_PASSWORD="${QBITTORRENT_PASSWORD:-Not found, check logs manually}"

echo "Getting filebrowser password from logs..."

# Get password from docker filebrowser logs
FILEBROWSER_PASSWORD=$(docker-compose logs filebrowser 2>/dev/null | grep "User 'admin' initialized with randomly generated password" | tail -n1 | sed 's/.*password: //')

FILEBROWSER_PASSWORD="${FILEBROWSER_PASSWORD:-Not found, check logs manually}"

if [ "$LOCAL_IP" != "Unknown" ] && [ -n "$LOCAL_IP" ]; then
    echo "================================="
    echo "🌐 Network access URLs (clickable):"
    echo "================================="
    echo -e "QBittorrent: http://$LOCAL_IP:8080"
    echo -e "Jellyfin:    http://$LOCAL_IP:8096"
    echo -e "Piwigo:      http://$LOCAL_IP:8082"
    echo -e "FileBrowser: http://$LOCAL_IP:8083"
    echo "================================="
    echo ""
    echo "⚠️  Закрепи IP $LOCAL_IP в роутере (DHCP reservation)"
else
    echo "❌ Не удалось определить локальный IP. Проверь сеть."
fi

echo ""
echo "📋 CREDENTIALS:"
echo "================================="
echo "QBittorrent login: admin"
echo "QBittorrent password: $QBITTORRENT_PASSWORD"
echo "---------------------------------"
echo "FileBrowser login: admin"
echo "FileBrowser password: $FILEBROWSER_PASSWORD"
echo "================================="
echo "🚨🚨🚨 This passwords are temporary, change it! 🚨🚨🚨"
echo "---------------------------------"
echo "DB host: mariadb"
echo "DB Password: $(grep DB_PASS .env | cut -d'=' -f2)"
echo "DB Login: $(grep DB_LOGIN .env | cut -d'=' -f2)"
echo "DB Name: $(grep DB_NAME .env | cut -d'=' -f2)"
echo "================================="
echo "⚠️  Save these credentials in a secure place!"
