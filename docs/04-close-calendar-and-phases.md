# 04 - Close Calendar and Phases

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director
**Classification**: Internal - Process

---

## Executive Summary

This document defines the **5-phase financial close cycle** for Odoo 18 CE month-end, quarter-end, and year-end close operations. The framework ensures systematic execution, clear accountability, and compliance with regulatory deadlines (BIR tax filing, board reporting, audit schedules).

**Core Objectives**:
- **Predictability**: Standardized timeline enabling resource planning and deadline management
- **Efficiency**: Optimized task sequencing minimizing idle time and dependency bottlenecks
- **Quality**: Built-in review gates preventing error propagation to financial statements
- **Compliance**: Alignment with BIR statutory deadlines (1601-C by Day 10, 2550Q by Day 60)
- **Auditability**: Comprehensive checkpoint documentation supporting internal and external audits

**Close Cycle Performance Targets**:
- **Monthly close**: ≤5 business days (Day 1-5 of following month)
- **Quarterly close**: ≤7 business days (includes tax provision adjustments)
- **Annual close**: ≤15 business days (includes audit coordination and dividend accrual)

---

## 1. Five-Phase Close Cycle Architecture

### 1.1 Phase Overview

```
Phase 1: PRE-CLOSE (Days -5 to -1)
   → Objective: Transaction completeness, minimize post-close adjustments
   → Owner: Finance Manager
   → Deliverable: 95% transaction capture, clean cutoff

Phase 2: CLOSE EXECUTION (Days 1-3)
   → Objective: Period-end adjustments, account reconciliations
   → Owner: GL Accountant
   → Deliverable: Locked trial balance, all accounts reconciled

Phase 3: REVIEW & RECONCILIATION (Days 4-5)
   → Objective: Variance analysis, quality assurance
   → Owner: Finance Manager
   → Deliverable: Management reports, variance explanations

Phase 4: APPROVAL & LOCK (Days 6-7)
   → Objective: Financial statement certification, period lock
   → Owner: Finance Director
   → Deliverable: Signed financial statements, locked period

Phase 5: REPORTING & AUDIT (Days 8+)
   → Objective: Tax filing, board reporting, audit support
   → Owner: Tax Compliance Officer / Finance Director
   → Deliverable: BIR returns filed, board package distributed
```

### 1.2 Critical Path Analysis

**Dependencies and Sequencing**:
```
Day -5: Invoice processing (AP/AR Clerks) → ALL subsequent phases dependent
Day 1: Bank reconciliation (GL Accountant) → Trial balance validation dependent
Day 2: Depreciation calculation (FA Accountant) → Asset section of balance sheet dependent
Day 3: Payroll reconciliation (Payroll Specialist) → Compensation expense dependent
Day 4: Variance analysis (Finance Manager) → Management decision-making dependent
Day 5: Trial balance sign-off (GL Accountant) → Period lock dependent
Day 6: Financial statement review (Finance Director) → Certification dependent
Day 10: BIR 1601-C filing (Tax Compliance Officer) → Statutory compliance dependent
```

**Bottleneck Mitigation**:
- **Parallel processing**: AR/AP activities run concurrently during pre-close
- **Early start tasks**: Bank reconciliation begins Day 1 (doesn't wait for full cutoff)
- **Provisional entries**: Tax accruals posted with best estimates, refined in Phase 3
- **Workday buffering**: 7-day close allows 2-day buffer for exceptions/rework

---

## 2. Phase 1: Pre-Close (Days -5 to -1)

### 2.1 Objectives and Success Criteria

**Primary Objectives**:
- Maximize transaction capture before period-end (target: ≥95% completeness)
- Establish clean cutoff for goods/services received and delivered
- Resolve outstanding reconciliation items from prior period
- Prepare period-end adjustment templates (accruals, deferrals, allocations)

**Success Criteria**:
- ✅ All vendor invoices received by Day -2 are processed to "approval-ready" status
- ✅ All customer invoices for goods/services delivered by month-end are generated
- ✅ No open reconciling items >30 days old in bank, AR, or AP subledgers
- ✅ Payroll for month-end processed and validated
- ✅ Depreciation schedules reviewed and exception cases flagged
- ✅ Tax accrual templates prepared with preliminary calculations

### 2.2 Detailed Task Breakdown

#### Day -5 to -3: Transaction Processing Push

**AP Clerk Activities** (8 hours workload):
- **Vendor invoice processing** (4 hours):
  - Scan inbox for pending invoices (email, portal, OCR queue)
  - Validate OCR extraction (confidence ≥0.60, manual correction if needed)
  - 3-way match: PO → Goods Receipt → Invoice (tolerance: ±2%)
  - Route for approval: <₱50K auto-approve, ≥₱50K to Finance Manager
  - Target: ≤10 invoices in "pending validation" queue by Day -3

- **Expense report validation** (2 hours):
  - Review employee expense claims for policy compliance
  - Validate receipt authenticity (no duplicates, tampering)
  - Check budget availability for cost centers
  - Route for approval: <₱10K auto-approve, ≥₱10K to Finance Manager

- **Accrued expenses preparation** (2 hours):
  - Identify recurring accruals (rent, utilities, subscriptions)
  - Obtain vendor statements for goods received, not invoiced (GR/NI)
  - Prepare accrual journal entry templates with supporting documentation
  - Coordinate with GL Accountant for posting in Phase 2

**AR Clerk Activities** (6 hours workload):
- **Customer invoice generation** (3 hours):
  - Review sales orders with delivery confirmation (proof of shipment/acceptance)
  - Generate invoices for all delivered goods/services through month-end
  - Validate pricing, discounts, payment terms against contracts
  - Email invoices to customers (target: 100% sent by Day -2)

- **Payment application** (2 hours):
  - Match customer payments (bank deposits, checks) to open invoices
  - Clear unapplied cash (suspense account balance target: ₱0)
  - Resolve disputes and short-payments with sales team
  - Update aging report (target: <5% AR balance in dispute)

- **Deferred revenue review** (1 hour):
  - Identify advance payments for undelivered goods/services
  - Prepare deferral journal entry templates
  - Coordinate with GL Accountant for posting

**Payroll Specialist Activities** (10 hours workload):
- **Payroll run execution** (4 hours):
  - Collect timesheets and attendance records (cutoff: last working day of month)
  - Calculate gross pay, overtime, allowances, bonuses
  - Compute statutory deductions (SSS, PhilHealth, Pag-IBIG, withholding tax)
  - Generate payslips for employee review

- **Payroll validation** (2 hours):
  - Reconcile payroll register to prior month (variance analysis for new hires, separations)
  - Validate deduction calculations against BIR/SSS/PhilHealth/Pag-IBIG tables
  - Review outliers (gross pay >2× average, negative net pay)
  - Route for approval: Finance Manager sign-off required

- **Statutory compliance preparation** (2 hours):
  - Prepare government remittance summaries (SSS, PhilHealth, Pag-IBIG)
  - Calculate employer share contributions
  - Prepare withholding tax summary for 1601-C filing

- **Payroll reconciliation prep** (2 hours):
  - Generate payroll journal entry (debit: expense accounts, credit: liability accounts)
  - Reconcile payroll liability accounts to government remittance returns
  - Prepare supporting documentation for GL Accountant posting

**Fixed Asset Accountant Activities** (4 hours workload):
- **Depreciation calculation** (2 hours):
  - Run monthly depreciation routine (Odoo: `account_asset` module)
  - Review new asset acquisitions (ensure capitalized in correct period)
  - Validate disposal processing (gain/loss calculation, accumulated depreciation clearing)
  - Flag exceptions: fully depreciated assets still in use, impairment indicators

- **Asset register review** (1 hour):
  - Reconcile asset register to GL fixed asset accounts (tolerance: ±₱1,000)
  - Investigate variances (common causes: unrecorded disposals, capitalization errors)
  - Prepare correcting journal entries if needed

- **Capital expenditure tracking** (1 hour):
  - Review pending purchase orders for capital items
  - Coordinate with AP Clerk to ensure invoices processed timely
  - Update capital budget vs. actual report

**Tax Compliance Officer Activities** (6 hours workload):
- **Withholding tax calculation** (2 hours):
  - Extract vendor payments subject to withholding (professional fees, rent, services)
  - Calculate creditable withholding tax (CWT) per BIR rates (1%, 2%, 5%, 10%)
  - Reconcile withholding tax payable account to computation

- **VAT compliance review** (2 hours):
  - Validate input VAT claims (valid VAT invoices, registered suppliers)
  - Compute output VAT on taxable sales (12% VAT)
  - Identify zero-rated and exempt transactions (documentary requirements)
  - Prepare VAT return template (BIR Form 2550Q for quarter-end)

- **Tax accrual preparation** (2 hours):
  - Estimate income tax provision (effective tax rate method or actual computation)
  - Prepare deferred tax asset/liability calculation (if applicable)
  - Coordinate with GL Accountant for tax provision posting

#### Day -2 to -1: Cutoff and Pre-Close Checklist

**GL Accountant Activities** (6 hours workload):
- **Cutoff controls** (2 hours):
  - Review last transaction dates in subledgers (AR, AP, inventory)
  - Validate no backdated entries in current period
  - Document cutoff procedures (e.g., last shipping document number, last check number)

- **Intercompany reconciliation initiation** (2 hours):
  - Extract intercompany balances (receivables/payables between agencies)
  - Send reconciliation requests to counterparty agencies
  - Set deadline for response (Day 2 of Phase 2)

- **Prepayment/Accrual review** (2 hours):
  - Review prepaid expense schedules (insurance, rent, subscriptions)
  - Calculate amortization for current period
  - Identify new prepayments requiring setup
  - Review accrued expenses (utilities, interest, professional fees)
  - Prepare adjusting journal entry templates

**Finance Manager Activities** (4 hours workload):
- **Pre-close checklist review** (2 hours):
  - Review transaction processing status (target: ≥95% completeness)
  - Identify high-risk areas (large balances, unusual transactions)
  - Assign additional resources if backlog detected

- **Exception approval** (2 hours):
  - Review and approve queued transactions (vendor bills, expenses, credit memos)
  - Investigate outliers flagged by subordinates
  - Communicate expected adjustments to Finance Director

### 2.3 Phase 1 Deliverables

**Mandatory Outputs**:
1. **Transaction Completeness Report**:
   - Total invoices processed vs. received
   - Open PO items with goods receipts but no invoice
   - Unbilled revenue (delivered but not invoiced)

2. **Cutoff Documentation**:
   - Last transaction numbers (check, invoice, receipt, delivery)
   - Period-end inventory count summary (if applicable)
   - Bank statement cutoff balances

3. **Pre-Close Checklist**:
   - Task completion status (green/yellow/red by assigned role)
   - Outstanding items requiring resolution in Phase 2
   - Estimated adjustment journal entries (count and total amount)

**Quality Gate**: Finance Manager approval required to proceed to Phase 2. Criteria:
- ≥95% transaction processing complete
- ≤5 high-priority reconciling items outstanding
- All payroll and depreciation calculations validated

---

## 3. Phase 2: Close Execution (Days 1-3)

### 3.1 Objectives and Success Criteria

**Primary Objectives**:
- Post period-end adjusting journal entries (accruals, deferrals, reclassifications)
- Complete account reconciliations (bank, subledgers, intercompany)
- Lock subledgers to prevent further transaction entry
- Generate preliminary trial balance for review

**Success Criteria**:
- ✅ All bank accounts reconciled with outstanding items aged and explained
- ✅ All subledger-to-GL reconciliations balanced (AR, AP, inventory, fixed assets, payroll)
- ✅ All adjusting journal entries posted and approved
- ✅ Trial balance sum of debits = sum of credits (no out-of-balance condition)
- ✅ Suspense accounts cleared or explained (balance target: ≤₱5,000)

### 3.2 Detailed Task Breakdown

#### Day 1: Core Reconciliations

**GL Accountant Activities** (10 hours workload):
- **Bank reconciliation** (4 hours):
  - Download bank statements for all accounts (main operating, payroll, tax, savings)
  - Import transactions to Odoo (or Supabase if using custom ETL)
  - Perform automatic matching (cleared checks, deposits)
  - Manually reconcile outstanding items:
    - Deposits in transit (verify with deposit slips)
    - Outstanding checks (cross-reference check register)
    - Bank fees and interest (create journal entries)
  - Investigate reconciling items >30 days old (potential stale checks, errors)
  - Target: ≤10 outstanding items per account, all aged and explained

- **Cash flow statement reconciliation** (2 hours):
  - Reconcile bank balance change to cash flow statement
  - Validate operating, investing, financing activity classifications
  - Investigate large variances (>10% or ₱100,000)

- **Intercompany reconciliation** (2 hours):
  - Follow up on Day -2 reconciliation requests sent to counterparties
  - Match intercompany balances (Receivable in Agency A = Payable in Agency B)
  - Identify and investigate variances (common causes: timing, classification)
  - Prepare reconciling journal entries for next-day posting

- **Suspense account review** (2 hours):
  - Analyze all suspense/clearing account balances (unapplied cash, unidentified receipts)
  - Trace original transactions and identify proper classification
  - Prepare reclassification journal entries
  - Target: Clear all balances >₱5,000 or age >90 days

**AR Clerk Activities** (4 hours workload):
- **AR subledger reconciliation** (3 hours):
  - Run AR aging report (Odoo: `account.report_agedpartnerbalance`)
  - Reconcile AR aging total to GL accounts receivable control account
  - Investigate variances (common causes: unapplied payments, unrecorded credits)
  - Prepare reconciling journal entries if needed (e.g., write-off immaterial differences <₱100)

- **Bad debt reserve calculation** (1 hour):
  - Analyze aged AR (buckets: current, 1-30, 31-60, 61-90, 90+ days)
  - Apply reserve percentages (e.g., 0% current, 2% 31-60, 5% 61-90, 50% 90+)
  - Calculate required reserve balance
  - Prepare bad debt expense journal entry (coordinate with GL Accountant for posting)

**AP Clerk Activities** (4 hours workload):
- **AP subledger reconciliation** (3 hours):
  - Run AP aging report (Odoo: `account.report_agedpartnerbalance`)
  - Reconcile AP aging total to GL accounts payable control account
  - Investigate variances (common causes: unrecorded invoices, duplicate payments)
  - Prepare reconciling journal entries if needed

- **Accrued liabilities validation** (1 hour):
  - Review accrued expense balances (utilities, rent, professional fees)
  - Validate accruals from Phase 1 were posted correctly
  - Identify missing accruals (coordinate with department heads for unbilled services)

**Fixed Asset Accountant Activities** (3 hours workload):
- **Fixed asset register reconciliation** (2 hours):
  - Run fixed asset report (Odoo: `account_asset` summary)
  - Reconcile asset register totals to GL accounts:
    - Fixed asset cost accounts (by category: building, equipment, vehicles, etc.)
    - Accumulated depreciation accounts
    - Net book value validation
  - Investigate variances (tolerance: ±₱1,000)
  - Prepare reconciling journal entries if needed

- **Depreciation posting** (1 hour):
  - Review depreciation journal entry generated in Phase 1
  - Validate account mapping (debit: depreciation expense, credit: accumulated depreciation)
  - Post depreciation journal entry
  - Update asset register with current period depreciation

**Payroll Specialist Activities** (3 hours workload):
- **Payroll journal entry posting** (1 hour):
  - Review payroll journal entry prepared in Phase 1
  - Validate account distributions (salary expense by department, statutory liability accounts)
  - Post payroll journal entry
  - Confirm payroll bank account funded (coordinate with Finance Manager for transfer)

- **Payroll reconciliation to GL** (2 hours):
  - Reconcile payroll register to GL payroll expense accounts (by department/cost center)
  - Reconcile statutory liability accounts (SSS, PhilHealth, Pag-IBIG, withholding tax payable)
  - Investigate variances (common causes: timing differences, reclassifications)
  - Prepare reconciling journal entries if needed

**Tax Compliance Officer Activities** (2 hours workload):
- **Tax accrual posting** (1 hour):
  - Review income tax provision calculation from Phase 1
  - Post tax provision journal entry (debit: income tax expense, credit: income tax payable)
  - Post deferred tax adjustments (if applicable)

- **Tax account reconciliation** (1 hour):
  - Reconcile withholding tax payable to detailed withholding tax computation
  - Reconcile VAT payable to VAT return computation
  - Reconcile income tax payable to tax provision
  - Investigate variances and prepare reconciling entries

#### Day 2-3: Adjusting Entries and Trial Balance Validation

**GL Accountant Activities** (12 hours workload over 2 days):
- **Accrual and deferral posting** (4 hours):
  - Review templates prepared in Phase 1 (prepaid expenses, accrued expenses, deferred revenue, unbilled revenue)
  - Validate calculations and supporting documentation
  - Post adjusting journal entries
  - Update schedules (prepayment amortization, accrual aging)

- **Reclassification entries** (2 hours):
  - Review balance sheet accounts for proper classification:
    - Current vs. non-current assets/liabilities (12-month rule)
    - Short-term vs. long-term debt
    - Intercompany eliminations (if consolidated reporting)
  - Post reclassification journal entries

- **Period-end allocations** (2 hours):
  - Allocate overhead costs (e.g., rent, utilities by square footage; IT costs by headcount)
  - Allocate shared service costs to cost centers
  - Post allocation journal entries

- **Trial balance generation and validation** (4 hours):
  - Generate trial balance report (Odoo: `account.report_trialbalance`)
  - Validate debit/credit balance (must be equal, no out-of-balance)
  - Review account balances for reasonableness:
    - Negative balances in wrong accounts (e.g., negative AP, negative cash)
    - Unusually large balances (>3 standard deviations from average)
    - Zero balances in accounts that should have activity (e.g., depreciation expense)
  - Investigate and resolve anomalies
  - Prepare preliminary trial balance for Finance Manager review

**Finance Manager Activities** (4 hours workload over 2 days):
- **Adjusting entry review and approval** (2 hours):
  - Review all journal entries posted in Phase 2 (focus on manual entries >₱50,000)
  - Validate business rationale and supporting documentation
  - Approve or reject entries
  - Follow up on rejected entries with GL Accountant

- **Subledger reconciliation sign-off** (2 hours):
  - Review reconciliation workpapers from AP, AR, FA, Payroll teams
  - Validate reconciling items are legitimate (not masking errors)
  - Approve or request rework
  - Document sign-off in reconciliation tracker

### 3.3 Phase 2 Deliverables

**Mandatory Outputs**:
1. **Reconciliation Package**:
   - Bank reconciliation statements (all accounts)
   - AR subledger to GL reconciliation
   - AP subledger to GL reconciliation
   - Fixed asset register to GL reconciliation
   - Payroll register to GL reconciliation
   - Intercompany reconciliation (with counterparty sign-off)

2. **Adjusting Journal Entry Register**:
   - List of all manual journal entries posted in Phase 2
   - Entry number, date, description, amount, preparer, approver
   - Supporting documentation references (file paths, attachment IDs)

3. **Preliminary Trial Balance**:
   - All accounts with debit/credit balances
   - Prior period comparison (month-over-month variance)
   - Flagged anomalies with investigation status

**Quality Gate**: Finance Manager approval required to proceed to Phase 3. Criteria:
- All reconciliations completed and approved
- Trial balance balanced (debits = credits)
- ≤3 open investigation items (minor variances, non-material)

---

## 4. Phase 3: Review & Reconciliation (Days 4-5)

### 4.1 Objectives and Success Criteria

**Primary Objectives**:
- Perform variance analysis (actual vs. budget, current vs. prior period)
- Generate management reports (income statement, balance sheet, cash flow)
- Validate financial statement line items for reasonableness
- Identify and document unusual transactions or trends

**Success Criteria**:
- ✅ All material variances (>10% or ₱100,000) explained with written narratives
- ✅ Management reports generated and reviewed by Finance Manager
- ✅ Financial ratios calculated and compared to benchmarks (liquidity, profitability, leverage)
- ✅ No unexplained negative balances in balance sheet accounts
- ✅ Revenue and expense recognition policies consistently applied

### 4.2 Detailed Task Breakdown

#### Day 4: Variance Analysis and Management Reporting

**GL Accountant Activities** (8 hours workload):
- **Variance analysis preparation** (4 hours):
  - Generate comparison reports (Odoo: custom views or Supabase SQL queries):
    - Actual vs. Budget (by account, department, cost center)
    - Current period vs. Prior period (month-over-month, year-over-year)
    - Quarterly trends (for quarter-end close)
  - Calculate variance percentages and absolute amounts
  - Flag material variances (criteria: >10% AND >₱100,000)
  - Prepare variance summary table for Finance Manager review

- **Financial statement generation** (2 hours):
  - Generate draft financial statements:
    - Income Statement (P&L): Revenue, COGS, Operating Expenses, Net Income
    - Balance Sheet: Assets, Liabilities, Equity
    - Cash Flow Statement: Operating, Investing, Financing Activities
    - Statement of Changes in Equity (annual close only)
  - Apply presentation rules (IFRS or PH GAAP formatting)
  - Validate mathematical accuracy (e.g., Assets = Liabilities + Equity)

- **Intercompany elimination** (2 hours, if consolidated reporting):
  - Identify intercompany transactions (revenue/expense, receivables/payables)
  - Post elimination journal entries (zero out intercompany balances)
  - Validate consolidated financial statements after eliminations

**Finance Manager Activities** (8 hours workload):
- **Variance investigation** (4 hours):
  - Review variance analysis prepared by GL Accountant
  - Investigate material variances:
    - **Revenue variances**: Contact sales/operations for volume/price explanations
    - **Expense variances**: Contact department heads for spending justifications
    - **Balance sheet variances**: Investigate changes in asset/liability balances
  - Document variance explanations in narrative form (template: account, variance %, amount, explanation, supporting evidence)

- **Financial ratio analysis** (2 hours):
  - Calculate key financial ratios:
    - **Liquidity**: Current Ratio (Current Assets / Current Liabilities), Quick Ratio
    - **Profitability**: Gross Margin %, Operating Margin %, Net Margin %, ROA, ROE
    - **Leverage**: Debt-to-Equity, Debt-to-Assets, Interest Coverage
    - **Efficiency**: AR Turnover, AP Turnover, Inventory Turnover (if applicable)
  - Compare ratios to:
    - Prior period (trend analysis)
    - Budget/forecast (performance vs. plan)
    - Industry benchmarks (if available)
  - Document unusual ratio movements (e.g., current ratio drops below 1.0)

- **Management report narrative preparation** (2 hours):
  - Prepare executive summary (1-page):
    - Key financial highlights (revenue, net income, cash position)
    - Major variances and explanations
    - Financial ratio summary with trends
    - Action items or concerns requiring management attention
  - Prepare detailed variance commentary (by financial statement section)

#### Day 5: Quality Assurance and Pre-Lock Review

**GL Accountant Activities** (6 hours workload):
- **Final trial balance review** (2 hours):
  - Regenerate trial balance after all Phase 2 and Phase 3 adjustments
  - Perform final reasonableness checks:
    - No negative balances in asset, revenue, or equity accounts (unless valid, e.g., accumulated depreciation)
    - No positive balances in liability or expense accounts (unless valid, e.g., prepaid expenses)
    - Account balance alignment with expected business activity (e.g., zero sales revenue for inactive products)
  - Update trial balance comparison to prior period

- **Financial statement tie-out** (2 hours):
  - Trace financial statement line items to trial balance account balances
  - Validate all adjustments properly reflected in statements
  - Reconcile net income to retained earnings change (plus/minus dividends, prior period adjustments)
  - Reconcile cash flow statement change in cash to balance sheet cash accounts

- **Close checklist completion** (2 hours):
  - Update close checklist tracker (Supabase `close_checklist` table):
    - Mark all completed tasks with timestamp and responsible user
    - Document outstanding items (if any) with resolution plan and deadline
  - Prepare close summary report:
    - Total journal entries posted (count and total debit/credit amount)
    - Reconciliation completion status (percentage and outstanding items)
    - Variance analysis summary (count of material variances, resolution status)

**Finance Manager Activities** (6 hours workload):
- **Financial statement review** (3 hours):
  - Review draft financial statements prepared by GL Accountant
  - Validate consistency across statements (e.g., net income ties to P&L and retained earnings)
  - Review management narrative for accuracy and completeness
  - Identify any last-minute adjustments required
  - Approve or reject financial statement draft

- **Pre-lock sign-off meeting** (2 hours):
  - Convene close team (GL Accountant, Tax Compliance Officer, key specialists)
  - Review close status dashboard:
    - Task completion percentage (target: 100%)
    - Open investigation items (target: ≤2, both non-material)
    - Financial statement readiness (approved draft ready for Director review)
  - Assign responsibility for remaining items (if any)
  - Set deadline for final adjustments (before end of Day 5)

- **Communication to Finance Director** (1 hour):
  - Prepare briefing memo for Finance Director:
    - Close process summary (on-time, delayed, issues encountered)
    - Financial highlights (revenue, net income, cash position, key ratios)
    - Material variances and explanations
    - Recommended adjustments or actions
  - Schedule Phase 4 review meeting with Finance Director (Day 6)

### 4.3 Phase 3 Deliverables

**Mandatory Outputs**:
1. **Variance Analysis Report**:
   - Comparison tables (actual vs. budget, current vs. prior)
   - Material variance narratives (explanation for each >10% or >₱100K variance)
   - Supporting documentation references (emails, invoices, contracts)

2. **Management Reports Package**:
   - Income Statement (with variance columns)
   - Balance Sheet (with prior period comparison)
   - Cash Flow Statement
   - Financial Ratio Dashboard (with trend analysis)
   - Executive Summary (1-page narrative)

3. **Close Status Dashboard**:
   - Task completion tracker (by role, by phase)
   - Open items log (description, responsible party, deadline, status)
   - Quality metrics (reconciliation accuracy, variance resolution rate)

**Quality Gate**: Finance Manager approval required to proceed to Phase 4. Criteria:
- All material variances explained and documented
- Financial statements mathematically accurate and consistent
- No open high-priority items (low-priority items allowed if documented)

---

## 5. Phase 4: Approval & Lock (Days 6-7)

### 5.1 Objectives and Success Criteria

**Primary Objectives**:
- Obtain Finance Director certification of financial statements
- Execute period lock to prevent backdated transactions
- Document close process completion and handoff to reporting/tax teams
- Archive close workpapers and audit trail

**Success Criteria**:
- ✅ Finance Director sign-off on financial statements (electronic signature or email approval)
- ✅ Period locked in Odoo (accounting period status = "closed")
- ✅ Close workpapers archived in designated repository (Supabase Storage or shared drive)
- ✅ Close summary communicated to stakeholders (board, audit committee, external auditor)

### 5.2 Detailed Task Breakdown

#### Day 6: Finance Director Review and Approval

**Finance Director Activities** (4 hours workload):
- **Financial statement review** (2 hours):
  - Review financial statements prepared by Finance Manager:
    - Validate alignment with strategic goals and board expectations
    - Review variance explanations for reasonableness
    - Assess financial ratios and trends (liquidity, profitability, leverage)
    - Identify any red flags or concerns requiring further investigation
  - Review management narrative for clarity and completeness

- **Adjustment approval** (1 hour):
  - Review all material journal entries posted in Phases 2-3 (focus on >₱500,000)
  - Validate business rationale and supporting documentation
  - Approve or request modifications
  - Document approval in journal entry log (approval timestamp, signature)

- **Certification and sign-off** (1 hour):
  - Certify financial statements as fairly presenting financial position and results
  - Sign financial statements electronically (Odoo digital signature or DocuSign)
  - Document certification in `close_certification_log` table:
    - Period, certification date, certifying officer, comments/qualifications

**GL Accountant Activities** (2 hours workload):
- **Final adjustments** (if any) (1 hour):
  - Post any last-minute adjustments requested by Finance Director
  - Regenerate financial statements after adjustments
  - Resubmit for final approval

- **Close workpaper preparation** (1 hour):
  - Organize all close documentation:
    - Reconciliation workpapers (bank, AR, AP, FA, payroll, intercompany)
    - Journal entry register with supporting documents
    - Variance analysis and explanations
    - Financial statements (certified version)
    - Close checklist and status dashboard
  - Upload to designated archive location (Supabase Storage: `close_workpapers/YYYY-MM/`)

#### Day 7: Period Lock and Handoff

**GL Accountant Activities** (3 hours workload):
- **Period lock execution** (1 hour):
  - Navigate to Odoo Accounting > Configuration > Periods
  - Select period to close (e.g., "January 2025")
  - Set status to "Closed" (prevents new transactions in closed period)
  - Validate lock effective (attempt to post transaction in closed period, should fail)
  - Document lock timestamp in audit log

- **Close summary report generation** (1 hour):
  - Generate close metrics report:
    - Close cycle time (calendar days from month-end to period lock)
    - Task completion rate (percentage of tasks completed on-time)
    - Adjustments summary (count and total amount of manual journal entries)
    - Variance resolution rate (percentage of material variances explained)
  - Generate lessons learned summary:
    - Process improvements identified
    - Bottlenecks encountered
    - Training needs identified

- **Handoff to Tax and Reporting teams** (1 hour):
  - Notify Tax Compliance Officer that period is locked and ready for tax filing (Phase 5)
  - Provide access to close workpapers and financial statements
  - Notify Finance Director that board package preparation can begin

**Finance Manager Activities** (2 hours workload):
- **Close debrief meeting** (1 hour):
  - Convene close team for post-close review
  - Discuss successes and challenges
  - Document process improvements for next close cycle
  - Update close procedures documentation if needed

- **Stakeholder communication** (1 hour):
  - Draft close summary memo to Finance Director:
    - Close completion status (on-time, cycle time)
    - Financial highlights (key metrics, trends)
    - Process improvements for next cycle
  - Email close completion notification to external auditor (if quarterly or annual close)

### 5.3 Phase 4 Deliverables

**Mandatory Outputs**:
1. **Certified Financial Statements**:
   - Income Statement (signed by Finance Director)
   - Balance Sheet (signed by Finance Director)
   - Cash Flow Statement (signed by Finance Director)
   - Certification statement (template: "I certify that these financial statements fairly present the financial position and results of operations for the period ended [date].")

2. **Close Workpaper Archive**:
   - Organized folder structure (by close phase, by team)
   - All reconciliations, journal entries, variance analyses
   - Indexed for easy retrieval during audits

3. **Close Summary Report**:
   - Close metrics dashboard (cycle time, task completion, adjustments)
   - Lessons learned and process improvements
   - Stakeholder communication log

**Quality Gate**: Finance Director approval required to proceed to Phase 5. Criteria:
- Financial statements certified and signed
- Period locked in Odoo
- Close workpapers archived and accessible

---

## 6. Phase 5: Reporting & Audit (Days 8+)

### 6.1 Objectives and Success Criteria

**Primary Objectives**:
- File BIR tax returns (monthly: 1601-C by Day 10, quarterly: 2550Q by Day 60)
- Prepare board package and management reports
- Support external audit requests (quarterly reviews, annual audit)
- Archive final deliverables and close out period

**Success Criteria**:
- ✅ BIR tax returns filed on or before statutory deadlines
- ✅ Board package distributed within board meeting notice period (typically 7 days)
- ✅ External audit requests responded to within agreed SLA (typically ≤5 business days)
- ✅ Final close documentation archived for regulatory retention period (10 years for BIR)

### 6.2 Detailed Task Breakdown

#### Days 8-10: Tax Filing

**Tax Compliance Officer Activities** (6 hours workload over 3 days):
- **BIR 1601-C preparation** (monthly, 3 hours):
  - Extract withholding tax data from Odoo (vendor payments with CWT)
  - Populate BIR Form 1601-C (Monthly Remittance Return of Income Taxes Withheld on Compensation)
  - Validate tax computation against detailed withholding tax register
  - Attach required schedules (alphalist of employees, payroll summary)
  - Generate eFPS file for electronic filing

- **BIR 1601-C filing** (1 hour):
  - Upload to BIR eFPS portal
  - Generate payment form (tax due amount)
  - Pay withholding tax via authorized agent bank
  - Download eFPS confirmation receipt (proof of filing)
  - Archive confirmation receipt in `bir_filings/YYYY-MM/`

- **Quarterly tax return preparation** (quarter-end only, 2 hours):
  - BIR Form 2550Q (Quarterly VAT Return): Extract sales/purchases, compute output/input VAT
  - BIR Form 1601-EQ (Quarterly Remittance Return of Creditable Income Taxes Withheld - Expanded): Extract vendor withholding
  - BIR Form 1601-FQ (Quarterly Remittance Return of Final Income Taxes Withheld): Extract final withholding (dividends, royalties)
  - Validate computations against GL tax accounts

#### Days 8-10: Board Reporting

**Finance Director Activities** (4 hours workload):
- **Board package preparation** (3 hours):
  - Assemble board materials:
    - Certified financial statements
    - Management narrative (business highlights, financial performance, risks/opportunities)
    - Variance analysis (budget vs. actual, prior period comparison)
    - Financial ratio dashboard
    - Cash flow forecast (next quarter)
    - Capital expenditure report (approved vs. actual)
  - Format for board presentation (PowerPoint or PDF)
  - Coordinate with other departments for non-financial content (operations, HR, legal)

- **Board package distribution** (1 hour):
  - Distribute board package to directors (email or board portal)
  - Schedule board meeting (coordinate with Corporate Secretary)
  - Prepare talking points for financial presentation

**Finance Manager Activities** (2 hours workload):
- **Management report distribution** (1 hour):
  - Distribute financial statements to department heads
  - Schedule management meetings to review results and variances
  - Provide variance explanations and action items

- **Investor/Lender reporting** (if applicable, 1 hour):
  - Prepare reports for external stakeholders (lenders, investors, regulators)
  - Validate compliance with debt covenants (leverage ratios, interest coverage)
  - Submit reports by contractual deadlines

#### Days 8+: External Audit Support

**GL Accountant Activities** (ongoing, 2-4 hours per audit request):
- **Audit request response** (variable workload):
  - Respond to external auditor requests for documentation:
    - Bank confirmations (coordinate with banks for direct confirmation)
    - AR/AP confirmations (send to customers/vendors, follow up on responses)
    - Legal confirmations (coordinate with legal counsel)
    - Reconciliation workpapers (bank, AR, AP, FA, intercompany)
    - Journal entry listings (manual entries, unusual transactions)
    - Supporting documentation (invoices, contracts, approvals)
  - Organize and upload documents to audit file sharing portal (e.g., ShareFile, Dropbox)
  - Track audit request log (request date, due date, responsible party, status)

- **Audit inquiry response** (variable workload):
  - Respond to auditor questions about accounting policies, estimates, judgments
  - Provide explanations for unusual transactions or trends
  - Coordinate with Finance Manager/Director for complex inquiries

**Finance Director Activities** (2-4 hours per audit cycle):
- **Audit coordination** (1 hour):
  - Schedule audit entrance meeting (kickoff for quarterly review or annual audit)
  - Assign audit liaison (typically Finance Manager or GL Accountant)
  - Communicate audit schedule to close team

- **Management representation letter** (1 hour, annual audit):
  - Review and sign management representation letter (auditor-prepared)
  - Attest to completeness and accuracy of financial statements
  - Disclose any known fraud, related party transactions, contingencies

- **Audit exit meeting** (1-2 hours, annual audit):
  - Review audit findings with external auditor
  - Discuss management letter comments (control deficiencies, improvement recommendations)
  - Agree on remediation plans and timelines

### 6.3 Phase 5 Deliverables

**Mandatory Outputs**:
1. **BIR Tax Returns** (monthly):
   - Form 1601-C (withholding tax on compensation)
   - eFPS confirmation receipt
   - Bank-validated payment form (proof of tax payment)

2. **BIR Tax Returns** (quarterly, in addition to monthly):
   - Form 2550Q (VAT return)
   - Form 1601-EQ (expanded withholding tax)
   - Form 1601-FQ (final withholding tax)
   - eFPS confirmation receipts
   - Bank-validated payment forms

3. **Board Package**:
   - Certified financial statements
   - Management narrative and variance analysis
   - Financial ratio dashboard
   - Cash flow forecast
   - Meeting agenda and supporting materials

4. **Audit Support Documentation**:
   - Audit request log (tracker of all requests and responses)
   - Organized audit workpaper folder (by audit area: cash, AR, AP, etc.)
   - Management representation letter (signed)
   - Audit findings and remediation tracker

**Quality Gate**: No formal gate (Phase 5 ongoing). Success criteria:
- Tax returns filed before statutory deadlines (100% on-time)
- Board package distributed per board notice requirements
- Audit requests responded to within SLA (≥95% on-time)

---

## 7. Timeline Templates

### 7.1 Monthly Close Calendar (Standard)

| Day | Phase | Key Activities | Critical Deliverable | Responsible Role |
|-----|-------|----------------|----------------------|------------------|
| **-5** | Pre-Close | Invoice processing, expense validation | 90% transaction capture | AP/AR Clerks |
| **-3** | Pre-Close | Payroll run, depreciation calculation | Payroll validated, depreciation calculated | Payroll Specialist, FA Accountant |
| **-2** | Pre-Close | Cutoff controls, prepayment/accrual review | Cutoff documented | GL Accountant |
| **-1** | Pre-Close | Pre-close checklist review, exception approval | 95% transaction capture | Finance Manager |
| **1** | Close Execution | Bank reconciliation, intercompany reconciliation | Bank reconciled | GL Accountant |
| **2** | Close Execution | Subledger reconciliations (AR, AP, FA, Payroll) | All subledgers reconciled | AR/AP Clerks, FA Accountant, Payroll Specialist |
| **3** | Close Execution | Adjusting entries, trial balance validation | Preliminary trial balance | GL Accountant |
| **4** | Review & Reconciliation | Variance analysis, management reporting | Variance analysis report | GL Accountant, Finance Manager |
| **5** | Review & Reconciliation | Financial statement review, quality assurance | Draft financial statements approved | Finance Manager |
| **6** | Approval & Lock | Finance Director review and certification | Certified financial statements | Finance Director |
| **7** | Approval & Lock | Period lock, close workpaper archive | Period locked, workpapers archived | GL Accountant |
| **8-10** | Reporting & Audit | BIR 1601-C filing, board package preparation | Tax returns filed, board package distributed | Tax Compliance Officer, Finance Director |

### 7.2 Quarterly Close Calendar (Extended)

**Additional Activities for Quarter-End**:
- **Day 4**: Income tax provision calculation (current and deferred tax)
- **Day 5**: Quarterly VAT return preparation (BIR 2550Q)
- **Day 6**: Deferred tax reconciliation (temporary differences, valuation allowance)
- **Day 8-60**: Quarterly tax returns filed (2550Q, 1601-EQ, 1601-FQ)
- **Day 60**: Quarterly tax return deadline (statutory)

**Cycle Time Target**: ≤7 business days (Day 1-7 for core close, Day 8-60 for tax filing)

### 7.3 Annual Close Calendar (Extended)

**Additional Activities for Year-End**:
- **Day -10 to -1**: Physical inventory count (if applicable), fixed asset verification
- **Day 1-3**: Year-end adjustments (accruals, reserves, provisions)
- **Day 4-5**: Segment reporting, related party disclosures
- **Day 6-7**: Consolidated financial statement preparation (if applicable)
- **Day 8-10**: Annual tax return preparation (BIR 1702-RT)
- **Day 10-15**: Audit fieldwork coordination (audit entrance meeting, PBC list)
- **Day 30**: Draft audited financial statements
- **Day 60**: Final audited financial statements, audit report
- **Day 90**: Annual tax return filing deadline (BIR 1702-RT)
- **Day 120**: Annual report to SEC (if publicly listed)

**Cycle Time Target**: ≤15 business days (Day 1-15 for core close, Day 16-120 for audit and tax filing)

---

## 8. Critical Path and Bottleneck Management

### 8.1 Critical Path Identification

**Definition**: Sequence of tasks where delays directly impact overall close cycle time.

**Critical Path Tasks** (monthly close):
```
Day -5: Invoice Processing (AP/AR) → Day 1: Bank Reconciliation → Day 2: Subledger Reconciliations
   → Day 3: Trial Balance Validation → Day 4: Variance Analysis → Day 5: Financial Statement Review
   → Day 6: Finance Director Approval → Day 7: Period Lock
```

**Slack Time Analysis**:
- **Zero slack tasks**: Bank reconciliation (Day 1), Trial balance (Day 3), Period lock (Day 7)
- **1-day slack**: Subledger reconciliations (can slip to Day 3 without delaying close)
- **2-day slack**: Depreciation calculation (can complete by Day 2 without impact)

### 8.2 Bottleneck Mitigation Strategies

**Common Bottlenecks**:
1. **Bank reconciliation delays** (Day 1):
   - **Root cause**: Late bank statement receipt, complex reconciling items
   - **Mitigation**: Automate bank feed import (Odoo bank sync), pre-reconcile outstanding checks during pre-close

2. **Subledger reconciliation variances** (Day 2):
   - **Root cause**: Unapplied payments, duplicate invoices, classification errors
   - **Mitigation**: Daily reconciliation discipline during month (not just at close), automated variance alerts

3. **Intercompany reconciliation delays** (Day 2):
   - **Root cause**: Counterparty agency non-responsiveness, timing differences
   - **Mitigation**: Standardized intercompany cutoff (all agencies use same transaction date), escalation path to Finance Director if non-responsive

4. **Variance analysis bottleneck** (Day 4):
   - **Root cause**: Finance Manager overwhelmed with explanations, department heads slow to respond
   - **Mitigation**: Assign variance investigation to GL Accountant (Finance Manager reviews only), send variance requests to department heads in Phase 1

5. **Period lock delays** (Day 7):
   - **Root cause**: Last-minute adjustments from Finance Director review
   - **Mitigation**: Pre-lock review meeting (Day 5) to surface issues early, Finance Director delegation for immaterial adjustments (<₱50,000)

### 8.3 Workload Balancing

**Peak Workload Periods**:
- **Day 1-3**: GL Accountant peak (reconciliations, adjustments)
- **Day 4-5**: Finance Manager peak (variance analysis, review)
- **Day -3 to -1**: AP/AR Clerks peak (transaction processing)

**Balancing Strategies**:
- **Cross-training**: AR Clerk backs up AP Clerk for invoice processing during peak periods
- **Temporary staffing**: Engage contractors for transaction processing during quarter/year-end
- **Process automation**: Use OCR for invoice processing, robotic process automation (RPA) for reconciliations
- **Early start**: Begin non-critical tasks in pre-close (e.g., depreciation calculation on Day -5 instead of Day 2)

---

## 9. Calendar Customization for Agency-Specific Needs

### 9.1 Multi-Agency Close Coordination

**Challenge**: 8-agency portfolio with different transaction volumes and complexity.

**Customization Framework**:
1. **Tiered close schedule**:
   - **Tier 1 agencies** (high volume, complex): Full 7-day close calendar
   - **Tier 2 agencies** (medium volume): 5-day close calendar (skip Day 4 variance analysis)
   - **Tier 3 agencies** (low volume, simple): 3-day close calendar (reconciliations only, minimal adjustments)

2. **Staggered close deadlines**:
   - Tier 3 agencies close by Day 3 (provides data for consolidated reporting)
   - Tier 2 agencies close by Day 5
   - Tier 1 agencies close by Day 7 (final consolidated close)

3. **Consolidated reporting timeline**:
   - Day 8: All agency closes complete, begin intercompany eliminations
   - Day 9: Consolidated trial balance
   - Day 10: Consolidated financial statements for board

### 9.2 Industry-Specific Adjustments

**Example: Advertising/Media Industry**:
- **Day -3**: Media billing reconciliation (match media buys to vendor invoices)
- **Day 2**: Commission accrual (sales commissions on billed revenue)
- **Day 4**: Client profitability analysis (revenue vs. direct costs by client)

**Example: Professional Services**:
- **Day -2**: Timesheet cutoff and validation (all billable hours entered)
- **Day 1**: Work-in-progress (WIP) reconciliation (unbilled services)
- **Day 3**: Revenue recognition analysis (percentage-of-completion method)

### 9.3 Seasonal Close Variations

**Quarter-End Close**:
- Add 1 day to Phase 3 for income tax provision calculation (Day 5 becomes Day 6)
- Add 1 day to Phase 5 for quarterly tax return preparation (Days 8-10 become Days 8-60)
- **Total cycle time**: 7 days (core close) + 53 days (tax filing window)

**Year-End Close**:
- Add 3 days to Phase 1 for physical inventory and fixed asset verification (Days -5 to -1 become Days -10 to -1)
- Add 2 days to Phase 3 for segment reporting and consolidations (Days 4-5 become Days 4-7)
- Add 8 days to Phase 4 for audit coordination (Days 6-7 become Days 8-15)
- **Total cycle time**: 15 days (core close) + 105 days (audit and annual tax filing)

---

## 10. Performance Metrics and Continuous Improvement

### 10.1 Close Cycle KPIs

**Timeliness Metrics**:
- **Close cycle time**: Calendar days from month-end to period lock (target: ≤7 days)
- **On-time completion rate**: Percentage of tasks completed by target date (target: ≥95%)
- **Critical path adherence**: Percentage of critical path tasks completed on schedule (target: 100%)

**Quality Metrics**:
- **Adjustment rate**: Number of material adjustments (>₱50,000) after initial trial balance (target: ≤5 per month)
- **Reconciliation accuracy**: Percentage of reconciliations balanced on first attempt (target: ≥90%)
- **Variance resolution rate**: Percentage of material variances explained by Day 5 (target: 100%)

**Efficiency Metrics**:
- **Labor hours per close**: Total hours logged by close team (target: ≤200 hours for monthly close)
- **Automation rate**: Percentage of tasks automated vs. manual (target: ≥40%)
- **Rework rate**: Percentage of tasks requiring rework due to errors (target: ≤5%)

### 10.2 Continuous Improvement Process

**Monthly Post-Close Review** (Finance Manager):
- Conduct close debrief meeting (Day 8, 1 hour)
- Review close metrics dashboard (cycle time, on-time completion, adjustments)
- Identify process improvements (template: problem statement, root cause, proposed solution, owner, target date)
- Document in `close_improvement_tracker` table

**Quarterly Process Audit** (Finance Director):
- Review 3-month trend of close metrics
- Identify systemic issues (recurring bottlenecks, quality problems)
- Approve process improvement investments (system enhancements, training, staffing)
- Update close procedures documentation

**Annual Benchmark Review** (Finance Director):
- Compare close performance to industry benchmarks (APQC, Hackett Group)
- Identify gaps and improvement opportunities
- Set targets for next fiscal year (cycle time reduction, automation increase)

### 10.3 Process Improvement Case Studies

**Example 1: Bank Reconciliation Automation**
- **Problem**: Bank reconciliation (Day 1) consistently delayed due to manual transaction matching
- **Root Cause**: No automated bank feed, manual CSV import and matching
- **Solution**: Implement Odoo bank synchronization module (Plaid or Salt Edge integration)
- **Result**: Reconciliation time reduced from 4 hours to 1 hour (75% reduction), Day 1 critical path protected

**Example 2: Variance Analysis Efficiency**
- **Problem**: Variance analysis (Day 4) bottleneck due to Finance Manager overload
- **Root Cause**: Finance Manager investigates all variances personally, department heads slow to respond
- **Solution**:
  - Delegate variance investigation to GL Accountant for variances <₱200,000
  - Implement automated variance alerts to department heads in Phase 1 (Day -3)
- **Result**: Variance analysis completion time reduced from 6 hours to 3 hours (50% reduction)

---

## 11. Technology Enablers and System Integration

### 11.1 Odoo Close Automation Features

**Automated Period Management**:
- **Lock dates**: Prevent backdated transactions (Settings > Accounting > Lock dates)
- **Recurring entries**: Automate monthly accruals (rent, depreciation, amortization)
- **Scheduled actions**: Cron jobs for reconciliation alerts, task assignments

**Reconciliation Tools**:
- **Bank reconciliation widget**: Drag-and-drop matching, automated rules
- **Subledger reconciliation reports**: AR/AP aging with GL comparison
- **Intercompany matching**: Automated matching of intercompany transactions

**Reporting and Analytics**:
- **Financial reports**: Standard P&L, balance sheet, cash flow with comparison columns
- **Custom views**: SQL views for variance analysis, trend reporting
- **Dashboard widgets**: Real-time close status, task completion, metrics

### 11.2 Supabase Integration for Close Management

**Close Task Tracking**:
```sql
-- close_checklist table schema
CREATE TABLE close_checklist (
  id BIGSERIAL PRIMARY KEY,
  period_end DATE NOT NULL,
  phase TEXT NOT NULL CHECK (phase IN ('pre_close', 'close_execution', 'review', 'approval', 'reporting')),
  task_name TEXT NOT NULL,
  assigned_role TEXT NOT NULL,
  target_date DATE NOT NULL,
  completed_date TIMESTAMP,
  completed_by UUID REFERENCES auth.users,
  status TEXT NOT NULL CHECK (status IN ('pending', 'in_progress', 'completed', 'blocked')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- RLS policy: Users can only update tasks assigned to their role
CREATE POLICY close_checklist_role_update ON close_checklist
  FOR UPDATE
  USING (
    assigned_role IN (SELECT role FROM user_role_assignments WHERE user_id = auth.uid() AND active = TRUE)
  );
```

**Close Metrics Dashboard**:
```sql
-- Real-time close status view
CREATE VIEW close_status_dashboard AS
SELECT
  period_end,
  phase,
  COUNT(*) AS total_tasks,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_tasks,
  ROUND(COUNT(CASE WHEN status = 'completed' THEN 1 END)::NUMERIC / COUNT(*)::NUMERIC * 100, 1) AS completion_pct,
  COUNT(CASE WHEN status = 'blocked' THEN 1 END) AS blocked_tasks,
  COUNT(CASE WHEN completed_date > target_date THEN 1 END) AS late_tasks
FROM close_checklist
WHERE period_end = (SELECT MAX(period_end) FROM close_checklist)
GROUP BY period_end, phase
ORDER BY phase;
```

### 11.3 n8n Close Workflow Automation

**Example: Pre-Close Invoice Processing Alert**
```json
{
  "name": "Pre-Close Invoice Alert",
  "trigger": {
    "type": "cron",
    "expression": "0 8 * * *",  // Daily 8AM
    "condition": "EXTRACT(DAY FROM CURRENT_DATE) BETWEEN 23 AND 28"  // Days -5 to -1 (month-end)
  },
  "workflow": [
    {
      "node": "PostgreSQL Query",
      "query": "SELECT COUNT(*) FROM account_move WHERE state = 'draft' AND move_type = 'in_invoice'"
    },
    {
      "node": "Condition",
      "if": "{{$node['PostgreSQL Query'].json.count}} > 10",
      "then": {
        "node": "Mattermost Notification",
        "message": "⚠️ Pre-Close Alert: {{$node['PostgreSQL Query'].json.count}} vendor invoices pending approval. Target: ≤10 by Day -3."
      }
    }
  ]
}
```

---

## 12. Governance and Policy Maintenance

### 12.1 Calendar Review and Update Cycle

**Annual Review** (Finance Director):
- Review close calendar against actual performance (cycle time, bottlenecks)
- Incorporate process improvements from quarterly audits
- Update task assignments based on organizational changes
- Adjust timelines for complexity or volume changes

**Quarterly Review** (Finance Manager):
- Review close metrics trends (3-month rolling average)
- Identify emerging bottlenecks or quality issues
- Propose calendar adjustments to Finance Director
- Update close checklist templates in Supabase

### 12.2 Exception Management

**Authorized Deviations**:
- **Finance Manager**: Extend non-critical task deadlines by ≤1 day (e.g., FA reconciliation from Day 2 to Day 3)
- **Finance Director**: Extend critical path tasks by ≤2 days (e.g., period lock from Day 7 to Day 9), requires notification to external auditor and board

**Deviation Documentation**:
- Log in `close_exception_log` table (reason, impact assessment, approval)
- Review in next monthly post-close debrief
- If recurring, trigger process improvement initiative

### 12.3 Related Documents

- `03-roles-and-sod-matrix.md` - Role-specific task assignments and RACI matrix
- `11-change-management.md` - Governance for calendar modifications
- `99-appendix-data-dictionary.md` - Data model for close tracking tables

---

## 13. Appendix

### 13.1 Glossary of Terms

- **Critical Path**: Sequence of tasks where delays directly impact overall close cycle time
- **Cutoff**: Period-end boundary for transaction inclusion (e.g., all sales through 11:59 PM on month-end)
- **Material Variance**: Variance exceeding significance threshold (typically >10% AND >₱100,000)
- **Period Lock**: System control preventing modifications to closed accounting periods
- **Trial Balance**: Report of all GL account balances (debits and credits must equal)

### 13.2 Sample Close Checklist Template

```
Period: January 2025
Close Coordinator: Finance Manager

Phase 1: Pre-Close (Days -5 to -1: Jan 23-27)
□ AP invoice processing (AP Clerk, Day -5, Target: 90% processed)
□ AR invoice generation (AR Clerk, Day -5, Target: 100% delivered goods invoiced)
□ Payroll run (Payroll Specialist, Day -3, Target: Payroll validated)
□ Depreciation calculation (FA Accountant, Day -3, Target: Depreciation calculated)
□ Tax accrual prep (Tax Officer, Day -2, Target: Accrual templates ready)
□ Prepayment/Accrual review (GL Accountant, Day -2, Target: JE templates ready)
□ Pre-close checklist review (Finance Manager, Day -1, Target: 95% transaction capture)

Phase 2: Close Execution (Days 1-3: Jan 28-30)
□ Bank reconciliation (GL Accountant, Day 1, Target: All banks reconciled)
□ AR reconciliation (AR Clerk, Day 2, Target: AR to GL balanced)
□ AP reconciliation (AP Clerk, Day 2, Target: AP to GL balanced)
□ FA reconciliation (FA Accountant, Day 2, Target: FA register to GL balanced)
□ Payroll reconciliation (Payroll Specialist, Day 2, Target: Payroll to GL balanced)
□ Intercompany reconciliation (GL Accountant, Day 2, Target: All agencies matched)
□ Adjusting entries (GL Accountant, Day 3, Target: All JEs posted)
□ Trial balance validation (GL Accountant, Day 3, Target: Balanced trial balance)

Phase 3: Review & Reconciliation (Days 4-5: Jan 31 - Feb 1)
□ Variance analysis (GL Accountant, Day 4, Target: Material variances flagged)
□ Variance investigation (Finance Manager, Day 4, Target: All variances explained)
□ Financial ratio analysis (Finance Manager, Day 4, Target: Ratios calculated)
□ Management report narrative (Finance Manager, Day 4, Target: Executive summary drafted)
□ Final trial balance review (GL Accountant, Day 5, Target: No anomalies)
□ Financial statement tie-out (GL Accountant, Day 5, Target: Statements balanced)
□ Pre-lock sign-off meeting (Finance Manager, Day 5, Target: Team approval)

Phase 4: Approval & Lock (Days 6-7: Feb 2-3)
□ Financial statement review (Finance Director, Day 6, Target: Statements reviewed)
□ Certification (Finance Director, Day 6, Target: Statements signed)
□ Period lock (GL Accountant, Day 7, Target: Period locked in Odoo)
□ Close workpaper archive (GL Accountant, Day 7, Target: Workpapers uploaded)
□ Close debrief meeting (Finance Manager, Day 7, Target: Lessons learned documented)

Phase 5: Reporting & Audit (Days 8-10: Feb 4-6)
□ BIR 1601-C preparation (Tax Officer, Day 8, Target: Tax return drafted)
□ BIR 1601-C filing (Tax Officer, Day 10, Target: Filed and paid)
□ Board package preparation (Finance Director, Day 9, Target: Package assembled)
□ Board package distribution (Finance Director, Day 10, Target: Directors notified)

Close Completion Date: ______________________
Finance Manager Sign-Off: ___________________
Finance Director Sign-Off: __________________
```

### 13.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial 5-phase close calendar creation |

---

**Document Classification**: Internal - Process
**Review Frequency**: Annual (or upon process improvement initiative)
**Next Review Date**: 2026-01-31
**Approver**: Finance Director (signature required)

**End of Document**