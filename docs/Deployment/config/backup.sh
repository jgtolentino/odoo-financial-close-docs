#!/bin/bash
# ===========================================
# AFC N8N Automated Backup Script
# ===========================================
#
# Usage: ./backup.sh [--upload-s3]
#
# Features:
#   - PostgreSQL database backup
#   - Redis RDB backup
#   - N8N data volume backup
#   - Optional S3 upload
#   - Automatic cleanup (30-day retention)
#
# Cron setup (daily 1 AM):
#   0 1 * * * /opt/afc-n8n-deployment/backup.sh >> /var/log/afc-backup.log 2>&1

set -e

# ===========================================
# Configuration
# ===========================================
BACKUP_DIR="${BACKUP_DIR:-/opt/backups/afc-n8n}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
DATE=$(date +%Y%m%d_%H%M%S)
UPLOAD_S3=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --upload-s3)
            UPLOAD_S3=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Load environment variables
if [ -f /opt/afc-n8n-deployment/.env ]; then
    export $(cat /opt/afc-n8n-deployment/.env | grep -v '^#' | xargs)
fi

# ===========================================
# Functions
# ===========================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_disk_space() {
    local required_mb=5000
    local available_mb=$(df -m ${BACKUP_DIR} | tail -1 | awk '{print $4}')

    if [ ${available_mb} -lt ${required_mb} ]; then
        log "ERROR: Insufficient disk space. Available: ${available_mb}MB, Required: ${required_mb}MB"
        exit 1
    fi
}

backup_postgres() {
    log "Starting PostgreSQL backup..."

    docker exec afc-postgres pg_dump \
        -U ${POSTGRES_USER:-postgres} \
        -d ${POSTGRES_DB:-n8n_production} \
        --format=custom \
        --compress=9 \
        > ${BACKUP_DIR}/postgres_${DATE}.dump

    # Also create SQL backup for portability
    docker exec afc-postgres pg_dump \
        -U ${POSTGRES_USER:-postgres} \
        -d ${POSTGRES_DB:-n8n_production} \
        | gzip > ${BACKUP_DIR}/postgres_${DATE}.sql.gz

    log "PostgreSQL backup completed: postgres_${DATE}.dump"
}

backup_redis() {
    log "Starting Redis backup..."

    # Trigger background save
    docker exec afc-redis redis-cli -a ${REDIS_PASSWORD} BGSAVE

    # Wait for save to complete
    sleep 5

    # Copy RDB file
    docker cp afc-redis:/data/dump.rdb ${BACKUP_DIR}/redis_${DATE}.rdb

    log "Redis backup completed: redis_${DATE}.rdb"
}

backup_n8n_data() {
    log "Starting N8N data backup..."

    # Backup N8N data volume
    docker run --rm \
        -v afc-n8n-deployment_n8n_data:/data:ro \
        -v ${BACKUP_DIR}:/backup \
        alpine tar czf /backup/n8n_data_${DATE}.tar.gz -C /data .

    log "N8N data backup completed: n8n_data_${DATE}.tar.gz"
}

backup_workflows() {
    log "Exporting N8N workflows..."

    # Export all workflows via API
    curl -s -u ${N8N_BASIC_AUTH_USER}:${N8N_BASIC_AUTH_PASSWORD} \
        http://localhost:5678/api/v1/workflows \
        | jq '.data' > ${BACKUP_DIR}/workflows_${DATE}.json

    log "Workflows exported: workflows_${DATE}.json"
}

upload_to_s3() {
    if [ "$UPLOAD_S3" = true ] && [ -n "$BACKUP_S3_BUCKET" ]; then
        log "Uploading backups to S3..."

        aws s3 sync ${BACKUP_DIR}/ s3://${BACKUP_S3_BUCKET}/afc-n8n-backups/${DATE}/ \
            --exclude "*" \
            --include "*_${DATE}*"

        log "S3 upload completed"
    fi
}

cleanup_old_backups() {
    log "Cleaning up backups older than ${RETENTION_DAYS} days..."

    find ${BACKUP_DIR} -type f -mtime +${RETENTION_DAYS} -delete

    log "Cleanup completed"
}

verify_backups() {
    log "Verifying backups..."

    local errors=0

    # Check PostgreSQL backup
    if [ ! -f "${BACKUP_DIR}/postgres_${DATE}.dump" ]; then
        log "ERROR: PostgreSQL backup missing"
        errors=$((errors + 1))
    fi

    # Check Redis backup
    if [ ! -f "${BACKUP_DIR}/redis_${DATE}.rdb" ]; then
        log "ERROR: Redis backup missing"
        errors=$((errors + 1))
    fi

    # Check N8N data backup
    if [ ! -f "${BACKUP_DIR}/n8n_data_${DATE}.tar.gz" ]; then
        log "ERROR: N8N data backup missing"
        errors=$((errors + 1))
    fi

    if [ $errors -eq 0 ]; then
        log "All backups verified successfully"
    else
        log "WARNING: ${errors} backup(s) failed verification"
        exit 1
    fi
}

create_manifest() {
    log "Creating backup manifest..."

    cat > ${BACKUP_DIR}/manifest_${DATE}.json << EOF
{
    "backup_date": "${DATE}",
    "backup_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "components": {
        "postgres": "postgres_${DATE}.dump",
        "postgres_sql": "postgres_${DATE}.sql.gz",
        "redis": "redis_${DATE}.rdb",
        "n8n_data": "n8n_data_${DATE}.tar.gz",
        "workflows": "workflows_${DATE}.json"
    },
    "sizes": {
        "postgres": "$(du -h ${BACKUP_DIR}/postgres_${DATE}.dump | cut -f1)",
        "redis": "$(du -h ${BACKUP_DIR}/redis_${DATE}.rdb | cut -f1)",
        "n8n_data": "$(du -h ${BACKUP_DIR}/n8n_data_${DATE}.tar.gz | cut -f1)"
    },
    "retention_days": ${RETENTION_DAYS}
}
EOF

    log "Manifest created: manifest_${DATE}.json"
}

# ===========================================
# Main Execution
# ===========================================
log "=== AFC N8N Backup Started ==="

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Pre-flight checks
check_disk_space

# Run backups
backup_postgres
backup_redis
backup_n8n_data
backup_workflows

# Create manifest
create_manifest

# Verify backups
verify_backups

# Upload to S3 (if enabled)
upload_to_s3

# Cleanup old backups
cleanup_old_backups

log "=== AFC N8N Backup Completed Successfully ==="

# Calculate total backup size
TOTAL_SIZE=$(du -sh ${BACKUP_DIR}/*_${DATE}* | awk '{sum += $1} END {print sum}')
log "Total backup size: ${TOTAL_SIZE}"
