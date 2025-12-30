# Odoo Security Hardening Guide

## Overview

This guide provides production-grade security best practices for Odoo CE/Enterprise deployments. Covers access control, configuration hardening, TLS, SQL injection prevention, and operational security.

## Quick Reference (Top 5)

| Priority | Control | Implementation |
|----------|---------|----------------|
| 1 | ACLs + Record Rules | Every model: least-privilege access |
| 2 | Config Hardening | `list_db=False`, `dbfilter`, `proxy_mode=True` |
| 3 | TLS + Headers | Nginx with security headers + rate limits |
| 4 | Input Validation | Parameterized SQL + HTML sanitization |
| 5 | Backups + Audit | DB + filestore backups, centralized logging |

---

## 1. Access Control (ACLs + Record Rules)

### Principles

- **Every model**: Define least-privilege ACLs (`ir.model.access`)
- **Sensitive data**: Add record rules (`ir.rule`) scoped by company/branch/team
- **Avoid `sudo()`**: If unavoidable, scope tightly and document rationale

### ACL Configuration

```csv
# security/ir.model.access.csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_afc_task_user,afc.task user,model_afc_closing_task,base.group_user,1,1,1,0
access_afc_task_manager,afc.task manager,model_afc_closing_task,account.group_account_manager,1,1,1,1
```

### Record Rules

```xml
<!-- security/security.xml -->
<record id="rule_task_company" model="ir.rule">
    <field name="name">AFC Task: Company Scope</field>
    <field name="model_id" ref="model_afc_closing_task"/>
    <field name="domain_force">[('company_id', 'in', company_ids)]</field>
    <field name="groups" eval="[(4, ref('base.group_user'))]"/>
</record>

<record id="rule_task_own_department" model="ir.rule">
    <field name="name">AFC Task: Own Department Only</field>
    <field name="model_id" ref="model_afc_closing_task"/>
    <field name="domain_force">[('department_id', '=', user.department_id.id)]</field>
    <field name="groups" eval="[(4, ref('base.group_user'))]"/>
</record>
```

---

## 2. Odoo Configuration Hardening

### Production odoo.conf

```ini
; /etc/odoo/odoo.conf
[options]
; === SECURITY ===
proxy_mode = True
list_db = False
dbfilter = ^YOURDBNAME$        ; or ^%d$ for subdomain-mapped dbs
admin_passwd = CHANGE_ME_LONG_RANDOM_64CHAR

; === NETWORK BINDING ===
; Bind to localhost only - expose via reverse proxy
xmlrpc_interface = 127.0.0.1
netrpc_interface = 127.0.0.1
xmlrpc_port = 8069
longpolling_port = 8072

; === RESOURCE LIMITS ===
limit_time_cpu = 60
limit_time_real = 120
limit_time_real_cron = 3600
limit_memory_hard = 2684354560    ; 2.5GB
limit_memory_soft = 2147483648    ; 2GB
limit_request = 8192

; === WORKERS ===
workers = 4
max_cron_threads = 1

; === LOGGING ===
log_level = info
log_handler = :INFO
logfile = /var/log/odoo/odoo.log
logrotate = True

; === ADDONS ===
; Keep addons controlled - no external paths
addons_path = /opt/odoo/odoo/addons,/opt/odoo/custom-addons

; === DATABASE ===
db_host = 127.0.0.1
db_port = 5432
db_user = odoo_user
db_password = ${ODOO_DB_PASSWORD}
db_name = odoo
db_sslmode = require

; === SESSION ===
; Force server-side session storage
server_wide_modules = base,web
```

### Configuration Checklist

| Setting | Value | Purpose |
|---------|-------|---------|
| `proxy_mode` | `True` | Trust X-Forwarded headers from proxy |
| `list_db` | `False` | Hide database selector |
| `dbfilter` | `^YOURDB$` | Restrict to single database |
| `xmlrpc_interface` | `127.0.0.1` | Bind to localhost only |
| `admin_passwd` | 64+ chars | Strong master password |
| `workers` | 2-8 | Based on CPU cores |

---

## 3. Reverse Proxy with TLS + Security Headers

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/odoo.conf

# Rate limiting zones
limit_req_zone $binary_remote_addr zone=odoo_login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=odoo_api:10m rate=30r/s;
limit_req_zone $binary_remote_addr zone=odoo_general:10m rate=10r/s;

# Connection limiting
limit_conn_zone $binary_remote_addr zone=odoo_conn:10m;

# Upstream
upstream odoo {
    server 127.0.0.1:8069;
    keepalive 32;
}

upstream odoo-longpolling {
    server 127.0.0.1:8072;
}

# HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name erp.example.com;
    return 301 https://$server_name$request_uri;
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name erp.example.com;

    # === TLS Configuration ===
    ssl_certificate /etc/letsencrypt/live/erp.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/erp.example.com/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # Modern TLS only
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;

    # === Security Headers ===
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=()" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self';" always;

    # === Upload Limits ===
    client_max_body_size 25m;
    client_body_buffer_size 128k;

    # === Connection Limits ===
    limit_conn odoo_conn 20;

    # === Gzip Compression ===
    gzip on;
    gzip_types text/css text/plain text/xml application/xml application/javascript application/json;
    gzip_min_length 1000;

    # === Proxy Settings ===
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;
    proxy_read_timeout 720s;

    # === Login Rate Limiting ===
    location /web/login {
        limit_req zone=odoo_login burst=5 nodelay;
        proxy_pass http://odoo;
    }

    # === API Rate Limiting ===
    location /api/ {
        limit_req zone=odoo_api burst=50 nodelay;
        proxy_pass http://odoo;
    }

    location /xmlrpc/ {
        limit_req zone=odoo_api burst=50 nodelay;
        proxy_pass http://odoo;
    }

    location /jsonrpc {
        limit_req zone=odoo_api burst=50 nodelay;
        proxy_pass http://odoo;
    }

    # === Longpolling ===
    location /longpolling {
        proxy_pass http://odoo-longpolling;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # === Static Files (Cached) ===
    location ~* /web/static/ {
        proxy_pass http://odoo;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # === Block Sensitive Paths ===
    location ~ ^/(web/database|jsonrpc.*database) {
        deny all;
        return 404;
    }

    # === General Traffic ===
    location / {
        limit_req zone=odoo_general burst=30 nodelay;
        proxy_pass http://odoo;
        proxy_redirect off;
    }

    # === Health Check (Internal) ===
    location /health {
        access_log off;
        proxy_pass http://odoo/web/health;
    }
}
```

### Security Headers Reference

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Force HTTPS |
| `X-Frame-Options` | `SAMEORIGIN` | Prevent clickjacking |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Control referrer leakage |
| `Permissions-Policy` | `geolocation=(), camera=()` | Disable unused APIs |
| `Content-Security-Policy` | See above | XSS protection |

---

## 4. SQL Injection Prevention

### Parameterized Queries (Required)

```python
# CORRECT - Parameterized query
def search_partner_by_email(self, email):
    self.env.cr.execute(
        "SELECT id FROM res_partner WHERE email = %s",
        (email,)
    )
    return self.env.cr.fetchall()

# CORRECT - Using ORM (preferred)
def search_partner_by_email_orm(self, email):
    return self.env['res.partner'].search([('email', '=', email)])
```

### Anti-Patterns (Never Do This)

```python
# WRONG - String formatting (SQL injection vulnerable)
def search_partner_bad(self, email):
    self.env.cr.execute(
        f"SELECT id FROM res_partner WHERE email = '{email}'"  # VULNERABLE!
    )

# WRONG - String concatenation
def search_partner_also_bad(self, email):
    query = "SELECT id FROM res_partner WHERE email = '" + email + "'"  # VULNERABLE!
    self.env.cr.execute(query)

# WRONG - % formatting
def search_partner_still_bad(self, email):
    self.env.cr.execute(
        "SELECT id FROM res_partner WHERE email = '%s'" % email  # VULNERABLE!
    )
```

### ORM Security Methods

```python
# Use ORM methods - they handle escaping automatically
partners = self.env['res.partner'].search([
    ('email', '=', user_input),      # Safe
    ('name', 'ilike', search_term),  # Safe
])

# For complex queries, use _where_calc with proper escaping
query = self.env['res.partner']._where_calc([('active', '=', True)])
query.add_where("email = %s", [email])  # Safe - parameterized
```

---

## 5. XSS Prevention

### HTML Sanitization

```python
from odoo.tools import html_sanitize

class MyModel(models.Model):
    _name = 'my.model'

    # Sanitize user HTML input
    @api.constrains('description')
    def _check_description(self):
        for record in self:
            if record.description:
                # Sanitize HTML content
                record.description = html_sanitize(record.description)

    # Safe rendering in compute
    def _compute_display_html(self):
        for record in self:
            record.display_html = html_sanitize(
                record.raw_content,
                strip_style=True,
                strip_classes=True
            )
```

### QWeb Template Security

```xml
<!-- SAFE - Automatic escaping (default) -->
<span t-esc="record.user_input"/>

<!-- SAFE - Explicit escaping -->
<span t-out="record.user_input"/>

<!-- DANGEROUS - Only for pre-sanitized HTML -->
<span t-raw="record.sanitized_html"/>

<!-- SAFE - Use t-raw only with html_sanitize -->
<span t-raw="html_sanitize(record.description)"/>
```

---

## 6. Controller Security

### Authentication Requirements

```python
from odoo import http
from odoo.http import request

class AFCController(http.Controller):

    # Require authentication (default for most routes)
    @http.route('/afc/tasks', type='json', auth='user', methods=['GET'])
    def get_tasks(self):
        return request.env['afc.closing_task'].search_read([])

    # Public route (use sparingly)
    @http.route('/afc/public/status', type='http', auth='public', methods=['GET'])
    def public_status(self):
        # Never expose sensitive data in public routes
        return "OK"

    # CSRF protection (enabled by default for form routes)
    @http.route('/afc/submit', type='http', auth='user', methods=['POST'], csrf=True)
    def submit_form(self, **post):
        # Validate all inputs
        task_id = int(post.get('task_id', 0))
        if task_id <= 0:
            raise ValueError("Invalid task_id")
        # Process...
```

### Input Validation

```python
from odoo.exceptions import ValidationError

class AFCController(http.Controller):

    @http.route('/afc/api/task', type='json', auth='user')
    def api_task(self, task_id, status, amount=None):
        # Type validation
        if not isinstance(task_id, int) or task_id <= 0:
            raise ValidationError("Invalid task_id")

        # Enum validation
        valid_statuses = ['draft', 'in_progress', 'completed', 'approved']
        if status not in valid_statuses:
            raise ValidationError(f"Invalid status. Must be one of: {valid_statuses}")

        # Bounds validation
        if amount is not None:
            if not isinstance(amount, (int, float)) or amount < 0:
                raise ValidationError("Amount must be a positive number")
            if amount > 10000000:  # Business rule: max 10M
                raise ValidationError("Amount exceeds maximum allowed")

        # Proceed with validated data
        task = request.env['afc.closing_task'].browse(task_id)
        if not task.exists():
            raise ValidationError("Task not found")

        return task.write({'status': status, 'amount': amount})
```

---

## 7. Attachment Security

### Upload Controls

```python
import magic
from odoo.exceptions import ValidationError

ALLOWED_MIME_TYPES = {
    'application/pdf',
    'image/png',
    'image/jpeg',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
}

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

class AFCAttachment(models.Model):
    _inherit = 'ir.attachment'

    @api.constrains('datas', 'mimetype')
    def _check_attachment_security(self):
        for attachment in self:
            if not attachment.datas:
                continue

            # Size check
            if len(attachment.datas) > MAX_FILE_SIZE:
                raise ValidationError(f"File size exceeds {MAX_FILE_SIZE // 1024 // 1024}MB limit")

            # MIME type validation (use python-magic for accuracy)
            detected_mime = magic.from_buffer(
                base64.b64decode(attachment.datas),
                mime=True
            )
            if detected_mime not in ALLOWED_MIME_TYPES:
                raise ValidationError(f"File type '{detected_mime}' not allowed")
```

### Attachment Access Control

```xml
<!-- Restrict attachment access by model -->
<record id="rule_attachment_afc_task" model="ir.rule">
    <field name="name">AFC Attachments: Task Owners Only</field>
    <field name="model_id" ref="base.model_ir_attachment"/>
    <field name="domain_force">[
        '|',
        ('res_model', '!=', 'afc.closing_task'),
        '&amp;',
        ('res_model', '=', 'afc.closing_task'),
        ('res_id', 'in', user.afc_task_ids.ids)
    ]</field>
</record>
```

---

## 8. Identity & Authentication

### Password Policy

```python
# In a custom module: models/res_users.py
from odoo import models, api
from odoo.exceptions import ValidationError
import re

class ResUsers(models.Model):
    _inherit = 'res.users'

    @api.constrains('password')
    def _check_password_policy(self):
        for user in self:
            password = user.password
            if len(password) < 12:
                raise ValidationError("Password must be at least 12 characters")
            if not re.search(r'[A-Z]', password):
                raise ValidationError("Password must contain uppercase letter")
            if not re.search(r'[a-z]', password):
                raise ValidationError("Password must contain lowercase letter")
            if not re.search(r'\d', password):
                raise ValidationError("Password must contain a digit")
            if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
                raise ValidationError("Password must contain special character")
```

### SSO/OAuth2 Configuration

```xml
<!-- data/auth_oauth_data.xml -->
<record id="provider_azure_ad" model="auth.oauth.provider">
    <field name="name">Azure AD SSO</field>
    <field name="client_id">YOUR_CLIENT_ID</field>
    <field name="auth_endpoint">https://login.microsoftonline.com/TENANT/oauth2/v2.0/authorize</field>
    <field name="token_endpoint">https://login.microsoftonline.com/TENANT/oauth2/v2.0/token</field>
    <field name="scope">openid email profile</field>
    <field name="enabled">True</field>
</record>
```

---

## 9. PostgreSQL Hardening

### pg_hba.conf

```conf
# /etc/postgresql/16/main/pg_hba.conf

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Local connections (odoo on same server)
local   all             postgres                                peer
local   odoo            odoo_user                               scram-sha-256

# Odoo application (localhost only)
host    odoo            odoo_user       127.0.0.1/32            scram-sha-256

# Reject everything else
host    all             all             0.0.0.0/0               reject
host    all             all             ::/0                    reject
```

### postgresql.conf Security

```conf
# /etc/postgresql/16/main/postgresql.conf

# Network binding (localhost only)
listen_addresses = '127.0.0.1'
port = 5432

# SSL (if remote connections needed)
ssl = on
ssl_cert_file = '/etc/ssl/certs/postgres.crt'
ssl_key_file = '/etc/ssl/private/postgres.key'
ssl_min_protocol_version = 'TLSv1.2'

# Logging
log_connections = on
log_disconnections = on
log_statement = 'ddl'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '

# Connection limits
max_connections = 200
```

### Least-Privilege DB User

```sql
-- Create dedicated Odoo user (not superuser)
CREATE USER odoo_user WITH PASSWORD 'STRONG_PASSWORD_HERE';

-- Create database owned by odoo_user
CREATE DATABASE odoo OWNER odoo_user;

-- Grant minimal permissions
GRANT CONNECT ON DATABASE odoo TO odoo_user;
GRANT USAGE ON SCHEMA public TO odoo_user;
GRANT CREATE ON SCHEMA public TO odoo_user;

-- No superuser privileges
ALTER USER odoo_user NOSUPERUSER NOCREATEDB NOCREATEROLE;
```

---

## 10. Secrets Management

### Environment Variables

```bash
# /etc/odoo/odoo.env (chmod 600, owned by odoo user)
ODOO_DB_PASSWORD=your-strong-db-password
ODOO_ADMIN_PASSWD=your-64-char-master-password
SMTP_PASSWORD=your-smtp-password
ANTHROPIC_API_KEY=sk-ant-api03-xxx
```

### Systemd Integration

```ini
# /etc/systemd/system/odoo.service
[Unit]
Description=Odoo
After=postgresql.service

[Service]
Type=simple
User=odoo
Group=odoo
EnvironmentFile=/etc/odoo/odoo.env
ExecStart=/opt/odoo/venv/bin/python /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf
Restart=always
RestartSec=5

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/odoo /var/log/odoo

[Install]
WantedBy=multi-user.target
```

---

## 11. Audit Logging

### Critical Model Auditing

```python
# Using OCA auditlog module
from odoo import models, api

class AFCClosingTask(models.Model):
    _name = 'afc.closing_task'
    _inherit = ['afc.closing_task', 'mail.thread', 'mail.activity.mixin']

    # Track all field changes
    state = fields.Selection(tracking=True)
    assigned_user_id = fields.Many2one(tracking=True)
    amount = fields.Monetary(tracking=True)

    # Log state transitions
    def write(self, vals):
        for record in self:
            if 'state' in vals:
                record.message_post(
                    body=f"State changed: {record.state} → {vals['state']}",
                    message_type='notification'
                )
        return super().write(vals)
```

### Centralized Log Shipping

```yaml
# /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/odoo/*.log
    fields:
      app: odoo
      env: production

output.elasticsearch:
  hosts: ["https://elasticsearch:9200"]
  username: "filebeat"
  password: "${FILEBEAT_PASSWORD}"
```

### Alert Rules

```yaml
# Prometheus alerting rules
groups:
  - name: odoo-security
    rules:
      - alert: OdooLoginFailures
        expr: rate(odoo_login_failures_total[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High login failure rate detected"

      - alert: OdooAdminAction
        expr: increase(odoo_admin_actions_total[1m]) > 0
        labels:
          severity: info
        annotations:
          summary: "Admin action performed"

      - alert: OdooModuleInstall
        expr: increase(odoo_module_installs_total[5m]) > 0
        labels:
          severity: warning
        annotations:
          summary: "Module installed/uninstalled"
```

---

## 12. Backup & Recovery

### Automated Backup Script

```bash
#!/bin/bash
# /opt/scripts/backup-odoo.sh

set -euo pipefail

# Configuration
DB_NAME="odoo"
DB_USER="odoo_user"
BACKUP_DIR="/backups/odoo"
FILESTORE_PATH="/var/lib/odoo/.local/share/Odoo/filestore/${DB_NAME}"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Database backup (custom format for parallel restore)
pg_dump -Fc -U "${DB_USER}" -d "${DB_NAME}" \
    > "${BACKUP_DIR}/${DB_NAME}_${DATE}.dump"

# Filestore backup
tar -czf "${BACKUP_DIR}/filestore_${DATE}.tgz" \
    -C "$(dirname ${FILESTORE_PATH})" \
    "$(basename ${FILESTORE_PATH})"

# Create checksum
sha256sum "${BACKUP_DIR}/${DB_NAME}_${DATE}.dump" \
    "${BACKUP_DIR}/filestore_${DATE}.tgz" \
    > "${BACKUP_DIR}/checksums_${DATE}.sha256"

# Cleanup old backups
find "${BACKUP_DIR}" -name "*.dump" -mtime +${RETENTION_DAYS} -delete
find "${BACKUP_DIR}" -name "*.tgz" -mtime +${RETENTION_DAYS} -delete
find "${BACKUP_DIR}" -name "*.sha256" -mtime +${RETENTION_DAYS} -delete

# Upload to S3 (optional)
# aws s3 sync "${BACKUP_DIR}" "s3://your-bucket/odoo-backups/"

echo "Backup completed: ${DATE}"
```

### Restore Procedure

```bash
#!/bin/bash
# /opt/scripts/restore-odoo.sh

set -euo pipefail

BACKUP_DATE="$1"
DB_NAME="odoo"
DB_USER="odoo_user"
BACKUP_DIR="/backups/odoo"
FILESTORE_PATH="/var/lib/odoo/.local/share/Odoo/filestore"

# Verify checksums
cd "${BACKUP_DIR}"
sha256sum -c "checksums_${BACKUP_DATE}.sha256"

# Stop Odoo
systemctl stop odoo

# Restore database
dropdb --if-exists -U postgres "${DB_NAME}"
createdb -U postgres -O "${DB_USER}" "${DB_NAME}"
pg_restore -U postgres -d "${DB_NAME}" "${BACKUP_DIR}/${DB_NAME}_${BACKUP_DATE}.dump"

# Restore filestore
rm -rf "${FILESTORE_PATH}/${DB_NAME}"
tar -xzf "${BACKUP_DIR}/filestore_${BACKUP_DATE}.tgz" -C "${FILESTORE_PATH}"
chown -R odoo:odoo "${FILESTORE_PATH}/${DB_NAME}"

# Start Odoo
systemctl start odoo

echo "Restore completed from: ${BACKUP_DATE}"
```

### Backup Cron

```cron
# /etc/cron.d/odoo-backup
0 2 * * * odoo /opt/scripts/backup-odoo.sh >> /var/log/odoo/backup.log 2>&1
```

---

## 13. Dependency Security

### Python Audit

```bash
# Install pip-audit
pip install pip-audit

# Scan for vulnerabilities
pip-audit -r /opt/odoo/requirements.txt

# Generate SBOM
pip-audit --format=json -o sbom.json
```

### Addon Hygiene

```bash
# List installed addons
./odoo-bin shell -d odoo -c /etc/odoo/odoo.conf <<EOF
for addon in env['ir.module.module'].search([('state', '=', 'installed')]):
    print(f"{addon.name}: {addon.installed_version}")
EOF

# Remove unused addons from path
# Only include necessary addon directories in addons_path
```

---

## Security Checklist

### Pre-Deployment

- [ ] `list_db = False` in odoo.conf
- [ ] `dbfilter` set to specific database
- [ ] `proxy_mode = True` enabled
- [ ] `admin_passwd` is 64+ random characters
- [ ] Odoo bound to `127.0.0.1` only
- [ ] Workers configured for server capacity
- [ ] Resource limits set appropriately

### Network Security

- [ ] TLS 1.2+ only at reverse proxy
- [ ] HSTS header enabled
- [ ] Security headers configured
- [ ] Rate limiting on login/API endpoints
- [ ] Database manager routes blocked
- [ ] Health check endpoint internal only

### Application Security

- [ ] ACLs defined for all custom models
- [ ] Record rules scope data by company/user
- [ ] All SQL queries parameterized
- [ ] HTML input sanitized
- [ ] Controllers use `auth='user'` by default
- [ ] CSRF protection enabled
- [ ] Attachments validated (size, MIME type)

### Database Security

- [ ] PostgreSQL bound to localhost
- [ ] Dedicated Odoo user (non-superuser)
- [ ] pg_hba.conf restricts connections
- [ ] SSL enabled if remote connections needed

### Operations

- [ ] Automated daily backups
- [ ] Restore tested monthly
- [ ] Audit logging enabled
- [ ] Logs shipped to central system
- [ ] Alerts configured for security events
- [ ] Dependencies scanned for vulnerabilities
- [ ] Secrets in environment variables (not code)
