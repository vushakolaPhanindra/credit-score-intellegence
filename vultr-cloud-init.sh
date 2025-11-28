#!/bin/bash
# Vultr Cloud-Init Script for Financial Project Deployment
# This script will be executed when the Vultr instance starts

set -e

echo "======================================"
echo "Financial Project - Vultr Setup Script"
echo "======================================"

# Update system packages
echo "Step 1: Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker
echo "Step 2: Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Docker Compose
echo "Step 3: Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker
systemctl start docker
systemctl enable docker

# Install Git
echo "Step 4: Installing Git..."
apt-get install -y git

# Create app directory
echo "Step 5: Creating application directory..."
mkdir -p /opt/financial-project
cd /opt/financial-project

# Clone repository (you can modify the URL)
echo "Step 6: Cloning repository..."
git clone https://github.com/vushakolaPhanindra/Financial_Project.git .

# Create .env file from example
echo "Step 7: Creating .env file..."
cp .env.example .env

# Generate SSL certificates (self-signed for now, should be replaced with Let's Encrypt)
echo "Step 8: Generating SSL certificates..."
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=yourdomain.com"

# Create data and models directories
echo "Step 9: Creating necessary directories..."
mkdir -p data models outputs/plots outputs/shap_summaries outputs/rationales

# Set permissions
chmod -R 755 data models outputs

# Pull Docker images
echo "Step 10: Building Docker images..."
docker compose build

# Create systemd service for automatic startup
echo "Step 11: Creating systemd service..."
cat > /etc/systemd/system/financial-project.service << 'EOF'
[Unit]
Description=Financial Project - Credit Score Intelligence
After=docker.service
Requires=docker.service

[Service]
Type=simple
WorkingDirectory=/opt/financial-project
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable financial-project.service

# Start containers
echo "Step 12: Starting Docker containers..."
docker compose up -d

# Wait for containers to be ready
sleep 15

# Create backup script
echo "Step 13: Creating backup script..."
cat > /usr/local/bin/backup-financial-project.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/financial-project"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p $BACKUP_DIR

# Backup models and data
tar -czf "$BACKUP_DIR/data_$TIMESTAMP.tar.gz" -C /opt/financial-project data/ models/

# Keep only last 7 days of backups
find $BACKUP_DIR -name "data_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/data_$TIMESTAMP.tar.gz"
EOF

chmod +x /usr/local/bin/backup-financial-project.sh

# Add backup to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-financial-project.sh") | crontab -

# Setup log rotation
echo "Step 14: Setting up log rotation..."
cat > /etc/logrotate.d/financial-project << 'EOF'
/opt/financial-project/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        docker compose -f /opt/financial-project/docker-compose.yml kill -s HUP app 2>/dev/null || true
    endscript
}
EOF

# Display final information
echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Application URL: https://$(hostname -I | awk '{print $1}')"
echo "API Documentation: https://$(hostname -I | awk '{print $1}')/docs"
echo ""
echo "Next Steps:"
echo "1. SSH into your server: ssh root@$(hostname -I | awk '{print $1}')"
echo "2. Edit .env file: nano /opt/financial-project/.env"
echo "3. Add your OpenAI API key and other configuration"
echo "4. Restart containers: docker compose restart"
echo ""
echo "To view logs: docker compose logs -f"
echo "To manage containers: docker compose up/down/restart"
echo ""
echo "For production, replace self-signed certificates with Let's Encrypt!"
echo "======================================"
