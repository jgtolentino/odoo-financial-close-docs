# AI-Assisted Codebase Documentation Awareness

## Overview

This document describes how to configure AI coding assistants (Claude Code, Continue.dev, Cursor, etc.) to be context-aware of the AFC Odoo financial close system. Proper context configuration enables more accurate code suggestions, documentation generation, and compliance-aware development.

---

## 1. Context Configuration

### 1.1 Project Rules Structure

The `.continue/rules/` directory contains markdown files that provide context to AI assistants:

```
.continue/rules/
├── project-architecture.md    # Repository structure, tech stack
├── coding-standards.md        # Code patterns, security requirements
└── domain-knowledge.md        # Financial close processes, tax rules
```

### 1.2 Key Context Files

| File | Purpose | When Updated |
|------|---------|--------------|
| `project-architecture.md` | Module layout, dependencies | On structural changes |
| `coding-standards.md` | Code patterns, security rules | On standard updates |
| `domain-knowledge.md` | Business rules, tax rates | Annually / on regulation changes |

---

## 2. Claude Code Web Session Configuration

### 2.1 Session Context

When starting a Claude Code session, the AI automatically reads:

1. Repository structure via `git status`
2. Recent commits via `git log`
3. Active branch context
4. `.continue/rules/` directory (if present)

### 2.2 Effective Prompting Patterns

**For compliance-aware development:**
```
"Add a new GL posting validation that enforces the Four-Eyes Principle.
The preparer, reviewer, and approver must be different users.
Reference the SoD rules in domain-knowledge.md."
```

**For tax-compliant features:**
```
"Implement BIR Form 2550Q calculation using the 2024 VAT rates.
Follow the afc_philippines module patterns in coding-standards.md."
```

**For documentation updates:**
```
"Update the deployment guide to include the new Redis cluster configuration.
Follow the documentation standards in coding-standards.md."
```

---

## 3. Continue.dev Integration

### 3.1 Configuration

Add to `.continuerc.json`:

```json
{
  "contextProviders": [
    {
      "name": "rules",
      "params": {
        "path": ".continue/rules"
      }
    }
  ],
  "tools": [
    {
      "name": "file-explorer",
      "enabled": true
    },
    {
      "name": "code-search",
      "enabled": true
    }
  ]
}
```

### 3.2 Agent Mode Setup

Enable repository access for:
- File exploration and reading
- Code search with pattern matching
- Git history access
- Project structure understanding

---

## 4. Context Awareness for Compliance

### 4.1 SoD-Aware Code Generation

When the AI understands SoD rules, it will:

- Suggest separate methods for prepare/review/approve actions
- Include user validation checks in approval workflows
- Add audit logging for all state transitions
- Flag potential SoD conflicts in code reviews

**Example AI suggestion:**
```python
def action_approve(self):
    # AI-generated with SoD awareness
    if self.preparer_id == self.env.user:
        raise UserError(_("Approver cannot be the same as preparer (SOD-002)"))
    if self.reviewer_id == self.env.user:
        raise UserError(_("Approver cannot be the same as reviewer"))
    self._log_audit_action('approve')
    self.state = 'approved'
```

### 4.2 Tax-Aware Code Generation

With Philippine tax context, the AI will:

- Use correct 2024 tax rates
- Apply proper withholding tax calculations
- Generate BIR-compliant XML structures
- Include required fields for eBIR submission

### 4.3 Audit-Aware Code Generation

With SOX 404 context, the AI will:

- Never generate code that deletes audit records
- Always include audit trail logging
- Use immutable patterns for financial data
- Suggest proper evidence retention

---

## 5. Documentation RAG Integration

### 5.1 MCP Server Configuration

For AI assistants that support MCP (Model Context Protocol):

```json
{
  "mcpServers": {
    "afc-docs": {
      "command": "node",
      "args": ["mcp-server-docs"],
      "env": {
        "DOCS_PATH": "./docs"
      }
    }
  }
}
```

### 5.2 Custom RAG for Large Codebases

For the AFC module codebase (9K+ lines), implement chunked indexing:

```python
# afc_copilot/models/rag_indexer.py
class AfcRagIndexer(models.Model):
    _name = 'afc.rag.indexer'

    def index_module(self, module_name):
        """Index Odoo module for RAG retrieval."""
        chunks = self._chunk_python_files(module_name)
        embeddings = self._generate_embeddings(chunks)
        self._store_vectors(embeddings)
```

---

## 6. Best Practices

### 6.1 Context File Maintenance

| Task | Frequency | Owner |
|------|-----------|-------|
| Update tax rates | Annually | Finance/Compliance |
| Update SoD rules | On policy change | GRC Team |
| Update tech stack | On upgrades | DevOps |
| Update module docs | On major releases | Development |

### 6.2 AI Session Guidelines

1. **Start with context**: Reference `.continue/rules/` files in prompts
2. **Be specific about compliance**: Mention SOX, SoD, or BIR requirements
3. **Request audit logging**: Always ask for audit trail inclusion
4. **Validate suggestions**: AI suggestions should be reviewed for compliance

### 6.3 Security Considerations

- Never include API keys or secrets in context files
- Exclude `.env` files from AI context
- Review AI-generated code for SQL injection risks
- Verify SoD enforcement in generated approval workflows

---

## 7. Troubleshooting

### 7.1 Context Not Loading

```bash
# Verify .continue/rules exists
ls -la .continue/rules/

# Check file permissions
chmod 644 .continue/rules/*.md
```

### 7.2 Outdated Context

```bash
# Compare context with current implementation
git diff HEAD~10 .continue/rules/

# Update after major changes
git add .continue/rules/ && git commit -m "docs: update AI context files"
```

### 7.3 AI Ignoring Compliance Rules

If the AI generates non-compliant code:

1. Explicitly reference the rule file: "Following domain-knowledge.md..."
2. Quote the specific rule: "Per SOD-002, preparer cannot post..."
3. Request validation: "Verify this follows Four-Eyes Principle"

---

## 8. References

- [Continue.dev Documentation](https://docs.continue.dev/guides/codebase-documentation-awareness)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Odoo Development Guidelines](https://www.odoo.com/documentation/17.0/contributing/development.html)

---

*Document Version: 1.0*
*Last Updated: 2025-01*
*Owner: DevOps / IT Market Director*
