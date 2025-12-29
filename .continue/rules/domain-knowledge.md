# AFC Odoo - Domain Knowledge

## Financial Close Process

### Month-End Close Phases

1. **Preparation (WD-5 to WD-3)**
   - Cutoff communications
   - Preliminary accruals
   - Intercompany confirmations

2. **Transaction Processing (WD-2 to WD+1)**
   - Final invoicing
   - Expense submissions
   - Bank reconciliations

3. **Adjustments (WD+2 to WD+3)**
   - Accrual adjustments
   - FX revaluation
   - Inventory adjustments

4. **Review & Close (WD+4 to WD+5)**
   - Trial balance review
   - Manager sign-offs
   - Period lock

5. **Reporting (WD+6 to WD+10)**
   - Financial statements
   - Management reports
   - Variance analysis

### Key Accounting Principles

- **Debit = Credit**: Every journal entry must balance
- **Accrual Basis**: Recognize when earned/incurred, not when cash moves
- **Materiality**: Focus on items that affect decision-making
- **Consistency**: Same methods period over period

## Philippine Tax Compliance

### BIR Forms

| Form | Description | Deadline |
|------|-------------|----------|
| 1601-C | Monthly Withholding Tax | 10th of following month |
| 2550Q | Quarterly VAT Return | 25th of month after quarter |
| 1700 | Annual Income Tax | April 15 |

### Tax Rates (2024)

| Tax Type | Rate |
|----------|------|
| Corporate Income Tax | 25% (regular) / 20% (MSME) |
| VAT | 12% |
| Withholding Tax (Services) | 2% |
| Withholding Tax (Rental) | 5% |
| Documentary Stamp Tax | 1.50 per 200 |

### eBIR Filing Requirements

- XML format with BIR-specified schema
- TIN validation required
- Digital signature for amounts > PHP 1M
- 5-year retention of filed documents

## Separation of Duties (SoD)

### Core Principles

1. **Authorization**: Approve transactions
2. **Custody**: Physical control of assets
3. **Recording**: Maintain records
4. **Reconciliation**: Verify accuracy

No single person should perform more than one function for the same transaction.

### AFC SoD Conflict Rules

| Rule | Conflict | Prevention |
|------|----------|------------|
| SOD-001 | Create vendor + Approve payment | Block at approval |
| SOD-002 | Prepare JE + Post JE | Require different users |
| SOD-003 | Create employee + Approve payroll | Segregated roles |
| SOD-004 | Modify CoA + Post entries | Admin vs user separation |
| SOD-005 | Create customer + Apply credits | Credit approval workflow |
| SOD-006 | Bank recon + Approve transfers | Treasury controls |
| SOD-007 | Modify tax rates + File returns | Compliance officer approval |

### Four-Eyes Principle

All financial transactions require:
- **Preparer**: Creates the document
- **Reviewer**: Validates accuracy
- **Approver**: Authorizes posting

Preparer ≠ Reviewer ≠ Approver (enforced by system)

## Audit Requirements

### SOX 404 Compliance

- **Documentation**: All controls must be documented
- **Testing**: Controls must be tested quarterly
- **Evidence**: Retain evidence for 7 years
- **Immutability**: Audit logs cannot be modified

### GITC Controls

- **IT S01**: User account provisioning
- **IT S05**: Periodic access reviews (quarterly)
- **IT S07**: Change management
- **IT S09**: Incident management

### Audit Trail Requirements

Every financial transaction must capture:
- User ID and name
- Timestamp (with timezone)
- Action performed
- Before/after values
- IP address
- Session ID

## Key Terminology

| Term | Definition |
|------|------------|
| **WD** | Working Day (relative to month-end) |
| **CoA** | Chart of Accounts |
| **JE** | Journal Entry |
| **GL** | General Ledger |
| **AP** | Accounts Payable |
| **AR** | Accounts Receivable |
| **FX** | Foreign Exchange |
| **BIR** | Bureau of Internal Revenue (Philippines) |
| **TIN** | Tax Identification Number |
| **VAT** | Value Added Tax |
| **RFC** | Remote Function Call (SAP integration term) |
| **OCA** | Odoo Community Association |
