.PHONY: help install build up down logs restart clean test lint format seed deploy-check

help:
	@echo "Financial Project - Development Commands"
	@echo ""
	@echo "Installation & Setup:"
	@echo "  make install          Install Python dependencies"
	@echo "  make build            Build Docker images"
	@echo ""
	@echo "Running:"
	@echo "  make up               Start all services (Docker Compose)"
	@echo "  make down             Stop all services"
	@echo "  make logs             View logs from all containers"
	@echo "  make restart          Restart all services"
	@echo ""
	@echo "Development:"
	@echo "  make dev              Run with development overrides"
	@echo "  make format           Format code (black)"
	@echo "  make lint             Check code quality (flake8)"
	@echo "  make test             Run tests"
	@echo ""
	@echo "Database & Data:"
	@echo "  make seed             Create sample data"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            Remove containers and volumes"
	@echo "  make clean-all        Full cleanup including images"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-check     Verify deployment readiness"
	@echo ""

install:
	pip install --upgrade pip
	pip install -r requirements.txt
	@echo "✅ Dependencies installed successfully"

build:
	docker compose build
	@echo "✅ Docker images built successfully"

up:
	docker compose up -d
	@echo "✅ Services started"
	@echo "🌐 Web UI: http://localhost:8501"
	@echo "📚 API Docs: http://localhost:8000/docs"

down:
	docker compose down
	@echo "✅ Services stopped"

logs:
	docker compose logs -f

logs-backend:
	docker compose logs -f backend

logs-frontend:
	docker compose logs -f frontend

restart:
	docker compose restart
	@echo "✅ Services restarted"

dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up
	@echo "✅ Development environment started"

clean:
	docker compose down
	docker system prune -f
	@echo "✅ Cleaned up stopped containers"

clean-all:
	docker compose down -v
	docker system prune -a -f
	@echo "✅ Full cleanup completed"

lint:
	@echo "🔍 Running flake8..."
	flake8 src/ ui/ --max-line-length=120 --ignore=E501,W503
	@echo "✅ Linting passed"

format:
	@echo "🎨 Formatting code with black..."
	black src/ ui/ main.py
	@echo "✅ Code formatted"

test:
	@echo "🧪 Running tests..."
	python -m pytest tests/ -v
	@echo "✅ Tests completed"

seed:
	@echo "🌱 Creating sample data..."
	python main.py
	@echo "✅ Sample data created"

status:
	docker compose ps

shell-backend:
	docker compose exec backend bash

shell-frontend:
	docker compose exec frontend bash

env:
	cp .env.example .env
	@echo "✅ Created .env from template"
	@echo "⚠️  Please edit .env and add your OpenAI API key"

# Deployment checks
deploy-check:
	@echo "🔍 Checking deployment readiness..."
	@echo ""
	@echo "Checking .env file..."
	@if [ -f .env ]; then echo "✅ .env exists"; else echo "❌ .env missing"; fi
	@echo ""
	@echo "Checking Docker..."
	@docker --version || echo "❌ Docker not found"
	@docker compose --version || echo "❌ Docker Compose not found"
	@echo ""
	@echo "Checking required files..."
	@test -f vultr-cloud-init.sh && echo "✅ vultr-cloud-init.sh" || echo "❌ vultr-cloud-init.sh missing"
	@test -f Dockerfile && echo "✅ Dockerfile" || echo "❌ Dockerfile missing"
	@test -f docker-compose.yml && echo "✅ docker-compose.yml" || echo "❌ docker-compose.yml missing"
	@test -f nginx.conf && echo "✅ nginx.conf" || echo "❌ nginx.conf missing"
	@echo ""
	@echo "Checking documentation..."
	@test -f VULTR_DEPLOYMENT.md && echo "✅ VULTR_DEPLOYMENT.md" || echo "❌ VULTR_DEPLOYMENT.md missing"
	@test -f DEPLOYMENT_CHECKLIST.md && echo "✅ DEPLOYMENT_CHECKLIST.md" || echo "❌ DEPLOYMENT_CHECKLIST.md missing"
	@echo ""
	@echo "Checking data and models..."
	@test -d data && echo "✅ data/ directory" || echo "❌ data/ directory missing"
	@test -d models && echo "✅ models/ directory" || echo "❌ models/ directory missing"
	@echo ""
	@echo "✅ Deployment readiness check complete"

# Vultr deployment helpers
deploy-prepare:
	@echo "🚀 Preparing for Vultr deployment..."
	@echo "1. Ensure .env is configured"
	@echo "2. Ensure all models are trained"
	@echo "3. Run: make deploy-check"
	@echo "4. Copy vultr-cloud-init.sh content to Vultr User Data"
	@echo "5. Deploy!"

backup:
	@echo "💾 Creating manual backup..."
	ssh root@$(SERVER_IP) "/usr/local/bin/backup-financial-project.sh" || echo "⚠️  Could not create backup (check SERVER_IP)"

ssh-connect:
	@if [ -z "$(SERVER_IP)" ]; then echo "Usage: make ssh-connect SERVER_IP=1.2.3.4"; else ssh root@$(SERVER_IP); fi

# Python specific commands
python-version:
	python --version

pip-freeze:
	pip freeze > requirements-frozen.txt
	@echo "✅ Frozen requirements saved to requirements-frozen.txt"

# API testing
api-health:
	curl -s http://localhost:8000/health | python -m json.tool || echo "❌ API not responding"

api-docs:
	@echo "📚 API documentation available at: http://localhost:8000/docs"

# Monitoring
monitor:
	docker stats

# Database operations (if using PostgreSQL)
db-migrate:
	@echo "Running database migrations..."
	docker compose exec backend python -m alembic upgrade head

db-seed:
	@echo "Seeding database..."
	docker compose exec backend python scripts/seed_db.py

# Performance testing
performance-test:
	@echo "🏃 Running performance tests..."
	python -c "import requests; requests.get('http://localhost:8000/health')" && echo "✅ API responsive" || echo "❌ API not responding"

# Git operations
git-status:
	git status

git-push:
	git add -A
	git commit -m "Update: $(shell date +%Y-%m-%d)" || true
	git push origin main

# Documentation
docs-open:
	@echo "📖 Available documentation:"
	@echo "  - VULTR_DEPLOYMENT.md"
	@echo "  - DEPLOYMENT_CHECKLIST.md"
	@echo "  - SECRETS_MANAGEMENT.md"
	@echo "  - README.md"

# Version info
versions:
	@echo "📦 Component Versions:"
	@echo "Python: $$(python --version)"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker compose --version)"
	@echo "Git: $$(git --version)"

# Development server with auto-reload
dev-server:
	python -m uvicorn src.api:app --reload --host 0.0.0.0 --port 8000

# Development frontend
dev-frontend:
	streamlit run ui/app.py

# Project info
info:
	@echo "📦 Financial Project - Credit Score Intelligence"
	@echo ""
	@echo "Project Structure:"
	@echo "  src/         - Backend API code"
	@echo "  ui/          - Frontend Streamlit app"
	@echo "  data/        - Data files"
	@echo "  models/      - Trained ML models"
	@echo "  outputs/     - Generated outputs"
	@echo "  notebooks/   - Jupyter notebooks"
	@echo ""
	@echo "Key Technologies:"
	@echo "  - FastAPI (Backend API)"
	@echo "  - Streamlit (Frontend)"
	@echo "  - scikit-learn (ML Model)"
	@echo "  - SHAP (Explainability)"
	@echo "  - OpenAI GPT (Rationale Generation)"
	@echo ""
	@echo "Documentation: https://github.com/vushakolaPhanindra/Financial_Project"
