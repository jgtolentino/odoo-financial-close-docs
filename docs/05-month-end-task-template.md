# Month-End Close Task Template

## Document Control

**Version**: 1.0
**Last Updated**: 2025-12-29
**Owner**: Finance SSC Manager
**Approvers**: Finance Manager, Finance Director
**Review Cycle**: Monthly (post-close retrospective)

---

## Executive Summary

This document provides a comprehensive 44-task checklist for month-end financial close operations at TBWA Finance SSC. The template ensures systematic execution, evidence-based validation, and timely completion of all closing activities within the 5-business-day target.

**Target Timeline**: 5 business days from month-end
**Critical Success Factors**:
- Task sequencing adherence (dependencies honored)
- Evidence completeness (all supporting documents attached)
- Approval gates passed (Finance Manager and Finance Director sign-offs)
- BIR compliance validation (withholding tax accuracy ≥98%)

---

## Month-End Close Architecture

### Process Flow Overview

```
Day 1-2: Transaction Cut-off & Reconciliations (Tasks 1-15)
   ↓
Day 2-3: Adjusting Entries & Reclassifications (Tasks 16-25)
   ↓
Day 3-4: Financial Reporting & Analysis (Tasks 26-35)
   ↓
Day 4-5: Review, Approval & BIR Preparation (Tasks 36-44)
```

### Approval Gates

**Gate 1 - Reconciliation Approval** (End of Day 2)
- **Approver**: Finance Manager
- **Criteria**: All bank/GL reconciliations complete with variance ≤0.1%
- **Evidence**: Reconciliation reports with variance analysis

**Gate 2 - Journal Entry Approval** (End of Day 3)
- **Approver**: Finance Manager
- **Criteria**: All adjusting entries posted and balanced
- **Evidence**: JE summary report with supporting documentation

**Gate 3 - Financial Statements Approval** (End of Day 4)
- **Approver**: Finance Director
- **Criteria**: Trial balance balanced, variances explained, commentary complete
- **Evidence**: Full financial package with variance analysis

**Gate 4 - BIR Compliance Approval** (End of Day 5)
- **Approver**: Finance Director
- **Criteria**: BIR 1601-C prepared with accuracy ≥98%, ready for submission
- **Evidence**: BIR form PDF with supporting schedules

---

## Task Checklist (44 Tasks)

### Phase 1: Transaction Cut-off & Reconciliations (Day 1-2)

#### Task 1: Month-End Cut-off Notification
**Owner**: Finance SSC Manager
**Duration**: 15 minutes
**Dependencies**: None
**Timing**: Last business day of month, 4:00 PM

**Procedure**:
1. Send cut-off notification to all stakeholders via Mattermost
2. Specify cut-off time (5:00 PM Philippine time)
3. Remind teams of document submission deadlines
4. Highlight critical deliverables (expense reports, invoices, timesheets)

**Evidence Required**:
- Screenshot of Mattermost notification
- Stakeholder acknowledgment confirmations

**Acceptance Criteria**:
- All 8 agencies acknowledged receipt
- No late submissions flagged in system

---

#### Task 2: Expense Report Validation
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 1 (cut-off notification)
**Timing**: Day 1, 9:00 AM - 11:00 AM

**Procedure**:
1. Query Odoo for all expense reports submitted in closing month
2. Validate OCR confidence scores (minimum 0.60 threshold)
3. Flag reports with missing receipts or policy violations
4. Route flagged reports to employees for correction via n8n workflow
5. Verify all corrections completed before proceeding

**SQL Query**:
```sql
SELECT
  e.name AS expense_report,
  e.employee_id,
  e.total_amount,
  e.state,
  COUNT(l.id) AS line_count,
  AVG(l.ocr_confidence) AS avg_confidence
FROM hr_expense_sheet e
JOIN hr_expense l ON l.sheet_id = e.id
WHERE e.date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
  AND e.date < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY e.id
HAVING AVG(l.ocr_confidence) < 0.60 OR COUNT(l.id) = 0;
```

**Evidence Required**:
- Expense report validation log (CSV export from Odoo)
- OCR confidence score summary
- Flagged report list with resolution status

**Acceptance Criteria**:
- Zero reports with OCR confidence <0.60
- All policy violations resolved or escalated
- Total expense amount matches bank statement deductions

---

#### Task 3: Bank Reconciliation (All Accounts)
**Owner**: Finance Supervisor
**Duration**: 4 hours
**Dependencies**: Task 2 (expense validation)
**Timing**: Day 1, 11:00 AM - 3:00 PM

**Procedure**:
1. Download bank statements for all 12 accounts (8 agencies × 1-2 accounts each)
2. Import statements to Odoo via Supabase ETL pipeline
3. Auto-match transactions using fuzzy matching (threshold: 0.80)
4. Manually investigate unmatched items (variance tolerance: PHP 100)
5. Book adjusting entries for bank charges, interest, errors
6. Generate reconciliation report per account

**Reconciliation Formula**:
```
GL Balance (per Odoo)
+ Outstanding Deposits
- Outstanding Checks
+ Bank Adjustments
= Bank Statement Balance
```

**Evidence Required**:
- Bank statement PDFs (12 files)
- Reconciliation reports (12 reports, one per account)
- Adjusting journal entries (if any)
- Variance analysis (for variances >PHP 100)

**Acceptance Criteria**:
- All accounts reconciled with variance ≤0.1% or PHP 1,000 (whichever lower)
- Outstanding items aged <30 days (older items escalated)
- Finance Manager approval obtained

---

#### Task 4: Accounts Receivable Aging
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 1, 3:00 PM - 5:00 PM

**Procedure**:
1. Generate AR aging report from Odoo (0-30, 31-60, 61-90, 90+ days)
2. Validate customer balances against project management system
3. Identify overdue invoices requiring collection action
4. Flag disputed invoices for management review
5. Calculate bad debt provision (5% for 90+ days, 10% for 180+ days)

**SQL Query**:
```sql
SELECT
  p.name AS customer,
  ai.date_invoice,
  ai.date_due,
  ai.residual AS outstanding_balance,
  CASE
    WHEN CURRENT_DATE - ai.date_due <= 30 THEN '0-30 days'
    WHEN CURRENT_DATE - ai.date_due <= 60 THEN '31-60 days'
    WHEN CURRENT_DATE - ai.date_due <= 90 THEN '61-90 days'
    ELSE '90+ days'
  END AS aging_bucket
FROM account_move ai
JOIN res_partner p ON ai.partner_id = p.id
WHERE ai.move_type = 'out_invoice'
  AND ai.state = 'posted'
  AND ai.residual > 0
ORDER BY ai.date_due;
```

**Evidence Required**:
- AR aging report (Excel with pivot table)
- Overdue invoice list with collection status
- Bad debt provision calculation worksheet

**Acceptance Criteria**:
- Total AR balance ties to GL control account
- Aging bucket totals reconciled to subsidiary ledger
- Bad debt provision reviewed by Finance Manager

---

#### Task 5: Accounts Payable Aging
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 2, 9:00 AM - 11:00 AM

**Procedure**:
1. Generate AP aging report from Odoo (0-30, 31-60, 61-90, 90+ days)
2. Validate vendor balances against purchase order system
3. Identify overdue payables requiring payment prioritization
4. Flag disputed invoices or delivery issues for resolution
5. Verify accruals for goods received not invoiced (GRNI)

**Evidence Required**:
- AP aging report (Excel with pivot table)
- Overdue payable list with payment schedule
- GRNI accrual calculation worksheet

**Acceptance Criteria**:
- Total AP balance ties to GL control account
- Aging bucket totals reconciled to subsidiary ledger
- GRNI accruals reviewed by Finance Manager

---

#### Task 6: Intercompany Reconciliation
**Owner**: Finance Supervisor
**Duration**: 3 hours
**Dependencies**: Task 3, Task 4, Task 5
**Timing**: Day 2, 11:00 AM - 2:00 PM

**Procedure**:
1. Extract intercompany balances from all 8 agency GL accounts
2. Prepare intercompany reconciliation matrix (8×8 grid)
3. Identify mismatches between receivable and payable balances
4. Investigate timing differences (in-transit invoices, FX differences)
5. Book adjusting entries to eliminate reconciling items
6. Obtain confirmations from each agency Finance lead

**Reconciliation Matrix Example**:
```
         CKVC    BOM     JPAL    JLI     ...
CKVC     -       50K    (30K)    0       ...
BOM     (50K)    -       0       20K     ...
JPAL     30K     0       -      (10K)    ...
JLI      0      (20K)    10K     -       ...
```

**Evidence Required**:
- Intercompany reconciliation matrix (Excel)
- Confirmation emails from all agencies
- Adjusting journal entries (if any)
- Variance analysis for mismatches >PHP 10,000

**Acceptance Criteria**:
- All intercompany balances reconciled (variance ≤PHP 5,000)
- Net intercompany position per agency confirmed
- Finance Manager approval obtained

---

#### Task 7: Inventory Reconciliation (Asset-Heavy Agencies)
**Owner**: Finance Analyst
**Duration**: 3 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 2, 2:00 PM - 5:00 PM

**Procedure**:
1. Extract inventory balances from Odoo per agency (if applicable)
2. Reconcile to physical count reports from operations team
3. Calculate inventory variance (physical vs. book)
4. Investigate significant variances (>5% or PHP 50,000)
5. Book adjusting entries for shrinkage, damage, obsolescence
6. Update inventory valuation (FIFO method)

**Inventory Variance Formula**:
```
Variance = Physical Count - Book Balance
Variance % = (Variance / Book Balance) × 100%
```

**Evidence Required**:
- Physical inventory count sheets (signed by operations manager)
- Inventory reconciliation report (Excel)
- Variance investigation notes
- Adjusting journal entries for material variances

**Acceptance Criteria**:
- Inventory balance ties to GL control account
- All variances >5% or PHP 50,000 explained
- Inventory valuation reviewed by Finance Manager

---

#### Task 8: Prepaid Expense Amortization
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 2, 5:00 PM - 7:00 PM (overtime if needed)

**Procedure**:
1. Review prepaid expense register for all agencies
2. Calculate monthly amortization per prepaid item (straight-line)
3. Book amortization journal entries in Odoo
4. Update prepaid balance schedule for next month
5. Flag fully amortized items for reclassification to expense

**Amortization Formula**:
```
Monthly Amortization = Prepaid Balance / Remaining Months
```

**Evidence Required**:
- Prepaid expense register (Excel with amortization schedule)
- Amortization journal entries
- Supporting documents for new prepaid items (invoices, contracts)

**Acceptance Criteria**:
- All prepaid items amortized per policy
- Prepaid balance schedule updated
- Zero prepaid items with negative balances

---

#### Task 9: Accrued Expense Review
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 5 (AP aging)
**Timing**: Day 2, 7:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Review accrued expense accounts (utilities, rent, salaries, professional fees)
2. Validate accrual calculations against contracts and historical trends
3. Book adjusting entries for under/over-accrued amounts
4. Reverse prior month accruals (if reversing entry method used)
5. Update accrual tracking schedule

**Common Accruals**:
- **Utilities**: Estimate based on last 3-month average
- **Rent**: Per lease agreement (monthly rent ÷ days in month × days consumed)
- **Salaries**: Unpaid salaries for last few days of month
- **Professional Fees**: Retainer fees not yet invoiced

**Evidence Required**:
- Accrued expense calculation worksheet (Excel)
- Supporting documents (contracts, invoices, historical data)
- Adjusting journal entries

**Acceptance Criteria**:
- All material accruals booked (threshold: PHP 10,000)
- Accrual methodology documented and consistent
- Finance Manager approval obtained

---

#### Task 10: Fixed Asset Depreciation
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 3, 9:00 AM - 11:00 AM

**Procedure**:
1. Run Odoo fixed asset depreciation batch job for closing month
2. Validate depreciation calculations (straight-line method)
3. Review newly capitalized assets (additions in closing month)
4. Flag fully depreciated assets for disposal consideration
5. Post depreciation journal entries

**Depreciation Formula (Straight-Line)**:
```
Monthly Depreciation = (Cost - Salvage Value) / Useful Life (months)
```

**Useful Life Standards**:
- Computer equipment: 3 years (36 months)
- Furniture and fixtures: 5 years (60 months)
- Vehicles: 5 years (60 months)
- Leasehold improvements: Lesser of lease term or 10 years

**Evidence Required**:
- Fixed asset register with depreciation schedule
- Depreciation journal entry summary
- New asset capitalization forms (if any)

**Acceptance Criteria**:
- Depreciation expense matches asset register calculation
- All new assets capitalized with proper approval
- Fixed asset balance ties to GL control account

---

#### Task 11: Payroll Reconciliation
**Owner**: Finance Supervisor
**Duration**: 3 hours
**Dependencies**: Task 9 (accrued expenses)
**Timing**: Day 3, 11:00 AM - 2:00 PM

**Procedure**:
1. Extract payroll summary from payroll system (8 employees)
2. Reconcile gross salaries to GL payroll expense accounts
3. Validate payroll deductions (SSS, PhilHealth, Pag-IBIG, withholding tax)
4. Verify employer contributions and book accrual if unpaid
5. Reconcile net pay to bank disbursements
6. Book adjusting entries for timing differences

**Payroll Reconciliation Formula**:
```
Gross Salaries
- Employee Deductions (SSS, PhilHealth, Pag-IBIG, WHT)
= Net Pay (must equal bank disbursement)

Employer Contributions:
+ SSS Employer Share
+ PhilHealth Employer Share
+ Pag-IBIG Employer Share
= Total Employer Liability (accrue if unpaid)
```

**Evidence Required**:
- Payroll register (PDF from payroll system)
- Payroll reconciliation worksheet (Excel)
- Bank disbursement confirmations
- Employer contribution calculation worksheet

**Acceptance Criteria**:
- Payroll expense ties to payroll register
- Net pay matches bank disbursements
- All payroll taxes and contributions accrued
- Finance Manager approval obtained

---

#### Task 12: Revenue Recognition Review
**Owner**: Finance Analyst
**Duration**: 3 hours
**Dependencies**: Task 4 (AR aging)
**Timing**: Day 3, 2:00 PM - 5:00 PM

**Procedure**:
1. Review project revenue recognition per agency (percentage of completion method)
2. Validate project billing milestones against contracts
3. Calculate unbilled revenue (work performed but not yet invoiced)
4. Book deferred revenue for advance billings
5. Reconcile revenue to project management system

**Revenue Recognition Formula (Percentage of Completion)**:
```
Revenue Recognized = Contract Value × (Actual Costs / Total Estimated Costs)
Unbilled Revenue = Revenue Recognized - Billed to Date
```

**Evidence Required**:
- Project revenue schedule (Excel with percentage completion)
- Contract milestone documentation
- Unbilled/deferred revenue calculation worksheet
- Reconciliation to project management system

**Acceptance Criteria**:
- Revenue recognized per policy (percentage of completion)
- Unbilled/deferred revenue balances validated
- Revenue variance to budget explained
- Finance Manager approval obtained

---

#### Task 13: Credit Card Reconciliation
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 2 (expense validation)
**Timing**: Day 3, 5:00 PM - 7:00 PM (overtime if needed)

**Procedure**:
1. Download credit card statements for all corporate cards (8 employees)
2. Match transactions to expense reports in Odoo
3. Identify unmatched transactions and request employee clarification
4. Verify all personal charges have been reimbursed by employees
5. Book adjusting entries for timing differences (charges posted after month-end)

**Evidence Required**:
- Credit card statements (8 PDFs)
- Credit card reconciliation report (Excel)
- Unmatched transaction list with resolution notes
- Employee reimbursement confirmations (for personal charges)

**Acceptance Criteria**:
- All credit card charges matched to expense reports
- Personal charges reimbursed or deducted from payroll
- Credit card liability balance ties to statements
- Finance Manager approval obtained

---

#### Task 14: Petty Cash Reconciliation
**Owner**: Finance Supervisor
**Duration**: 1 hour
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 3, 7:00 PM - 8:00 PM (overtime if needed)

**Procedure**:
1. Count physical petty cash per agency (if applicable)
2. Reconcile to petty cash GL account balance
3. Review petty cash vouchers for closing month
4. Book replenishment journal entry
5. Update petty cash custodian log

**Petty Cash Reconciliation Formula**:
```
Beginning Balance
+ Replenishments
- Disbursements (per vouchers)
= Ending Balance (must equal physical count)
```

**Evidence Required**:
- Petty cash count sheet (signed by custodian)
- Petty cash vouchers (receipts attached)
- Replenishment journal entry

**Acceptance Criteria**:
- Physical count matches GL balance
- All disbursements supported by receipts
- Petty cash limit not exceeded (PHP 10,000 per agency)

---

#### Task 15: Reconciliation Approval Gate (Gate 1)
**Owner**: Finance Manager
**Duration**: 1 hour
**Dependencies**: Tasks 3-14 (all reconciliations)
**Timing**: Day 3, 8:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Review all reconciliation reports (bank, AR, AP, inventory, etc.)
2. Validate variance analyses and explanations
3. Approve or reject reconciliations based on materiality thresholds
4. Document approval decision in Odoo task record
5. Escalate material issues to Finance Director if needed

**Approval Criteria**:
- All reconciliations complete with variance ≤0.1%
- Material variances (>PHP 10,000 or >5%) explained
- Supporting evidence attached to each reconciliation

**Evidence Required**:
- Approval sign-off in Odoo (digital signature)
- Reconciliation summary report (all accounts)
- Escalation notes (if any)

**Outcome**:
- **Approved**: Proceed to Phase 2 (adjusting entries)
- **Rejected**: Return to respective tasks for correction

---

### Phase 2: Adjusting Entries & Reclassifications (Day 3-4)

#### Task 16: Accrual Journal Entries
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 15 (Gate 1 approval)
**Timing**: Day 3, 9:00 PM - 11:00 PM (overtime if needed)

**Procedure**:
1. Prepare accrual journal entries for all accrued expenses (from Task 9)
2. Validate account codes and cost center allocations
3. Post entries in Odoo with supporting documentation
4. Update accrual tracking schedule
5. Generate JE summary report for Finance Manager review

**Standard Journal Entry Format**:
```
Debit: Expense Account (6xxxx)   PHP XXX,XXX.XX
  Credit: Accrued Liability (2xxxx)   PHP XXX,XXX.XX
Narration: "To accrue [expense type] for [month/year] per [supporting doc]"
```

**Evidence Required**:
- Journal entry listing (from Odoo)
- Supporting documentation per entry (contracts, calculations)
- Accrual tracking schedule (updated)

**Acceptance Criteria**:
- All material accruals booked (threshold: PHP 10,000)
- Journal entries balanced (debits = credits)
- Supporting documentation attached in Odoo

---

#### Task 17: Prepaid Amortization Entries
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 8 (prepaid amortization)
**Timing**: Day 4, 9:00 AM - 10:00 AM

**Procedure**:
1. Post prepaid amortization journal entries (from Task 8)
2. Validate amortization calculations and allocations
3. Update prepaid balance schedule in Odoo
4. Generate amortization summary report

**Standard Journal Entry Format**:
```
Debit: Expense Account (6xxxx)   PHP XXX,XXX.XX
  Credit: Prepaid Asset (1xxxx)   PHP XXX,XXX.XX
Narration: "To amortize prepaid [expense type] for [month/year]"
```

**Evidence Required**:
- Amortization journal entries (from Odoo)
- Prepaid balance schedule (updated)

**Acceptance Criteria**:
- All prepaid items amortized per schedule
- Prepaid balances reduced correctly

---

#### Task 18: Depreciation Journal Entries
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 10 (depreciation calculation)
**Timing**: Day 4, 10:00 AM - 11:00 AM

**Procedure**:
1. Post depreciation journal entries (from Task 10)
2. Validate depreciation expense allocation to cost centers
3. Update fixed asset register in Odoo
4. Generate depreciation summary report

**Standard Journal Entry Format**:
```
Debit: Depreciation Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Accumulated Depreciation (1xxxx)   PHP XXX,XXX.XX
Narration: "To record depreciation for [month/year] per fixed asset register"
```

**Evidence Required**:
- Depreciation journal entries (from Odoo)
- Fixed asset register (updated)

**Acceptance Criteria**:
- Depreciation expense matches asset register
- Accumulated depreciation balances updated

---

#### Task 19: Revenue Adjustment Entries
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 12 (revenue recognition review)
**Timing**: Day 4, 11:00 AM - 1:00 PM

**Procedure**:
1. Post unbilled revenue and deferred revenue entries (from Task 12)
2. Validate revenue recognition per contract terms
3. Reconcile to project management system
4. Generate revenue adjustment summary report

**Unbilled Revenue Entry**:
```
Debit: Unbilled Revenue (1xxxx)   PHP XXX,XXX.XX
  Credit: Service Revenue (4xxxx)   PHP XXX,XXX.XX
Narration: "To recognize unbilled revenue for [project] per POC method"
```

**Deferred Revenue Entry**:
```
Debit: Cash/AR (1xxxx)   PHP XXX,XXX.XX
  Credit: Deferred Revenue (2xxxx)   PHP XXX,XXX.XX
Narration: "To defer advance billing for [project] pending delivery"
```

**Evidence Required**:
- Revenue adjustment journal entries
- Project revenue schedule (from Task 12)
- Contract milestone documentation

**Acceptance Criteria**:
- Revenue recognized per policy
- Unbilled/deferred balances validated

---

#### Task 20: Intercompany Elimination Entries
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 6 (intercompany reconciliation)
**Timing**: Day 4, 1:00 PM - 3:00 PM

**Procedure**:
1. Prepare elimination journal entries for intercompany balances
2. Validate elimination amounts against reconciliation matrix (Task 6)
3. Post entries in consolidated GL (if applicable)
4. Generate elimination summary report

**Standard Elimination Entry**:
```
Debit: Intercompany Payable (2xxxx)   PHP XXX,XXX.XX
  Credit: Intercompany Receivable (1xxxx)   PHP XXX,XXX.XX
Narration: "To eliminate intercompany balance between [Agency A] and [Agency B]"
```

**Evidence Required**:
- Elimination journal entries
- Intercompany reconciliation matrix (from Task 6)

**Acceptance Criteria**:
- All intercompany balances eliminated in consolidation
- Net intercompany position per agency confirmed

---

#### Task 21: Reclassification Entries
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Tasks 4, 5 (AR/AP aging)
**Timing**: Day 4, 3:00 PM - 5:00 PM

**Procedure**:
1. Review aging reports for reclassification needs (current vs. non-current)
2. Reclassify long-term debt due within 12 months to current liability
3. Reclassify long-term receivables due within 12 months to current asset
4. Post reclassification journal entries
5. Update balance sheet classification schedule

**Standard Reclassification Entry**:
```
Debit: Current Portion of Long-Term Debt (2xxxx)   PHP XXX,XXX.XX
  Credit: Long-Term Debt (2xxxx)   PHP XXX,XXX.XX
Narration: "To reclassify debt maturing within 12 months per loan agreement"
```

**Evidence Required**:
- Reclassification journal entries
- Loan amortization schedules
- Balance sheet classification schedule

**Acceptance Criteria**:
- All debt/receivables properly classified (current vs. non-current)
- Supporting documentation attached

---

#### Task 22: Foreign Exchange Revaluation
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 3 (bank reconciliation)
**Timing**: Day 4, 5:00 PM - 7:00 PM (overtime if needed)

**Procedure**:
1. Identify foreign currency balances (USD, EUR, JPY, etc.)
2. Obtain month-end exchange rates from BSP (Bangko Sentral ng Pilipinas)
3. Calculate unrealized FX gain/loss per currency balance
4. Post revaluation journal entries
5. Update FX revaluation schedule

**FX Revaluation Formula**:
```
Unrealized Gain/Loss = (Month-End Rate - Book Rate) × Foreign Currency Balance
```

**Standard Revaluation Entry**:
```
Debit: Foreign Currency Asset/Liability   PHP XXX,XXX.XX
  Credit: Unrealized FX Gain (4xxxx)   PHP XXX,XXX.XX
(or reverse if loss)
Narration: "To revalue [currency] balances at BSP rate of [rate] as of [date]"
```

**Evidence Required**:
- BSP exchange rate confirmation (screenshot from BSP website)
- FX revaluation calculation worksheet
- Revaluation journal entries

**Acceptance Criteria**:
- All foreign currency balances revalued at month-end rates
- FX gain/loss properly classified (realized vs. unrealized)

---

#### Task 23: Bad Debt Provision Entry
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 4 (AR aging)
**Timing**: Day 4, 7:00 PM - 8:00 PM (overtime if needed)

**Procedure**:
1. Calculate bad debt provision per aging analysis (Task 4)
2. Compare to existing allowance for doubtful accounts balance
3. Book adjusting entry for under/over-provision
4. Update bad debt provision schedule

**Provision Rates**:
- 0-60 days: 0% (fully collectible)
- 61-90 days: 5% (management estimate)
- 91-180 days: 10% (management estimate)
- 180+ days: 50% (likely uncollectible)

**Standard Provision Entry**:
```
Debit: Bad Debt Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Allowance for Doubtful Accounts (1xxxx)   PHP XXX,XXX.XX
Narration: "To record bad debt provision for [month/year] per aging analysis"
```

**Evidence Required**:
- Bad debt provision calculation (from Task 4)
- Journal entry
- Bad debt provision schedule (updated)

**Acceptance Criteria**:
- Provision calculation methodology documented
- Provision rates approved by Finance Manager

---

#### Task 24: Tax Provision Calculation
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 19 (revenue adjustment)
**Timing**: Day 4, 8:00 PM - 10:00 PM (overtime if needed)

**Procedure**:
1. Calculate taxable income per agency (accounting income ± tax adjustments)
2. Apply income tax rate (25% regular corporate tax or 20% OSD)
3. Calculate quarterly income tax provision
4. Book tax provision journal entry
5. Update tax provision schedule

**Tax Provision Formula**:
```
Taxable Income = Accounting Income + Non-Deductible Expenses - Tax-Exempt Income
Income Tax Provision = Taxable Income × Tax Rate
```

**Standard Tax Provision Entry**:
```
Debit: Income Tax Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Income Tax Payable (2xxxx)   PHP XXX,XXX.XX
Narration: "To record income tax provision for [quarter/year] at [rate]%"
```

**Evidence Required**:
- Tax provision calculation worksheet
- Tax adjustment schedule
- Journal entry

**Acceptance Criteria**:
- Tax provision calculated per BIR regulations
- Tax rate validated (regular vs. OSD)
- Finance Manager approval obtained

---

#### Task 25: Journal Entry Approval Gate (Gate 2)
**Owner**: Finance Manager
**Duration**: 1 hour
**Dependencies**: Tasks 16-24 (all adjusting entries)
**Timing**: Day 4, 10:00 PM - 11:00 PM (overtime if needed)

**Procedure**:
1. Review all journal entries posted in closing month
2. Validate account codes, amounts, and supporting documentation
3. Verify all entries balanced (debits = credits)
4. Approve or reject entries based on materiality and policy compliance
5. Document approval decision in Odoo

**Approval Criteria**:
- All entries balanced and properly coded
- Supporting documentation attached
- Material entries (>PHP 50,000) reviewed in detail

**Evidence Required**:
- Journal entry summary report (from Odoo)
- Approval sign-off (digital signature)

**Outcome**:
- **Approved**: Proceed to Phase 3 (financial reporting)
- **Rejected**: Return to respective tasks for correction

---

### Phase 3: Financial Reporting & Analysis (Day 4-5)

#### Task 26: Trial Balance Generation
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 25 (Gate 2 approval)
**Timing**: Day 5, 9:00 AM - 10:00 AM

**Procedure**:
1. Generate trial balance report from Odoo for closing month
2. Validate trial balance balanced (total debits = total credits)
3. Compare to prior month trial balance for reasonableness
4. Flag unusual account balances for investigation
5. Export trial balance to Excel for financial statement preparation

**Trial Balance Validation Checks**:
- Total debits = Total credits (must balance)
- No negative balances in asset/expense accounts (investigate if found)
- No negative balances in liability/equity/revenue accounts (investigate if found)

**Evidence Required**:
- Trial balance report (PDF from Odoo)
- Trial balance comparison (current vs. prior month)
- Investigation notes for unusual balances

**Acceptance Criteria**:
- Trial balance balanced (zero variance)
- All account balances reasonable and explainable

---

#### Task 27: Balance Sheet Preparation
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 26 (trial balance)
**Timing**: Day 5, 10:00 AM - 12:00 PM

**Procedure**:
1. Prepare balance sheet from trial balance data
2. Apply standard balance sheet format (assets, liabilities, equity)
3. Classify accounts (current vs. non-current)
4. Calculate key financial ratios (current ratio, debt-to-equity, etc.)
5. Add footnotes for significant balances

**Balance Sheet Format**:
```
ASSETS
Current Assets
  Cash and Cash Equivalents      PHP XXX,XXX
  Accounts Receivable (net)      PHP XXX,XXX
  Inventory                      PHP XXX,XXX
  Prepaid Expenses               PHP XXX,XXX
Total Current Assets             PHP XXX,XXX

Non-Current Assets
  Fixed Assets (net)             PHP XXX,XXX
  Intangible Assets              PHP XXX,XXX
Total Non-Current Assets         PHP XXX,XXX
TOTAL ASSETS                     PHP XXX,XXX

LIABILITIES AND EQUITY
Current Liabilities
  Accounts Payable               PHP XXX,XXX
  Accrued Expenses               PHP XXX,XXX
  Current Portion of LT Debt     PHP XXX,XXX
Total Current Liabilities        PHP XXX,XXX

Non-Current Liabilities
  Long-Term Debt                 PHP XXX,XXX
Total Non-Current Liabilities    PHP XXX,XXX

Equity
  Share Capital                  PHP XXX,XXX
  Retained Earnings              PHP XXX,XXX
Total Equity                     PHP XXX,XXX
TOTAL LIABILITIES AND EQUITY     PHP XXX,XXX
```

**Key Financial Ratios**:
- Current Ratio = Current Assets / Current Liabilities (target: ≥1.5)
- Quick Ratio = (Current Assets - Inventory) / Current Liabilities (target: ≥1.0)
- Debt-to-Equity = Total Liabilities / Total Equity (target: ≤2.0)

**Evidence Required**:
- Balance sheet (Excel with formulas)
- Financial ratio calculation worksheet

**Acceptance Criteria**:
- Balance sheet balanced (assets = liabilities + equity)
- All accounts properly classified
- Financial ratios within policy targets

---

#### Task 28: Income Statement Preparation
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 26 (trial balance)
**Timing**: Day 5, 12:00 PM - 2:00 PM

**Procedure**:
1. Prepare income statement from trial balance data
2. Apply standard income statement format (revenue, expenses, net income)
3. Calculate gross profit, operating profit, net profit margins
4. Compare to budget and explain significant variances (>10%)
5. Add footnotes for non-recurring items

**Income Statement Format**:
```
REVENUE
Service Revenue                  PHP XXX,XXX
Other Revenue                    PHP XXX,XXX
Total Revenue                    PHP XXX,XXX

COST OF SERVICES
Direct Labor                     PHP XXX,XXX
Direct Materials                 PHP XXX,XXX
Total Cost of Services           PHP XXX,XXX

GROSS PROFIT                     PHP XXX,XXX
Gross Profit Margin              XX.X%

OPERATING EXPENSES
Salaries and Wages               PHP XXX,XXX
Rent                             PHP XXX,XXX
Utilities                        PHP XXX,XXX
Depreciation                     PHP XXX,XXX
Other Operating Expenses         PHP XXX,XXX
Total Operating Expenses         PHP XXX,XXX

OPERATING PROFIT                 PHP XXX,XXX
Operating Profit Margin          XX.X%

OTHER INCOME/(EXPENSES)
Interest Income                  PHP XXX,XXX
Interest Expense                 (PHP XXX,XXX)
FX Gain/(Loss)                   PHP XXX,XXX
Total Other Income/(Expenses)    PHP XXX,XXX

NET INCOME BEFORE TAX            PHP XXX,XXX
Income Tax Expense               (PHP XXX,XXX)
NET INCOME                       PHP XXX,XXX
Net Profit Margin                XX.X%
```

**Key Performance Metrics**:
- Gross Profit Margin = Gross Profit / Revenue (target: ≥40%)
- Operating Profit Margin = Operating Profit / Revenue (target: ≥15%)
- Net Profit Margin = Net Income / Revenue (target: ≥10%)

**Evidence Required**:
- Income statement (Excel with formulas)
- Budget variance analysis (actual vs. budget)

**Acceptance Criteria**:
- Income statement mathematically correct
- Margins within policy targets
- Budget variances >10% explained

---

#### Task 29: Cash Flow Statement Preparation
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 26, 27, 28 (trial balance, balance sheet, income statement)
**Timing**: Day 5, 2:00 PM - 4:00 PM

**Procedure**:
1. Prepare cash flow statement using indirect method
2. Reconcile net income to operating cash flow
3. Identify investing and financing activities
4. Validate ending cash balance to balance sheet
5. Calculate free cash flow

**Cash Flow Statement Format (Indirect Method)**:
```
OPERATING ACTIVITIES
Net Income                       PHP XXX,XXX
Adjustments:
  Depreciation                   PHP XXX,XXX
  Changes in Working Capital:
    (Increase)/Decrease in AR    (PHP XXX,XXX)
    (Increase)/Decrease in Inv   (PHP XXX,XXX)
    Increase/(Decrease) in AP    PHP XXX,XXX
Net Cash from Operations         PHP XXX,XXX

INVESTING ACTIVITIES
Purchase of Fixed Assets         (PHP XXX,XXX)
Proceeds from Asset Disposal     PHP XXX,XXX
Net Cash from Investing          (PHP XXX,XXX)

FINANCING ACTIVITIES
Proceeds from Long-Term Debt     PHP XXX,XXX
Repayment of Long-Term Debt      (PHP XXX,XXX)
Dividends Paid                   (PHP XXX,XXX)
Net Cash from Financing          (PHP XXX,XXX)

NET CHANGE IN CASH               PHP XXX,XXX
Cash - Beginning of Period       PHP XXX,XXX
Cash - End of Period             PHP XXX,XXX
```

**Free Cash Flow Formula**:
```
Free Cash Flow = Operating Cash Flow - Capital Expenditures
```

**Evidence Required**:
- Cash flow statement (Excel with formulas)
- Cash reconciliation to balance sheet

**Acceptance Criteria**:
- Cash flow statement reconciles to balance sheet cash balance
- Operating cash flow positive (target)
- Free cash flow calculated

---

#### Task 30: Financial Statement Consolidation (Multi-Agency)
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Tasks 27, 28, 29 (all financial statements)
**Timing**: Day 5, 4:00 PM - 6:00 PM (overtime if needed)

**Procedure**:
1. Consolidate financial statements for all 8 agencies
2. Eliminate intercompany balances and transactions
3. Calculate consolidated financial ratios
4. Prepare consolidation workpaper
5. Generate consolidated financial package

**Consolidation Adjustments**:
- Eliminate intercompany receivables/payables (from Task 20)
- Eliminate intercompany revenue/expenses
- Adjust for minority interests (if applicable)

**Evidence Required**:
- Consolidation workpaper (Excel with elimination entries)
- Consolidated financial statements (balance sheet, income statement, cash flow)

**Acceptance Criteria**:
- All intercompany balances eliminated
- Consolidated statements balanced
- Consolidation methodology documented

---

#### Task 31: Variance Analysis (Actual vs. Budget)
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 28 (income statement)
**Timing**: Day 5, 6:00 PM - 8:00 PM (overtime if needed)

**Procedure**:
1. Prepare variance analysis report (actual vs. budget)
2. Calculate variances for revenue and expense line items
3. Classify variances (favorable vs. unfavorable)
4. Investigate and document variances >10% or PHP 100,000
5. Prepare management commentary for significant variances

**Variance Analysis Format**:
```
Account          Budget    Actual    Variance   Variance%   F/U
Service Revenue  1,000,000 1,100,000 100,000    10.0%       F
Direct Labor     400,000   420,000   20,000     5.0%        U
Rent             80,000    82,000    2,000      2.5%        U
...
```

**Variance Investigation Thresholds**:
- Revenue: Variance >10% or PHP 100,000
- Expenses: Variance >10% or PHP 50,000

**Evidence Required**:
- Variance analysis report (Excel)
- Management commentary for significant variances

**Acceptance Criteria**:
- All material variances (>10%) explained
- Commentary clear and actionable

---

#### Task 32: Key Performance Indicator (KPI) Dashboard
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Tasks 27, 28 (balance sheet, income statement)
**Timing**: Day 5, 8:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Calculate KPIs for closing month
2. Compare to prior month and budget targets
3. Update KPI dashboard in Apache Superset
4. Generate KPI summary report
5. Flag KPIs not meeting targets for management attention

**Key Performance Indicators**:
- **Revenue Growth**: (Current Month Revenue - Prior Month Revenue) / Prior Month Revenue
- **Gross Profit Margin**: Gross Profit / Revenue
- **Operating Profit Margin**: Operating Profit / Revenue
- **Net Profit Margin**: Net Income / Revenue
- **Current Ratio**: Current Assets / Current Liabilities
- **Days Sales Outstanding (DSO)**: (AR / Revenue) × 30 days
- **Days Payable Outstanding (DPO)**: (AP / COGS) × 30 days
- **Cash Conversion Cycle**: DSO + DIO - DPO

**Evidence Required**:
- KPI calculation worksheet (Excel)
- KPI dashboard screenshot (from Superset)

**Acceptance Criteria**:
- All KPIs calculated accurately
- Dashboard updated and accessible
- KPIs not meeting targets flagged

---

#### Task 33: Management Commentary Report
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 31 (variance analysis)
**Timing**: Day 5, 9:00 PM - 11:00 PM (overtime if needed)

**Procedure**:
1. Draft management commentary for financial statements
2. Summarize financial performance highlights
3. Explain significant variances and unusual items
4. Discuss financial position and liquidity
5. Outline key risks and opportunities for next month

**Management Commentary Outline**:
1. **Executive Summary** (1 paragraph)
2. **Financial Performance** (revenue, expenses, profitability)
3. **Financial Position** (assets, liabilities, equity)
4. **Cash Flow and Liquidity** (operating cash flow, free cash flow)
5. **Key Variances** (actual vs. budget explanations)
6. **Risks and Opportunities** (forward-looking statements)

**Evidence Required**:
- Management commentary report (Word document)

**Acceptance Criteria**:
- Commentary clear, concise, and insightful
- All significant variances explained
- Approved by Finance Director

---

#### Task 34: Financial Package Assembly
**Owner**: Finance Supervisor
**Duration**: 1 hour
**Dependencies**: Tasks 27-33 (all financial statements and reports)
**Timing**: Day 5, 11:00 PM - 12:00 AM (overnight if needed)

**Procedure**:
1. Assemble complete financial package (PDF)
2. Include all financial statements (balance sheet, income statement, cash flow)
3. Include supporting schedules (trial balance, variance analysis, KPI dashboard)
4. Include management commentary
5. Add table of contents and executive summary
6. Generate PDF and upload to shared drive

**Financial Package Contents**:
1. Cover page (month/year, agency, date prepared)
2. Table of contents
3. Executive summary
4. Balance sheet
5. Income statement
6. Cash flow statement
7. Trial balance
8. Variance analysis
9. KPI dashboard
10. Management commentary
11. Supporting schedules (reconciliations, aging reports, etc.)

**Evidence Required**:
- Complete financial package (PDF)
- Upload confirmation (shared drive link)

**Acceptance Criteria**:
- All sections included and properly formatted
- PDF accessible to stakeholders
- File naming convention followed (YYYYMM_FinancialPackage_[Agency].pdf)

---

#### Task 35: Financial Statements Approval Gate (Gate 3)
**Owner**: Finance Director
**Duration**: 2 hours
**Dependencies**: Task 34 (financial package assembly)
**Timing**: Day 5, 12:00 AM - 2:00 AM (overnight if needed)

**Procedure**:
1. Review complete financial package
2. Validate financial statements for accuracy and completeness
3. Review management commentary for reasonableness
4. Assess compliance with accounting standards (PFRS/IFRS)
5. Approve or reject financial statements
6. Document approval decision in Odoo

**Approval Criteria**:
- Financial statements accurate and complete
- All material variances explained
- Compliance with accounting standards
- Management commentary clear and insightful

**Evidence Required**:
- Approval sign-off (digital signature)
- Approval memo (Word document)

**Outcome**:
- **Approved**: Proceed to Phase 4 (BIR preparation)
- **Rejected**: Return to financial reporting tasks for revision

---

### Phase 4: Review, Approval & BIR Preparation (Day 5)

#### Task 36: BIR 1601-C Preparation (Withholding Tax)
**Owner**: Finance Supervisor
**Duration**: 3 hours
**Dependencies**: Task 35 (Gate 3 approval)
**Timing**: Day 5, 2:00 AM - 5:00 AM (overnight if needed)

**Procedure**:
1. Extract withholding tax data from Odoo for closing month
2. Classify withholding taxes by type (compensation, professional fees, etc.)
3. Calculate total withholding tax per BIR tax code
4. Prepare BIR Form 1601-C using n8n workflow
5. Generate supporting schedules (alphalist of payees)
6. Validate accuracy against payroll and vendor payment records

**BIR 1601-C Sections**:
- **Part I**: Monthly Remittance Return of Income Taxes Withheld
- **Part II**: Breakdown of taxes withheld by type
  - WC010: Compensation (salaries)
  - WC020: Professional fees
  - WC030: Rentals
  - WC040: Dividends
  - ... (other tax codes as applicable)

**Accuracy Validation Formula**:
```
Total WHT per BIR Form = Sum of WHT per Odoo GL Account
Accuracy % = (BIR Form Amount / Odoo Amount) × 100%
Target: ≥98% accuracy
```

**Evidence Required**:
- BIR Form 1601-C (PDF)
- Alphalist of payees (Excel)
- Withholding tax computation worksheet
- Reconciliation to Odoo GL (variance report)

**Acceptance Criteria**:
- BIR form completed with all required fields
- Accuracy ≥98% (variance ≤2%)
- Supporting schedules attached
- Finance Director approval obtained

---

#### Task 37: Multi-Employee BIR Consolidation
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 36 (BIR 1601-C preparation)
**Timing**: Day 5, 5:00 AM - 7:00 AM (overnight if needed)

**Procedure**:
1. Consolidate BIR 1601-C forms for all 8 employees (RIM, CKVC, BOM, JPAL, JLI, JAP, LAS, RMQB)
2. Validate each employee's form for completeness and accuracy
3. Prepare consolidated summary report
4. Generate individual and consolidated PDFs
5. Upload to Supabase storage for audit trail

**Consolidation Summary Format**:
```
Employee  TIN          Total WHT    Status      Validation
RIM       XXX-XXX-XXX  PHP XXX,XXX  Approved    ✅
CKVC      XXX-XXX-XXX  PHP XXX,XXX  Approved    ✅
BOM       XXX-XXX-XXX  PHP XXX,XXX  Approved    ✅
...
TOTAL                  PHP X,XXX,XXX
```

**Evidence Required**:
- Consolidated BIR summary report (Excel)
- Individual BIR forms (8 PDFs)
- Upload confirmation (Supabase storage link)

**Acceptance Criteria**:
- All 8 employee forms completed and validated
- Consolidated total matches sum of individual forms
- All forms uploaded to Supabase

---

#### Task 38: BIR Filing Preparation (Payment & Submission)
**Owner**: Finance Supervisor
**Duration**: 1 hour
**Dependencies**: Task 37 (multi-employee consolidation)
**Timing**: Day 5, 7:00 AM - 8:00 AM

**Procedure**:
1. Calculate total BIR tax payable for closing month
2. Prepare payment instruction for bank (online or over-the-counter)
3. Generate BIR payment form (if manual payment)
4. Coordinate with bank for tax remittance
5. Obtain payment confirmation and reference number

**BIR Payment Methods**:
- **eBIRForms**: Electronic filing and payment (preferred)
- **Authorized Agent Banks**: Over-the-counter payment with BIR form
- **Online Banking**: GCash, BDO Online, BPI Online (select banks)

**Evidence Required**:
- BIR payment confirmation (screenshot or receipt)
- Bank transaction reference number

**Acceptance Criteria**:
- Payment completed on or before BIR deadline (10th of following month)
- Payment confirmation obtained

---

#### Task 39: BIR Submission Tracking
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 38 (BIR filing preparation)
**Timing**: Day 5, 8:00 AM - 9:00 AM

**Procedure**:
1. Log BIR submission in tracking system (Odoo or Supabase)
2. Update BIR schedule table with submission status
3. Set reminder for BIR filing deadline (10th of following month)
4. Generate BIR submission summary report
5. Send Mattermost notification to stakeholders

**BIR Submission Log Fields**:
- Form type (1601-C)
- Period covered (YYYY-MM)
- Employee/Agency
- Total tax amount
- Filing status (prepared, filed, paid)
- Filing date
- Payment reference number

**Evidence Required**:
- BIR submission log (screenshot from Odoo)
- Mattermost notification confirmation

**Acceptance Criteria**:
- All submissions logged in tracking system
- Reminder set for filing deadline
- Stakeholders notified

---

#### Task 40: Closing Checklist Review
**Owner**: Finance Manager
**Duration**: 1 hour
**Dependencies**: All prior tasks (1-39)
**Timing**: Day 5, 9:00 AM - 10:00 AM

**Procedure**:
1. Review month-end close checklist (all 44 tasks)
2. Validate completion status and evidence for each task
3. Identify any incomplete or non-compliant tasks
4. Escalate issues to Finance Director if needed
5. Document overall close status and lessons learned

**Checklist Review Criteria**:
- **Complete**: Task finished with evidence attached
- **In Progress**: Task started but not yet complete (flag for follow-up)
- **Not Started**: Task not yet initiated (escalate)
- **Blocked**: Task waiting on external input (escalate)

**Evidence Required**:
- Checklist review summary (Excel with task status)
- Lessons learned notes (Word document)

**Acceptance Criteria**:
- All 44 tasks reviewed
- Incomplete tasks escalated
- Close status documented

---

#### Task 41: Supabase Data Sync Validation
**Owner**: Finance Analyst
**Duration**: 1 hour
**Dependencies**: Task 34 (financial package)
**Timing**: Day 5, 10:00 AM - 11:00 AM

**Procedure**:
1. Verify financial data synced from Odoo to Supabase
2. Validate ETL pipeline success (Bronze → Silver → Gold)
3. Check data quality metrics in `scout.data_quality_metrics`
4. Run reconciliation queries (Odoo totals vs. Supabase totals)
5. Generate data sync validation report

**Key Validation Queries**:
```sql
-- Validate revenue sync
SELECT
  SUM(amount) AS total_revenue_supabase
FROM scout.silver_transactions
WHERE transaction_type = 'revenue'
  AND period = '2025-12';

-- Compare to Odoo GL total
-- Revenue variance = Supabase Total - Odoo Total
-- Target: Variance ≤ 0.1%
```

**Evidence Required**:
- Data sync validation report (SQL query results)
- ETL pipeline log (from Supabase)
- Variance analysis (Odoo vs. Supabase)

**Acceptance Criteria**:
- All data synced successfully (no ETL errors)
- Variance between Odoo and Supabase ≤0.1%
- Data quality metrics green (completeness ≥95%, consistency ≥98%)

---

#### Task 42: Month-End Close Summary Report
**Owner**: Finance Manager
**Duration**: 1 hour
**Dependencies**: Task 40 (checklist review)
**Timing**: Day 5, 11:00 AM - 12:00 PM

**Procedure**:
1. Prepare month-end close summary report for Finance Director
2. Summarize key financial results (revenue, expenses, net income)
3. Highlight significant variances and unusual items
4. Report on close process efficiency (on-time completion, issues)
5. Provide recommendations for next month's close

**Close Summary Report Outline**:
1. **Close Status**: On-time / Delayed (with reason)
2. **Financial Highlights**: Key results and variances
3. **Process Efficiency**: Task completion timeline, bottlenecks
4. **Issues and Resolutions**: Problems encountered and how resolved
5. **Recommendations**: Process improvements for next close

**Evidence Required**:
- Month-end close summary report (Word/PDF)

**Acceptance Criteria**:
- Summary report complete and accurate
- Recommendations actionable and specific

---

#### Task 43: Stakeholder Communication
**Owner**: Finance Director
**Duration**: 1 hour
**Dependencies**: Task 42 (close summary report)
**Timing**: Day 5, 12:00 PM - 1:00 PM

**Procedure**:
1. Review financial package and close summary report
2. Prepare stakeholder communication (email or presentation)
3. Distribute financial package to authorized stakeholders
4. Schedule finance review meeting with senior management
5. Send Mattermost notification to all Finance team members

**Stakeholder Communication Content**:
- Financial performance summary
- Key achievements and challenges
- Action items for next month
- Finance review meeting invitation

**Evidence Required**:
- Stakeholder communication email/presentation
- Distribution list confirmation
- Mattermost notification screenshot

**Acceptance Criteria**:
- All authorized stakeholders received financial package
- Finance review meeting scheduled
- Team notified of close completion

---

#### Task 44: BIR Compliance Approval Gate (Gate 4)
**Owner**: Finance Director
**Duration**: 1 hour
**Dependencies**: Task 36-39 (BIR preparation and submission)
**Timing**: Day 5, 1:00 PM - 2:00 PM

**Procedure**:
1. Review all BIR forms (1601-C) for closing month
2. Validate BIR calculation accuracy (≥98% target)
3. Verify payment confirmations and reference numbers
4. Confirm submission tracking and deadline reminders
5. Approve BIR compliance package or reject for corrections

**Approval Criteria**:
- BIR forms completed with all required fields
- Calculation accuracy ≥98%
- Payment confirmations obtained
- Submission tracking updated

**Evidence Required**:
- BIR approval memo (Word document)
- Approval sign-off (digital signature)

**Outcome**:
- **Approved**: Month-end close officially complete
- **Rejected**: Return to BIR preparation tasks for corrections

---

## Acceptance Criteria Summary

### Critical Success Factors

**Timeline Compliance**:
- ✅ All 44 tasks completed within 5 business days
- ✅ All approval gates passed on schedule
- ✅ BIR filing deadline met (10th of following month)

**Quality Standards**:
- ✅ All reconciliations within variance thresholds (≤0.1%)
- ✅ Financial statements balanced and accurate
- ✅ BIR calculation accuracy ≥98%

**Documentation Completeness**:
- ✅ All evidence requirements met (supporting documents attached)
- ✅ All approval sign-offs obtained (digital signatures)
- ✅ All reports generated and distributed

**System Integration**:
- ✅ Data synced from Odoo to Supabase (variance ≤0.1%)
- ✅ ETL pipeline success (no errors)
- ✅ Visual parity maintained (SSIM thresholds met)

---

## Common Issues & Troubleshooting

### Issue 1: Reconciliation Variance >0.1%
**Symptom**: Bank or GL reconciliation shows variance exceeding threshold

**Root Causes**:
- Timing differences (transactions posted after month-end)
- Data entry errors (incorrect amounts or accounts)
- Missing transactions (not recorded in system)
- FX revaluation issues (foreign currency balances)

**Resolution Steps**:
1. Review reconciliation workpaper for calculation errors
2. Investigate unmatched items in detail (query Odoo for transaction history)
3. Book adjusting entries for legitimate variances
4. Escalate to Finance Manager if variance unexplained

**Prevention**:
- Daily reconciliation monitoring (don't wait until month-end)
- Automated reconciliation tools (fuzzy matching in Supabase)
- Staff training on proper transaction coding

---

### Issue 2: BIR Calculation Accuracy <98%
**Symptom**: BIR form totals do not match Odoo GL within 2% tolerance

**Root Causes**:
- Incorrect tax code classification (wrong withholding rate applied)
- Missing transactions (not captured in BIR extract)
- Manual calculation errors (formula errors in Excel)
- System configuration issues (Odoo tax settings incorrect)

**Resolution Steps**:
1. Re-run BIR extract query from Odoo
2. Validate tax code mappings (Odoo → BIR tax codes)
3. Manually reconcile line-by-line (Odoo transactions vs. BIR form)
4. Correct errors and regenerate BIR form
5. Escalate to Finance Director if discrepancy persists

**Prevention**:
- Automated BIR form generation via n8n workflow
- Quarterly tax code audit (validate all mappings)
- Tax calculation testing in UAT environment before month-end

---

### Issue 3: Missed Approval Gate Deadline
**Symptom**: Approval gate not completed on schedule (delays subsequent tasks)

**Root Causes**:
- Task dependencies not completed on time
- Approver unavailable or unresponsive
- Quality issues requiring rework (rejected tasks)
- Resource constraints (insufficient staff)

**Resolution Steps**:
1. Escalate to Finance Director immediately
2. Reallocate resources to critical path tasks
3. Request approval override if justified
4. Adjust timeline for subsequent tasks (communicate impact)

**Prevention**:
- Daily status updates during close period
- Early warning system (Mattermost alerts for at-risk tasks)
- Backup approver designation (if primary approver unavailable)
- Monthly close retrospective (identify process bottlenecks)

---

## Appendix A: Task Dependency Matrix

```
Task   Depends On   Blocking
1      -            2
2      1            3, 13
3      2            4, 5, 6, 7, 8, 14, 15
4      3            12, 15
5      3            15
6      3,4,5        15, 20
7      3            15
8      3            15, 17
9      5            15, 16
10     3            15, 18
11     9            15
12     4            15, 19
13     2            15
14     3            15
15     3-14         16-25
16     15           25
17     8            25
18     10           25
19     12           25
20     6            25
21     4,5          25
22     3            25
23     4            25
24     19           25
25     16-24        26-35
26     25           27-35
27     26           30, 31, 32, 34, 35
28     26           30, 31, 32, 34, 35
29     26,27,28     34, 35
30     27,28,29     34, 35
31     28           32, 33, 34, 35
32     27,28        34, 35
33     31           34, 35
34     27-33        35
35     34           36-44
36     35           37, 44
37     36           38, 44
38     37           39, 44
39     38           44
40     1-39         42
41     34           42
42     40           43
43     42           44
44     36-43        (Close Complete)
```

---

## Appendix B: Role Assignments

| Role | Primary Tasks | Backup |
|------|---------------|--------|
| Finance SSC Manager | 1, 40, 42 | Finance Manager |
| Finance Supervisor | 2, 3, 6, 9, 11, 16, 19, 20, 24, 27, 28, 34, 36, 38 | Finance Manager |
| Finance Analyst | 4, 5, 7, 8, 10, 13, 17, 18, 21, 22, 23, 26, 29, 31, 32, 39, 41 | Finance Supervisor |
| Finance Manager | 15, 25, 30, 33, 37, 40 | Finance Director |
| Finance Director | 35, 43, 44 | (None - final approver) |

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-29 | Finance SSC Manager | Initial template creation |

---

**End of Month-End Close Task Template**