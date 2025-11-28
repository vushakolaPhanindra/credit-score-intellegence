# 🚀 Vultr Cloud Deployment Guide - Financial Project

## Overview

This guide provides step-by-step instructions for deploying the Credit Score Intelligence application to Vultr cloud infrastructure using Docker containers.

## Architecture

```
┌─────────────────────────────────────────┐
│         Vultr Cloud Instance            │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │     Nginx (Reverse Proxy)         │ │
│  │  Port 80 (HTTP) & 443 (HTTPS)     │ │
│  └───────────────────────────────────┘ │
│           ↓           ↓                 │
│  ┌──────────────┐  ┌──────────────┐   │
│  │   FastAPI    │  │  Streamlit   │   │
│  │   Backend    │  │  Frontend    │   │
│  │  :8000       │  │   :8501      │   │
│  └──────────────┘  └──────────────┘   │
│           ↓              ↓              │
│  ┌──────────────────────────────────┐ │
│  │     Shared Data & Models         │ │
│  │   (Volumes/Persistent Storage)   │ │
│  └──────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Prerequisites

1. **Vultr Account**: Create an account at https://www.vultr.com/
2. **Domain Name** (optional): For HTTPS with custom domain
3. **OpenAI API Key**: For LLM-based rationale generation
4. **Git**: For cloning the repository

## Quick Start (Recommended) - Using Cloud-Init

### Step 1: Create a Vultr Instance

1. Go to [Vultr Console](https://www.vultr.com/console/)
2. Click **"Deploy New Server"**
3. Select server location (closest to your users)
4. **Choose OS**: Ubuntu 22.04 LTS or newer
5. **Choose Server Size**: Recommended minimum 2GB RAM (start with $6/mo)
   - For production: 4GB+ RAM recommended
6. **Additional Options**: Skip for now
7. Scroll down to **User Data** section

### Step 2: Add Cloud-Init Script

1. Enable **User Data** checkbox
2. In the text area, paste the contents of `vultr-cloud-init.sh`
3. Click **"Deploy Now"**

The server will automatically:
- Install Docker and Docker Compose
- Clone your repository
- Build and start all containers
- Generate SSL certificates
- Enable automatic backups

**Wait 5-10 minutes for setup to complete.**

### Step 3: Configure the Application

1. SSH into your server:
```bash
ssh root@YOUR_SERVER_IP
```

2. Edit the environment configuration:
```bash
nano /opt/financial-project/.env
```

3. Add your OpenAI API key and other settings:
```bash
OPENAI_API_KEY=sk-your-actual-key-here
ENVIRONMENT=production
ALLOWED_HOSTS=your-domain.com,YOUR_SERVER_IP
```

4. Save and restart containers:
```bash
cd /opt/financial-project
docker compose restart
```

### Step 4: Access Your Application

- **Web Interface**: https://YOUR_SERVER_IP
- **API Documentation**: https://YOUR_SERVER_IP/docs
- **API Base URL**: https://YOUR_SERVER_IP/api

## Manual Deployment (Alternative)

If you prefer manual setup or cloud-init fails:

### Step 1: SSH into Vultr Instance

```bash
ssh root@YOUR_SERVER_IP
```

### Step 2: Run Deployment Script

```bash
# Download and execute deployment script
curl -O https://raw.githubusercontent.com/vushakolaPhanindra/Financial_Project/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

Or clone and deploy manually:

```bash
# Clone repository
git clone https://github.com/vushakolaPhanindra/Financial_Project.git
cd Financial_Project

# Setup environment
cp .env.example .env
nano .env  # Edit with your API keys

# Build and start
docker compose up -d
```

## Configuration

### Essential Environment Variables

Edit `.env` file to configure:

```bash
# OpenAI (REQUIRED)
OPENAI_API_KEY=sk-xxxxxxxxxxxx

# Application
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=info

# Security
SECRET_KEY=generate-strong-random-key
ALLOWED_HOSTS=yourdomain.com,YOUR_SERVER_IP

# API Configuration
API_WORKERS=4
API_TIMEOUT=60

# Streamlit
STREAMLIT_SERVER_HEADLESS=true
```

### SSL/TLS Configuration

**Development (Default)**:
- Self-signed certificates auto-generated
- Browser will show security warning
- Fine for testing

**Production (Recommended)**:
1. Install Let's Encrypt certificates:

```bash
# SSH to server
ssh root@YOUR_SERVER_IP
cd /opt/financial-project

# Install certbot
apt-get install -y certbot python3-certbot-nginx

# Get certificate
certbot certonly --standalone -d yourdomain.com

# Update nginx.conf with certificate paths
nano nginx.conf
# Change:
# ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privatekey.pem

# Restart nginx
docker compose restart nginx
```

2. Auto-renew certificates:

```bash
# Add to crontab
crontab -e

# Add this line:
0 3 * * * certbot renew --quiet && docker compose -f /opt/financial-project/docker-compose.yml restart nginx
```

## Management & Monitoring

### Useful Docker Commands

```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend
docker compose logs -f frontend

# Restart services
docker compose restart

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Rebuild images
docker compose build --no-cache

# Execute command in container
docker compose exec backend python -c "import pandas; print(pandas.__version__)"
```

### Health Checks

```bash
# Check API health
curl https://YOUR_SERVER_IP/health

# Check via SSH
ssh root@YOUR_SERVER_IP "docker compose ps"

# View system resources
ssh root@YOUR_SERVER_IP "docker stats"
```

### Backup & Restore

**Automatic backups** are enabled (daily at 2 AM):

```bash
# Manual backup
ssh root@YOUR_SERVER_IP "/usr/local/bin/backup-financial-project.sh"

# View backups
ssh root@YOUR_SERVER_IP "ls -lh /backups/financial-project/"

# Restore from backup
ssh root@YOUR_SERVER_IP
cd /opt/financial-project
tar -xzf /backups/financial-project/data_YYYYMMDD_HHMMSS.tar.gz
docker compose restart
```

## Scaling & Performance

### Increase API Workers

Edit `.env`:
```bash
API_WORKERS=8  # Increase from 4 to 8
```

Restart:
```bash
docker compose restart backend
```

### Upgrade Server Size

1. In Vultr console, click "Resize" on your instance
2. Choose larger plan (up to 32GB RAM)
3. Server restarts automatically
4. Application continues running

### Database (Future Enhancement)

For production with database:

1. Add PostgreSQL to `docker-compose.yml`
2. Update connection string in `.env`
3. Run migrations: `docker compose exec backend python manage.py migrate`

## Troubleshooting

### Containers not starting?

```bash
# Check logs
docker compose logs

# Rebuild images
docker compose build --no-cache

# Restart
docker compose down
docker compose up -d
```

### High memory usage?

```bash
# Check container stats
docker stats

# Limit container memory in docker-compose.yml
# Add under service:
#   mem_limit: 2g
#   memswap_limit: 4g

docker compose restart
```

### SSL certificate errors?

```bash
# Verify certificate
ssh root@YOUR_SERVER_IP
openssl x509 -in ssl/cert.pem -text -noout

# Regenerate
rm ssl/*.pem
cd /opt/financial-project
docker compose restart nginx
```

### API not responding?

```bash
# Check if port is open
curl http://YOUR_SERVER_IP:8000/health

# Check firewall
sudo ufw status

# Open port 8000 (if needed)
sudo ufw allow 8000
```

## Firewall Configuration

Recommended UFW setup:

```bash
ssh root@YOUR_SERVER_IP

# Enable firewall
ufw enable

# Allow SSH (important!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow Nginx to bypass
ufw allow 'Nginx Full'

# Check status
ufw status
```

## Monitoring & Alerts

### CPU/Memory Alerts

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Monitor in real-time
docker stats

# Set up Sentry for error tracking (optional)
# Add to .env:
# SENTRY_DSN=https://key@sentry.io/project-id
```

### Log Rotation

Configured automatically. Logs are rotated daily:

```bash
cat /etc/logrotate.d/financial-project
```

## Cost Optimization

1. **Start Small**: Begin with $6/mo 2GB instance
2. **Scale as Needed**: Upgrade only when needed
3. **Use Vultr High Frequency**: 40% cheaper than standard
4. **Regional**: Deploy closer to users to reduce latency

| Plan | RAM | CPU | Storage | Price/mo |
|------|-----|-----|---------|----------|
| Start | 2GB | 1 | 60GB | $6 |
| Standard | 4GB | 2 | 120GB | $12 |
| Production | 8GB | 4 | 200GB | $24 |

## Security Best Practices

✅ **Do**:
- [x] Change root password immediately
- [x] Use SSH keys (not passwords)
- [x] Keep .env file secure (never commit)
- [x] Enable firewall
- [x] Use HTTPS with valid certificates
- [x] Rotate secrets regularly
- [x] Monitor logs for suspicious activity
- [x] Keep Docker images updated

❌ **Don't**:
- [ ] Commit .env to Git
- [ ] Use default passwords
- [ ] Expose debug mode in production
- [ ] Leave SSH on default port 22 (optional: change to custom port)
- [ ] Run containers as root (where possible)

## CI/CD Integration (GitHub Actions)

See `.github/workflows/deploy.yml` for automated deployment on push.

## Support & Resources

- **Vultr Docs**: https://www.vultr.com/docs/
- **Docker Docs**: https://docs.docker.com/
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Streamlit Docs**: https://docs.streamlit.io/

## Advanced: Custom Domain

### Point Domain to Vultr Server

1. In your domain registrar's DNS settings:
   - Create `A` record pointing to YOUR_SERVER_IP
   - Create `AAAA` record for IPv6 (optional)

2. Update `.env`:
```bash
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

3. Get SSL certificate for domain:
```bash
ssh root@YOUR_SERVER_IP
cd /opt/financial-project
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

4. Restart services:
```bash
docker compose restart
```

## Cleanup & Removal

To remove everything:

```bash
ssh root@YOUR_SERVER_IP
cd /opt/financial-project

# Stop containers
docker compose down

# Remove volumes (careful!)
docker volume prune

# Delete application directory
rm -rf /opt/financial-project

# Delete service
systemctl disable financial-project.service
rm /etc/systemd/system/financial-project.service
systemctl daemon-reload
```

---

**Questions?** Check the [GitHub Issues](https://github.com/vushakolaPhanindra/Financial_Project/issues) or create a new one!
