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


# Function to check internet connection
check_internet() {
    echo "🌐 Checking internet connection..."
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "✅ Internet connection: OK"
        return 0
    else
        echo "❌ Internet connection: FAILED"
        echo "⚠️  Some services may not work properly without internet"
        return 1
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

# Check internet
check_internet
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
chmod -R 755 films downloads storage piwigo mariadb filebrowser qbittorrent jellyfin

echo "Done! All folders created."

# Create .env file only if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file with passwords..."
    
    # Generate random passwords (10 characters)
    USER_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 10)
    DB_ROOT_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 10)
    DB_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 10)
    
    # Create .env file
    cat > .env << EOF
# FileBrowser credentials
USER_LOGIN=admin
USER_PASSWORD=$USER_PASSWORD

# Database credentials
DB_ROOT_PASS=$DB_ROOT_PASS
DB_PASS=$DB_PASS
DB_LOGIN=piwigo
DB_NAME=piwigo

# Timezone
TZ=Europe/Moscow
EOF

    echo "✅ .env file created with random passwords"
    
    # Show saved credentials
    
else
    echo "⚠️  .env file already exists. Using existing settings."
    
    # Check if variables exist
    if ! grep -q "USER_LOGIN" .env; then
        echo "⚠️ USER_LOGIN not found in .env"
    fi

    if ! grep -q "USER_PASSWORD" .env; then
        echo "⚠️ USER_PASSWORD not found in .env"
    fi

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

# Check containers status
echo ""
echo "📊 Containers status:"
docker-compose ps

# Show used ports
echo ""
echo "🔌 Used ports:"
if command -v ss &> /dev/null; then
    ss -tulpn | grep -E ":(8080|8081|8082|8083)" || echo "Ports 8080,8081,8082,8083 are not listening"
elif command -v netstat &> /dev/null; then
    netstat -tulpn | grep -E ":(8080|8081|8082|8083)" 2>/dev/null || echo "Ports 8080,8081,8082,8083 are not listening"
else
    echo "Cannot check ports (neither ss nor netstat is available)"
fi

echo ""
echo "✅ Done! Containers are running."
echo "Getting qbittorrent password from logs..."

# Get password from docker qbittorrent logs
QBITTORRENT_PASSWORD=$(docker-compose logs qbittorrent 2>/dev/null | grep "The WebUI administrator password was not set" | tail -n1 | sed 's/.*session: //')

QBITTORRENT_PASSWORD:-Not found, check logs manually
if [ "$LOCAL_IP" != "Unknown" ] && [ -n "$LOCAL_IP" ]; then
    echo "================================="
    echo "🌐 Network access URLs (clickable):"
    echo "================================="
    echo -e "QBittorrent: http://$LOCAL_IP:8080"
    echo -e "Jellyfin:    http://$LOCAL_IP:8081"
    echo -e "Piwigo:      http://$LOCAL_IP:8082"
    echo -e "FileBrowser: http://$LOCAL_IP:8083"
    echo "================================="
    echo ""
    echo "⚠️  Закрепи IP $LOCAL_IP в роутере (DHCP reservation)"
else
    echo "❌ Не удалось определить локальный IP. Проверь сеть."
fi

echo "⚠️ Временный пароль для входа в qBittorrent: $QBITTORRENT_PASSWORD"
echo "❌ Если не удалось найти, запусти docker-compose logs qbittorrent и посмотри сам"

echo ""
echo "📋 CREDENTIALS:"
echo "================================="
echo "FileBrowser, QBittorrent, Piwigo login: $(grep USER_LOGIN .env | cut -d'=' -f2)"
echo "FileBrowser, QBittorrent, Piwigo password: $(grep USER_PASSWORD .env | cut -d'=' -f2)"
echo "---------------------------------"
echo "DB Root Password: $(grep DB_ROOT_PASS .env | cut -d'=' -f2)"
echo "DB Piwigo Password: $(grep DB_PASS .env | cut -d'=' -f2)"
echo "DB Login: $(grep DB_LOGIN .env | cut -d'=' -f2)"
echo "DB Name: $(grep DB_NAME .env | cut -d'=' -f2)"
echo "================================="
echo ""
echo "⚠️  Save these credentials in a secure place!"
