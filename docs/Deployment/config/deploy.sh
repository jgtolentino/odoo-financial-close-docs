#!/bin/bash
# ===========================================
# AFC Odoo + N8N Production Deployment Script
# ===========================================
#
# Usage: ./deploy.sh [--skip-pull] [--skip-backup]
#
# This script:
#   1. Validates environment
#   2. Creates required directories
#   3. Generates encryption key (if needed)
#   4. Pulls Docker images
#   5. Deploys the stack
#   6. Verifies deployment
#
# Prerequisites:
#   - Docker 24.0+
#   - Docker Compose 2.20+
#   - curl, jq
#   - .env file configured

set -e

# ===========================================
# Configuration
# ===========================================
DEPLOY_DIR="/opt/afc-n8n-deployment"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_PULL=false
SKIP_BACKUP=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-pull)
            SKIP_PULL=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ===========================================
# Functions
# ===========================================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi

    # Check Docker daemon
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi

    # Check required tools
    for cmd in curl jq openssl; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd is required but not installed"
            exit 1
        fi
    done

    log_info "All prerequisites met"
}

create_directories() {
    log_info "Creating required directories..."

    mkdir -p ${DEPLOY_DIR}/{data/postgres,data/redis,data/n8n,workflows,logs}
    chmod 755 ${DEPLOY_DIR}/data/*

    log_info "Directories created"
}

validate_env() {
    log_info "Validating environment configuration..."

    if [ ! -f "${DEPLOY_DIR}/.env" ]; then
        log_error ".env file not found at ${DEPLOY_DIR}/.env"
        log_info "Copy .env.example to .env and configure it"
        exit 1
    fi

    # Load environment
    export $(cat ${DEPLOY_DIR}/.env | grep -v '^#' | xargs)

    # Check required variables
    required_vars=(
        "POSTGRES_ROOT_PASSWORD"
        "POSTGRES_NON_ROOT_USER"
        "POSTGRES_NON_ROOT_PASSWORD"
        "N8N_ENCRYPTION_KEY"
        "REDIS_PASSWORD"
    )

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Required environment variable $var is not set"
            exit 1
        fi
    done

    # Validate password strength
    if [ ${#POSTGRES_ROOT_PASSWORD} -lt 16 ]; then
        log_warn "POSTGRES_ROOT_PASSWORD should be at least 16 characters"
    fi

    log_info "Environment validated"
}

generate_encryption_key() {
    if [ -z "${N8N_ENCRYPTION_KEY}" ] || [ "${N8N_ENCRYPTION_KEY}" = "<GENERATE_WITH_OPENSSL>" ]; then
        log_info "Generating N8N encryption key..."

        NEW_KEY=$(openssl rand -hex 16)

        # Update .env file
        sed -i "s/N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=${NEW_KEY}/" ${DEPLOY_DIR}/.env

        log_info "Encryption key generated and saved"
        log_warn "IMPORTANT: Back up your .env file - the encryption key cannot be recovered!"
    fi
}

pull_images() {
    if [ "$SKIP_PULL" = false ]; then
        log_info "Pulling Docker images..."

        docker pull postgres:16-alpine
        docker pull redis:6-alpine
        docker pull docker.n8n.io/n8nio/n8n:2.1.4

        log_info "Images pulled successfully"
    else
        log_info "Skipping image pull (--skip-pull)"
    fi
}

backup_existing() {
    if [ "$SKIP_BACKUP" = false ]; then
        if docker ps -q --filter "name=afc-n8n" | grep -q .; then
            log_info "Existing deployment detected, creating backup..."
            ${DEPLOY_DIR}/backup.sh || log_warn "Backup failed, continuing anyway"
        fi
    fi
}

deploy_stack() {
    log_info "Deploying AFC N8N stack..."

    cd ${DEPLOY_DIR}

    # Stop existing containers (if any)
    docker-compose down --remove-orphans 2>/dev/null || true

    # Create network if not exists
    docker network create afc_network 2>/dev/null || true

    # Deploy
    docker-compose up -d

    log_info "Stack deployed"
}

wait_for_healthy() {
    log_info "Waiting for services to become healthy..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        local healthy=true

        # Check each service
        for service in afc-postgres afc-redis afc-n8n; do
            status=$(docker inspect --format='{{.State.Health.Status}}' $service 2>/dev/null || echo "not_found")
            if [ "$status" != "healthy" ]; then
                healthy=false
                break
            fi
        done

        if [ "$healthy" = true ]; then
            log_info "All services are healthy"
            return 0
        fi

        echo -n "."
        sleep 5
        attempt=$((attempt + 1))
    done

    log_error "Services did not become healthy within timeout"
    docker-compose logs --tail=50
    exit 1
}

verify_deployment() {
    log_info "Verifying deployment..."

    # Check N8N API
    if curl -s http://localhost:5678/healthz | grep -q "ok"; then
        log_info "N8N API: OK"
    else
        log_error "N8N API: FAILED"
        exit 1
    fi

    # Check PostgreSQL
    if docker exec afc-postgres pg_isready -q; then
        log_info "PostgreSQL: OK"
    else
        log_error "PostgreSQL: FAILED"
        exit 1
    fi

    # Check Redis
    if docker exec afc-redis redis-cli -a ${REDIS_PASSWORD} ping 2>/dev/null | grep -q "PONG"; then
        log_info "Redis: OK"
    else
        log_error "Redis: FAILED"
        exit 1
    fi

    log_info "Deployment verified successfully"
}

setup_cron() {
    log_info "Setting up automated backups..."

    # Add backup cron job (daily at 1 AM)
    (crontab -l 2>/dev/null | grep -v "afc-n8n-deployment/backup.sh"; echo "0 1 * * * ${DEPLOY_DIR}/backup.sh >> /var/log/afc-backup.log 2>&1") | crontab -

    log_info "Backup cron job configured"
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "  AFC N8N Deployment Complete"
    echo "=========================================="
    echo ""
    echo "Access N8N:"
    echo "  URL: http://localhost:5678"
    echo "  User: ${N8N_BASIC_AUTH_USER:-admin}"
    echo ""
    echo "Container Status:"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}"
    echo ""
    echo "Next Steps:"
    echo "  1. Configure Nginx reverse proxy for HTTPS"
    echo "  2. Create admin user in N8N"
    echo "  3. Configure Odoo API credentials"
    echo "  4. Import workflow templates"
    echo ""
    echo "Useful Commands:"
    echo "  Logs:    docker-compose logs -f"
    echo "  Status:  docker-compose ps"
    echo "  Restart: docker-compose restart"
    echo "  Stop:    docker-compose down"
    echo ""
}

# ===========================================
# Main Execution
# ===========================================
echo "=========================================="
echo "  AFC Odoo + N8N Production Deployment"
echo "=========================================="
echo ""

check_prerequisites
create_directories

# Copy config files to deploy directory
if [ -f "${SCRIPT_DIR}/docker-compose.yml" ]; then
    cp ${SCRIPT_DIR}/docker-compose.yml ${DEPLOY_DIR}/
    cp ${SCRIPT_DIR}/init-db.sh ${DEPLOY_DIR}/
    cp ${SCRIPT_DIR}/backup.sh ${DEPLOY_DIR}/
    chmod +x ${DEPLOY_DIR}/*.sh
fi

validate_env
generate_encryption_key
pull_images
backup_existing
deploy_stack
wait_for_healthy
verify_deployment
setup_cron
print_summary

log_info "Deployment completed successfully!"
