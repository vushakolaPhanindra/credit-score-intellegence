# 📋 Vultr Deployment Checklist & Quick Reference

## Pre-Deployment Checklist

### 1. Prerequisites
- [ ] Created Vultr account
- [ ] Generated API token (optional, for automation)
- [ ] Have OpenAI API key ready
- [ ] Have SSH key pair generated (or will use password)
- [ ] Domain name registered (optional but recommended)

### 2. Repository Preparation
- [ ] Cloned Financial_Project repository
- [ ] Created `.env` file from `.env.example`
- [ ] Reviewed all configuration files
- [ ] Updated `ALLOWED_HOSTS` with your domain/IP
- [ ] Committed all changes to Git

### 3. Application Setup
- [ ] Tested application locally
- [ ] Verified all models exist in `/models`
- [ ] Verified data files exist in `/data`
- [ ] Checked Docker is installed locally (for testing)
- [ ] Built Docker images locally: `docker compose build`

---

## Quick Start Commands

### Option 1: Cloud-Init (Fastest)
```bash
# 1. Create Vultr instance
# 2. Paste vultr-cloud-init.sh in User Data section
# 3. Deploy
# 4. Wait 5-10 minutes
# 5. SSH and configure .env

ssh root@YOUR_SERVER_IP
nano /opt/financial-project/.env  # Add OPENAI_API_KEY
docker compose restart
```

### Option 2: Manual Deployment
```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Run deployment script
curl -O https://raw.githubusercontent.com/vushakolaPhanindra/Financial_Project/main/deploy.sh
chmod +x deploy.sh
./deploy.sh

# Configure
cd /opt/financial-project
nano .env
docker compose restart
```

### Option 3: Clone & Deploy Manually
```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Install Docker
apt-get update && apt-get install -y docker.io docker-compose

# Clone and deploy
git clone https://github.com/vushakolaPhanindra/Financial_Project.git
cd Financial_Project
cp .env.example .env
nano .env  # Add API keys
docker compose up -d
```

---

## Access URLs

Once deployed:

| Service | URL | Purpose |
|---------|-----|---------|
| **Web UI** | `https://YOUR_SERVER_IP` | Streamlit dashboard |
| **API** | `https://YOUR_SERVER_IP/api` | REST endpoints |
| **API Docs** | `https://YOUR_SERVER_IP/docs` | Interactive Swagger UI |
| **API Health** | `https://YOUR_SERVER_IP/health` | Health check |

---

## Essential Docker Commands

```bash
# View status
docker compose ps

# View logs
docker compose logs -f              # All services
docker compose logs -f backend      # Only backend
docker compose logs -f frontend     # Only frontend

# Start/Stop
docker compose up -d                # Start in background
docker compose down                 # Stop all services
docker compose restart              # Restart all
docker compose restart backend      # Restart specific service

# Rebuild
docker compose build                # Build images
docker compose build --no-cache     # Force rebuild
docker compose pull                 # Pull base images

# Execute commands
docker compose exec backend bash           # Shell into backend
docker compose exec backend python main.py # Run script in backend

# Cleanup
docker system prune                 # Remove unused images/containers
docker volume prune                 # Remove unused volumes
```

---

## Troubleshooting Quick Reference

### Problem: Can't connect to `https://SERVER_IP`

**Solution:**
```bash
ssh root@YOUR_SERVER_IP

# Check containers running
docker compose ps

# Check if nginx is running
docker compose logs nginx

# Verify firewall
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443
```

### Problem: API returning 502 Bad Gateway

**Solution:**
```bash
ssh root@YOUR_SERVER_IP

# Check backend logs
docker compose logs backend

# Restart backend
docker compose restart backend

# Check if port 8000 is responsive
docker compose exec nginx curl http://backend:8000/health
```

### Problem: High memory usage

**Solution:**
```bash
ssh root@YOUR_SERVER_IP

# Check resource usage
docker stats

# If too high, edit docker-compose.yml:
# Add under each service:
#   mem_limit: 1g
#   memswap_limit: 2g

docker compose up -d
```

### Problem: Application logs show errors

**Solution:**
```bash
ssh root@YOUR_SERVER_IP
cd /opt/financial-project

# View detailed logs
docker compose logs backend 2>&1 | tail -100

# Rebuild and restart
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Problem: Out of disk space

**Solution:**
```bash
ssh root@YOUR_SERVER_IP

# Check disk usage
df -h

# Clean up Docker
docker system prune -a --volumes

# Remove old logs
sudo journalctl --vacuum=100M
```

---

## Environment Variables Quick Reference

**Critical** (must set):
```bash
OPENAI_API_KEY=sk-xxxxxxxxx
```

**Important** (should set):
```bash
ENVIRONMENT=production
DEBUG=false
ALLOWED_HOSTS=yourdomain.com,YOUR_SERVER_IP
SECRET_KEY=generate-a-strong-random-key-here
```

**Optional** (sensible defaults):
```bash
API_WORKERS=4
LOG_LEVEL=info
STREAMLIT_SERVER_HEADLESS=true
```

---

## Monitoring Checklist

Daily:
- [ ] Check application is accessible
- [ ] Verify API health endpoint responds
- [ ] Check container status: `docker compose ps`

Weekly:
- [ ] Review logs for errors
- [ ] Check disk space: `df -h`
- [ ] Verify backups completed
- [ ] Monitor performance: `docker stats`

Monthly:
- [ ] Update system packages
- [ ] Review security logs
- [ ] Test backup restoration
- [ ] Update Docker images

---

## Security Checklist

- [ ] Changed root password
- [ ] Added SSH key (disable password auth)
- [ ] Enabled firewall (ufw)
- [ ] Set up SSL certificates
- [ ] Never committed `.env` to Git
- [ ] Configured CORS properly
- [ ] Set `DEBUG=false` in production
- [ ] Enabled automatic backups
- [ ] Set up monitoring/alerting
- [ ] Rotate secrets regularly

---

## Performance Optimization

### For Small Traffic (< 100 users)
```bash
API_WORKERS=2
# Server: 2GB RAM / $6/mo
```

### For Medium Traffic (100-1000 users)
```bash
API_WORKERS=4
# Server: 4GB RAM / $12/mo
```

### For Large Traffic (1000+ users)
```bash
API_WORKERS=8
# Server: 8GB RAM / $24/mo
# Consider load balancing across multiple servers
```

---

## Cost Estimation

| Component | Cost/mo | Notes |
|-----------|---------|-------|
| **Vultr Server (4GB)** | $12 | Includes bandwidth |
| **Domain Name** | $10 | Optional |
| **OpenAI API** | Varies | Pay-as-you-go |
| **SSL Certificate** | $0 | Let's Encrypt (free) |
| **Backups** | $0 | Automated locally |
| **Monitoring** | $0-50 | Optional services |
| **TOTAL (Basic)** | ~$22 | Excluding API calls |

---

## Scaling Strategy

### Phase 1: Single Server (Current Setup)
- Single Vultr instance
- Docker Compose
- Self-hosted database (optional)

### Phase 2: Multiple Servers
- Load balancer
- Separate API and Frontend servers
- Managed database (Vultr Database)
- Redis for caching

### Phase 3: Enterprise
- Kubernetes cluster
- Auto-scaling groups
- CDN for static assets
- Advanced monitoring

---

## Useful Links

- **Vultr Console**: https://www.vultr.com/console/
- **Vultr Documentation**: https://www.vultr.com/docs/
- **Vultr API**: https://www.vultr.com/api/
- **Docker Documentation**: https://docs.docker.com/
- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **Streamlit Documentation**: https://docs.streamlit.io/
- **Let's Encrypt**: https://letsencrypt.org/

---

## Emergency Procedures

### Server is Unresponsive
```bash
# From Vultr console:
1. Click server instance
2. Click "Restart" button
3. Wait 1-2 minutes

# Or via SSH if accessible:
ssh root@YOUR_SERVER_IP
sudo reboot
```

### Need to Restore from Backup
```bash
ssh root@YOUR_SERVER_IP
cd /opt/financial-project

# Stop containers
docker compose down

# List backups
ls -lh /backups/financial-project/

# Restore
tar -xzf /backups/financial-project/data_LATEST.tar.gz

# Start containers
docker compose up -d
```

### Complete Data Loss Recovery
```bash
# 1. Deploy new server (from cloud-init)
# 2. Once ready:
ssh root@NEW_SERVER_IP

# 3. Retrieve old data if available
# From old server:
scp -r root@OLD_SERVER_IP:/opt/financial-project/data ./

# 4. Copy to new server
scp -r ./data root@NEW_SERVER_IP:/opt/financial-project/

# 5. Restart containers
ssh root@NEW_SERVER_IP
docker compose restart
```

---

## Support & Debugging

### Enable Debug Logging
```bash
ssh root@YOUR_SERVER_IP
cd /opt/financial-project
nano .env

# Change to:
DEBUG=true
LOG_LEVEL=debug

docker compose restart
docker compose logs -f
```

### Collect Diagnostic Information
```bash
ssh root@YOUR_SERVER_IP
cat > /tmp/diagnostics.sh << 'EOF'
echo "=== System Info ==="
uname -a
df -h
free -h

echo "=== Docker Info ==="
docker version
docker-compose --version

echo "=== Container Status ==="
docker compose ps

echo "=== Recent Logs (last 50 lines) ==="
docker compose logs --tail=50

echo "=== Resource Usage ==="
docker stats --no-stream
EOF

bash /tmp/diagnostics.sh
```

---

## Post-Deployment Tasks

1. **Update DNS** (if using domain)
   - Point A record to server IP
   - Wait for propagation (5-60 minutes)

2. **Get SSL Certificate**
   - For production domain: use Let's Encrypt
   - Update nginx.conf with cert paths
   - Restart nginx

3. **Configure Backups**
   - Verify cron job: `crontab -l`
   - Test manual backup: `/usr/local/bin/backup-financial-project.sh`

4. **Setup Monitoring** (optional)
   - Sentry for error tracking
   - New Relic for performance
   - Custom dashboards

5. **Document Deployment**
   - Save server IP and SSH key
   - Document any custom configurations
   - Create runbook for team

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial setup |
| 1.1 | 2024 | Added monitoring |
| 1.2 | 2024 | SSL improvements |

---

**Last Updated**: November 2024
**Maintained By**: Financial Project Team
