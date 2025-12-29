# Error Codes Reference

## Overview

The AFC modules use a structured error code system for consistent error handling, logging, and troubleshooting. All error codes follow the format: `AFC-E-{CATEGORY}-{NUMBER}`.

## Error Code Format

```
AFC-E-VAL-001
│   │ │   └── Sequential number within category
│   │ └────── Category (3-letter code)
│   └──────── Error indicator
└──────────── Module prefix
```

## Categories

| Category | Description | Module |
|----------|-------------|--------|
| `VAL` | Validation errors | All |
| `STATE` | State transition errors | afc_close_manager |
| `SOD` | Separation of duties errors | afc_sod_controls |
| `BIR` | BIR form/filing errors | afc_close_manager_ph |
| `AUTH` | Authentication/authorization | All |
| `DATA` | Data integrity errors | All |
| `SYS` | System/infrastructure errors | All |
| `RAG` | RAG copilot errors | afc_rag_copilot |
| `INT` | Integration errors | All |

---

## Validation Errors (AFC-E-VAL-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-VAL-001` | Required field missing: {field_name} | Mandatory field not provided | Provide the required field value |
| `AFC-E-VAL-002` | Invalid date format: {value} | Date not in YYYY-MM-DD format | Use ISO 8601 date format |
| `AFC-E-VAL-003` | Invalid date range: start > end | Period start date after end date | Correct date range order |
| `AFC-E-VAL-004` | Duplicate record: {model} with {criteria} | Unique constraint violation | Check existing records before creation |
| `AFC-E-VAL-005` | Invalid amount: {value} | Non-numeric or negative amount | Provide valid positive decimal |
| `AFC-E-VAL-006` | Invalid TIN format: {value} | Tax ID doesn't match pattern | Use format: XXX-XXX-XXX-XXX |
| `AFC-E-VAL-007` | Invalid ATC code: {value} | Alphanumeric Tax Code not found | Check BIR ATC reference |
| `AFC-E-VAL-008` | Period overlap detected | Close period overlaps existing | Adjust period dates |
| `AFC-E-VAL-009` | Template not found: {template_id} | Referenced template doesn't exist | Create or use valid template |
| `AFC-E-VAL-010` | Invalid file type: {mime_type} | Unsupported evidence file format | Use PDF, PNG, JPG, XLSX |
| `AFC-E-VAL-011` | File size exceeds limit: {size} MB | Evidence file too large | Compress or split file (max 10MB) |
| `AFC-E-VAL-012` | Invalid email format: {value} | Email doesn't match pattern | Provide valid email address |
| `AFC-E-VAL-013` | Invalid phone format: {value} | Phone doesn't match pattern | Use international format |
| `AFC-E-VAL-014` | Checklist incomplete: {count} items | Not all checklist items completed | Complete all required items |
| `AFC-E-VAL-015` | Evidence required but missing | Task requires evidence attachment | Attach required evidence |

---

## State Transition Errors (AFC-E-STATE-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-STATE-001` | Invalid state transition: {from} → {to} | Attempted invalid workflow step | Follow correct state sequence |
| `AFC-E-STATE-002` | Period already locked | Cannot modify locked period | Request unlock from admin |
| `AFC-E-STATE-003` | Period has pending tasks | Cannot close period with open tasks | Complete all tasks first |
| `AFC-E-STATE-004` | Task has pending dependencies | Parent task not complete | Complete parent task first |
| `AFC-E-STATE-005` | Task already approved | Cannot modify approved task | Create new task if changes needed |
| `AFC-E-STATE-006` | Cannot reject: no rejection reason | Rejection requires explanation | Provide rejection reason |
| `AFC-E-STATE-007` | Period close date passed | Close deadline exceeded | Extend deadline or escalate |
| `AFC-E-STATE-008` | Task not in reviewable state | Task must be completed for review | Complete task execution first |
| `AFC-E-STATE-009` | Cannot reopen: period locked | Locked periods cannot be modified | Request period unlock |
| `AFC-E-STATE-010` | Workflow stalled: no next action | No valid next step available | Contact administrator |

### State Transition Matrix

```
         ┌─────────────────────────────────────────────────────────────┐
         │                    VALID TRANSITIONS                        │
         ├─────────┬──────┬─────────────┬────────┬──────────┬─────────┤
         │  draft  │ open │ in_progress │ review │ approved │ closed  │
┌────────┼─────────┼──────┼─────────────┼────────┼──────────┼─────────┤
│ draft  │    -    │  ✓   │      ✗      │   ✗    │    ✗     │    ✗    │
│ open   │    ✗    │  -   │      ✓      │   ✗    │    ✗     │    ✗    │
│in_prog │    ✗    │  ✗   │      -      │   ✓    │    ✗     │    ✗    │
│ review │    ✗    │  ✗   │      ✓      │   -    │    ✓     │    ✗    │
│approved│    ✗    │  ✗   │      ✗      │   ✗    │    -     │    ✓    │
│ closed │    ✗    │  ✗   │      ✗      │   ✗    │    ✗     │    -    │
└────────┴─────────┴──────┴─────────────┴────────┴──────────┴─────────┘
```

---

## Separation of Duties Errors (AFC-E-SOD-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-SOD-001` | SoD violation: {rule_code} | Conflicting action by same user | Assign to different user |
| `AFC-E-SOD-002` | Four-eyes principle violated | Same user in multiple roles | Assign each role to different user |
| `AFC-E-SOD-003` | Role conflict detected: {role1} vs {role2} | Incompatible roles assigned | Remove conflicting role assignment |
| `AFC-E-SOD-004` | Preparer cannot be approver | Self-approval attempted | Route to different approver |
| `AFC-E-SOD-005` | Reviewer cannot be approver | Same person in both roles | Assign third party as approver |
| `AFC-E-SOD-006` | Insufficient segregation | Not enough distinct users | Add more users to workflow |
| `AFC-E-SOD-007` | Exception required: {rule_code} | Blocked action needs override | Request exception from authorized approver |
| `AFC-E-SOD-008` | Exception expired | Previously granted exception no longer valid | Request new exception |
| `AFC-E-SOD-009` | Exception approver not authorized | Approver lacks exception authority | Use authorized exception approver |
| `AFC-E-SOD-010` | Role assignment expired | User role no longer active | Renew role assignment |
| `AFC-E-SOD-011` | Audit trail modification blocked | Cannot alter immutable records | Audit records cannot be changed |
| `AFC-E-SOD-012` | Critical violation: escalation required | High-severity SoD breach | Immediate management escalation |

### SoD Rule Severity Levels

| Level | Code | Auto-Block | Notification | Escalation |
|-------|------|------------|--------------|------------|
| Low | `L` | No | Log only | None |
| Medium | `M` | Warn | Email user + supervisor | After 24h |
| High | `H` | Block | Email + Mattermost | Immediate to manager |
| Critical | `C` | Block + Lock | All channels | Immediate to CFO/audit |

---

## BIR Errors (AFC-E-BIR-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-BIR-001` | Invalid form type: {type} | Unsupported BIR form | Use valid form type |
| `AFC-E-BIR-002` | Missing TIN | Company TIN not configured | Configure TIN in company settings |
| `AFC-E-BIR-003` | Invalid RDO code: {code} | Revenue District Office not found | Verify RDO assignment |
| `AFC-E-BIR-004` | Filing deadline exceeded: {date} | Past the BIR deadline | File immediately, penalties apply |
| `AFC-E-BIR-005` | Computation error: {field} | Unable to calculate tax amount | Verify source data |
| `AFC-E-BIR-006` | Schedule mismatch: expected {a}, got {b} | Schedule totals don't reconcile | Verify individual schedule items |
| `AFC-E-BIR-007` | WHT rate not found: {income_type} | No matching withholding rate | Configure WHT rate for income type |
| `AFC-E-BIR-008` | Period already filed | Duplicate filing for same period | Amend existing filing if needed |
| `AFC-E-BIR-009` | Amendment requires reason | Amended return needs explanation | Provide amendment justification |
| `AFC-E-BIR-010` | eFPS submission failed: {error} | Electronic filing system error | Retry or manual filing |
| `AFC-E-BIR-011` | Confirmation number invalid | Filed status but no confirmation | Contact BIR for verification |
| `AFC-E-BIR-012` | Tax calendar not configured | Missing calendar for form type | Import tax calendar data |
| `AFC-E-BIR-013` | Employee threshold exceeded | Over P720K annual income | Apply correct WHT rate |
| `AFC-E-BIR-014` | VAT registration required | Quarterly VAT threshold exceeded | Register for VAT |
| `AFC-E-BIR-015` | Penalty calculation required | Late filing detected | Compute penalties and interest |

### BIR Form Error Mapping

| Form | Common Errors | Troubleshooting |
|------|---------------|-----------------|
| 1601-C | `BIR-002`, `BIR-007` | Verify TIN, check WHT rate config |
| 2550Q | `BIR-006`, `BIR-014` | Reconcile output/input VAT |
| 1702-RT | `BIR-005`, `BIR-013` | Verify income computations |

---

## Authentication/Authorization Errors (AFC-E-AUTH-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-AUTH-001` | Unauthorized access | User lacks required permission | Request access from admin |
| `AFC-E-AUTH-002` | Session expired | Login session timeout | Re-authenticate |
| `AFC-E-AUTH-003` | Invalid API key | API key not recognized | Regenerate API key |
| `AFC-E-AUTH-004` | Rate limit exceeded | Too many requests | Wait and retry |
| `AFC-E-AUTH-005` | IP not whitelisted | Request from unauthorized IP | Add IP to whitelist |
| `AFC-E-AUTH-006` | Multi-company access denied | User not in company | Add to company users |
| `AFC-E-AUTH-007` | Group permission missing | User not in required group | Add to security group |
| `AFC-E-AUTH-008` | Record-level access denied | No access to specific record | Check record rules |
| `AFC-E-AUTH-009` | API endpoint disabled | Endpoint not active | Enable in settings |
| `AFC-E-AUTH-010` | 2FA required | Two-factor not completed | Complete 2FA verification |

---

## Data Integrity Errors (AFC-E-DATA-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-DATA-001` | Foreign key violation: {table}.{field} | Referenced record doesn't exist | Create parent record first |
| `AFC-E-DATA-002` | Orphan records detected | Child records without parent | Run data cleanup |
| `AFC-E-DATA-003` | Checksum mismatch: {record_id} | Data integrity compromised | Restore from backup |
| `AFC-E-DATA-004` | Circular reference detected | Self-referencing loop | Fix hierarchy structure |
| `AFC-E-DATA-005` | Data type mismatch: {field} | Wrong type for column | Correct data format |
| `AFC-E-DATA-006` | Constraint violation: {constraint} | Check constraint failed | Verify data meets constraints |
| `AFC-E-DATA-007` | Sequence gap detected: {sequence} | Missing sequence numbers | Investigate and document |
| `AFC-E-DATA-008` | Duplicate key: {key} | Primary/unique key collision | Use different identifier |
| `AFC-E-DATA-009` | Data truncation: {field} | Value exceeds field length | Shorten value or extend field |
| `AFC-E-DATA-010` | Encoding error: {character} | Invalid character encoding | Use UTF-8 encoding |

---

## System Errors (AFC-E-SYS-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-SYS-001` | Database connection failed | Cannot connect to PostgreSQL | Check database status |
| `AFC-E-SYS-002` | Redis connection failed | Cannot connect to Redis | Check Redis status |
| `AFC-E-SYS-003` | Timeout: operation exceeded {n}s | Request timeout | Increase timeout or optimize |
| `AFC-E-SYS-004` | Memory limit exceeded | Out of memory | Increase resources or optimize |
| `AFC-E-SYS-005` | Disk space critical: {percent}% | Low disk space | Free up space |
| `AFC-E-SYS-006` | Worker process crashed | Odoo worker failure | Restart workers |
| `AFC-E-SYS-007` | Queue overflow: {queue_name} | Job queue full | Scale workers |
| `AFC-E-SYS-008` | SSL certificate expired | HTTPS certificate invalid | Renew certificate |
| `AFC-E-SYS-009` | Cron job failed: {job_name} | Scheduled task failure | Check job configuration |
| `AFC-E-SYS-010` | Backup failed: {reason} | Database backup error | Verify backup configuration |
| `AFC-E-SYS-011` | Index corruption detected | Database index damaged | Reindex database |
| `AFC-E-SYS-012` | Replication lag: {seconds}s | Database replication delayed | Check replica status |

---

## RAG Copilot Errors (AFC-E-RAG-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-RAG-001` | API key invalid or expired | Claude API authentication failed | Update API key in settings |
| `AFC-E-RAG-002` | API rate limit exceeded | Too many Claude API calls | Implement rate limiting |
| `AFC-E-RAG-003` | Token limit exceeded: {tokens} | Prompt too long | Reduce context or query length |
| `AFC-E-RAG-004` | No relevant documents found | No matching chunks for query | Index more documents |
| `AFC-E-RAG-005` | Embedding generation failed | Cannot create vector embedding | Check embedding model status |
| `AFC-E-RAG-006` | Vector search timeout | pgvector query too slow | Optimize index or reduce k |
| `AFC-E-RAG-007` | Document indexing failed: {doc} | Cannot process document | Check document format |
| `AFC-E-RAG-008` | Chunk overlap invalid: {value} | Invalid chunking configuration | Use valid overlap percentage |
| `AFC-E-RAG-009` | Model not available: {model} | Requested model unavailable | Use available model version |
| `AFC-E-RAG-010` | Response generation failed | Claude API error | Retry or check API status |

---

## Integration Errors (AFC-E-INT-xxx)

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `AFC-E-INT-001` | Webhook delivery failed: {url} | Cannot reach webhook endpoint | Verify endpoint availability |
| `AFC-E-INT-002` | GitHub API error: {status} | GitHub API returned error | Check API permissions |
| `AFC-E-INT-003` | N8N workflow failed: {workflow} | Workflow execution error | Check N8N logs |
| `AFC-E-INT-004` | Mattermost notification failed | Cannot post to channel | Verify webhook URL |
| `AFC-E-INT-005` | Email delivery failed: {recipient} | SMTP error | Check SMTP configuration |
| `AFC-E-INT-006` | XML-RPC call failed: {method} | Odoo RPC error | Verify credentials and URL |
| `AFC-E-INT-007` | OAuth token refresh failed | Cannot renew access token | Re-authorize integration |
| `AFC-E-INT-008` | Payload too large: {size} | Request body exceeds limit | Reduce payload size |
| `AFC-E-INT-009` | Invalid webhook signature | HMAC verification failed | Check webhook secret |
| `AFC-E-INT-010` | Integration disabled: {name} | Integration turned off | Enable in settings |

---

## Error Handling Best Practices

### Logging Format

```python
import logging

_logger = logging.getLogger(__name__)

def handle_error(error_code, context=None):
    """
    Standard error handling pattern
    """
    error_msg = ERROR_MESSAGES.get(error_code, "Unknown error")

    _logger.error(
        "AFC Error: %s - %s | Context: %s",
        error_code,
        error_msg,
        context or {}
    )

    raise UserError(f"[{error_code}] {error_msg}")
```

### Client Error Response

```json
{
  "error": {
    "code": "AFC-E-VAL-001",
    "message": "Required field missing: period_id",
    "details": {
      "field": "period_id",
      "model": "afc.close.task"
    },
    "timestamp": "2025-01-15T10:30:00Z",
    "trace_id": "abc-123-def-456"
  }
}
```

### Error Monitoring Alerts

| Error Pattern | Alert Level | Notification |
|---------------|-------------|--------------|
| 5+ `AFC-E-SYS-*` in 5 min | Critical | PagerDuty + Mattermost |
| 10+ `AFC-E-AUTH-*` in 1 min | Warning | Mattermost |
| Any `AFC-E-SOD-012` | Critical | Email CFO + Mattermost |
| Any `AFC-E-BIR-004` | High | Email finance team |
