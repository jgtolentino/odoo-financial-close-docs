# AFC Odoo Financial Close - Project Architecture

## Project Overview

This is an enterprise-grade financial close documentation system for Odoo Community Edition 18 with OCA modules. It implements SAP AFC (Advanced Financial Closing) equivalent functionality with Philippine BIR tax compliance.

## Repository Structure

```
odoo-financial-close-docs/
├── docs/                          # MkDocs documentation source
│   ├── index.md                   # Home page
│   ├── 01-*.md to 14-*.md         # Core documentation
│   ├── HR-Processes/              # HR hire-to-retire workflows
│   ├── IT-Controls/               # GITC, SoD, audit remediation
│   └── Deployment/                # N8N + Docker production deployment
├── .github/workflows/             # CI/CD for MkDocs deployment
├── .continue/rules/               # AI assistant context (this directory)
└── mkdocs.yml                     # Site configuration
```

## Key Modules (Odoo CE 18)

| Module | Purpose | Lines |
|--------|---------|-------|
| `afc_core` | GL posting, close calendar, multi-company | 1,800 |
| `afc_philippines` | BIR forms, tax engine (2024 rates) | 2,100 |
| `afc_grc` | SoD roles, 7 conflict rules, Four-Eyes | 1,950 |
| `afc_copilot` | RAG AI, Claude API, multi-channel | 1,850 |

## Technology Stack

- **ERP**: Odoo CE 18 with OCA modules
- **Automation**: N8N 2.1.4 (Community Edition)
- **Database**: PostgreSQL 16
- **Cache/Queue**: Redis 6
- **Documentation**: MkDocs Material theme
- **AI**: Claude API for RAG copilot

## Compliance Framework

- **SOX 404**: Immutable audit trails, no deletion allowed
- **Four-Eyes Principle**: Preparer ≠ Reviewer ≠ Approver
- **SoD (Separation of Duties)**: 7 conflict rules enforced at transaction level
- **Philippine Tax**: BIR Forms 1700, 1601-C, 2550Q (2024 rates)

## Documentation Conventions

- All docs use Markdown with GitHub Flavored Markdown extensions
- Code blocks specify language for syntax highlighting
- Mermaid diagrams for flowcharts and ERDs
- Admonitions for warnings, notes, and tips
- Tables use pipe syntax with header row

## File Naming

- `XX-descriptive-name.md` - Numbered core documents
- `subdirectory/topic-name.md` - Section-specific documents
- `*.csv` - Machine-readable data files
- `*.json` - N8N workflow templates
- `*.sh` - Deployment scripts
