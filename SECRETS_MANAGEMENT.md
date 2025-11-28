# Vultr Deployment Configuration Secrets

This file contains templates for secrets management in production.

## GitHub Secrets Setup

For CI/CD deployment via GitHub Actions, add these secrets to your GitHub repository:

### 1. Go to Repository Settings
- Navigate to: Settings → Secrets and variables → Actions

### 2. Add Secrets

**`VULTR_SSH_KEY`**
- Your private SSH key for Vultr server
- Generate: `ssh-keygen -t ed25519 -f vultr_key`
- Content: Full private key (with `-----BEGIN OPENSSH PRIVATE KEY-----`)

**`VULTR_SERVER_IP`**
- Your Vultr server IP address
- Example: `123.45.67.89`

**`VULTR_SERVER_USER`**
- SSH user (usually `root`)
- Example: `root`

**`SLACK_WEBHOOK_URL`** (Optional)
- For deployment notifications
- Get from: Slack Workspace Settings → Apps & integrations → Webhooks

### 3. Example GitHub Actions Setup

```yaml
# In your workflow file
env:
  VULTR_SSH_KEY: ${{ secrets.VULTR_SSH_KEY }}
  VULTR_SERVER_IP: ${{ secrets.VULTR_SERVER_IP }}
  VULTR_SERVER_USER: ${{ secrets.VULTR_SERVER_USER }}
```

## Production .env Template

Use this template for your production `.env` file:

```bash
# ===========================================
# OPENAI CONFIGURATION (REQUIRED)
# ===========================================
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# ===========================================
# ENVIRONMENT & DEBUG
# ===========================================
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=info

# ===========================================
# SERVER CONFIGURATION
# ===========================================
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
API_TIMEOUT=60

# ===========================================
# SECURITY
# ===========================================
SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-min-32-chars
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,YOUR_SERVER_IP
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# ===========================================
# STREAMLIT
# ===========================================
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0
STREAMLIT_SERVER_HEADLESS=true
STREAMLIT_LOGGER_LEVEL=info
STREAMLIT_CLIENT_TOOLBAR_MODE=viewer

# ===========================================
# PATHS
# ===========================================
MODEL_PATH=/app/models/credit_model.pkl
DATA_PATH=/app/data/processed_credit.csv

# ===========================================
# MONITORING & ERROR TRACKING
# ===========================================
SENTRY_DSN=https://xxxxxxxx@xxxxx.ingest.sentry.io/xxxxxx
NEW_RELIC_LICENSE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# ===========================================
# EMAIL CONFIGURATION
# ===========================================
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=xxxx-xxxx-xxxx-xxxx
ALERT_EMAIL=admin@yourdomain.com

# ===========================================
# LLM CONFIGURATION
# ===========================================
LLM_TEMPERATURE=0.7
LLM_MAX_TOKENS=500
LLM_MODEL=gpt-3.5-turbo
```

## How to Generate Secure Values

### Generate SECRET_KEY

```bash
# Option 1: Using OpenSSL
openssl rand -hex 32

# Option 2: Using Python
python3 -c "import secrets; print(secrets.token_hex(32))"

# Option 3: Using urandom
python3 -c "import os; print(os.urandom(32).hex())"
```

### Generate Strong Passwords

```bash
# Option 1: OpenSSL
openssl rand -base64 32

# Option 2: Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Securing Secrets in Git

### Never Commit Secrets!

```bash
# Add .env to .gitignore (already done)
echo ".env" >> .gitignore

# Remove if accidentally committed
git rm --cached .env
git commit -m "Remove .env file"
git push
```

### Use git-secrets to Prevent Accidental Commits

```bash
# Install
brew install git-secrets  # macOS
# or
apt-get install git-secrets  # Linux

# Setup in repository
git secrets --install
git secrets --register-aws

# Scan history
git secrets --scan
```

## Environment-Specific Configurations

### Development (.env.dev)
```bash
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Staging (.env.staging)
```bash
ENVIRONMENT=staging
DEBUG=false
LOG_LEVEL=info
ALLOWED_HOSTS=staging.yourdomain.com
```

### Production (.env.prod)
```bash
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=warning
ALLOWED_HOSTS=yourdomain.com
```

## Rotating Secrets

### Monthly Secret Rotation Checklist

1. **Generate new values**
   ```bash
   openssl rand -hex 32  # New SECRET_KEY
   ```

2. **Update in production**
   ```bash
   ssh root@YOUR_SERVER_IP
   cd /opt/financial-project
   nano .env
   # Update values
   docker compose restart
   ```

3. **Update in GitHub Secrets**
   - Repository Settings → Secrets
   - Update secret values

4. **Document in password manager**
   - Update secure password storage
   - Share with authorized team members only

5. **Monitor logs for issues**
   ```bash
   docker compose logs -f backend
   ```

## Backup Secrets

Store backups of:
- SSH keys (encrypted)
- API keys (encrypted)
- Database passwords (encrypted)

In a secure location such as:
- 1Password
- LastPass
- KeePass
- HashiCorp Vault (for enterprise)

## API Keys Reference

### OpenAI API Key

1. Go to: https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Name it: "Financial-Project-Prod"
4. Copy and save securely

### Sentry (Error Tracking)

1. Go to: https://sentry.io/
2. Create project for "Python / FastAPI"
3. Copy DSN: `https://key@project.ingest.sentry.io/id`

### New Relic (Monitoring)

1. Go to: https://one.newrelic.com/
2. Get License Key from account settings
3. Format: 40-character hex string

### Slack Webhook

1. Go to: https://api.slack.com/messaging/webhooks
2. Create New App
3. Enable Incoming Webhooks
4. Add New Webhook to Workspace
5. Copy Webhook URL

## Docker Secrets (Advanced)

For multi-container deployments:

```bash
# Create secret
echo "your-secret-value" | docker secret create api_key -

# Use in docker-compose.yml
secrets:
  api_key:
    external: true
```

## Vault Integration (Enterprise)

For large deployments, consider HashiCorp Vault:

```bash
# Install Vault
# Configure as secret backend
# Integrate with Docker Compose

# Example:
vault kv get secret/financial-project/prod
```

## Compliance & Audit

- [ ] All secrets encrypted at rest
- [ ] All secrets encrypted in transit (HTTPS/SSH)
- [ ] Secrets rotated every 90 days
- [ ] Access logged and audited
- [ ] MFA enabled on all accounts
- [ ] Secret access monitored
- [ ] Regular security audits performed

---

**Important**: Keep this file secure and never share secrets!
