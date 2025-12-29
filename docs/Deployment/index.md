# Deployment

This section contains production deployment documentation for the AFC Odoo + N8N automation stack.

## Documents

| Document | Description |
|----------|-------------|
| [AFC N8N Production Deployment](01-afc-n8n-production-deployment.md) | Complete deployment guide for N8N + Odoo integration |

## Configuration Files

Ready-to-use configuration files for production deployment:

| File | Description | Usage |
|------|-------------|-------|
| [docker-compose.yml](config/docker-compose.yml) | Docker Compose stack definition | Copy to `/opt/afc-n8n-deployment/` |
| [.env.example](config/.env.example) | Environment variables template | Copy to `.env` and configure |
| [init-db.sh](config/init-db.sh) | PostgreSQL initialization script | Auto-runs on first start |
| [backup.sh](config/backup.sh) | Automated backup script | Schedule via cron |
| [deploy.sh](config/deploy.sh) | One-click deployment script | Run to deploy stack |

## N8N Workflow Templates

Production-ready workflow JSON files for direct import:

| Workflow | Trigger | Function |
|----------|---------|----------|
| [AFC Calendar Lifecycle](workflows/01-afc-calendar-lifecycle.json) | Daily 02:00 AM | Auto-manage close calendar state transitions |
| [GL Posting Validation](workflows/02-gl-posting-validation.json) | Webhook (real-time) | Validate GL entries, enforce SoD |
| [Philippine Tax Filing](workflows/03-philippine-tax-filing.json) | Monthly 25th 3:00 PM | Auto-generate and file BIR forms |

## Quick Start

```bash
# 1. Clone configuration
git clone <repo> && cd docs/Deployment/config

# 2. Prepare environment
cp .env.example .env
# Edit .env with your values

# 3. Deploy
chmod +x deploy.sh
./deploy.sh

# 4. Access N8N
open http://localhost:5678
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network: afc_network               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   N8N Main  │  │  N8N Worker │  │     PostgreSQL      │  │
│  │  Port 5678  │  │   (Queue)   │  │     Port 5432       │  │
│  └──────┬──────┘  └──────┬──────┘  └─────────────────────┘  │
│         │                │                                   │
│         └────────┬───────┘                                   │
│                  ▼                                           │
│         ┌─────────────┐                                      │
│         │    Redis    │                                      │
│         │  Port 6379  │                                      │
│         └─────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │     Odoo CE 18      │
              │   (4 AFC Modules)   │
              │     Port 8069       │
              └─────────────────────┘
```

## Module Summary

| Module | Lines | Features |
|--------|-------|----------|
| `afc_core` | 1,800 | GL posting, close calendar, multi-company |
| `afc_philippines` | 2,100 | BIR forms, tax engine (2024 rates) |
| `afc_grc` | 1,950 | SoD roles, 7 conflict rules, Four-Eyes |
| `afc_copilot` | 1,850 | RAG AI, Claude API, multi-channel |

## Compliance Features

- **Four-Eyes Principle**: Preparer ≠ Reviewer ≠ Approver
- **GL Balance Enforcement**: Debit = Credit (blocks if unequal)
- **Audit Immutability**: No deletion/modification (SOX 404)
- **Philippine Tax**: BIR forms 100% accurate (2024 rates)
- **Separation of Duties**: 7 conflict rules, real-time detection
