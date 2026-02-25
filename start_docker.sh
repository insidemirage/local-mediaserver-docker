#!/bin/bash

# Function to get local IP address
get_local_ip() {
    # Try different methods to get local IP
    if command -v ip &> /dev/null; then
        ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1
    elif command -v hostname &> /dev/null; then
        hostname -I | awk '{print $1}'
    else
        echo "Unknown"
    fi
}

# Function to check internet connection
check_internet() {
    echo "🌐 Checking internet connection..."
    
    # Try to ping Google DNS
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
    echo "   - Access services via: http://$LOCAL_IP:8080 (QBittorrent)"
    echo "                         http://$LOCAL_IP:8081 (Jellyfin)"
    echo "                         http://$LOCAL_IP:8082 (Piwigo)"
    echo "                         http://$LOCAL_IP:8083 (FileBrowser)"
else
    echo "⚠️  Could not determine local IP address"
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

# Set permissions (just in case)
chmod -R 755 films downloads storage piwigo mariadb filebrowser qbittorrent

echo "Done! All folders created."
echo ""
echo "Created folders:"
ls -la | grep -E "films|downloads|storage|piwigo|mariadb|filebrowser|qbittorrent"

# Show full structure
echo ""
echo "Full folder structure:"
if command -v tree &> /dev/null; then
    tree -L 2 . | grep -E "films|downloads|storage|piwigo|mariadb|filebrowser|qbittorrent" --color=always
else
    echo "tree not installed, skipping..."
    ls -R | grep -E "films|downloads|storage|piwigo|mariadb|filebrowser|qbittorrent"
fi

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
    
else
    echo "⚠️  .env file already exists. Using existing settings."
    
    # Show existing credentials
    echo ""
    echo "📋 Current credentials from .env:"
    echo "================================="
    
    # Check if variables exist
    if grep -q "USER_LOGIN" .env; then
        echo "FileBrowser, QBittorrent, Piwigo login: $(grep USER_LOGIN .env | cut -d'=' -f2)"
    else
        echo "⚠️ USER_LOGIN not found in .env"
    fi
    
    if grep -q "USER_PASSWORD" .env; then
        echo "FileBrowser, QBittorrent, Piwigo password: $(grep USER_PASSWORD .env | cut -d'=' -f2)"
    else
        echo "⚠️ USER_PASSWORD not found in .env"
    fi
    
    echo "---------------------------------"
    
    if grep -q "DB_ROOT_PASS" .env; then
        echo "DB Root Password: $(grep DB_ROOT_PASS .env | cut -d'=' -f2)"
    else
        echo "⚠️ DB_ROOT_PASS not found in .env"
    fi
    
    if grep -q "DB_PASS" .env; then
        echo "DB Piwigo Password: $(grep DB_PASS .env | cut -d'=' -f2)"
    else
        echo "⚠️ DB_PASS not found in .env"
    fi
    
    if grep -q "DB_LOGIN" .env; then
        echo "DB Login: $(grep DB_LOGIN .env | cut -d'=' -f2)"
    fi
    
    if grep -q "DB_NAME" .env; then
        echo "DB Name: $(grep DB_NAME .env | cut -d'=' -f2)"
    fi
    
    echo "================================="
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
echo ""
echo "🌐 Access URLs:"
echo "   Local access:"
echo "   - QBittorrent: http://localhost:8080"
echo "   - Jellyfin: http://localhost:8081"
echo "   - Piwigo: http://localhost:8082"
echo "   - FileBrowser: http://localhost:8083"
echo ""

if [ "$LOCAL_IP" != "Unknown" ] && [ -n "$LOCAL_IP" ]; then
    echo "   Network access:"
    echo "   - QBittorrent: http://$LOCAL_IP:8080"
    echo "   - Jellyfin: http://$LOCAL_IP:8081"
    echo "   - Piwigo: http://$LOCAL_IP:8082"
    echo "   - FileBrowser: http://$LOCAL_IP:8083"
    echo ""
    echo "⚠️  IMPORTANT: Don't forget to make IP $LOCAL_IP permanent in your router!"
    echo "   - Set DHCP reservation or static IP for this device"
    echo "   - Otherwise the IP might change after reboot"
fi

echo ""
echo "💡 Useful commands:"
echo "   docker-compose logs -f    # View logs"
echo "   docker-compose down       # Stop containers"
echo "   docker-compose restart    # Restart containers"
echo "   docker-compose ps         # Container status"