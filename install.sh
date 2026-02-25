#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Local Media Server Docker Stack Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Docker on Ubuntu/Debian
install_docker_ubuntu() {
    echo -e "${YELLOW}Installing Docker on Ubuntu/Debian...${NC}"
    
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up stable repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Start Docker and enable on boot
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
}

# Function to install Docker on CentOS/RHEL/Fedora
install_docker_centos() {
    echo -e "${YELLOW}Installing Docker on CentOS/RHEL/Fedora...${NC}"
    
    # Remove old versions
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    
    # Install prerequisites
    sudo yum install -y yum-utils
    
    # Set up repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
    # Start Docker and enable on boot
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
}

# Function to install Docker Compose
install_docker_compose() {
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    
    # Download Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Apply executable permissions
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo -e "${GREEN}✅ Docker Compose installed successfully${NC}"
}

# Check and install Docker
echo -e "${BLUE}Checking Docker installation...${NC}"
if command_exists docker; then
    echo -e "${GREEN}✅ Docker is already installed${NC}"
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "   Version: $DOCKER_VERSION"
else
    echo -e "${YELLOW}⚠️  Docker not found${NC}"
    
    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}Cannot detect OS. Please install Docker manually.${NC}"
        exit 1
    fi
    
    # Install Docker based on OS
    case $OS in
        ubuntu|debian)
            install_docker_ubuntu
            ;;
        centos|rhel|fedora)
            install_docker_centos
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS. Please install Docker manually.${NC}"
            exit 1
            ;;
    esac
fi

echo ""

# Check and install Docker Compose
echo -e "${BLUE}Checking Docker Compose installation...${NC}"
if command_exists docker-compose; then
    echo -e "${GREEN}✅ Docker Compose is already installed${NC}"
    COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f4 | cut -d ',' -f1)
    echo -e "   Version: $COMPOSE_VERSION"
else
    echo -e "${YELLOW}⚠️  Docker Compose not found${NC}"
    install_docker_compose
fi

echo ""

# Check if git is installed
echo -e "${BLUE}Checking Git installation...${NC}"
if command_exists git; then
    echo -e "${GREEN}✅ Git is already installed${NC}"
else
    echo -e "${YELLOW}⚠️  Git not found. Installing...${NC}"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                sudo apt-get update && sudo apt-get install -y git
                ;;
            centos|rhel|fedora)
                sudo yum install -y git
                ;;
            *)
                echo -e "${RED}Cannot install Git automatically. Please install manually.${NC}"
                exit 1
                ;;
        esac
    fi
    echo -e "${GREEN}✅ Git installed successfully${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}All prerequisites are installed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Clone the repository
echo -e "${YELLOW}Cloning the media server repository...${NC}"
if [ -d "local-mediaserver-docker" ]; then
    echo -e "${YELLOW}Directory already exists. Updating...${NC}"
    cd local-mediaserver-docker
    git pull
else
    git clone https://github.com/insidemirage/local-mediaserver-docker.git
    cd local-mediaserver-docker
fi

echo -e "${GREEN}✅ Repository cloned successfully${NC}"
echo ""

# Make start script executable
echo -e "${YELLOW}Making start script executable...${NC}"
chmod +x start_docker.sh
./start_docker.sh
echo -e "${GREEN}✅ Done${NC}"
echo ""