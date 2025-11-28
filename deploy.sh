#!/bin/bash
# Manual deployment script for Vultr
# Use this if you prefer manual setup over cloud-init

set -e

PROJECT_DIR="/opt/financial-project"
REPO_URL="https://github.com/vushakolaPhanindra/Financial_Project.git"

echo "=========================================="
echo "Financial Project - Manual Deployment"
echo "=========================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Function to print step headers
print_step() {
    echo ""
    echo ">>> $1"
}

# Update system
print_step "Updating system packages"
apt-get update && apt-get upgrade -y

# Install Docker
print_step "Installing Docker"
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
print_step "Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker
systemctl start docker
systemctl enable docker

# Create project directory
print_step "Creating project directory"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Clone repository
print_step "Cloning repository"
git clone "$REPO_URL" .

# Setup environment
print_step "Setting up environment"
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  .env created from template - PLEASE EDIT AND ADD YOUR API KEYS!"
fi

# Create SSL certificates
print_step "Generating SSL certificates"
mkdir -p ssl
if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/key.pem \
        -out ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$(hostname -I | awk '{print $1}')"
fi

# Create necessary directories
print_step "Creating directories"
mkdir -p data models outputs/{plots,shap_summaries,rationales}
chmod -R 755 data models outputs

# Build Docker images
print_step "Building Docker images"
docker compose build --no-cache

# Create systemd service
print_step "Creating systemd service"
cat > /etc/systemd/system/financial-project.service << 'SERVICE_EOF'
[Unit]
Description=Financial Project - Credit Score Intelligence
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/financial-project
ExecStart=/usr/local/bin/docker-compose up
ExecStop=/usr/local/bin/docker-compose down
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable financial-project.service

# Start services
print_step "Starting services"
docker compose up -d

# Wait for services to be ready
print_step "Waiting for services to start..."
sleep 20

# Check service status
print_step "Checking service status"
docker compose ps

# Get IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Display completion message
echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "📍 Server IP: $SERVER_IP"
echo "🌐 Application URL: https://$SERVER_IP"
echo "📚 API Docs: https://$SERVER_IP/docs"
echo ""
echo "📝 Important Next Steps:"
echo "1. Edit configuration:"
echo "   nano $PROJECT_DIR/.env"
echo ""
echo "2. Add your OpenAI API key:"
echo "   OPENAI_API_KEY=sk-your-key-here"
echo ""
echo "3. Restart services:"
echo "   cd $PROJECT_DIR && docker compose restart"
echo ""
echo "📊 Useful Commands:"
echo "   • View logs: docker compose logs -f"
echo "   • Restart: docker compose restart"
echo "   • Stop: docker compose down"
echo "   • Start: docker compose up -d"
echo ""
echo "🔒 Security Notes:"
echo "   • Replace self-signed SSL certificates with Let's Encrypt"
echo "   • Set strong passwords in .env file"
echo "   • Configure firewall rules"
echo "   • Enable automatic backups"
echo ""
echo "=========================================="
