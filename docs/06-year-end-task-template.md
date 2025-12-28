# Year-End Close Task Template

## Document Control

**Version**: 1.0
**Last Updated**: 2025-12-29
**Owner**: Finance SSC Manager
**Approvers**: Finance Manager, Finance Director, External Auditor
**Review Cycle**: Annually (post-close retrospective)

---

## Executive Summary

This document provides a comprehensive 38-task checklist for year-end financial close operations at TBWA Finance SSC. The year-end close builds upon the standard month-end close procedures (44 tasks from `05-month-end-task-template.md`) with additional tasks for annual regulatory compliance, tax provisions, inventory adjustments, depreciation reviews, and external audit coordination.

**Target Timeline**: 10 business days from year-end
**Critical Success Factors**:
- All month-end tasks completed (prerequisite)
- Additional year-end procedures executed (inventory, depreciation, tax)
- External auditor coordination and field work support
- Regulatory filing deadlines met (BIR annual returns, SEC reports)

---

## Year-End Close Architecture

### Process Flow Overview

```
Prerequisite: Complete Month-End Close (Tasks 1-44 from 05-month-end-task-template.md)
   ↓
Day 1-3: Year-End Inventory & Asset Verification (Tasks 1-10)
   ↓
Day 3-5: Tax Provisions & Regulatory Compliance (Tasks 11-20)
   ↓
Day 5-7: External Audit Coordination (Tasks 21-28)
   ↓
Day 7-10: Annual Reporting & Statutory Filings (Tasks 29-38)
```

### Approval Gates (Year-End Specific)

**Gate Y1 - Inventory & Asset Verification** (End of Day 3)
- **Approver**: Finance Manager + Operations Manager
- **Criteria**: Physical inventory count complete with variance ≤1%, fixed asset verification 100% complete
- **Evidence**: Physical count sheets, asset verification reports, variance analysis

**Gate Y2 - Tax Compliance & Annual Provisions** (End of Day 5)
- **Approver**: Finance Director + Tax Advisor
- **Criteria**: All annual tax provisions calculated per BIR regulations, deferred tax reconciled
- **Evidence**: Tax computation workpapers, BIR annual returns (draft), deferred tax schedule

**Gate Y3 - External Audit Readiness** (End of Day 7)
- **Approver**: Finance Director + External Auditor
- **Criteria**: All audit schedules prepared, management representation letter reviewed, audit field work complete
- **Evidence**: Audit file (PBC list complete), field work sign-off, draft audit opinion

**Gate Y4 - Statutory Filing Approval** (End of Day 10)
- **Approver**: Finance Director + Board of Directors
- **Criteria**: Annual financial statements approved, BIR/SEC filings ready for submission
- **Evidence**: Board resolution, signed audited financial statements, filing confirmations

---

## Year-End Specific Tasks (38 Tasks)

### Phase 1: Year-End Inventory & Asset Verification (Day 1-3)

#### Task 1: Physical Inventory Count Planning
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Month-end close complete (Task 44 from month-end template)
**Timing**: Day 1, 9:00 AM - 11:00 AM

**Procedure**:
1. Schedule physical inventory count date (typically Dec 31 or Jan 2)
2. Coordinate with operations team for warehouse access
3. Assign count teams (minimum 2 people per team for control)
4. Prepare inventory count sheets from Odoo system
5. Brief count teams on procedures and accuracy requirements
6. Establish cut-off procedures (stop all movements during count)

**Count Teams Assignment** (8 agencies):
- Team 1: CKVC, BOM (Analyst A + Supervisor B)
- Team 2: JPAL, JLI (Analyst C + Supervisor D)
- Team 3: JAP, LAS (Analyst E + Supervisor F)
- Team 4: RMQB, RIM (Analyst G + Manager)

**Evidence Required**:
- Inventory count schedule (calendar invite)
- Count team assignments (email)
- Count sheet templates (Excel)
- Count procedure briefing agenda

**Acceptance Criteria**:
- All count teams assigned and briefed
- Count sheets prepared from Odoo
- Cut-off procedures communicated

---

#### Task 2: Physical Inventory Count Execution
**Owner**: Finance Supervisor + Operations Manager
**Duration**: 8 hours (full day)
**Dependencies**: Task 1 (count planning)
**Timing**: Day 2, 8:00 AM - 5:00 PM

**Procedure**:
1. Enforce inventory movement cut-off (no receipts/shipments during count)
2. Distribute count sheets to count teams
3. Execute two-person count verification (Counter 1 counts, Counter 2 verifies)
4. Document serial numbers for high-value items (computers, vehicles)
5. Flag damaged, obsolete, or slow-moving items for write-off consideration
6. Collect completed count sheets with supervisor sign-off
7. Photograph inventory areas for audit evidence

**Count Accuracy Controls**:
- **Blind Count**: Count sheets do not show book balances (prevents bias)
- **Recounts**: Any variance >5% triggers immediate recount
- **Supervisor Verification**: Spot-check 10% of counts randomly
- **Serial Number Validation**: Scan asset tags for high-value items

**Evidence Required**:
- Completed count sheets (signed by counter and verifier)
- Serial number logs for high-value items
- Photographs of inventory areas
- Damage/obsolescence flagging list

**Acceptance Criteria**:
- 100% of inventory items counted and verified
- All count sheets signed by authorized personnel
- High-value items serial numbers validated

---

#### Task 3: Inventory Variance Analysis
**Owner**: Finance Analyst
**Duration**: 4 hours
**Dependencies**: Task 2 (physical count)
**Timing**: Day 2, 5:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Input physical count data into Odoo system
2. Generate inventory variance report (physical vs. book)
3. Calculate variance by category (raw materials, WIP, finished goods)
4. Classify variances (shrinkage, damage, obsolescence, system errors)
5. Investigate significant variances (>5% or PHP 50,000)
6. Prepare variance explanation summary for management
7. Obtain Operations Manager sign-off on variance explanations

**Variance Analysis Formula**:
```
Variance Quantity = Physical Count - Book Balance
Variance Value = Variance Quantity × Unit Cost
Variance % = (Variance Value / Book Value) × 100%
```

**Materiality Thresholds**:
- **Material Variance**: >5% or PHP 50,000 (requires investigation)
- **Immaterial Variance**: ≤5% and <PHP 50,000 (book adjustment without deep investigation)

**Evidence Required**:
- Inventory variance report (Excel with detail by SKU)
- Variance investigation notes (root cause analysis)
- Operations Manager sign-off on explanations

**Acceptance Criteria**:
- All variances calculated and classified
- Material variances (>5% or PHP 50,000) explained
- Total variance within 1% of book value

---

#### Task 4: Inventory Adjustment Entries
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 3 (variance analysis)
**Timing**: Day 3, 9:00 AM - 11:00 AM

**Procedure**:
1. Prepare inventory adjustment journal entries per variance analysis
2. Classify adjustments (shrinkage loss, damage write-off, obsolescence reserve)
3. Post adjusting entries in Odoo
4. Update inventory master data (remove obsolete SKUs, adjust reorder points)
5. Generate adjusted inventory valuation report

**Standard Adjustment Entries**:

**Shrinkage Loss**:
```
Debit: Inventory Shrinkage Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Inventory (1xxxx)   PHP XXX,XXX.XX
Narration: "To record inventory shrinkage per physical count variance"
```

**Obsolescence Reserve**:
```
Debit: Obsolescence Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Allowance for Obsolete Inventory (1xxxx)   PHP XXX,XXX.XX
Narration: "To record obsolescence reserve for slow-moving inventory"
```

**Evidence Required**:
- Inventory adjustment journal entries
- Updated inventory valuation report
- Obsolete inventory listing

**Acceptance Criteria**:
- All variances adjusted in Odoo
- Inventory balance reconciled to physical count
- Obsolescence reserve calculated per policy (1% for 6-12 months old, 5% for 12+ months)

---

#### Task 5: Fixed Asset Physical Verification
**Owner**: Finance Analyst
**Duration**: 6 hours
**Dependencies**: Month-end close Task 10 (depreciation)
**Timing**: Day 1, 11:00 AM - 5:00 PM

**Procedure**:
1. Extract fixed asset register from Odoo (all assets not fully depreciated)
2. Prepare asset verification checklist (asset tag, location, condition)
3. Conduct physical verification per agency/location
4. Scan asset tags and photograph assets
5. Flag missing, damaged, or fully depreciated assets for disposal
6. Update asset register with verification status and current location

**Asset Verification Checklist**:
- **Asset Tag Visible**: ✅ / ❌
- **Location Matches Register**: ✅ / ❌
- **Physical Condition**: Good / Fair / Poor / Damaged
- **In Use**: ✅ / ❌ (flag idle assets)
- **Photo Taken**: ✅ / ❌

**Evidence Required**:
- Asset verification checklist (Excel with photos attached)
- Asset tag scan log (barcode/QR scan records)
- Missing asset list (for investigation or write-off)
- Disposal recommendation list (fully depreciated or damaged assets)

**Acceptance Criteria**:
- 100% of assets in register physically verified
- All asset tags scanned and photographed
- Missing assets flagged for investigation
- Disposal recommendations submitted to Finance Manager

---

#### Task 6: Asset Impairment Assessment
**Owner**: Finance Manager
**Duration**: 3 hours
**Dependencies**: Task 5 (physical verification)
**Timing**: Day 3, 11:00 AM - 2:00 PM

**Procedure**:
1. Review asset verification results for impairment indicators
2. Assess fair value of damaged or idle assets
3. Calculate impairment loss (book value - recoverable amount)
4. Book impairment journal entries if material (>PHP 100,000)
5. Update fixed asset register with impairment status

**Impairment Indicators**:
- Physical damage reducing asset functionality
- Technological obsolescence (software, computers)
- Idle assets not in use for >12 months
- Market value significantly below book value

**Impairment Calculation**:
```
Carrying Amount = Cost - Accumulated Depreciation
Recoverable Amount = Higher of (Fair Value - Cost to Sell, Value in Use)
Impairment Loss = Carrying Amount - Recoverable Amount (if positive)
```

**Standard Impairment Entry**:
```
Debit: Impairment Loss (6xxxx)   PHP XXX,XXX.XX
  Credit: Accumulated Impairment - Fixed Assets (1xxxx)   PHP XXX,XXX.XX
Narration: "To record impairment loss on [asset description] per assessment"
```

**Evidence Required**:
- Impairment assessment report (Excel with fair value estimates)
- Impairment journal entries (if any)
- Updated fixed asset register

**Acceptance Criteria**:
- All impairment indicators identified and assessed
- Material impairments (>PHP 100,000) booked
- Impairment methodology documented

---

#### Task 7: Asset Disposal Processing
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 5, 6 (verification and impairment)
**Timing**: Day 3, 2:00 PM - 4:00 PM

**Procedure**:
1. Prepare asset disposal list (from Task 5 recommendations)
2. Obtain Finance Director approval for disposals
3. Calculate gain/loss on disposal (proceeds - net book value)
4. Remove disposed assets from fixed asset register
5. Book disposal journal entries

**Disposal Approval Criteria**:
- Fully depreciated (net book value = 0) OR
- Damaged/obsolete with no salvage value OR
- Sold/donated with documented transaction

**Gain/Loss on Disposal Formula**:
```
Net Book Value = Cost - Accumulated Depreciation - Accumulated Impairment
Gain/Loss = Proceeds from Sale - Net Book Value
```

**Standard Disposal Entry**:
```
Debit: Accumulated Depreciation (1xxxx)   PHP XXX,XXX.XX
Debit: Cash/Receivable (1xxxx)   PHP XXX,XXX.XX (if proceeds)
Debit/Credit: Loss/Gain on Disposal (6xxxx/4xxxx)   PHP XXX,XXX.XX
  Credit: Fixed Asset - Cost (1xxxx)   PHP XXX,XXX.XX
Narration: "To record disposal of [asset description] per approval memo"
```

**Evidence Required**:
- Asset disposal approval memo (signed by Finance Director)
- Disposal journal entries
- Sale/donation documentation (if proceeds received)
- Updated fixed asset register

**Acceptance Criteria**:
- All disposals approved by Finance Director
- Disposal entries posted and balanced
- Fixed asset register updated (disposed assets removed)

---

#### Task 8: Depreciation Policy Review
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 5, 6 (verification and impairment)
**Timing**: Day 3, 4:00 PM - 6:00 PM (overtime if needed)

**Procedure**:
1. Review depreciation policy for continued appropriateness
2. Assess useful life assumptions against actual usage patterns
3. Evaluate salvage value estimates for reasonableness
4. Recommend policy updates if needed (subject to auditor agreement)
5. Document policy review findings and conclusions

**Policy Review Checklist**:
- **Useful Life**: Does actual asset life match policy assumptions?
- **Salvage Value**: Are salvage value estimates realistic?
- **Depreciation Method**: Is straight-line method still appropriate?
- **Component Depreciation**: Should major components be depreciated separately?

**Evidence Required**:
- Depreciation policy review report (Word document)
- Useful life comparison analysis (policy vs. actual)
- Policy update recommendations (if any)

**Acceptance Criteria**:
- Policy review completed and documented
- Any policy changes approved by Finance Director and auditor
- Policy updates reflected in Odoo system (if applicable)

---

#### Task 9: Inventory Valuation Method Review
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 3, 4 (inventory variance and adjustment)
**Timing**: Day 3, 6:00 PM - 8:00 PM (overtime if needed)

**Procedure**:
1. Review inventory valuation method (FIFO, weighted average, etc.)
2. Validate method applied consistently throughout the year
3. Recalculate inventory valuation using chosen method
4. Compare to Odoo system valuation for accuracy
5. Document valuation method review findings

**Inventory Valuation Methods**:
- **FIFO** (First-In, First-Out): Oldest inventory expensed first
- **Weighted Average**: Average cost of all inventory units
- **Specific Identification**: For unique/serialized items

**Valuation Validation Formula**:
```
Ending Inventory Value = Σ (Quantity on Hand × Unit Cost per Valuation Method)
```

**Evidence Required**:
- Inventory valuation calculation worksheet (Excel)
- Valuation method consistency review (comparison across periods)
- Valuation method documentation (policy reference)

**Acceptance Criteria**:
- Valuation method applied consistently
- Inventory value matches Odoo system calculation
- Valuation method documented in accounting policy manual

---

#### Task 10: Inventory & Asset Verification Approval Gate (Gate Y1)
**Owner**: Finance Manager + Operations Manager
**Duration**: 1 hour
**Dependencies**: Tasks 1-9 (all inventory and asset tasks)
**Timing**: Day 3, 8:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Review physical inventory count results and variance analysis
2. Review fixed asset verification results and disposal recommendations
3. Validate inventory and asset adjustments posted correctly
4. Approve or reject based on materiality and accuracy
5. Document approval decision in Odoo

**Approval Criteria**:
- Inventory variance ≤1% of book value
- Fixed asset verification 100% complete
- All material variances (>5% or PHP 50,000) explained
- Disposal recommendations reasonable and approved

**Evidence Required**:
- Inventory verification summary report
- Fixed asset verification summary report
- Approval sign-off (digital signatures from Finance Manager and Operations Manager)

**Outcome**:
- **Approved**: Proceed to Phase 2 (tax provisions)
- **Rejected**: Return to inventory/asset tasks for recounts or additional investigation

---

### Phase 2: Tax Provisions & Regulatory Compliance (Day 3-5)

#### Task 11: Annual Income Tax Computation
**Owner**: Finance Supervisor
**Duration**: 4 hours
**Dependencies**: Gate Y1 approval (Task 10)
**Timing**: Day 4, 9:00 AM - 1:00 PM

**Procedure**:
1. Extract annual accounting income from Odoo (Jan-Dec)
2. Prepare tax reconciliation worksheet (accounting to taxable income)
3. Add back non-deductible expenses (entertainment >0.5%, non-business expenses)
4. Deduct tax-exempt income (interest from government securities, etc.)
5. Calculate taxable income and income tax payable
6. Compare to quarterly estimated tax payments (1601-EQ)
7. Calculate final tax payable or refundable

**Tax Reconciliation Worksheet**:
```
Accounting Income (per Odoo)                    PHP XXX,XXX,XXX
Add: Non-Deductible Expenses
  Entertainment (excess over 0.5% limit)        PHP XXX,XXX
  Penalties and fines                           PHP XXX,XXX
  Non-business expenses                         PHP XXX,XXX
Less: Tax-Exempt Income
  Interest from government securities           (PHP XXX,XXX)
Taxable Income                                  PHP XXX,XXX,XXX

Income Tax (25% regular or 20% OSD)             PHP XXX,XXX,XXX
Less: Quarterly Estimated Tax Payments (1601-EQ) (PHP XXX,XXX,XXX)
Final Tax Payable/(Refundable)                  PHP XXX,XXX,XXX
```

**Income Tax Rate Options**:
- **Regular Corporate Tax**: 25% (25% of taxable income)
- **Optional Standard Deduction (OSD)**: 20% (gross income × 60% deemed deductions × 25% tax rate)

**Evidence Required**:
- Annual income tax computation worksheet (Excel)
- Tax reconciliation schedule (accounting to taxable income)
- Quarterly estimated tax payment confirmations (BIR 1601-EQ receipts)

**Acceptance Criteria**:
- Taxable income calculated per BIR regulations
- Tax rate selection documented and approved
- Final tax payable/(refundable) calculated correctly

---

#### Task 12: Deferred Tax Asset/Liability Calculation
**Owner**: Finance Analyst
**Duration**: 3 hours
**Dependencies**: Task 11 (income tax computation)
**Timing**: Day 4, 1:00 PM - 4:00 PM

**Procedure**:
1. Identify temporary differences (accounting vs. tax treatment)
2. Calculate deferred tax asset (DTA) for deductible temporary differences
3. Calculate deferred tax liability (DTL) for taxable temporary differences
4. Assess valuation allowance for DTA (if recovery uncertain)
5. Book deferred tax journal entries
6. Update deferred tax schedule (opening, movement, closing)

**Common Temporary Differences**:
- **Deductible (DTA)**: Bad debt provision, warranty reserves, accrued expenses not yet deductible
- **Taxable (DTL)**: Accelerated depreciation (tax vs. book), prepaid income

**Deferred Tax Calculation**:
```
DTA = Deductible Temporary Difference × Tax Rate (25%)
DTL = Taxable Temporary Difference × Tax Rate (25%)
Net Deferred Tax = DTA - DTL
```

**Standard Deferred Tax Entry**:
```
Debit: Deferred Tax Asset (1xxxx)   PHP XXX,XXX.XX
Debit/Credit: Deferred Tax Expense/Benefit (6xxxx)   PHP XXX,XXX.XX
  Credit: Deferred Tax Liability (2xxxx)   PHP XXX,XXX.XX
Narration: "To record deferred tax per temporary differences schedule"
```

**Evidence Required**:
- Deferred tax calculation worksheet (Excel)
- Temporary differences schedule (detail by type)
- Deferred tax journal entries

**Acceptance Criteria**:
- All material temporary differences identified (>PHP 50,000)
- Deferred tax calculated at 25% tax rate
- Valuation allowance assessed if DTA recovery uncertain

---

#### Task 13: BIR 1702-RT Preparation (Annual Income Tax Return)
**Owner**: Finance Supervisor
**Duration**: 3 hours
**Dependencies**: Task 11, 12 (income tax and deferred tax)
**Timing**: Day 4, 4:00 PM - 7:00 PM (overtime if needed)

**Procedure**:
1. Prepare BIR Form 1702-RT (Regular Corporate Income Tax Return)
2. Complete all required schedules (revenues, expenses, tax reconciliation)
3. Attach supporting documents (audited financial statements, alphalist)
4. Calculate final tax payable or refundable
5. Generate form PDF for Finance Director review

**BIR 1702-RT Sections**:
- **Part I**: Background Information (TIN, business name, address)
- **Part II**: Computation of Taxable Income
- **Part III**: Computation of Tax Due
- **Part IV**: Summary of Tax Payments
- **Schedules**: Revenue (Sched 1), Cost of Sales (Sched 2), Operating Expenses (Sched 3), etc.

**Required Attachments**:
- Audited Financial Statements (balance sheet, income statement, notes)
- Alphalist of Payees (BIR Form 1604-E)
- List of Officers, Stockholders, Members
- Tax Credit Certificates (if claiming tax credits)

**Evidence Required**:
- BIR Form 1702-RT (PDF)
- Supporting schedules (Excel)
- Required attachments (PDFs)

**Acceptance Criteria**:
- BIR form completed with all required fields
- Taxable income matches tax computation worksheet (Task 11)
- All required attachments prepared
- Finance Director review obtained

---

#### Task 14: BIR 2550Q Preparation (Annual Withholding Tax Return)
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Month-end Task 36 (monthly 1601-C returns)
**Timing**: Day 4, 7:00 PM - 9:00 PM (overtime if needed)

**Procedure**:
1. Consolidate all monthly BIR 1601-C returns (Jan-Dec)
2. Prepare BIR Form 2550Q (Quarterly/Annual Withholding Tax Return)
3. Summarize total withholding taxes by type (compensation, professional fees, etc.)
4. Prepare alphalist of payees (annual consolidated)
5. Validate accuracy against GL withholding tax accounts

**BIR 2550Q Consolidation**:
```
Month       1601-C Amount   YTD Total
January     PHP XXX,XXX     PHP XXX,XXX
February    PHP XXX,XXX     PHP XXX,XXX
...
December    PHP XXX,XXX     PHP XXX,XXX,XXX (Annual Total)
```

**Evidence Required**:
- BIR Form 2550Q (PDF)
- Monthly 1601-C consolidation schedule (Excel)
- Annual alphalist of payees (Excel/CSV)

**Acceptance Criteria**:
- BIR form completed with all required fields
- Annual total matches sum of monthly 1601-C returns
- Alphalist of payees complete and accurate

---

#### Task 15: Documentary Stamp Tax (DST) Review
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Gate Y1 approval (Task 10)
**Timing**: Day 5, 9:00 AM - 11:00 AM

**Procedure**:
1. Review all taxable documents issued during the year (loan agreements, deeds of sale, etc.)
2. Calculate documentary stamp tax (DST) per BIR Revenue Regulations
3. Verify DST stamps affixed or e-DST paid
4. Book accrual for unpaid DST (if any)
5. Prepare DST summary report

**DST Rates (Common Documents)**:
- **Loan Agreements**: PHP 1.50 for every PHP 200 or fraction thereof
- **Deed of Sale - Real Property**: PHP 15.00 for every PHP 1,000 or fraction thereof
- **Deed of Sale - Shares**: PHP 1.50 for every PHP 200 of par value

**DST Accrual Entry** (if unpaid):
```
Debit: DST Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: DST Payable (2xxxx)   PHP XXX,XXX.XX
Narration: "To accrue unpaid documentary stamp tax per DST review"
```

**Evidence Required**:
- DST review report (Excel with document listing)
- DST payment confirmations (e-DST receipts or stamp affixation photos)
- DST accrual journal entry (if any)

**Acceptance Criteria**:
- All taxable documents identified and DST calculated
- DST paid or accrued per BIR regulations
- DST summary report reviewed by Finance Manager

---

#### Task 16: Other Tax Compliance Review (VAT, Local Taxes)
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Gate Y1 approval (Task 10)
**Timing**: Day 5, 11:00 AM - 1:00 PM

**Procedure**:
1. Review VAT compliance (if registered as VAT taxpayer)
2. Validate all quarterly VAT returns filed (BIR 2550Q for VAT)
3. Review local business tax compliance (Mayor's Permit, business tax)
4. Verify real property tax (RPT) payments for owned properties
5. Prepare tax compliance summary report

**Tax Compliance Checklist**:
- **VAT**: Quarterly 2550Q filed, input/output VAT reconciled
- **Local Business Tax**: Annual business tax paid to LGU
- **Real Property Tax**: Annual RPT paid for all owned properties
- **Community Tax Certificate (CTC)**: Cedula obtained annually

**Evidence Required**:
- Tax compliance summary report (Excel)
- Tax payment confirmations (receipts, tax declarations)
- VAT reconciliation (input vs. output VAT)

**Acceptance Criteria**:
- All tax compliance requirements met
- No outstanding tax obligations identified
- Tax compliance summary reviewed by Finance Manager

---

#### Task 17: Tax Audit Risk Assessment
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Tasks 11-16 (all tax compliance tasks)
**Timing**: Day 5, 1:00 PM - 3:00 PM

**Procedure**:
1. Assess tax audit risk based on BIR audit selection criteria
2. Identify potential audit triggers (large refunds, red flags)
3. Prepare tax audit defense file (supporting documentation)
4. Review tax positions for defensibility
5. Recommend tax planning strategies for next year

**BIR Audit Selection Criteria** (Common Triggers):
- Large tax refunds claimed (>PHP 1 million)
- Significant losses reported (for multiple years)
- Unusually low gross profit margins (<10%)
- High entertainment expenses (>0.5% of revenue)
- Related party transactions without proper documentation

**Tax Audit Defense File Contents**:
- Tax computation workpapers (auditable trail)
- Supporting documents for all tax deductions
- Transfer pricing documentation (for related party transactions)
- Tax ruling requests (if any tax positions uncertain)

**Evidence Required**:
- Tax audit risk assessment report (Word document)
- Tax audit defense file (organized folder in Supabase storage)

**Acceptance Criteria**:
- Tax audit risk assessed and documented
- Tax positions defensible with proper documentation
- Tax planning recommendations for next year provided

---

#### Task 18: Tax Provision Journal Entry
**Owner**: Finance Supervisor
**Duration**: 1 hour
**Dependencies**: Task 11, 12 (income tax and deferred tax)
**Timing**: Day 5, 3:00 PM - 4:00 PM

**Procedure**:
1. Book final income tax provision journal entry (from Task 11)
2. Book deferred tax journal entry (from Task 12)
3. Book DST accrual journal entry (from Task 15, if any)
4. Reverse quarterly estimated tax payments to final tax payable
5. Generate tax provision summary report

**Final Income Tax Provision Entry**:
```
Debit: Income Tax Expense (6xxxx)   PHP XXX,XXX.XX
  Credit: Income Tax Payable (2xxxx)   PHP XXX,XXX.XX
Narration: "To record annual income tax provision per BIR 1702-RT"

Debit: Income Tax Payable (2xxxx)   PHP XXX,XXX.XX (quarterly payments)
  Credit: Prepaid Income Tax (1xxxx)   PHP XXX,XXX.XX
Narration: "To reverse quarterly estimated tax payments to final tax payable"
```

**Evidence Required**:
- Tax provision journal entries
- Tax provision summary report (Excel)

**Acceptance Criteria**:
- All tax provision entries posted and balanced
- Final tax payable/(refundable) matches BIR 1702-RT

---

#### Task 19: Tax Filing Preparation (Payment & Submission)
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 13, 14 (BIR 1702-RT and 2550Q)
**Timing**: Day 5, 4:00 PM - 6:00 PM (overtime if needed)

**Procedure**:
1. Calculate total BIR tax payable for annual returns
2. Prepare payment instruction for bank (annual tax payment)
3. Generate payment forms (if manual payment)
4. Coordinate with bank for tax remittance
5. Obtain payment confirmation and reference numbers

**Annual Tax Filing Deadlines**:
- **BIR 1702-RT**: April 15 (Q1 following year)
- **BIR 2550Q**: January 31 (following year for Q4), April 15 (annual consolidated)
- **BIR 1604-E (Alphalist)**: April 15 (attached to 1702-RT)

**Evidence Required**:
- BIR payment confirmations (screenshots or receipts)
- Bank transaction reference numbers

**Acceptance Criteria**:
- Payment completed on or before BIR deadlines
- Payment confirmations obtained

---

#### Task 20: Tax Compliance Approval Gate (Gate Y2)
**Owner**: Finance Director + Tax Advisor
**Duration**: 2 hours
**Dependencies**: Tasks 11-19 (all tax compliance tasks)
**Timing**: Day 5, 6:00 PM - 8:00 PM (overtime if needed)

**Procedure**:
1. Review all annual tax provisions and BIR returns
2. Validate tax computation accuracy and BIR compliance
3. Review tax audit risk assessment and defense file
4. Approve or reject tax compliance package
5. Document approval decision in Odoo

**Approval Criteria**:
- All BIR annual returns completed (1702-RT, 2550Q, 1604-E)
- Tax computation accurate per BIR regulations
- Tax audit defense file complete
- No material tax compliance issues identified

**Evidence Required**:
- Tax compliance approval memo (Word document)
- Approval sign-offs (Finance Director and Tax Advisor digital signatures)

**Outcome**:
- **Approved**: Proceed to Phase 3 (external audit)
- **Rejected**: Return to tax compliance tasks for corrections

---

### Phase 3: External Audit Coordination (Day 5-7)

#### Task 21: Audit Planning Meeting
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Gate Y2 approval (Task 20)
**Timing**: Day 6, 9:00 AM - 11:00 AM

**Procedure**:
1. Schedule audit planning meeting with external auditor
2. Provide prior year audit file and financial statements
3. Discuss significant accounting changes or new transactions
4. Agree on audit scope, timeline, and materiality thresholds
5. Receive audit PBC (Provided By Client) list
6. Assign internal team to prepare audit schedules

**Audit Planning Discussion Topics**:
- **Audit Scope**: Full audit vs. review, locations to visit
- **Materiality**: Performance materiality for testing (typically 5-10% of net income)
- **Significant Risks**: Revenue recognition, related party transactions, inventory valuation
- **Timeline**: Field work dates, draft audit report date, final audit report date
- **Team**: Audit engagement partner, manager, senior, staff

**Evidence Required**:
- Audit planning meeting minutes
- Audit PBC list (Excel or Word)
- Audit timeline (calendar)

**Acceptance Criteria**:
- Audit planning meeting completed
- PBC list received and reviewed
- Internal team assigned to audit support

---

#### Task 22: Audit PBC List Preparation
**Owner**: Finance Supervisor + Finance Analyst
**Duration**: 8 hours (full day)
**Dependencies**: Task 21 (audit planning)
**Timing**: Day 6, 11:00 AM - 7:00 PM (overtime if needed)

**Procedure**:
1. Review audit PBC list for requested schedules and documents
2. Assign PBC items to team members (supervisor, analysts)
3. Prepare audit schedules per auditor's format
4. Gather supporting documentation (invoices, contracts, board minutes)
5. Upload all PBC items to shared audit folder (Supabase storage or Google Drive)
6. Notify auditor when PBC list complete

**Common Audit PBC Items**:
- **Cash**: Bank reconciliations, bank confirmations, cash count sheets
- **Receivables**: AR aging, customer confirmations, bad debt provision analysis
- **Inventory**: Physical count sheets, inventory valuation, obsolescence analysis
- **Fixed Assets**: Asset register, depreciation schedule, asset verification, disposal documentation
- **Liabilities**: AP aging, loan agreements, accrued expense calculations
- **Equity**: Articles of incorporation, stock ledger, dividend declarations
- **Revenue**: Revenue schedule by customer/project, contract terms
- **Expenses**: Expense schedule by account, supporting invoices
- **Tax**: Tax computation workpapers, BIR returns, tax payment confirmations
- **Related Party**: Related party transaction listing, transfer pricing documentation
- **Legal**: Legal representation letter, litigation summary, board minutes

**Evidence Required**:
- Completed audit PBC list (Excel with completion status)
- Audit schedules (Excel per auditor's format)
- Supporting documentation (PDFs uploaded to shared folder)
- PBC completion notification (email to auditor)

**Acceptance Criteria**:
- 100% of PBC items prepared and uploaded
- All schedules tie to general ledger
- Auditor notified of PBC completion

---

#### Task 23: Audit Field Work Support
**Owner**: Finance Team (All)
**Duration**: 3 days (staggered)
**Dependencies**: Task 22 (PBC list preparation)
**Timing**: Day 6-8, as needed per auditor schedule

**Procedure**:
1. Provide workspace for audit team (conference room, Wi-Fi access)
2. Respond to auditor questions and requests promptly (same-day turnaround)
3. Facilitate audit confirmations (bank, customer, vendor, legal)
4. Coordinate access to systems (Odoo view-only access for auditor)
5. Review audit findings and proposed adjustments daily
6. Escalate significant audit issues to Finance Director

**Audit Field Work Support Guidelines**:
- **Response Time**: Same-day response to auditor requests
- **Confirmation Coordination**: Send confirmation requests within 24 hours of auditor request
- **System Access**: Provide view-only Odoo access (no posting rights)
- **Daily Meetings**: 30-minute daily stand-up with auditor to review progress and issues
- **Issue Escalation**: Escalate any audit adjustments >PHP 100,000 to Finance Director

**Evidence Required**:
- Audit confirmation tracking log (Excel with send/receive dates)
- Daily meeting notes (Word document)
- Audit finding log (Excel with proposed adjustments)

**Acceptance Criteria**:
- All auditor requests addressed within same-day
- All confirmations sent and received
- No unresolved audit issues at end of field work

---

#### Task 24: Audit Adjustment Review
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 23 (field work support)
**Timing**: Day 7, 9:00 AM - 11:00 AM

**Procedure**:
1. Review all proposed audit adjustments (PAEs) from auditor
2. Validate accuracy and reasonableness of adjustments
3. Negotiate immaterial or judgment-based adjustments
4. Agree on final adjustments to book
5. Post agreed audit adjustments in Odoo
6. Update financial statements with audit adjustments

**Audit Adjustment Categories**:
- **Factual Errors**: Clear errors in accounting (book immediately)
- **Judgment Differences**: Estimates or assumptions (negotiate reasonableness)
- **Immaterial Items**: Below materiality threshold (may waive if immaterial)
- **Reclassifications**: Presentation only (book for clarity)

**Materiality Thresholds** (for waiving adjustments):
- **Performance Materiality**: 5-10% of net income
- **Individual Item**: Typically PHP 100,000 or 1% of total assets

**Evidence Required**:
- Proposed audit adjustments (PAE list from auditor)
- Audit adjustment decision log (Excel with accept/reject/negotiate)
- Posted audit adjustment journal entries

**Acceptance Criteria**:
- All material audit adjustments (>PHP 100,000) booked
- Financial statements updated with audit adjustments
- Auditor agreement obtained on final adjustments

---

#### Task 25: Management Representation Letter
**Owner**: Finance Director
**Duration**: 1 hour
**Dependencies**: Task 24 (audit adjustment review)
**Timing**: Day 7, 11:00 AM - 12:00 PM

**Procedure**:
1. Review draft management representation letter from auditor
2. Validate all representations are accurate and supportable
3. Sign management representation letter
4. Provide signed letter to auditor (prerequisite for audit opinion)

**Management Representation Letter Content**:
- **Financial Statements**: Management responsible for preparation and fair presentation
- **Completeness**: All transactions recorded, no unrecorded liabilities
- **Fraud**: No knowledge of fraud affecting financial statements
- **Related Party**: All related party transactions disclosed
- **Litigation**: All litigation and claims disclosed
- **Going Concern**: No material uncertainties about ability to continue as going concern
- **Subsequent Events**: All significant events after year-end disclosed

**Evidence Required**:
- Signed management representation letter (PDF)

**Acceptance Criteria**:
- Management representation letter signed by Finance Director and CEO
- Letter provided to auditor before audit opinion issuance

---

#### Task 26: Audited Financial Statements Review
**Owner**: Finance Director
**Duration**: 2 hours
**Dependencies**: Task 25 (management representation letter)
**Timing**: Day 7, 12:00 PM - 2:00 PM

**Procedure**:
1. Review draft audited financial statements from auditor
2. Validate all financial statement line items and notes
3. Review audit opinion for any qualifications or emphasis of matter
4. Request corrections for any errors or inconsistencies
5. Approve final audited financial statements

**Audit Opinion Types**:
- **Unqualified (Clean)**: Financial statements fairly presented (target)
- **Qualified**: Financial statements fairly presented except for specific issues
- **Adverse**: Financial statements not fairly presented (material misstatements)
- **Disclaimer**: Auditor unable to form opinion (scope limitation)

**Evidence Required**:
- Draft audited financial statements (PDF from auditor)
- Audit opinion letter
- Financial statement review notes (corrections requested)

**Acceptance Criteria**:
- Audit opinion is unqualified (clean)
- All financial statement line items validated
- Final audited financial statements approved

---

#### Task 27: Audit Findings and Recommendations Review
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: Task 26 (audited financial statements review)
**Timing**: Day 7, 2:00 PM - 4:00 PM

**Procedure**:
1. Review auditor's management letter (findings and recommendations)
2. Classify findings (significant deficiency, material weakness, best practice)
3. Prepare management response for each finding
4. Develop action plan with timelines for remediation
5. Present findings and action plan to Finance Director and Board

**Audit Finding Categories**:
- **Material Weakness**: Significant deficiency in internal controls (requires immediate action)
- **Significant Deficiency**: Important control weakness (requires remediation)
- **Best Practice Recommendation**: Suggested improvement (consider for future)

**Management Response Template**:
- **Finding**: [Auditor's observation]
- **Management Response**: [Agree/Disagree with reasoning]
- **Action Plan**: [Specific steps to address finding]
- **Timeline**: [Target completion date]
- **Responsible Person**: [Finance role assigned]

**Evidence Required**:
- Auditor's management letter (PDF)
- Management response document (Word)
- Remediation action plan (Excel with timelines)

**Acceptance Criteria**:
- All findings reviewed and management responses prepared
- Action plan approved by Finance Director
- Board presentation scheduled (if material weaknesses identified)

---

#### Task 28: External Audit Readiness Approval Gate (Gate Y3)
**Owner**: Finance Director + External Auditor
**Duration**: 1 hour
**Dependencies**: Tasks 21-27 (all external audit tasks)
**Timing**: Day 7, 4:00 PM - 5:00 PM

**Procedure**:
1. Review audit completion status and timeline
2. Validate all audit schedules and PBC items complete
3. Confirm audit adjustments posted and financial statements updated
4. Review audit opinion and management letter
5. Approve audit completion and readiness for statutory filings

**Approval Criteria**:
- Audit field work complete (100% of PBC items provided)
- Audit adjustments posted (all material items)
- Audit opinion is unqualified (clean)
- Management representation letter signed

**Evidence Required**:
- Audit completion approval memo (Word document)
- Approval sign-offs (Finance Director and External Auditor signatures)

**Outcome**:
- **Approved**: Proceed to Phase 4 (annual reporting and statutory filings)
- **Rejected**: Return to audit tasks for additional field work or corrections

---

### Phase 4: Annual Reporting & Statutory Filings (Day 7-10)

#### Task 29: Annual Report Preparation
**Owner**: Finance Manager
**Duration**: 4 hours
**Dependencies**: Gate Y3 approval (Task 28)
**Timing**: Day 8, 9:00 AM - 1:00 PM

**Procedure**:
1. Prepare annual report (financial and operational highlights)
2. Include audited financial statements
3. Add CEO/President's message
4. Include Board of Directors and management team profiles
5. Add key performance indicators and achievements
6. Format annual report professionally (layout, graphics)

**Annual Report Sections**:
1. **Cover Page**: Company name, logo, year
2. **Table of Contents**
3. **CEO/President's Message**: Strategic highlights and outlook
4. **Company Profile**: Business overview, mission, vision
5. **Financial Highlights**: Key financial metrics (revenue, net income, assets)
6. **Operational Highlights**: Achievements, milestones, awards
7. **Corporate Governance**: Board composition, committees
8. **Audited Financial Statements**: Full financial statements with notes
9. **Statistical Summary**: 5-year financial data comparison

**Evidence Required**:
- Annual report (PDF, professionally formatted)

**Acceptance Criteria**:
- Annual report complete with all sections
- Audited financial statements included
- Professional design and layout

---

#### Task 30: SEC Annual Report Preparation (GIS/AFS)
**Owner**: Finance Supervisor
**Duration**: 3 hours
**Dependencies**: Task 29 (annual report)
**Timing**: Day 8, 1:00 PM - 4:00 PM

**Procedure**:
1. Prepare SEC Form GIS (General Information Sheet)
2. Prepare SEC Form AFS (Audited Financial Statements)
3. Complete all required schedules (related party transactions, etc.)
4. Gather required attachments (board resolutions, stock ledger)
5. Generate SEC filing package (PDF)

**SEC Form GIS Sections**:
- **Part I**: Corporate Information (TIN, SEC registration, address)
- **Part II**: Directors and Officers (names, TINs, nationalities)
- **Part III**: Stockholders (top 20 stockholders, ownership %)
- **Part IV**: Affiliated Companies (subsidiaries, related parties)

**SEC Form AFS Sections**:
- **Cover Sheet**: Company name, fiscal year, auditor information
- **Audited Financial Statements**: Balance sheet, income statement, cash flow, notes
- **Supplementary Schedules**: Schedule A-G (aging, intangible assets, LT debt, etc.)

**Evidence Required**:
- SEC Form GIS (PDF)
- SEC Form AFS (PDF)
- Supplementary schedules (PDFs)
- Required attachments (board resolutions, stock ledger)

**Acceptance Criteria**:
- SEC forms completed with all required fields
- Audited financial statements attached
- All supplementary schedules prepared

---

#### Task 31: BIR Alphalist Preparation (1604-E)
**Owner**: Finance Analyst
**Duration**: 2 hours
**Dependencies**: Task 14 (BIR 2550Q)
**Timing**: Day 8, 4:00 PM - 6:00 PM (overtime if needed)

**Procedure**:
1. Prepare BIR Form 1604-E (Annual Alphalist of Payees)
2. Include all payees subject to withholding tax (Jan-Dec)
3. Classify payees by tax type (compensation, professional fees, etc.)
4. Generate electronic file (DAT format for eBIRForms)
5. Validate alphalist totals to BIR 2550Q

**Alphalist Categories**:
- **Schedule 1**: Compensation paid to employees (WC010)
- **Schedule 2**: Professional fees (WC020)
- **Schedule 3**: Rentals (WC030)
- **Schedule 4**: Dividends (WC040)
- ... (other categories as applicable)

**Alphalist Format** (per payee):
```
TIN         Name              Address    Income      Tax Withheld
XXX-XXX-XXX Juan Dela Cruz    Manila     PHP XXX,XXX PHP XX,XXX
```

**Evidence Required**:
- BIR Form 1604-E (PDF and DAT file)
- Alphalist validation report (totals to 2550Q)

**Acceptance Criteria**:
- Alphalist complete with all payees
- Electronic file (DAT) generated successfully
- Alphalist totals match BIR 2550Q

---

#### Task 32: Statutory Filing Timeline Preparation
**Owner**: Finance Supervisor
**Duration**: 1 hour
**Dependencies**: Tasks 13, 14, 30, 31 (all statutory filings)
**Timing**: Day 8, 6:00 PM - 7:00 PM (overtime if needed)

**Procedure**:
1. Prepare statutory filing timeline with all deadlines
2. Assign responsibilities for each filing
3. Set reminders in Odoo/Supabase task queue
4. Coordinate with external service providers (SEC filing agent, if used)
5. Generate filing timeline summary report

**Statutory Filing Deadlines (Year-End Dec 31)**:
- **BIR 2550Q (Annual WHT)**: January 31 (following year)
- **BIR 1702-RT (Annual ITR)**: April 15 (following year)
- **BIR 1604-E (Alphalist)**: April 15 (following year)
- **SEC GIS/AFS**: April 15 (following year, 120 days from year-end)
- **LGU Business Tax**: January 31 (following year)

**Evidence Required**:
- Statutory filing timeline (Excel with deadlines and responsibilities)
- Odoo task queue screenshot (reminders set)

**Acceptance Criteria**:
- All filing deadlines documented
- Responsibilities assigned
- Reminders set for all deadlines

---

#### Task 33: Board of Directors Meeting (Financial Statements Approval)
**Owner**: Finance Director
**Duration**: 2 hours
**Dependencies**: Task 26 (audited financial statements review)
**Timing**: Day 9, 10:00 AM - 12:00 PM

**Procedure**:
1. Schedule Board of Directors meeting (AGM or special meeting)
2. Present audited financial statements to Board
3. Present audit findings and management responses (if any)
4. Obtain Board approval of audited financial statements
5. Document Board resolution approving financial statements

**Board Meeting Agenda**:
1. **Call to Order**: Quorum confirmation
2. **Approval of Prior Minutes**
3. **Financial Statements Presentation**: Finance Director presents audited FS
4. **Audit Findings and Recommendations**: Review management letter
5. **Board Questions and Discussion**
6. **Board Resolution**: Approval of audited financial statements
7. **Adjournment**

**Evidence Required**:
- Board meeting minutes (Word document)
- Board resolution approving audited financial statements
- Attendance sheet (signed by all directors)

**Acceptance Criteria**:
- Board meeting held with quorum (majority of directors)
- Audited financial statements approved by Board resolution
- Meeting minutes and resolution documented

---

#### Task 34: Dividend Declaration (if applicable)
**Owner**: Finance Director
**Duration**: 1 hour
**Dependencies**: Task 33 (Board meeting)
**Timing**: Day 9, 12:00 PM - 1:00 PM

**Procedure**:
1. Review retained earnings balance for dividend availability
2. Calculate dividend payout ratio (dividends / net income)
3. Propose dividend declaration to Board (if policy requires)
4. Obtain Board approval for dividend declaration
5. Book dividend declaration journal entry

**Dividend Payout Policy** (example):
- **Target Payout Ratio**: 30-50% of net income
- **Frequency**: Annual (declared at AGM)
- **Form**: Cash dividend (alternative: stock dividend)

**Dividend Declaration Entry**:
```
Debit: Retained Earnings (3xxxx)   PHP XXX,XXX.XX
  Credit: Dividends Payable (2xxxx)   PHP XXX,XXX.XX
Narration: "To record dividend declaration per Board resolution dated [date]"
```

**Evidence Required**:
- Dividend calculation worksheet (Excel)
- Board resolution approving dividend declaration
- Dividend declaration journal entry

**Acceptance Criteria**:
- Dividend payout ratio within policy (30-50% of net income)
- Board approval obtained
- Dividend declaration entry posted

---

#### Task 35: BIR Filing Submission (1702-RT, 2550Q, 1604-E)
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 13, 14, 31 (BIR forms preparation)
**Timing**: Day 9, 1:00 PM - 3:00 PM

**Procedure**:
1. Compile all BIR annual returns (1702-RT, 2550Q, 1604-E)
2. Submit via eBIRForms (preferred) or manual filing at RDO
3. Obtain BIR filing confirmation and reference numbers
4. Upload filed returns to Supabase storage for audit trail
5. Update BIR submission tracking log

**BIR Filing Methods**:
- **eBIRForms**: Electronic filing via BIR system (preferred, faster processing)
- **Manual Filing**: Physical submission at Revenue District Office (RDO)

**Evidence Required**:
- BIR filing confirmations (screenshots or receipts)
- BIR transaction reference numbers
- Filed BIR returns (PDFs with stamped/confirmed status)
- Updated BIR submission tracking log

**Acceptance Criteria**:
- All BIR annual returns filed on or before deadlines
- Filing confirmations obtained
- Filed returns uploaded to Supabase storage

---

#### Task 36: SEC Filing Submission (GIS/AFS)
**Owner**: Finance Supervisor
**Duration**: 2 hours
**Dependencies**: Task 30 (SEC forms preparation)
**Timing**: Day 9, 3:00 PM - 5:00 PM

**Procedure**:
1. Compile all SEC annual reports (GIS, AFS, supplementary schedules)
2. Submit via SEC online filing system or manual filing
3. Obtain SEC filing confirmation and reference numbers
4. Pay SEC filing fees (if applicable)
5. Upload filed reports to Supabase storage for audit trail

**SEC Filing Methods**:
- **SEC Online Filing**: Electronic filing via SEC system (preferred)
- **Manual Filing**: Physical submission at SEC office (for certain cases)

**Evidence Required**:
- SEC filing confirmations (screenshots or receipts)
- SEC transaction reference numbers
- Filed SEC reports (PDFs with stamped/confirmed status)
- SEC filing fee payment receipts

**Acceptance Criteria**:
- All SEC annual reports filed on or before April 15 deadline
- Filing confirmations obtained
- Filed reports uploaded to Supabase storage

---

#### Task 37: Year-End Close Documentation Package
**Owner**: Finance Manager
**Duration**: 2 hours
**Dependencies**: All prior tasks (1-36)
**Timing**: Day 10, 9:00 AM - 11:00 AM

**Procedure**:
1. Assemble complete year-end close documentation package
2. Include all financial statements (audited and internal)
3. Include all audit schedules and PBC items
4. Include all BIR and SEC filings
5. Include Board resolutions and meeting minutes
6. Upload complete package to Supabase storage
7. Generate table of contents and executive summary

**Year-End Close Documentation Package Contents**:
1. **Executive Summary**: Year-end close status and highlights
2. **Month-End Close Checklist**: Completed 44-task checklist (from month-end template)
3. **Year-End Close Checklist**: Completed 38-task checklist (this template)
4. **Financial Statements**: Audited balance sheet, income statement, cash flow, notes
5. **Audit File**: All audit schedules, PBC items, management letter, audit opinion
6. **Tax Filings**: BIR 1702-RT, 2550Q, 1604-E with supporting schedules
7. **Statutory Filings**: SEC GIS, AFS, supplementary schedules
8. **Board Documentation**: Board resolutions, meeting minutes, attendance sheets
9. **Inventory & Asset Documentation**: Physical count sheets, verification reports, disposal documentation
10. **Supporting Schedules**: All reconciliations, variance analyses, KPI reports

**Evidence Required**:
- Complete year-end close documentation package (organized folder structure in Supabase)
- Table of contents (Word document)
- Upload confirmation (Supabase storage link)

**Acceptance Criteria**:
- All documentation sections included and properly organized
- Complete package uploaded to Supabase storage
- Table of contents accurate and complete

---

#### Task 38: Statutory Filing Approval Gate (Gate Y4)
**Owner**: Finance Director + Board of Directors
**Duration**: 1 hour
**Dependencies**: Tasks 35, 36, 37 (all filings and documentation)
**Timing**: Day 10, 11:00 AM - 12:00 PM

**Procedure**:
1. Review all statutory filings (BIR, SEC)
2. Validate filing confirmations and reference numbers
3. Review year-end close documentation package
4. Approve year-end close completion
5. Document approval decision in Odoo and Board minutes

**Approval Criteria**:
- All BIR annual returns filed (1702-RT, 2550Q, 1604-E)
- All SEC annual reports filed (GIS, AFS)
- All filing deadlines met
- Year-end close documentation package complete

**Evidence Required**:
- Statutory filing approval memo (Word document)
- Approval sign-offs (Finance Director and Board Secretary signatures)
- Board resolution approving year-end close completion

**Outcome**:
- **Approved**: Year-end close officially complete
- **Rejected**: Return to filing tasks for corrections or additional submissions

---

## Acceptance Criteria Summary

### Critical Success Factors

**Timeline Compliance**:
- ✅ All 38 year-end tasks completed within 10 business days
- ✅ All approval gates passed on schedule (Gates Y1-Y4)
- ✅ All statutory filing deadlines met (BIR: Apr 15, SEC: Apr 15)

**Quality Standards**:
- ✅ Physical inventory count variance ≤1%
- ✅ Fixed asset verification 100% complete
- ✅ Audit opinion is unqualified (clean)
- ✅ Tax computation accuracy per BIR regulations

**Documentation Completeness**:
- ✅ All evidence requirements met (audit PBC list 100% complete)
- ✅ All approval sign-offs obtained (Finance Manager, Finance Director, Board, Auditor)
- ✅ All statutory filings submitted (BIR, SEC)

**System Integration**:
- ✅ All audit adjustments posted in Odoo
- ✅ Year-end data synced to Supabase (variance ≤0.1%)
- ✅ Year-end close documentation package uploaded to Supabase storage

---

## Common Issues & Troubleshooting

### Issue 1: Inventory Variance >1%
**Symptom**: Physical inventory count shows variance exceeding 1% threshold

**Root Causes**:
- Inaccurate counting procedures (rushed counts, untrained counters)
- Inventory movements during count (cut-off not enforced)
- System errors (incorrect unit of measure, pricing errors)
- Theft or shrinkage (security issues)

**Resolution Steps**:
1. Conduct immediate recount of high-variance items
2. Review cut-off procedures (ensure no movements during count)
3. Validate Odoo inventory data (check for system errors)
4. Investigate potential theft (review security logs, access controls)
5. Book variance adjustments after thorough investigation

**Prevention**:
- Cycle counting throughout the year (quarterly physical counts)
- Automated count verification (barcode scanning, RFID)
- Staff training on count procedures
- Enhanced security measures (cameras, access controls)

---

### Issue 2: Audit Opinion Not Unqualified (Qualified/Adverse)
**Symptom**: External auditor issues qualified or adverse opinion

**Root Causes**:
- Material misstatements in financial statements (errors not corrected)
- Scope limitation (auditor unable to obtain sufficient evidence)
- Going concern uncertainty (material doubt about ability to continue operations)
- Non-compliance with accounting standards (PFRS/IFRS violations)

**Resolution Steps**:
1. Immediately escalate to Finance Director and Board
2. Meet with auditor to understand specific qualification reasons
3. Prepare corrective action plan (address misstatements or scope limitations)
4. Request auditor reconsideration after corrections
5. If qualification stands, prepare board memo explaining impact

**Prevention**:
- Quarterly external auditor reviews (not just year-end)
- Monthly close discipline (catch errors early)
- Accounting policy compliance reviews
- Proactive communication with auditor on complex transactions

---

### Issue 3: Missed Statutory Filing Deadline
**Symptom**: BIR or SEC filing not submitted by deadline (Apr 15)

**Root Causes**:
- Late audit completion (audited FS not ready by deadline)
- System issues (eBIRForms downtime, SEC portal errors)
- Resource constraints (insufficient staff to complete filings)
- Document preparation delays (missing required attachments)

**Resolution Steps**:
1. File immediately upon readiness (minimize penalty period)
2. Calculate penalties (BIR: 25% surcharge + 12% interest p.a., SEC: PHP 200/day)
3. Prepare penalty payment and submission
4. Document reason for late filing (for penalty abatement request if justified)
5. Escalate to Finance Director and Board

**Prevention**:
- Early audit planning (start field work in January, not March)
- Filing timeline monitoring (weekly status checks from January)
- Backup filing methods (manual filing if eBIRForms down)
- Document preparation checklists (ensure all attachments ready early)

---

## Appendix A: Year-End vs. Month-End Task Comparison

| Category | Month-End (44 Tasks) | Year-End (38 Additional Tasks) |
|----------|---------------------|-------------------------------|
| **Inventory** | Reconciliation (Task 7) | Physical count, variance analysis, obsolescence (Tasks 1-4) |
| **Fixed Assets** | Depreciation (Task 10) | Physical verification, impairment, disposal (Tasks 5-7) |
| **Tax** | Monthly WHT (Task 36) | Annual ITR, deferred tax, DST review (Tasks 11-20) |
| **Audit** | Internal review | External audit coordination (Tasks 21-28) |
| **Reporting** | Internal financial package (Task 34) | Annual report, SEC/BIR filings (Tasks 29-36) |
| **Approval** | Finance Manager, Finance Director | Board of Directors, External Auditor |

---

## Appendix B: Statutory Filing Checklist

| Filing | Form | Deadline | Responsible | Evidence |
|--------|------|----------|-------------|----------|
| Annual Income Tax Return | BIR 1702-RT | April 15 | Finance Supervisor | Filed return PDF, payment receipt |
| Annual Withholding Tax Return | BIR 2550Q | April 15 | Finance Analyst | Filed return PDF |
| Annual Alphalist of Payees | BIR 1604-E | April 15 | Finance Analyst | Filed DAT file, PDF |
| SEC General Information Sheet | SEC GIS | April 15 | Finance Supervisor | Filed GIS PDF, SEC receipt |
| SEC Audited Financial Statements | SEC AFS | April 15 | Finance Supervisor | Filed AFS PDF, SEC receipt |
| Local Business Tax Return | LGU Form | January 31 | Finance Analyst | Filed return, payment receipt |

---

## Appendix C: External Audit PBC List (Sample)

| Schedule | Description | Owner | Due Date | Status |
|----------|-------------|-------|----------|--------|
| **Cash** | Bank reconciliations (all accounts) | Finance Supervisor | Day 6 | ✅ |
| **Cash** | Bank confirmations (auditor sends) | Finance Analyst | Day 6 | ✅ |
| **Receivables** | AR aging report (12/31) | Finance Analyst | Day 6 | ✅ |
| **Receivables** | Customer confirmations (auditor selects) | Finance Analyst | Day 7 | 🔄 |
| **Inventory** | Physical count sheets | Finance Supervisor | Day 6 | ✅ |
| **Inventory** | Inventory valuation schedule | Finance Analyst | Day 6 | ✅ |
| **Fixed Assets** | Fixed asset register | Finance Analyst | Day 6 | ✅ |
| **Fixed Assets** | Asset verification report | Finance Analyst | Day 6 | ✅ |
| **Liabilities** | AP aging report (12/31) | Finance Analyst | Day 6 | ✅ |
| **Liabilities** | Loan agreements | Finance Supervisor | Day 6 | ✅ |
| **Tax** | Tax computation workpapers | Finance Supervisor | Day 6 | ✅ |
| **Tax** | BIR returns (all months) | Finance Analyst | Day 6 | ✅ |
| **Revenue** | Revenue schedule by customer | Finance Analyst | Day 6 | ✅ |
| **Expenses** | Expense schedule by account | Finance Analyst | Day 6 | ✅ |
| **Related Party** | Related party transaction listing | Finance Manager | Day 6 | ✅ |
| **Legal** | Legal representation letter | Finance Director | Day 7 | 🔄 |
| **Governance** | Board minutes (all meetings) | Finance Manager | Day 6 | ✅ |

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-29 | Finance SSC Manager | Initial template creation |

---

**End of Year-End Close Task Template**