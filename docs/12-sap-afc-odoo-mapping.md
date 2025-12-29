# SAP Advanced Financial Closing → Odoo CE Configuration

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director
**Classification**: Internal - Implementation

---

## Complete Month-End Closing Task Template

This document maps SAP AFC's best-practice financial closing tasks to Odoo CE implementation.
**Goal: Zero custom modules** - use configuration, OCA modules, and automation only.

---

## SAP AFC Task Structure Overview

```
SAP AFC Hierarchy:
├── Task List Template (reusable blueprint)
│   ├── Communication System Folders (ERP connections)
│   │   ├── Company Code Folders (legal entities)
│   │   │   ├── Process Folders (functional areas)
│   │   │   │   └── Tasks (individual closing activities)
```

**Odoo Equivalent:**
```
Odoo Project Structure:
├── Project Template: "Month-End Close Template"
│   ├── Stage: Draft → In Progress → Pending Approval → Completed
│   │   ├── Task Tags: [GL] [AP] [AR] [AA] [Tax] [Reporting]
│   │   │   └── Tasks with Dependencies + Automated Actions
```

---

## Phase 1: PRE-CLOSING (Days -5 to -1)

### 1.1 Period Management

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Open new posting period | OB52 | Accounting → Configuration → Periods | Scheduled Action (Day 1) |
| Close previous period | OB52 | Lock Date settings | Scheduled Action (Day 5) |
| Verify period status | S_ALR_87003642 | Lock Date Exception Groups | Manual check |

**Odoo Configuration:**
```
Settings → Accounting → Lock Dates
├── Lock Date for Non-Advisers: [Last day of prior month]
├── Lock Date for All Users: [Last day of prior month]
└── Tax Lock Date: [Per BIR filing deadline]
```

**Automated Action (XML-only module):**
```xml
<record id="action_open_period" model="ir.cron">
  <field name="name">Open New Accounting Period</field>
  <field name="model_id" ref="account.model_res_company"/>
  <field name="interval_number">1</field>
  <field name="interval_type">months</field>
  <field name="numbercall">-1</field>
  <field name="doall">False</field>
  <field name="code">
# Runs on Day 1 of each month
model.search([]).write({
    'period_lock_date': fields.Date.today() - relativedelta(months=1, day=31)
})
  </field>
</record>
```

---

### 1.2 Master Data Verification

| SAP AFC Task | Odoo Implementation | Automation |
|--------------|---------------------|------------|
| Review new vendors created | Contacts → Vendors filter | Report (Spreadsheet) |
| Review new customers created | Contacts → Customers filter | Report (Spreadsheet) |
| Verify bank account changes | Accounting → Banks | Audit log (OCA) |
| Check chart of accounts changes | Accounting → Chart of Accounts | Audit log (OCA) |

**OCA Module:** `auditlog` - tracks all master data changes

---

## Phase 2: SUBLEDGER CLOSING (Days 1-3)

### 2.1 Accounts Payable (FI-AP)

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Process pending invoices | MIRO | Accounting → Vendors → Bills | Workflow |
| Match GR/IR (Goods Receipt/Invoice Receipt) | MR11 | Purchase → 3-way matching | Auto-match |
| Clear GR/IR variances | F.13 | Accounting → Reconciliation | OCA module |
| Vendor payment run | F110 | Accounting → Payments → Batch | Scheduled |
| Post accrued expenses | FBS1 | Journal Entry (recurring) | Scheduled Action |
| Vendor balance confirmation | F.18 | Vendor Statement report | Email automation |

**Odoo Tasks:**

```
Task: Process Pending Vendor Bills
├── Predecessor: None (start task)
├── Responsible: AP Team
├── Checklist:
│   ├── [ ] Review draft bills in queue
│   ├── [ ] Validate 3-way match (PO → Receipt → Invoice)
│   ├── [ ] Post approved bills
│   └── [ ] Flag discrepancies for review
├── Approval: Not required
└── Auto-schedule: Day 1, 9:00 AM

Task: Vendor Payment Run
├── Predecessor: Process Pending Vendor Bills
├── Responsible: Treasury
├── Checklist:
│   ├── [ ] Review payment proposal
│   ├── [ ] Verify bank balance
│   ├── [ ] Execute payment batch
│   └── [ ] Confirm bank file transmission
├── Approval: Required (Finance Manager)
└── Auto-schedule: Day 2, 2:00 PM
```

**Server Action for Accrual Posting:**
```python
# Settings → Technical → Server Actions
# Name: Post Monthly AP Accruals
# Model: account.move
# Action: Execute Python Code

accrual_journal = env['account.journal'].search([('code', '=', 'ACCR')], limit=1)
today = fields.Date.today()
last_day = today + relativedelta(day=31)

# Find uninvoiced receipts
po_lines = env['purchase.order.line'].search([
    ('order_id.state', '=', 'purchase'),
    ('qty_received', '>', 0),
    ('qty_invoiced', '<', 'qty_received'),
    ('order_id.date_order', '<=', last_day)
])

if po_lines:
    # Create accrual entry
    move_vals = {
        'journal_id': accrual_journal.id,
        'date': last_day,
        'ref': f'AP Accrual {last_day.strftime("%B %Y")}',
        'line_ids': []
    }
    # ... build lines from po_lines
    env['account.move'].create(move_vals).action_post()
```

---

### 2.2 Accounts Receivable (FI-AR)

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Post customer invoices | VF01 | Accounting → Invoices | Workflow |
| Process credit notes | VF01 | Credit Notes | Manual |
| Run dunning | F150 | Accounting → Follow-ups | Scheduled |
| Revenue recognition | VF44 | Deferred Revenue (OCA) | Scheduled |
| Bad debt provision | F.28 | Journal Entry | Server Action |
| Customer balance confirmation | F.27 | Customer Statement | Email automation |

**OCA Modules:**
- `account_invoice_blocking` - invoice approval workflow
- `account_payment_term_extension` - complex payment terms
- `account_credit_control` - dunning automation

**Task Dependencies:**
```
Task: Revenue Cut-off Review
├── Predecessor: Post Customer Invoices
├── Responsible: AR Team
├── Due: Day +2 from predecessor
├── Checklist:
│   ├── [ ] Verify all shipments invoiced
│   ├── [ ] Check deferred revenue balances
│   ├── [ ] Post revenue accruals if needed
│   └── [ ] Document any cut-off adjustments
└── Approval: Required (Accounting Manager)
```

---

### 2.3 Asset Accounting (FI-AA)

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Run depreciation | AFAB | Accounting → Assets → Compute Depreciation | Scheduled |
| Post depreciation entries | AFAB | Auto-posted with compute | Automatic |
| Capitalize AUC (Assets Under Construction) | AIAB | Asset → Change Status | Manual |
| Asset retirements | ABAON | Asset → Dispose | Manual |
| Verify asset register | S_ALR_87011990 | Asset Reports | Report |

**Scheduled Action for Depreciation:**
```python
# Settings → Technical → Scheduled Actions
# Name: Monthly Depreciation Run
# Model: account.asset
# Interval: 1 Month
# Next Execution: Last day of month, 11:00 PM

# Code:
assets = env['account.asset'].search([
    ('state', '=', 'open'),
    ('depreciation_date', '<=', fields.Date.today())
])
for asset in assets:
    asset._compute_depreciation_board()
    asset._post_depreciation_moves()
```

**Task:**
```
Task: Depreciation Posting Run
├── Predecessor: Asset Capitalizations Complete
├── Responsible: Fixed Assets Accountant
├── Type: Automated Job
├── Schedule: Day 28, 11:00 PM (or last business day)
├── Checklist:
│   ├── [ ] Verify all asset acquisitions entered
│   ├── [ ] Check disposals processed
│   ├── [ ] Review depreciation preview
│   └── [ ] Confirm posting successful
└── Auto-verification: Check account.move created
```

---

## Phase 3: GENERAL LEDGER CLOSING (Days 3-5)

### 3.1 Accruals and Deferrals

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Post manual accruals | FBS1 | Journal Entries | Recurring entries |
| Post prepaid expenses | FBS1 | Deferred Expenses (OCA) | Automatic |
| Reverse prior month accruals | F.81 | Reversal entries | Scheduled Action |
| Post payroll accruals | PC00_M99 | HR → Payroll | Integration |

**Recurring Entry Template:**
```
Accounting → Configuration → Recurring Entries

Name: Monthly Rent Accrual
Journal: Accruals
Debit Account: 6100 - Rent Expense
Credit Account: 2110 - Accrued Expenses
Amount: [Fixed or Formula]
Frequency: Monthly
Auto-reverse: Yes (Day 1 of next month)
```

**OCA Modules:**
- `account_cutoff_accrual_picking` - automatic accruals from shipments
- `account_cutoff_prepaid` - prepaid expense automation
- `account_move_template` - recurring entry templates

---

### 3.2 Intercompany Transactions

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Match intercompany invoices | FBL1N/FBL5N | Multi-company reconciliation | OCA module |
| Post intercompany eliminations | F-02 | Consolidation entries | Manual/Superset |
| Verify IC balances net to zero | F.16 | Intercompany report | Report |

**OCA Module:** `account_invoice_inter_company` - auto-creates mirror invoices

**Note for Multi-Entity:**
```
Intercompany reconciliation happens OUTSIDE Odoo
├── Each entity = separate Odoo database (tenant)
├── Consolidation = Superset dashboard
├── Elimination entries = at group reporting level
└── Not in operational ERP
```

---

### 3.3 Foreign Currency Revaluation

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Update exchange rates | OB08 | Accounting → Configuration → Currencies | Scheduled (OCA) |
| Run FX revaluation | FAGL_FC_VAL | Unrealized Gains/Losses posting | Scheduled Action |
| Post FX gains/losses | Automatic | Auto-posted with revaluation | Automatic |

**OCA Module:** `currency_rate_update` - auto-fetches BSP rates

**Scheduled Action:**
```python
# Name: Foreign Currency Revaluation
# Model: res.currency
# Schedule: Last business day of month, 6:00 PM

# Update rates first
env['res.currency.rate.provider'].search([]).refresh_currency()

# Then revalue open items
companies = env['res.company'].search([])
for company in companies:
    env['account.move'].with_company(company)._run_fx_revaluation()
```

---

### 3.4 Allocations and Reclassifications

| SAP AFC Task | SAP T-Code | Odoo Implementation | Automation |
|--------------|------------|---------------------|------------|
| Cost center allocations | KSV5 | Analytic distribution | Superset/external |
| Overhead allocations | KSUB | Journal entries | Server Action |
| Balance sheet reclassifications | F-02 | Journal entries | Manual |

**Note:** Complex allocations better handled in Superset BI layer, not Odoo.

---

## Phase 4: TAX & COMPLIANCE (Days 3-7)

### 4.1 BIR Compliance (Philippines-Specific)

| Task | BIR Form | Due Date | Odoo Implementation |
|------|----------|----------|---------------------|
| Withholding Tax - Compensation | 1601-C | 10th | Tax report + export |
| Withholding Tax - Expanded | 1601-EQ | 10th | Tax report + export |
| VAT Return | 2550M/2550Q | 20th/25th | Tax report + export |
| Annual ITR | 1702-RT/EX | Apr 15 | Tax report + export |
| Alphalist | 1604-CF/E | Jan 31 | Export to BIR format |

**Thin Extension Required:** `ipai_bir_tax` (~100 lines Python)
```python
# Only extends existing tax reports with BIR export formats
# Does NOT replace Odoo tax calculation logic

class AccountTaxReport(models.Model):
    _inherit = 'account.tax.report'

    def export_bir_1601c(self):
        """Export to BIR 1601-C DAT format"""
        # Generate DAT file per BIR specifications
        pass

    def export_bir_2550q(self):
        """Export to BIR 2550Q format"""
        pass
```

**Task:**
```
Task: Prepare BIR 2550Q (VAT Return)
├── Predecessor: All AP/AR invoices posted
├── Responsible: Tax Accountant
├── Due: 20th of following month
├── Checklist:
│   ├── [ ] Run VAT summary report
│   ├── [ ] Reconcile output vs input VAT
│   ├── [ ] Generate BIR 2550Q export
│   ├── [ ] Upload to eBIRForms
│   └── [ ] File and pay via bank
├── Approval: Required (Finance Director)
└── Attachment: BIR 2550Q PDF + Payment confirmation
```

---

### 4.2 Withholding Tax Processing

| SAP AFC Task | Odoo Implementation |
|--------------|---------------------|
| Calculate EWT on payments | Automatic (vendor tax config) |
| Generate BIR 2307 certificates | PDF report (OCA `report_py3o`) |
| File alphalist | Export to CSV/DAT |

**OCA Module:** `l10n_ph` (Philippine localization) or thin extension

---

## Phase 5: REPORTING & REVIEW (Days 5-7)

### 5.1 Financial Statements

| SAP AFC Task | SAP T-Code | Odoo Implementation | Output |
|--------------|------------|---------------------|--------|
| Trial Balance | S_ALR_87012277 | Accounting → Reports → Trial Balance | Excel (OCA) |
| Balance Sheet | S_ALR_87012284 | Accounting → Reports → Balance Sheet | Excel (OCA) |
| Profit & Loss | S_ALR_87012284 | Accounting → Reports → P&L | Excel (OCA) |
| Cash Flow Statement | FF7A | Indirect method report | Excel (OCA) |

**OCA Modules:**
- `account_financial_report` - enhanced financial reports
- `report_xlsx` - Excel export for all reports
- `mis_builder` - custom financial report builder

**Task:**
```
Task: Generate Monthly Financial Statements
├── Predecessor: All closing adjustments posted
├── Responsible: Reporting Accountant
├── Due: Day +5
├── Checklist:
│   ├── [ ] Run Trial Balance - verify debits = credits
│   ├── [ ] Generate Balance Sheet
│   ├── [ ] Generate Profit & Loss
│   ├── [ ] Compare to prior month/budget
│   └── [ ] Document significant variances
├── Approval: Required (Finance Director)
└── Deliverable: Financial statements package (PDF/Excel)
```

---

### 5.2 Reconciliations

| SAP AFC Task | Odoo Implementation | Automation |
|--------------|---------------------|------------|
| Bank reconciliation | Accounting → Banks → Reconcile | OCA module |
| Subledger to GL reconciliation | Reports comparison | Superset |
| Intercompany reconciliation | Cross-entity report | Superset |
| Account analysis | Aged reports | Built-in |

**OCA Modules:**
- `account_reconcile_oca` - enhanced reconciliation
- `account_bank_statement_import_*` - bank file imports

---

### 5.3 Management Review

| SAP AFC Task | Odoo Implementation |
|--------------|---------------------|
| Variance analysis | Superset dashboard |
| KPI review | Superset dashboard |
| Commentary preparation | Attached to closing task |
| Management sign-off | Approval workflow |

**Final Approval Task:**
```
Task: Month-End Close Sign-Off
├── Predecessor: All reporting tasks complete
├── Responsible: Finance Director
├── Type: Approval Gate
├── Checklist:
│   ├── [ ] Review financial statements
│   ├── [ ] Verify all reconciliations complete
│   ├── [ ] Confirm no open issues
│   ├── [ ] Approve close
│   └── [ ] Lock period
├── Approval: Required (CFO)
└── Post-action: Lock accounting period (Scheduled Action)
```

---

## Implementation in Odoo: Project Template

### Create the Template

1. **Project → Configuration → Templates**
2. Create: "Month-End Close Template"

### Stage Configuration

| Stage | Sequence | Fold | Description |
|-------|----------|------|-------------|
| Backlog | 1 | No | Tasks not yet started |
| In Progress | 2 | No | Active work |
| Pending Approval | 3 | No | Awaiting sign-off |
| Completed | 4 | Yes | Done |
| Blocked | 5 | Yes | Issues/escalations |

### Task Tags

| Tag | Color | Use For |
|-----|-------|---------|
| [GL] | Blue | General Ledger tasks |
| [AP] | Green | Accounts Payable |
| [AR] | Yellow | Accounts Receivable |
| [AA] | Orange | Asset Accounting |
| [Tax] | Red | Tax/Compliance |
| [Report] | Purple | Reporting |
| [Auto] | Gray | Automated tasks |

### Task List (Import-Ready CSV)

```csv
name,tag_ids,predecessor_ids,user_id,date_deadline,description
"Open New Period","[GL][Auto]","","System","Day 1","Unlock new posting period"
"Process Pending Bills","[AP]","","AP Team","Day 1","Review and post vendor invoices"
"Run AP Accruals","[AP][Auto]","Process Pending Bills","System","Day 2","Automated accrual for uninvoiced receipts"
"Vendor Payment Run","[AP]","Process Pending Bills","Treasury","Day 2","Execute payment batch"
"Post Customer Invoices","[AR]","","AR Team","Day 1","Ensure all shipments invoiced"
"Run Dunning","[AR][Auto]","Post Customer Invoices","System","Day 2","Automated payment reminders"
"Revenue Cut-off Review","[AR]","Post Customer Invoices","AR Team","Day 2","Verify revenue recognition"
"Asset Capitalizations","[AA]","","Fixed Assets","Day 2","Capitalize any AUC"
"Depreciation Run","[AA][Auto]","Asset Capitalizations","System","Day 3","Monthly depreciation posting"
"Post Manual Accruals","[GL]","","Accounting","Day 3","Payroll, rent, other accruals"
"Reverse Prior Accruals","[GL][Auto]","","System","Day 1","Auto-reverse prior month"
"Update FX Rates","[GL][Auto]","","System","Day 3","Fetch BSP exchange rates"
"FX Revaluation","[GL][Auto]","Update FX Rates","System","Day 3","Revalue foreign currency"
"Prepare BIR 1601-C","[Tax]","Vendor Payment Run","Tax Team","Day 10","Withholding tax return"
"Prepare BIR 2550Q","[Tax]","Post Customer Invoices,Process Pending Bills","Tax Team","Day 20","VAT return (quarterly)"
"Run Trial Balance","[Report]","FX Revaluation,Depreciation Run","Reporting","Day 5","Verify TB balances"
"Generate Financial Statements","[Report]","Run Trial Balance","Reporting","Day 5","BS, P&L, CF"
"Bank Reconciliation","[Report]","Vendor Payment Run","Treasury","Day 5","Reconcile all bank accounts"
"Management Review","[Report]","Generate Financial Statements","Finance Director","Day 6","Review and approve"
"Close Period","[GL][Auto]","Management Review","System","Day 7","Lock posting period"
```

---

## n8n Automation Workflows

### Workflow 1: Depreciation Run
```
Trigger: Schedule (28th of month, 11 PM)
├── HTTP Request: Odoo API - Get open assets
├── HTTP Request: Odoo API - Compute depreciation
├── IF: Depreciation entries created?
│   ├── Yes → HTTP Request: Post entries
│   └── No → Slack notification: "No depreciation to post"
├── HTTP Request: Odoo API - Update task status
└── Slack notification: "Depreciation run complete"
```

### Workflow 2: BIR Rate Update
```
Trigger: Schedule (Daily, 6 AM)
├── HTTP Request: BSP API - Get exchange rates
├── HTTP Request: Odoo API - Update currency rates
└── IF: Rates changed significantly (>1%)?
    └── Yes → Slack alert: "FX rate movement alert"
```

### Workflow 3: Month-End Reminder
```
Trigger: Schedule (Day 1 of month, 9 AM)
├── HTTP Request: Odoo API - Create task list from template
├── HTTP Request: Odoo API - Assign users
├── FOR EACH: Assigned user
│   └── Email: "Month-end closing tasks assigned"
└── Slack: #finance channel - "Month-end close initiated"
```

---

## Summary: Module Requirements

| Layer | Solution | Custom Code? |
|-------|----------|--------------|
| Project/Tasks | Odoo Project (native) | None |
| Automation | Scheduled Actions, Server Actions | Config only |
| Workflows | n8n external orchestration | Config only |
| AP/AR | Native + OCA | OCA install |
| Assets | Native | None |
| Bank Recon | OCA `account_reconcile_oca` | OCA install |
| Reports | OCA `account_financial_report` | OCA install |
| Excel Export | OCA `report_xlsx` | OCA install |
| Audit Trail | OCA `auditlog` | OCA install |
| FX Rates | OCA `currency_rate_update` | OCA install |
| BIR Exports | **ipai_bir_tax** | ~100 lines |
| BIR 2307 | **ipai_bir_withholding** | ~50 lines |

**Total Custom Code: ~150 lines Python** (2 thin modules for BIR compliance only)

---

## Files to Create

1. `closing_template.xml` - Project template with all tasks
2. `closing_automation.xml` - Scheduled actions
3. `closing_server_actions.xml` - Server actions for manual triggers
4. `n8n_workflows.json` - n8n automation exports

All deliverable via XML data files - no Python models needed except BIR exports.

---

## Related Documentation

- [Month-End Task Template](05-month-end-task-template.md) - Task checklist details
- [Year-End Task Template](06-year-end-task-template.md) - Annual close procedures
- [BIR Tax Filing Process](07-bir-tax-filing-process.md) - Philippine tax compliance
- [Runbook - Monthly Close](09-runbook-monthly-close.md) - Operational procedures

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial SAP AFC mapping |

---

**Document Classification**: Internal - Implementation
**Review Frequency**: Annually
**Next Review Date**: 2026-01-31
**Approver**: Finance Director
