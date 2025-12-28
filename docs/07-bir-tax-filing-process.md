# BIR Tax Filing Process Documentation

## Document Control

**Version**: 1.0
**Last Updated**: 2025-12-29
**Owner**: Finance SSC Manager
**Approvers**: Finance Manager, Finance Director, Tax Advisor
**Review Cycle**: Quarterly (after each BIR filing cycle)

---

## Executive Summary

This document provides comprehensive Philippine BIR (Bureau of Internal Revenue) tax compliance workflows for TBWA Finance SSC, covering 6 primary tax forms, tax computation methodologies, filing deadlines, penalty calculations, and multi-agency/multi-employee handling procedures. The processes ensure ≥98% accuracy in tax calculations and 100% on-time filing compliance.

**Scope**: Philippine tax compliance for 8 agencies with 8 employee withholding agents
**Critical Forms**: 1601-C, 0619-E, 2550Q, 1702-RT, 1601-EQ, 1601-FQ
**Accuracy Target**: ≥98% (variance ≤2% between BIR forms and GL)
**Filing Compliance Target**: 100% on-time submissions (zero penalties)

---

## BIR Tax Compliance Architecture

### Tax Forms Ecosystem

```
Monthly Withholding Tax Forms (Due: 10th of following month)
   ├── BIR 1601-C: Withholding Tax on Compensation & Other Payments
   └── BIR 0619-E: Monthly Remittance of Creditable Income Tax Withheld (Expanded)

Quarterly Income Tax Forms (Due: 60 days after quarter-end)
   ├── BIR 1601-EQ: Quarterly Remittance of Creditable Income Tax Withheld (Expanded)
   ├── BIR 1601-FQ: Quarterly Remittance of Final Income Tax Withheld
   └── BIR 2550Q: Quarterly/Annual Income Tax Return

Annual Tax Forms (Due: April 15 following year)
   ├── BIR 1702-RT: Annual Income Tax Return (Regular Corporate)
   └── BIR 1604-E: Annual Information Return (Alphalist of Payees)
```

### Multi-Agency/Multi-Employee Handling

**8 Agencies**: CKVC, BOM, JPAL, JLI, JAP, LAS, RMQB, RIM
**8 Employee Withholding Agents**: One per agency (responsible for BIR compliance)

**Aggregation Strategy**:
- **Monthly Forms (1601-C, 0619-E)**: Filed per employee/agency (8 separate filings per month)
- **Quarterly Forms (2550Q, 1601-EQ, 1601-FQ)**: Filed per agency (8 separate filings per quarter)
- **Annual Forms (1702-RT, 1604-E)**: Filed per agency (8 separate filings annually)

**Consolidated Tracking**: Finance SSC Manager maintains consolidated view across all agencies/employees

---

## BIR Form Detailed Workflows

### BIR Form 1601-C: Monthly Withholding Tax Return

**Full Form Name**: Monthly Remittance Return of Income Taxes Withheld on Compensation and Final Withholding Taxes

**Filing Frequency**: Monthly
**Filing Deadline**: 10th day of the following month
**Who Files**: Each of 8 employee withholding agents (per agency)
**Penalty for Late Filing**: 25% surcharge + 12% interest per annum (calculated daily)

---

#### Scope and Coverage

**Income Payments Subject to Withholding**:

**WC010 - Compensation Income** (Employees):
- Salaries and wages
- Bonuses (13th month, performance bonuses)
- Overtime pay
- Allowances (taxable portion)
- Benefits in kind (taxable value)

**WC020 - Professional Fees** (Independent Contractors):
- Consulting fees
- Legal/accounting services
- Medical/dental fees
- Engineering/architectural services
- Talent fees (actors, models, influencers)

**WC030 - Rentals**:
- Office space rental
- Equipment rental
- Vehicle rental
- Property rental (real estate)

**WC040 - Dividends**:
- Cash dividends
- Stock dividends (if applicable)

**WC050 - Interest Income**:
- Bank deposits (if payor is withholding agent)
- Loans to individuals

**WC060 - Royalties**:
- Intellectual property royalties
- Franchise fees
- Patent/copyright royalties

**WC070 - Prizes and Winnings**:
- Raffle prizes
- Contest winnings (>PHP 10,000)

**WC080 - Professional Entertainers/Athletes**:
- Performance fees
- Appearance fees
- Endorsement fees

---

#### Tax Computation Methodology

**WC010 - Compensation (Progressive Tax Rates)**:

Tax is withheld using the graduated withholding tax table per RR No. 11-2018 (as amended by TRAIN Law):

```
Annual Compensation           Tax Rate
PHP 0 - 250,000               0%
PHP 250,001 - 400,000         15% of excess over PHP 250,000
PHP 400,001 - 800,000         PHP 22,500 + 20% of excess over PHP 400,000
PHP 800,001 - 2,000,000       PHP 102,500 + 25% of excess over PHP 800,000
PHP 2,000,001 - 8,000,000     PHP 402,500 + 30% of excess over PHP 2,000,000
PHP 8,000,001 and above       PHP 2,202,500 + 35% of excess over PHP 8,000,000
```

**Example (Monthly Withholding)**:
```
Employee: Juan Dela Cruz
Monthly Gross Salary: PHP 50,000
Annualized: PHP 50,000 × 12 = PHP 600,000

Annual Tax:
  0 - 250,000: PHP 0
  250,000 - 400,000: (400,000 - 250,000) × 15% = PHP 22,500
  400,000 - 600,000: (600,000 - 400,000) × 20% = PHP 40,000
Total Annual Tax: PHP 62,500

Monthly Withholding: PHP 62,500 / 12 = PHP 5,208.33
```

**WC020 - Professional Fees (10% or 15%)**:
- **10%**: If payee has BIR Authority to Print (ATP) receipts
- **15%**: If payee has no ATP (informal receipts)

**WC030 - Rentals (5%)**:
- Rental income × 5% withholding rate

**WC040 - Dividends (10%)**:
- Cash dividends × 10% final withholding tax

**WC050 - Interest (20%)**:
- Interest income × 20% final withholding tax

**WC060 - Royalties (10% or 20%)**:
- **10%**: If royalty is for books, literary works
- **20%**: Other royalties (patents, franchises)

**WC070 - Prizes (20%)**:
- Prize amount × 20% final withholding tax

---

#### Data Extraction from Odoo

**SQL Query for WC010 (Compensation)**:
```sql
SELECT
  e.name AS employee_name,
  e.tin AS employee_tin,
  p.date_from,
  p.date_to,
  SUM(CASE WHEN pl.code = 'BASIC' THEN pl.total ELSE 0 END) AS basic_salary,
  SUM(CASE WHEN pl.code = 'ALLOWANCE' THEN pl.total ELSE 0 END) AS taxable_allowances,
  SUM(CASE WHEN pl.code = 'BONUS' THEN pl.total ELSE 0 END) AS bonuses,
  SUM(CASE WHEN pl.code = 'WITHHOLDING' THEN pl.total ELSE 0 END) AS tax_withheld
FROM hr_payslip p
JOIN hr_employee e ON p.employee_id = e.id
JOIN hr_payslip_line pl ON pl.slip_id = p.id
WHERE p.date_from >= '2025-12-01'
  AND p.date_to <= '2025-12-31'
  AND p.state = 'done'
GROUP BY e.id, p.date_from, p.date_to
ORDER BY e.name;
```

**SQL Query for WC020 (Professional Fees)**:
```sql
SELECT
  p.name AS vendor_name,
  p.vat AS vendor_tin,
  ai.date_invoice,
  ai.number AS invoice_number,
  SUM(ail.price_subtotal) AS professional_fees,
  SUM(ail.price_subtotal * 0.10) AS tax_withheld_10pct,
  CASE
    WHEN p.has_atp = TRUE THEN 'With ATP (10%)'
    ELSE 'No ATP (15%)'
  END AS withholding_rate
FROM account_invoice ai
JOIN res_partner p ON ai.partner_id = p.id
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE ai.date_invoice >= '2025-12-01'
  AND ai.date_invoice <= '2025-12-31'
  AND ai.move_type = 'in_invoice'
  AND ail.account_id IN (SELECT id FROM account_account WHERE code LIKE '6%' AND name ILIKE '%professional%')
  AND ai.state = 'posted'
GROUP BY p.id, ai.id
ORDER BY ai.date_invoice;
```

---

#### BIR Form 1601-C Completion Steps

**Part I: Background Information**
1. Enter TIN of Withholding Agent (agency TIN)
2. Enter Registered Name of Withholding Agent (agency legal name)
3. Enter Registered Address
4. Enter RDO Code (Revenue District Office where registered)
5. Enter Line of Business (advertising, consulting, etc.)
6. Enter Telephone/Mobile Number
7. Enter Email Address

**Part II: Computation of Income Taxes Withheld**

For each tax code (WC010, WC020, etc.):
1. **ATC (Alphanumeric Tax Code)**: Select from dropdown (e.g., WC010)
2. **Nature of Income Payment**: Description (e.g., Compensation, Professional Fees)
3. **Tax Rate**: Enter applicable rate (e.g., 10%, 15%, 20%)
4. **Amount of Income Payment**: Gross amount paid (before withholding)
5. **Tax Withheld**: Amount of tax withheld from payment

**Example Entries**:
```
ATC    Nature                  Tax Rate   Income Payment   Tax Withheld
WC010  Compensation            Progressive PHP 500,000     PHP 62,500
WC020  Professional Fees       10%        PHP 100,000     PHP 10,000
WC030  Rentals                 5%         PHP 50,000      PHP 2,500
Total                                     PHP 650,000     PHP 75,000
```

**Part III: Computation of Penalties**
- Leave blank if filing on time
- If late, system auto-calculates 25% surcharge + 12% interest p.a.

**Part IV: Summary of Remittance**
1. **Total Income Tax Withheld**: Sum of all tax withheld (from Part II)
2. **Add: Penalties** (if late filing): Surcharge + Interest
3. **Total Amount Payable**: Income Tax + Penalties
4. **Less: Tax Payments Made** (if any prior payments for this period)
5. **Tax Still Due/(Overpayment)**: Final amount to remit

---

#### Validation and Accuracy Checks

**Pre-Submission Validation**:

1. **Reconciliation to GL**:
```sql
-- GL Withholding Tax Liability Account (Month-End Balance)
SELECT
  SUM(debit - credit) AS gl_withholding_liability
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2103')
  AND date >= '2025-12-01'
  AND date <= '2025-12-31';

-- Compare to BIR Form Total Tax Withheld
-- Variance = GL Balance - BIR Form Total
-- Target: Variance ≤ 2%
```

2. **Alphalist Reconciliation**:
```
Total Tax Withheld (per BIR Form 1601-C) = Sum of Tax Withheld per Payee (per Alphalist)
If variance detected → investigate line-by-line
```

3. **Payroll Reconciliation (WC010)**:
```
Total Compensation (BIR Form) = Total Gross Salaries (Payroll Register)
Total Tax Withheld (BIR Form) = Total Withholding Tax (Payroll Register)
```

**Accuracy Target**: ≥98% (variance ≤2%)

**Common Variance Causes**:
- Timing differences (December salaries paid in January)
- Accrued expenses not yet paid (professional fees accrued but not invoiced)
- Manual adjustments not recorded in Odoo
- Incorrect tax code classification

---

#### Filing and Payment Process

**Step 1: Generate BIR Form PDF**
- Use n8n workflow: `BIR_1601C_Generator.json`
- Workflow extracts data from Odoo → Populates BIR Form PDF → Saves to Supabase storage

**Step 2: Review and Approve**
- Finance Supervisor reviews form for accuracy
- Finance Manager approves form (digital signature in Odoo task record)

**Step 3: File via eBIRForms** (Preferred Method)
1. Log in to eBIRForms (https://ebir.bir.gov.ph/)
2. Select BIR Form 1601-C
3. Upload generated PDF or manually enter data
4. Submit electronically
5. Obtain electronic filing confirmation (e-Receipt)

**Alternative: Manual Filing at RDO**
1. Print BIR Form 1601-C (3 copies: BIR file, taxpayer copy, RDO copy)
2. Visit Revenue District Office (RDO) where registered
3. Submit form with payment (if applicable)
4. Obtain stamped receipt copy

**Step 4: Payment via Authorized Agent Bank (AAB)**
1. Generate BIR payment form (if paying at bank)
2. Visit AAB (BDO, BPI, Metrobank, etc.)
3. Pay total tax withheld amount
4. Obtain bank-validated receipt (official receipt)

**Alternative Payment Methods**:
- **eBIRForms**: Pay online via GCash, PayMaya, or bank transfer
- **Mobile Banking**: Select BIR as biller, enter tax type and amount

**Step 5: Record Filing and Payment in Odoo**
```sql
-- Update BIR submission tracking table
UPDATE ipai_finance_bir_schedule
SET
  status = 'filed',
  filing_date = '2026-01-10',
  filing_reference = 'eBIR-1601C-2025-12-12345678',
  payment_reference = 'BDO-OR-98765432'
WHERE bir_form = '1601-C'
  AND period = '2025-12';
```

---

### BIR Form 0619-E: Monthly Expanded Withholding Tax Return

**Full Form Name**: Monthly Remittance Return of Income Taxes Withheld (Expanded)

**Filing Frequency**: Monthly
**Filing Deadline**: 10th day of the following month
**Who Files**: Each of 8 agencies (corporate level, not per employee)
**Penalty for Late Filing**: 25% surcharge + 12% interest per annum

---

#### Scope and Coverage

**Expanded Withholding Tax (EWT)** applies to income payments to suppliers/service providers:

**WI010 - Professional Services** (10% or 15%):
- Lawyers, accountants, engineers, architects
- Consultants, contractors, designers

**WI020 - Professional Entertainers** (10%):
- Talent fees, performance fees
- Endorsement fees, appearance fees

**WI030 - Directors' Fees** (10%):
- Fees paid to Board of Directors
- Committee meeting fees

**WI040 - Management/Technical Consultancy** (10%):
- Management consulting fees
- IT consulting, technical advisory

**WI050 - Commission to Agents** (10%):
- Sales commissions
- Broker commissions

**WI060 - Tolling Fees** (1%):
- Manufacturing tolling arrangements

**WI070 - Rentals** (5%):
- Real estate rentals (land, buildings)
- Equipment/machinery rentals

**WI080 - Income Payments to Government Personnel** (1-10%):
- Fees to government employees (moonlighting)

**WI090 - Income Payments to Certain Professionals** (10% or 15%):
- Medical/dental practitioners
- Veterinarians

**WI100 - Income Distributed to Beneficiaries** (15%):
- Estate/trust income distribution

---

#### Tax Computation Methodology

**General Formula**:
```
Tax Withheld = Gross Payment × Withholding Rate
```

**Example (Professional Fees - WI010)**:
```
Service Provider: ABC Consulting Corp.
Invoice Amount: PHP 100,000 (professional consulting services)
Withholding Rate: 10% (has BIR ATP)
Tax Withheld: PHP 100,000 × 10% = PHP 10,000

Payment to Vendor:
  Invoice Amount: PHP 100,000
  Less: EWT (10%): (PHP 10,000)
  Net Payment: PHP 90,000
```

**Withholding Rate Determination**:
- **With ATP (Authority to Print)**: 10%
- **Without ATP**: 15%
- **Government/VAT-Registered**: 10%

---

#### Data Extraction from Odoo

**SQL Query for EWT (All Suppliers)**:
```sql
SELECT
  p.name AS supplier_name,
  p.vat AS supplier_tin,
  ai.date_invoice,
  ai.number AS invoice_number,
  ail.name AS service_description,
  ail.price_subtotal AS gross_amount,
  awt.code AS tax_code,  -- e.g., WI010, WI020
  awt.amount AS withholding_rate,
  ail.price_subtotal * (awt.amount / 100) AS tax_withheld
FROM account_invoice ai
JOIN res_partner p ON ai.partner_id = p.id
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
JOIN account_tax awt ON ail.invoice_line_tax_ids @> ARRAY[awt.id]
WHERE ai.date_invoice >= '2025-12-01'
  AND ai.date_invoice <= '2025-12-31'
  AND ai.move_type = 'in_invoice'
  AND awt.type_tax_use = 'purchase'
  AND awt.tax_group_id = (SELECT id FROM account_tax_group WHERE name = 'Withholding Tax')
  AND ai.state = 'posted'
ORDER BY ai.date_invoice, p.name;
```

---

#### BIR Form 0619-E Completion Steps

**Part I: Background Information**
- Same as BIR 1601-C (TIN, name, address, RDO code)

**Part II: Computation of Expanded Withholding Taxes**

For each ATC (WI010, WI020, etc.):
1. **ATC**: Select from dropdown (e.g., WI010)
2. **Nature of Income Payment**: Description (e.g., Professional Services)
3. **Tax Rate**: Enter applicable rate (e.g., 10%)
4. **Amount of Income Payment**: Gross amount paid (before withholding)
5. **Tax Withheld**: Amount of tax withheld

**Example Entries**:
```
ATC    Nature                         Tax Rate   Income Payment   Tax Withheld
WI010  Professional Services          10%        PHP 500,000     PHP 50,000
WI040  Management Consultancy         10%        PHP 200,000     PHP 20,000
WI070  Rentals                        5%         PHP 100,000     PHP 5,000
Total                                            PHP 800,000     PHP 75,000
```

**Part III: Summary of Remittance**
- Same as BIR 1601-C (total tax withheld, penalties, payments, net due)

---

#### Validation and Accuracy Checks

**Reconciliation to GL**:
```sql
-- GL EWT Payable Account (Month-End Balance)
SELECT
  SUM(debit - credit) AS gl_ewt_payable
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2104')
  AND date >= '2025-12-01'
  AND date <= '2025-12-31';

-- Compare to BIR Form Total Tax Withheld
-- Variance = GL Balance - BIR Form Total
-- Target: Variance ≤ 2%
```

**Supplier Confirmation**:
- Send BIR Form 2307 (Certificate of Creditable Tax Withheld at Source) to each supplier
- Supplier validates tax withheld matches their records
- File signed 2307 with supplier confirmations in audit file

---

#### Filing and Payment Process

**Same as BIR 1601-C**:
1. Generate form PDF via n8n workflow
2. Review and approve (Finance Supervisor → Finance Manager)
3. File via eBIRForms or manual filing at RDO
4. Pay via AAB or online banking
5. Record filing and payment in Odoo

**Deadline**: 10th day of following month (same as 1601-C)

---

### BIR Form 2550Q: Quarterly/Annual Income Tax Return

**Full Form Name**: Quarterly/Annual Income Tax Return for Individuals, Estates and Trusts (also used by corporations on OSD)

**Filing Frequency**: Quarterly and Annually
**Filing Deadline**:
- **Quarterly**: 60 days after quarter-end (Feb 28/29 for Q4, May 31 for Q1, Aug 31 for Q2, Nov 30 for Q3)
- **Annual**: April 15 of following year (consolidated)

**Who Files**: Each of 8 agencies (corporate level)
**Penalty for Late Filing**: 25% surcharge + 20% interest per annum (on unpaid tax)

---

#### Scope and Coverage

**Quarterly Income Tax** is an estimated tax payment based on projected annual income:

**Quarter 1 (Jan-Mar)**: File by May 15 (60 days from Mar 31)
**Quarter 2 (Apr-Jun)**: File by Aug 15 (60 days from Jun 30)
**Quarter 3 (Jul-Sep)**: File by Nov 15 (60 days from Sep 30)
**Quarter 4 (Oct-Dec)**: File by Feb 28/29 (60 days from Dec 31)

**Annual Consolidated**: File by April 15 (summarizing all 4 quarters)

---

#### Tax Computation Methodology

**Quarterly Estimated Tax Formula**:
```
Quarterly Taxable Income = (Quarterly Revenue - Quarterly Expenses) × Tax Rate
Tax Rate = 25% (Regular Corporate Tax) or 20% (Optional Standard Deduction)

Quarterly Income Tax = Quarterly Taxable Income × 25%
Less: Prior Quarter Payments (if filing Q2, Q3, or Q4)
Net Tax Due = Current Quarter Tax - Prior Quarter Payments
```

**Example (Q1 2025)**:
```
Agency: CKVC
Q1 Revenue (Jan-Mar): PHP 5,000,000
Q1 Expenses (Jan-Mar): PHP 3,500,000
Q1 Net Income: PHP 1,500,000

Q1 Taxable Income: PHP 1,500,000
Q1 Income Tax (25%): PHP 1,500,000 × 25% = PHP 375,000

Net Tax Due (Q1): PHP 375,000 (no prior payments)
```

**Example (Q2 2025)**:
```
Q2 Revenue (Apr-Jun): PHP 6,000,000
Q2 Expenses (Apr-Jun): PHP 4,000,000
Q2 Net Income: PHP 2,000,000

YTD Net Income (Jan-Jun): PHP 1,500,000 + PHP 2,000,000 = PHP 3,500,000
YTD Income Tax (25%): PHP 3,500,000 × 25% = PHP 875,000

Less: Q1 Payment: (PHP 375,000)
Net Tax Due (Q2): PHP 500,000
```

---

#### Data Extraction from Odoo

**SQL Query for Quarterly Income**:
```sql
-- Quarterly Revenue
SELECT
  SUM(ail.price_subtotal) AS quarterly_revenue
FROM account_invoice ai
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE ai.date_invoice >= '2025-01-01'
  AND ai.date_invoice <= '2025-03-31'
  AND ai.move_type = 'out_invoice'
  AND ai.state = 'posted';

-- Quarterly Expenses
SELECT
  SUM(ail.price_subtotal) AS quarterly_expenses
FROM account_invoice ai
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE ai.date_invoice >= '2025-01-01'
  AND ai.date_invoice <= '2025-03-31'
  AND ai.move_type = 'in_invoice'
  AND ai.state = 'posted';

-- Quarterly Net Income
SELECT
  (SELECT SUM(ail.price_subtotal) FROM account_invoice ai JOIN account_invoice_line ail ON ail.invoice_id = ai.id WHERE ai.date_invoice >= '2025-01-01' AND ai.date_invoice <= '2025-03-31' AND ai.move_type = 'out_invoice' AND ai.state = 'posted') -
  (SELECT SUM(ail.price_subtotal) FROM account_invoice ai JOIN account_invoice_line ail ON ail.invoice_id = ai.id WHERE ai.date_invoice >= '2025-01-01' AND ai.date_invoice <= '2025-03-31' AND ai.move_type = 'in_invoice' AND ai.state = 'posted')
  AS quarterly_net_income;
```

---

#### BIR Form 2550Q Completion Steps

**Part I: Background Information**
- TIN, name, address, RDO code (same as other forms)

**Part II: Computation of Quarterly/Annual Income Tax**

**For Corporations (Regular)**:
```
1. Gross Income from Operations                 PHP XXX,XXX
2. Cost of Sales/Services                       (PHP XXX,XXX)
3. Gross Income from Operations                 PHP XXX,XXX
4. Ordinary Allowable Deductions                (PHP XXX,XXX)
5. Net Income (Loss)                            PHP XXX,XXX
6. Add: Non-Deductible Expenses                 PHP XXX,XXX
7. Less: Tax-Exempt Income                      (PHP XXX,XXX)
8. Taxable Income                               PHP XXX,XXX
9. Income Tax Due (25% of line 8)               PHP XXX,XXX
10. Less: Tax Credits/Payments                  (PHP XXX,XXX)
11. Tax Payable/(Overpayment)                   PHP XXX,XXX
```

**For Corporations (OSD - Optional Standard Deduction)**:
```
1. Gross Income from Operations                 PHP XXX,XXX
2. Less: Optional Standard Deduction (40%)      (PHP XXX,XXX)
3. Taxable Income (60% of gross income)         PHP XXX,XXX
4. Income Tax Due (25% of line 3)               PHP XXX,XXX
5. Less: Tax Credits/Payments                   (PHP XXX,XXX)
6. Tax Payable/(Overpayment)                    PHP XXX,XXX
```

**Part III: Summary of Tax Payments**
- Prior Quarter Payments (Q1, Q2, Q3)
- Creditable Withholding Taxes (if applicable)
- Tax Payments Made (prior quarters)
- Net Tax Still Due/(Overpayment)

---

#### Annual Consolidated Return (April 15 Deadline)

**Annual 2550Q Consolidation**:
```
Quarter   Quarterly Income   Quarterly Tax   YTD Tax   Payment Made
Q1        PHP 1,500,000     PHP 375,000     PHP 375,000   PHP 375,000
Q2        PHP 2,000,000     PHP 500,000     PHP 875,000   PHP 500,000
Q3        PHP 1,800,000     PHP 450,000     PHP 1,325,000 PHP 450,000
Q4        PHP 2,200,000     PHP 550,000     PHP 1,875,000 PHP 550,000
Total     PHP 7,500,000     PHP 1,875,000   PHP 1,875,000 PHP 1,875,000

Annual Adjustment:
  Annual Taxable Income (per audited FS): PHP 7,500,000
  Annual Income Tax (25%): PHP 1,875,000
  Less: Quarterly Payments: (PHP 1,875,000)
  Final Tax Due/(Refundable): PHP 0
```

---

### BIR Form 1702-RT: Annual Corporate Income Tax Return

**Full Form Name**: Annual Income Tax Return for Corporations, Partnerships and Other Non-Individual Taxpayers

**Filing Frequency**: Annually
**Filing Deadline**: April 15 of following year (or 15th day of 4th month after fiscal year-end)
**Who Files**: Each of 8 agencies (corporate level)
**Penalty for Late Filing**: 25% surcharge + 20% interest per annum (on unpaid tax)

---

#### Scope and Coverage

**Annual Income Tax Return** is the definitive tax filing reconciling:
- Annual accounting income (per audited financial statements)
- Annual taxable income (per BIR regulations)
- Annual tax due vs. quarterly estimated payments (BIR 2550Q)

**Tax Rate Options**:
- **Regular Corporate Tax**: 25% of taxable income (allows itemized deductions)
- **Optional Standard Deduction (OSD)**: 20% effective rate (60% of gross income taxable at 25%)

---

#### Tax Computation Methodology

**Regular Corporate Tax Computation**:
```
Gross Income                                    PHP XXX,XXX,XXX
Less: Cost of Sales/Services                    (PHP XXX,XXX,XXX)
Gross Income from Operations                    PHP XXX,XXX,XXX

Less: Operating Expenses
  Salaries and Wages                            (PHP XXX,XXX)
  Rent                                          (PHP XXX,XXX)
  Utilities                                     (PHP XXX,XXX)
  Depreciation                                  (PHP XXX,XXX)
  Other Deductible Expenses                     (PHP XXX,XXX)
Total Operating Expenses                        (PHP XXX,XXX,XXX)

Net Income Before Tax (Accounting)              PHP XXX,XXX,XXX

Tax Adjustments:
  Add: Non-Deductible Expenses
    Entertainment (excess over 0.5% limit)      PHP XXX,XXX
    Penalties and Fines                         PHP XXX,XXX
    Non-Business Expenses                       PHP XXX,XXX
  Less: Tax-Exempt Income
    Interest from Government Securities         (PHP XXX,XXX)

Taxable Income                                  PHP XXX,XXX,XXX
Income Tax (25%)                                PHP XXX,XXX,XXX

Less: Tax Credits/Payments
  Quarterly Income Tax Payments (2550Q)         (PHP XXX,XXX,XXX)
  Creditable Withholding Taxes (if any)         (PHP XXX,XXX)

Final Tax Payable/(Refundable)                  PHP XXX,XXX,XXX
```

**OSD Computation**:
```
Gross Income from Operations                    PHP XXX,XXX,XXX
Less: Optional Standard Deduction (40%)         (PHP XXX,XXX,XXX)
Taxable Income (60% of gross income)            PHP XXX,XXX,XXX
Income Tax (25% of taxable income)              PHP XXX,XXX,XXX

Less: Tax Credits/Payments
  Quarterly Income Tax Payments (2550Q)         (PHP XXX,XXX,XXX)
Final Tax Payable/(Refundable)                  PHP XXX,XXX,XXX
```

**OSD vs. Regular Comparison**:
```
Scenario: Gross Income = PHP 10,000,000, Expenses = PHP 6,000,000

Regular:
  Taxable Income = PHP 10M - PHP 6M = PHP 4M
  Income Tax (25%) = PHP 1M

OSD:
  Taxable Income = PHP 10M × 60% = PHP 6M
  Income Tax (25%) = PHP 1.5M

Decision: Choose Regular (lower tax: PHP 1M vs. PHP 1.5M)
```

---

#### Data Extraction from Odoo

**SQL Query for Annual Income**:
```sql
-- Annual Revenue (Jan-Dec)
SELECT
  SUM(ail.price_subtotal) AS annual_revenue
FROM account_invoice ai
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE EXTRACT(YEAR FROM ai.date_invoice) = 2025
  AND ai.move_type = 'out_invoice'
  AND ai.state = 'posted';

-- Annual Expenses (Jan-Dec)
SELECT
  aa.code AS account_code,
  aa.name AS account_name,
  SUM(aml.debit - aml.credit) AS annual_expense
FROM account_move_line aml
JOIN account_account aa ON aml.account_id = aa.id
WHERE EXTRACT(YEAR FROM aml.date) = 2025
  AND aa.code LIKE '6%'  -- Expense accounts
GROUP BY aa.code, aa.name
ORDER BY aa.code;
```

---

#### BIR Form 1702-RT Completion Steps

**Part I: Background Information**
- TIN, name, address, RDO code, fiscal year-end (Dec 31 or other)

**Part II: Computation of Taxable Income**
- Schedule 1: Gross Revenue
- Schedule 2: Cost of Sales/Services
- Schedule 3: Operating Expenses (itemized)
- Schedule 4: Other Income/Expenses
- Schedule 5: Non-Deductible Expenses
- Schedule 6: Tax-Exempt Income

**Part III: Computation of Income Tax Due**
- Taxable Income (from Part II)
- Income Tax (25% or 20% OSD)
- Tax Credits/Payments (quarterly 2550Q, creditable withholding)
- Final Tax Payable/(Refundable)

**Part IV: Attachments Required**
- Audited Financial Statements (balance sheet, income statement, notes)
- Alphalist of Payees (BIR 1604-E)
- List of Officers, Stockholders, Members
- SEC Certificate of Filing (GIS/AFS)
- Tax Credit Certificates (if claiming tax credits)

---

### BIR Form 1601-EQ/1601-FQ: Quarterly Withholding Tax Returns

**BIR 1601-EQ**: Quarterly Remittance Return of Creditable Income Taxes Withheld (Expanded)
**BIR 1601-FQ**: Quarterly Remittance Return of Final Income Taxes Withheld

**Filing Frequency**: Quarterly
**Filing Deadline**: 30 days after quarter-end (Apr 30, Jul 31, Oct 31, Jan 31)
**Who Files**: Each of 8 agencies (corporate level)

---

#### Scope and Coverage

**1601-EQ (Expanded Withholding)**:
- Consolidation of monthly 0619-E returns (3 months per quarter)
- Same tax codes as 0619-E (WI010-WI100)

**1601-FQ (Final Withholding)**:
- Consolidation of final withholding taxes from 1601-C (e.g., dividends, interest)
- Tax codes: WC040 (dividends), WC050 (interest), WC060 (royalties), WC070 (prizes)

**Computation**:
```
Quarter 1 (Jan-Mar):
  January 0619-E: PHP 50,000
  February 0619-E: PHP 55,000
  March 0619-E: PHP 52,000
  Q1 1601-EQ Total: PHP 157,000

Quarter 2 (Apr-Jun):
  April 0619-E: PHP 60,000
  May 0619-E: PHP 58,000
  June 0619-E: PHP 62,000
  Q2 1601-EQ Total: PHP 180,000
```

---

#### Filing Process

**Same as Monthly Forms**:
1. Consolidate 3 months of data (month 1 + month 2 + month 3)
2. Generate quarterly form PDF via n8n workflow
3. Review and approve
4. File via eBIRForms or manual filing
5. Pay via AAB or online banking (if additional payment needed)
6. Record filing in Odoo

---

### BIR Form 1604-E: Annual Alphalist of Payees

**Full Form Name**: Annual Information Return of Income Taxes Withheld on Compensation and Final Withholding Taxes

**Filing Frequency**: Annually
**Filing Deadline**: April 15 of following year (attached to BIR 1702-RT)
**Who Files**: Each of 8 agencies (corporate level)
**Format**: Electronic DAT file + PDF summary

---

#### Scope and Coverage

**Alphalist of Payees** is a detailed listing of all payees (employees, suppliers, contractors) subject to withholding tax during the year:

**Schedule 1: Compensation** (Employees)
- TIN, name, address, gross compensation, tax withheld (per employee)

**Schedule 2: Professional Fees** (Independent Contractors)
- TIN, name, address, professional fees paid, tax withheld (per payee)

**Schedule 3: Rentals** (Lessors)
- TIN, name, address, rental income paid, tax withheld (per lessor)

... (Schedules 4-10 for other income types)

---

#### Data Extraction from Odoo

**SQL Query for Alphalist (All Payees)**:
```sql
-- Employees (Schedule 1)
SELECT
  'Schedule 1' AS schedule,
  e.tin,
  e.name,
  e.address,
  SUM(pl.total) FILTER (WHERE pl.code IN ('BASIC', 'ALLOWANCE', 'BONUS')) AS gross_compensation,
  SUM(pl.total) FILTER (WHERE pl.code = 'WITHHOLDING') AS tax_withheld
FROM hr_payslip p
JOIN hr_employee e ON p.employee_id = e.id
JOIN hr_payslip_line pl ON pl.slip_id = p.id
WHERE EXTRACT(YEAR FROM p.date_from) = 2025
  AND p.state = 'done'
GROUP BY e.tin, e.name, e.address

UNION ALL

-- Suppliers (Schedule 2 - Professional Fees)
SELECT
  'Schedule 2' AS schedule,
  p.vat AS tin,
  p.name,
  p.street AS address,
  SUM(ail.price_subtotal) AS professional_fees,
  SUM(ail.price_subtotal * 0.10) AS tax_withheld
FROM account_invoice ai
JOIN res_partner p ON ai.partner_id = p.id
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE EXTRACT(YEAR FROM ai.date_invoice) = 2025
  AND ai.move_type = 'in_invoice'
  AND ail.account_id IN (SELECT id FROM account_account WHERE code LIKE '6%' AND name ILIKE '%professional%')
  AND ai.state = 'posted'
GROUP BY p.vat, p.name, p.street

ORDER BY schedule, tin;
```

---

#### BIR Form 1604-E Completion Steps

**Part I: Background Information**
- TIN, name, address, RDO code, taxable year (2025)

**Part II: Summary by Schedule**
```
Schedule   Description                No. of Payees   Total Income    Total Tax Withheld
1          Compensation               50             PHP 30,000,000  PHP 3,750,000
2          Professional Fees          20             PHP 5,000,000   PHP 500,000
3          Rentals                    5              PHP 1,000,000   PHP 50,000
...
Total                                 75             PHP 36,000,000  PHP 4,300,000
```

**Part III: Detailed Listing (DAT File)**

Electronic file format (comma-delimited):
```
Schedule,TIN,First Name,Middle Name,Last Name,Address,Gross Income,Tax Withheld
1,123-456-789,Juan,Dela,Cruz,"123 Main St, Manila",600000.00,62500.00
2,987-654-321,ABC Consulting,,Corp,"456 Ayala Ave, Makati",100000.00,10000.00
...
```

---

#### Validation and Accuracy Checks

**Alphalist to BIR Forms Reconciliation**:
```
Total Tax Withheld (1604-E) = Sum of Monthly 1601-C Tax Withheld (Jan-Dec)
Variance Tolerance: 0% (must match exactly)
```

**Common Variance Causes**:
- Missing payees (not included in alphalist)
- Duplicate entries (payee listed twice)
- Incorrect TIN or name (typos)
- Incorrect tax withheld amount (calculation errors)

---

## Multi-Agency/Multi-Employee Handling

### Consolidated Tracking Dashboard

**Supabase Table**: `ipai_finance_bir_schedule`

**Schema**:
```sql
CREATE TABLE ipai_finance_bir_schedule (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bir_form TEXT NOT NULL,  -- '1601-C', '0619-E', '2550Q', '1702-RT', '1601-EQ', '1601-FQ', '1604-E'
  period TEXT NOT NULL,  -- 'YYYY-MM' for monthly, 'YYYY-QN' for quarterly, 'YYYY' for annual
  agency TEXT NOT NULL,  -- 'CKVC', 'BOM', 'JPAL', 'JLI', 'JAP', 'LAS', 'RMQB', 'RIM'
  employee_tin TEXT,  -- For 1601-C (per employee), NULL for corporate forms
  status TEXT DEFAULT 'not_started',  -- 'not_started', 'in_progress', 'submitted', 'filed', 'late'
  filing_deadline DATE NOT NULL,
  prep_deadline DATE GENERATED ALWAYS AS (filing_deadline - INTERVAL '4 days') STORED,
  review_deadline DATE GENERATED ALWAYS AS (filing_deadline - INTERVAL '2 days') STORED,
  approval_deadline DATE GENERATED ALWAYS AS (filing_deadline - INTERVAL '1 day') STORED,
  filing_date DATE,
  filing_reference TEXT,  -- eBIR confirmation number
  payment_reference TEXT,  -- Bank OR number
  total_tax_withheld NUMERIC(15,2),
  responsible_person TEXT,  -- Finance Supervisor, Finance Manager, Finance Director
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### Consolidated BIR Summary Report (Monthly)

**SQL Query**:
```sql
SELECT
  bir_form,
  period,
  COUNT(*) AS total_filings,
  SUM(CASE WHEN status = 'filed' THEN 1 ELSE 0 END) AS filed_count,
  SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) AS late_count,
  SUM(total_tax_withheld) AS total_tax_remitted,
  ROUND(
    (SUM(CASE WHEN status = 'filed' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100,
    2
  ) AS filing_compliance_pct
FROM ipai_finance_bir_schedule
WHERE period = '2025-12'
  AND bir_form IN ('1601-C', '0619-E')
GROUP BY bir_form, period
ORDER BY bir_form;
```

**Expected Output**:
```
BIR Form   Period    Total   Filed   Late   Total Tax        Compliance%
1601-C     2025-12   8       8       0      PHP 600,000     100.00%
0619-E     2025-12   8       8       0      PHP 500,000     100.00%
```

---

### Mattermost Notification Workflow

**n8n Workflow**: `BIR_Deadline_Alert.json`

**Triggers**:
- **7 days before deadline**: Reminder to Finance Supervisor
- **3 days before deadline**: Escalation to Finance Manager
- **1 day before deadline**: Escalation to Finance Director
- **Day of deadline**: Critical alert to all stakeholders

**Notification Format**:
```
🚨 BIR Filing Alert - 1601-C (Dec 2025)

Deadline: January 10, 2026 (3 days remaining)
Status: In Progress (6/8 agencies filed)

Pending Filings:
- JPAL (Finance Supervisor: Analyst C)
- RMQB (Finance Supervisor: Analyst G)

Action Required:
- Finance Supervisors: Complete filings by EOD
- Finance Manager: Review and approve by Jan 9

Total Tax Withheld (YTD): PHP 600,000
Filing Compliance (YTD): 94.12% (64/68 filings)
```

---

## Penalty Calculation and Avoidance

### BIR Penalty Structure

**Late Filing Penalties**:
```
Surcharge = 25% of tax due (one-time penalty)
Interest = 12% per annum (calculated daily from due date to payment date)

Total Penalty = Surcharge + Interest
```

**Example (1 Month Late)**:
```
Tax Due: PHP 100,000
Filing Deadline: January 10, 2026
Actual Filing Date: February 10, 2026 (31 days late)

Surcharge (25%): PHP 100,000 × 25% = PHP 25,000
Interest (12% p.a. × 31/365 days): PHP 100,000 × 12% × (31/365) = PHP 1,019
Total Penalty: PHP 25,000 + PHP 1,019 = PHP 26,019

Total Amount Due: PHP 100,000 + PHP 26,019 = PHP 126,019
```

**Compromise Penalty** (BIR discretion):
- First-time offenders may request penalty reduction
- Requires written request to RDO with justification
- Typical reduction: 25-50% of computed penalty

---

### Penalty Avoidance Strategies

**Strategy 1: Early Preparation**
- Start BIR form preparation 7 days before deadline
- Complete internal review 3 days before deadline
- Submit 2 days before deadline (buffer for issues)

**Strategy 2: Automated Reminders**
- Use Odoo task queue with escalation rules
- Mattermost notifications at T-7, T-3, T-1 days
- Email alerts to responsible persons

**Strategy 3: Backup Filing Methods**
- Primary: eBIRForms (faster processing)
- Backup: Manual filing at RDO (if eBIRForms down)
- Contingency: File via authorized tax agent

**Strategy 4: Payment Coordination**
- Pre-fund bank account with estimated tax amounts
- Setup online banking BIR billers in advance
- Keep payment references for audit trail

---

## BIR Audit Defense Preparation

### Audit Triggers (Common)

**Red Flags for BIR Audit Selection**:
1. Large tax refunds claimed (>PHP 1 million)
2. Significant losses reported (multiple consecutive years)
3. Unusually low gross profit margins (<10%)
4. High entertainment expenses (>0.5% of revenue)
5. Related party transactions without proper documentation
6. Missing or late BIR filings (chronic non-compliance)

---

### Audit Defense File Structure

**Folder 1: Tax Computation Workpapers**
- Excel calculation files (all BIR forms)
- Reconciliation reports (GL to BIR forms)
- Tax rate justification (regular vs. OSD decision)

**Folder 2: Supporting Documentation**
- Invoices (all withholding tax payments)
- Payroll registers (employee compensation)
- Bank statements (payment validations)
- Contracts (rental agreements, professional service agreements)

**Folder 3: BIR Filings and Receipts**
- Filed BIR forms (PDFs with stamps/confirmations)
- Payment receipts (bank ORs, eBIR confirmations)
- Alphalists (1604-E DAT files and PDFs)

**Folder 4: Accounting Records**
- General ledger (all accounts)
- Trial balance (monthly and annual)
- Financial statements (audited and internal)

**Folder 5: Transfer Pricing Documentation** (if applicable)
- Related party transaction listing
- Transfer pricing study (if transactions >PHP 15M annually)
- Arm's length pricing justification

---

### Audit Response Protocol

**Step 1: Letter of Authority (LOA) Receipt**
- BIR sends LOA notifying audit
- Respond within 10 days acknowledging LOA
- Coordinate with external tax advisor

**Step 2: Audit Planning Meeting**
- Meet with BIR examiners to discuss scope
- Provide audit defense file overview
- Agree on audit schedule and workspace

**Step 3: Audit Field Work Support**
- Provide requested documents promptly (same-day response)
- Answer examiner questions with evidence
- Escalate significant issues to Finance Director and tax advisor

**Step 4: Audit Findings Review**
- Review BIR audit findings (deficiency assessment)
- Validate accuracy of BIR calculations
- Negotiate immaterial or judgment-based items

**Step 5: Protest or Settlement**
- If findings material and disagree → file protest within 30 days
- If findings reasonable → pay deficiency tax and close audit
- Consult tax advisor before deciding

---

## Acceptance Criteria Summary

### Critical Success Factors

**Filing Compliance**:
- ✅ 100% on-time filing (zero late submissions)
- ✅ All 8 agencies/employees filed monthly forms (1601-C, 0619-E)
- ✅ All 8 agencies filed quarterly forms (2550Q, 1601-EQ, 1601-FQ)
- ✅ All 8 agencies filed annual forms (1702-RT, 1604-E)

**Accuracy Standards**:
- ✅ BIR form calculations ≥98% accurate (variance ≤2%)
- ✅ GL reconciliation variance ≤2%
- ✅ Alphalist totals match BIR forms (0% variance)

**Documentation Completeness**:
- ✅ All supporting documents attached (invoices, contracts, payroll)
- ✅ All filing confirmations obtained (eBIR receipts, bank ORs)
- ✅ All filings uploaded to Supabase storage for audit trail

**System Integration**:
- ✅ n8n workflows functional (form generation, deadline alerts)
- ✅ Odoo BIR tracking table updated (filing status, references)
- ✅ Mattermost notifications sent (timely alerts to stakeholders)

---

## Common Issues & Troubleshooting

### Issue 1: BIR Calculation Variance >2%
**Symptom**: BIR form totals do not match GL within 2% tolerance

**Root Causes**:
- Timing differences (transactions posted after month-end)
- Incorrect tax code classification (wrong withholding rate)
- Manual adjustments not recorded in Odoo
- Data extraction query errors (SQL logic issues)

**Resolution Steps**:
1. Re-run data extraction queries from Odoo
2. Compare BIR form line items to GL account detail (line-by-line)
3. Identify specific transactions causing variance
4. Book adjusting entries if legitimate (timing differences)
5. Correct Odoo tax settings if misconfiguration (update tax codes)
6. Regenerate BIR form with corrected data

**Prevention**:
- Monthly reconciliation (don't wait until deadline)
- Automated validation scripts (SQL checks before form generation)
- Tax code audit (quarterly review of all mappings)

---

### Issue 2: eBIRForms System Downtime
**Symptom**: eBIRForms portal unavailable on filing deadline

**Root Causes**:
- BIR system maintenance (unscheduled downtime)
- High traffic volume (deadline day congestion)
- Internet connectivity issues (ISP problems)

**Resolution Steps**:
1. **Immediate**: Switch to manual filing at RDO
   - Print BIR forms (3 copies)
   - Visit RDO before 5:00 PM deadline
   - Submit forms with payment (if applicable)
   - Obtain stamped receipt copy

2. **Contingency**: File via authorized tax agent
   - Contact tax agent with BIR form data
   - Agent files on behalf using their eBIR access
   - Obtain filing confirmation from agent

3. **Documentation**: Note system downtime in filing log
   - Screenshot eBIRForms error page
   - Document alternative filing method used
   - Justify manual filing (for audit defense)

**Prevention**:
- File 2 days before deadline (avoid deadline rush)
- Pre-test eBIRForms login credentials 1 week before deadline
- Maintain authorized tax agent relationship (backup option)

---

### Issue 3: Missing Payee Information (Incomplete TINs)
**Symptom**: Alphalist (1604-E) cannot be completed due to missing payee TINs

**Root Causes**:
- New suppliers/employees not providing TIN during onboarding
- Odoo partner records incomplete (TIN field blank)
- Incorrect TIN format (wrong number of digits)

**Resolution Steps**:
1. Query Odoo for payees with missing TINs:
```sql
SELECT
  p.name AS payee_name,
  p.vat AS tin,
  SUM(ail.price_subtotal) AS total_payments
FROM account_invoice ai
JOIN res_partner p ON ai.partner_id = p.id
JOIN account_invoice_line ail ON ail.invoice_id = ai.id
WHERE EXTRACT(YEAR FROM ai.date_invoice) = 2025
  AND ai.move_type = 'in_invoice'
  AND ai.state = 'posted'
  AND (p.vat IS NULL OR p.vat = '')
GROUP BY p.name, p.vat
ORDER BY total_payments DESC;
```

2. Contact payees to request TIN (email or phone)
3. Update Odoo partner records with TIN information
4. Regenerate alphalist with complete data

**Prevention**:
- Vendor onboarding checklist (require TIN before payment)
- Odoo validation rule (block invoice posting if TIN missing)
- Quarterly vendor master data audit (verify TIN completeness)

---

## Appendix A: BIR Filing Deadlines Calendar (2026)

| BIR Form | Filing Frequency | January | February | March | April | May | June | July | August | September | October | November | December |
|----------|------------------|---------|----------|-------|-------|-----|------|------|--------|-----------|---------|----------|----------|
| **1601-C** | Monthly | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 |
| **0619-E** | Monthly | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 |
| **2550Q** | Quarterly | - | - | - | - | 15 (Q1) | - | - | 15 (Q2) | - | - | 15 (Q3) | - |
| **1601-EQ** | Quarterly | 31 (Q4) | - | - | 30 (Q1) | - | - | 31 (Q2) | - | - | 31 (Q3) | - | - |
| **1601-FQ** | Quarterly | 31 (Q4) | - | - | 30 (Q1) | - | - | 31 (Q2) | - | - | 31 (Q3) | - | - |
| **1702-RT** | Annual | - | - | - | 15 | - | - | - | - | - | - | - | - |
| **1604-E** | Annual | - | - | - | 15 | - | - | - | - | - | - | - | - |

**Note**: If deadline falls on weekend/holiday, filing is due on next business day.

---

## Appendix B: BIR Form Checklist (Per Agency)

| BIR Form | Responsible | Review | Approve | Deadline | Evidence |
|----------|-------------|--------|---------|----------|----------|
| **1601-C** | Finance Supervisor | Finance Manager | Finance Director | 10th of month | Filed form PDF, payment receipt |
| **0619-E** | Finance Supervisor | Finance Manager | Finance Director | 10th of month | Filed form PDF, payment receipt |
| **2550Q (Q1)** | Finance Analyst | Finance Manager | Finance Director | May 15 | Filed form PDF, payment receipt |
| **2550Q (Q2)** | Finance Analyst | Finance Manager | Finance Director | Aug 15 | Filed form PDF, payment receipt |
| **2550Q (Q3)** | Finance Analyst | Finance Manager | Finance Director | Nov 15 | Filed form PDF, payment receipt |
| **2550Q (Q4)** | Finance Analyst | Finance Manager | Finance Director | Feb 28 | Filed form PDF, payment receipt |
| **1601-EQ (Q1)** | Finance Analyst | Finance Manager | Finance Director | Apr 30 | Filed form PDF |
| **1601-EQ (Q2)** | Finance Analyst | Finance Manager | Finance Director | Jul 31 | Filed form PDF |
| **1601-EQ (Q3)** | Finance Analyst | Finance Manager | Finance Director | Oct 31 | Filed form PDF |
| **1601-EQ (Q4)** | Finance Analyst | Finance Manager | Finance Director | Jan 31 | Filed form PDF |
| **1702-RT** | Finance Supervisor | Finance Manager + Tax Advisor | Finance Director + Board | Apr 15 | Filed form PDF, audited FS, payment receipt |
| **1604-E** | Finance Analyst | Finance Manager | Finance Director | Apr 15 | Filed DAT file, PDF summary |

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-29 | Finance SSC Manager | Initial documentation creation |

---

**End of BIR Tax Filing Process Documentation**