# 🚀 Vultr Cloud Deployment - Complete Package

## What's Included

This package contains everything needed to deploy the Financial Project (Credit Score Intelligence) to Vultr cloud infrastructure.

### Files Created/Modified

#### 1. **Docker Configuration**
- `Dockerfile` - Multi-stage Docker build for backend, frontend, and production
- `docker-compose.yml` - Production-ready compose configuration
- `docker-compose.dev.yml` - Development overrides for local testing
- `.dockerignore` - Excludes unnecessary files from Docker builds

#### 2. **Deployment Scripts**
- `vultr-cloud-init.sh` - Automated setup via Vultr cloud-init (recommended)
- `deploy.sh` - Manual deployment script for detailed control
- `supervisord.conf` - Process management configuration

#### 3. **Web Server & Proxy**
- `nginx.conf` - Nginx reverse proxy with SSL/TLS, security headers, rate limiting

#### 4. **Configuration & Secrets**
- `.env.example` - Template for environment variables
- `SECRETS_MANAGEMENT.md` - Guide for managing secrets securely

#### 5. **Documentation**
- `VULTR_DEPLOYMENT.md` - Complete step-by-step deployment guide
- `DEPLOYMENT_CHECKLIST.md` - Pre-deployment checklist and quick reference
- `README.md` - Updated with cloud deployment instructions

#### 6. **CI/CD**
- `.github/workflows/deploy.yml` - GitHub Actions automated deployment

---

## Quick Start Guide

### Option 1: Fastest - Cloud-Init (Recommended)

1. **Create Vultr Account** → https://www.vultr.com/
2. **Click "Deploy New Server"**
3. **Select**:
   - Location: Your preferred region
   - OS: Ubuntu 22.04 LTS
   - Size: 2GB RAM ($6/mo minimum)
4. **Scroll to "User Data"** → Paste contents of `vultr-cloud-init.sh`
5. **Click "Deploy Now"**
6. **Wait 5-10 minutes** for automatic setup
7. **SSH and configure**:
   ```bash
   ssh root@YOUR_SERVER_IP
   nano /opt/financial-project/.env
   # Add: OPENAI_API_KEY=sk-your-key-here
   docker compose restart
   ```
8. **Access at**: `https://YOUR_SERVER_IP`

### Option 2: Manual Deployment

```bash
ssh root@YOUR_SERVER_IP
bash <(curl -s https://raw.githubusercontent.com/vushakolaPhanindra/Financial_Project/main/deploy.sh)
```

### Option 3: From Repository

```bash
git clone https://github.com/vushakolaPhanindra/Financial_Project.git
cd Financial_Project
cp .env.example .env
nano .env
docker compose up -d
```

---

## Architecture

```
Internet (HTTPS)
    ↓
Nginx (Port 443, SSL/TLS)
    ↓
FastAPI Backend (Port 8000) ← → Streamlit Frontend (Port 8501)
    ↓
Shared Data & Models
    ↓
Credit Score Model
```

**Benefits:**
- ✅ Automatic SSL/TLS termination
- ✅ Rate limiting and security headers
- ✅ Load balancing capable
- ✅ WebSocket support for Streamlit

---

## Key Features

### Deployment
- [x] Automated cloud-init setup
- [x] Docker containerization
- [x] Docker Compose orchestration
- [x] Nginx reverse proxy with SSL/TLS
- [x] Supervisor for process management
- [x] Systemd service for auto-restart

### Security
- [x] Self-signed SSL certificates (auto-generated)
- [x] CORS configuration
- [x] Rate limiting
- [x] Security headers (HSTS, X-Frame-Options, etc.)
- [x] Firewall setup
- [x] SSH key-based authentication

### Operations
- [x] Health checks
- [x] Automatic backups (daily at 2 AM)
- [x] Log rotation
- [x] Container status monitoring
- [x] Simple restart/stop commands

### CI/CD
- [x] GitHub Actions workflow
- [x] Automated docker build and push
- [x] Automated testing
- [x] One-command deployment

---

## Access Points

Once deployed, access your application at:

| Service | URL | Purpose |
|---------|-----|---------|
| **Web UI** | `https://YOUR_SERVER_IP` | Main Streamlit interface |
| **API** | `https://YOUR_SERVER_IP/api` | REST endpoints |
| **API Docs** | `https://YOUR_SERVER_IP/docs` | Swagger documentation |
| **Health Check** | `https://YOUR_SERVER_IP/health` | Service health status |

---

## Important Configuration

### Must Set:
```bash
OPENAI_API_KEY=sk-xxxxxxxxx  # Your OpenAI API key
```

### Should Set:
```bash
ALLOWED_HOSTS=yourdomain.com,YOUR_SERVER_IP
SECRET_KEY=generated-32-char-random-string
```

### Optional:
```bash
SENTRY_DSN=  # For error tracking
ENVIRONMENT=production
LOG_LEVEL=info
```

---

## Common Commands

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# View containers
docker compose ps

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Stop all
docker compose down

# Manual backup
/usr/local/bin/backup-financial-project.sh

# Check resources
docker stats
```

---

## Cost Estimation

| Item | Cost | Notes |
|------|------|-------|
| **Vultr Server (2GB)** | $6/mo | Includes bandwidth |
| **Vultr Server (4GB)** | $12/mo | Recommended for production |
| **Domain** | ~$10/mo | Optional |
| **OpenAI API** | Usage-based | Pay-as-you-go |
| **SSL Certificate** | $0 | Let's Encrypt (free) |
| **Total (Minimal)** | ~$16/mo | Excluding API costs |

---

## Troubleshooting

### Can't access the site?
```bash
ssh root@YOUR_SERVER_IP
docker compose ps  # Check containers running
docker compose logs nginx  # Check nginx logs
sudo ufw allow 80,443/tcp  # Check firewall
```

### API returning errors?
```bash
docker compose logs backend  # View backend logs
docker compose restart backend  # Restart backend
```

### Out of disk space?
```bash
docker system prune -a  # Clean up Docker
df -h  # Check disk usage
```

See `DEPLOYMENT_CHECKLIST.md` for more troubleshooting.

---

## Security Best Practices

✅ **Do:**
- Keep `.env` secure (never commit to Git)
- Use strong SECRET_KEY
- Enable firewall
- Use HTTPS (not HTTP)
- Rotate secrets regularly
- Monitor logs

❌ **Don't:**
- Expose OpenAI keys
- Use default passwords
- Keep debug mode enabled
- Disable SSL/TLS
- Commit secrets to repository

---

## Scaling

### When to upgrade server size:
- Current: 2GB ($6/mo) - Development/Testing
- Small: 4GB ($12/mo) - 100-500 daily users
- Medium: 8GB ($24/mo) - 500-2000 daily users
- Large: 16GB ($48/mo) - 2000+ daily users

Upgrade via Vultr console → Resize → Choose larger plan.

---

## Support Resources

- **Vultr Documentation**: https://www.vultr.com/docs/
- **Docker Docs**: https://docs.docker.com/
- **FastAPI Guide**: https://fastapi.tiangolo.com/
- **Streamlit Docs**: https://docs.streamlit.io/
- **Nginx Docs**: https://nginx.org/en/docs/

---

## Next Steps

1. **Create Vultr account** → https://www.vultr.com/
2. **Deploy server** using cloud-init script (this package)
3. **Configure** with your OpenAI API key
4. **Access** and test the application
5. **Setup SSL** with Let's Encrypt (for production domain)
6. **Monitor** performance and logs
7. **Backup** regularly

---

## Files Quick Reference

| File | Purpose | When to Edit |
|------|---------|--------------|
| `vultr-cloud-init.sh` | Auto deployment | Before deploying |
| `docker-compose.yml` | Production config | For scaling/tuning |
| `.env.example` | Config template | Before deployment |
| `nginx.conf` | Web server config | For SSL/custom domain |
| `VULTR_DEPLOYMENT.md` | Step-by-step guide | Read before deploying |
| `DEPLOYMENT_CHECKLIST.md` | Quick reference | Daily operations |

---

## Deployment Checklist

Before deploying:
- [ ] Have OpenAI API key ready
- [ ] Noted Vultr instance IP
- [ ] Generated SSH key (or will use password)
- [ ] Reviewed all configuration files
- [ ] Tested application locally
- [ ] Created `.env` file locally (don't commit!)

After deploying:
- [ ] SSH to server successful
- [ ] `.env` configured with API key
- [ ] Containers running (docker compose ps)
- [ ] Web UI accessible
- [ ] API responding
- [ ] Backups enabled
- [ ] Monitoring active

---

## Questions?

1. Check `VULTR_DEPLOYMENT.md` for detailed instructions
2. Check `DEPLOYMENT_CHECKLIST.md` for quick troubleshooting
3. Review logs: `docker compose logs -f`
4. Check GitHub Issues for common problems

---

**Version**: 1.0
**Last Updated**: November 2024
**Status**: ✅ Production Ready

Enjoy your cloud deployment! 🚀
