# Final Pay Calculation

## Purpose

This document defines the complete final pay calculation methodology for separated employees, ensuring compliance with Philippine DOLE Labor Advisory No. 06-20 and internal TBWA\SMP Champion standards.

## Calculation Timing

**Statutory Deadline**: ≤30 calendar days from separation date (DOLE requirement)

**Internal SLA**: ≤7 calendar days from Clearance Completed (TBWA standard)

## Final Pay Components

### Additions (Credit to Employee)

#### 1. Pro-Rated Basic Salary

**Formula**:
```
Pro-Rated Salary = (Monthly Basic Salary / 22 work days) × Days Worked in Final Month
```

**Example**:
```
Monthly Basic Salary: ₱30,000
Last Working Day (LWD): November 15, 2025
Days Worked: 15 days (Nov 1-15)
Pro-Rated Salary = (₱30,000 / 22) × 15 = ₱20,454.55
```

**Odoo Field Reference**: `hr.contract.wage` (Monthly Basic Salary)

#### 2. Unused Leave Credit Conversion

**Formula**:
```
Daily Rate = Monthly Basic Salary / 22 work days

Vacation Leave (VL) Conversion = VL Balance × Daily Rate
Sick Leave (SL) Conversion = SL Balance × Daily Rate (if company policy allows)

Total Leave Conversion = VL Conversion + SL Conversion
```

**Example**:
```
Monthly Basic Salary: ₱30,000
Daily Rate: ₱30,000 / 22 = ₱1,363.64
VL Balance: 10 days
SL Balance: 5 days (assume convertible)

VL Conversion: 10 × ₱1,363.64 = ₱13,636.40
SL Conversion: 5 × ₱1,363.64 = ₱6,818.20
Total Leave Conversion: ₱20,454.60
```

**Odoo Field Reference**:
- `hr_holidays.hr_leave_allocation.number_of_days` (Leave Balance)
- `hr_holidays.hr_leave_type.name` (Leave Type: VL, SL)

**Policy Note**: Verify company policy on Sick Leave convertibility. Some companies only convert Vacation Leave.

#### 3. Pro-Rated 13th Month Pay

**Formula**:
```
Pro-Rated 13th Month = (Total Basic Salary Earned in Calendar Year) / 12
```

**Example**:
```
Hire Date: January 1, 2025
Separation Date: November 15, 2025
Months Worked: 10.5 months

Total Basic Salary Earned (Jan-Nov 15):
  Jan-Oct: ₱30,000 × 10 = ₱300,000
  Nov (pro-rated): ₱20,454.55
  Total: ₱320,454.55

Pro-Rated 13th Month = ₱320,454.55 / 12 = ₱26,704.55
```

**Legal Reference**: Presidential Decree No. 851 (13th Month Pay Law)

**Odoo Field Reference**: `hr.payslip.line` with `code='GROSS'` (Total Basic Salary)

#### 4. Approved Reimbursements

**Included Items**:
- Approved expense claims not yet paid
- Outstanding allowances (transportation, mobile, meal)
- Work-from-home stipends
- Client-billed expenses pending reimbursement

**Example**:
```
Approved Expense Claims: ₱5,000
Outstanding Mobile Allowance (Nov 1-15): ₱500
Total Reimbursements: ₱5,500
```

**Odoo Field Reference**:
- `hr.expense.sheet.state='approve'` and `payment_mode='own_account'`
- `hr.expense.total_amount` (Approved Amount)

**Validation**: Finance must verify all expense claims are approved before final pay calculation.

#### 5. Other Benefits Due

**Included Items**:
- Performance bonuses declared but unpaid
- Referral bonuses
- Project completion incentives
- Loyalty awards

**Example**:
```
Performance Bonus (Q3 2025): ₱10,000
Project Completion Incentive: ₱5,000
Total Other Benefits: ₱15,000
```

**Odoo Field Reference**: Custom payslip inputs or `hr.payslip.input`

### Deductions (Debit from Employee)

#### 1. Outstanding Cash Advances

**Included Items**:
- Unapproved cash advance requests
- Approved cash advances with incomplete liquidation
- Salary loans with outstanding balance

**Example**:
```
Cash Advance #1234 (Unliquidated): ₱10,000
Salary Loan (Remaining Balance): ₱5,000
Total Outstanding Advances: ₱15,000
```

**Odoo Field Reference**:
- `hr.expense.sheet.state='post'` and `liquidation_status!='completed'`
- `hr.loan.balance` (Salary Loan Balance)

**Validation**: Finance must verify all cash advances and loans before final pay calculation.

#### 2. Unreturned Asset Value

**Included Items**:
- Company laptop/desktop not returned
- Mobile phone not returned
- Office keys, ID, access cards not surrendered
- Uniforms, tools, equipment not returned

**Example**:
```
Laptop (MacBook Pro 2021): ₱80,000 (if not returned)
Mobile Phone (iPhone 13): ₱50,000 (if not returned)
Total Unreturned Asset Value: ₱130,000
```

**Odoo Field Reference**:
- `asset.asset.employee_id` (Assets assigned to employee)
- `asset.asset.value` (Current book value)

**Clearance Dependency**: IT clearance must confirm all assets returned before final pay release.

#### 3. Tax Adjustments (BIR)

**Formula**:
```
Annualized Taxable Income = Total Taxable Income (Jan-Nov) + Final Pay Taxable Portion

Tax Due = BIR Tax Table (Annualized Taxable Income)
Tax Already Withheld = Sum of Monthly Withholding Tax (Jan-Nov)
Tax Adjustment = Tax Due - Tax Already Withheld
```

**Example**:
```
Total Taxable Income (Jan-Nov): ₱350,000
Final Pay Taxable Portion: ₱50,000 (pro-rated salary + leave conversion)
Annualized Taxable Income: ₱400,000

BIR Tax Due (per Tax Table): ₱50,000
Tax Already Withheld: ₱45,000
Tax Adjustment: ₱50,000 - ₱45,000 = ₱5,000 (to be withheld)
```

**Legal Reference**: BIR Revenue Regulations No. 11-2018 (TRAIN Law)

**Odoo Field Reference**: `hr.payslip.line` with `code='WTAX'` (Withholding Tax)

#### 4. Government Contributions (SSS, PhilHealth, Pag-IBIG)

**Pro-Rated Contributions**:
```
SSS Contribution = Monthly SSS × (Days Worked / 22)
PhilHealth Contribution = Monthly PhilHealth × (Days Worked / 22)
Pag-IBIG Contribution = Monthly Pag-IBIG × (Days Worked / 22)

Total Government Contributions = SSS + PhilHealth + Pag-IBIG
```

**Example**:
```
Monthly SSS (Employee Share): ₱1,125
Monthly PhilHealth (Employee Share): ₱500
Monthly Pag-IBIG (Employee Share): ₱200

Days Worked in Final Month: 15 days
Pro-Rated SSS: ₱1,125 × (15 / 22) = ₱767.05
Pro-Rated PhilHealth: ₱500 × (15 / 22) = ₱340.91
Pro-Rated Pag-IBIG: ₱200 × (15 / 22) = ₱136.36

Total Government Contributions: ₱1,244.32
```

**Legal Reference**:
- SSS Law (RA 11199)
- Universal Health Care Act (RA 11223)
- Pag-IBIG Law (RA 9679)

**Odoo Field Reference**: `hr.payslip.line` with codes `SSS`, `PHIC`, `HDMF`

## Final Pay Calculation Summary

**Formula**:
```
FINAL PAY =
  (Pro-Rated Salary + Leave Conversion + 13th Month + Reimbursements + Other Benefits)
  -
  (Outstanding Advances + Unreturned Assets + Tax Adjustment + Government Contributions)
```

**Example (Full Calculation)**:
```
ADDITIONS:
  Pro-Rated Salary: ₱20,454.55
  Leave Conversion: ₱20,454.60
  13th Month Pay: ₱26,704.55
  Reimbursements: ₱5,500.00
  Other Benefits: ₱15,000.00
  SUBTOTAL: ₱88,113.70

DEDUCTIONS:
  Outstanding Advances: ₱15,000.00
  Unreturned Assets: ₱0.00 (all returned)
  Tax Adjustment: ₱5,000.00
  Government Contributions: ₱1,244.32
  SUBTOTAL: ₱21,244.32

FINAL PAY: ₱88,113.70 - ₱21,244.32 = ₱66,869.38
```

## Approval Workflow

1. **Preparation**: Finance Shared Services calculates final pay using Odoo payroll module
2. **Review**: Finance Supervisor reviews calculation for accuracy
3. **Approval**: Finance Director approves final pay
4. **Escalation**: If final pay >₱100,000, COO/MD approval required
5. **Payment**: Finance executes payment via bank transfer or check

## Quality Gates

Before final pay release, verify:
- ✅ All clearances completed (HR, Finance, IT, Admin)
- ✅ Leave balance verified by HR Ops
- ✅ Outstanding advances verified by Finance
- ✅ Tax computation reviewed by Finance
- ✅ Government contributions verified
- ✅ Finance Director approval obtained

## Common Errors and Fixes

| Error | Symptom | Fix |
|-------|---------|-----|
| **Incorrect Daily Rate** | Leave conversion wrong | Verify `Monthly Basic / 22`, not `/30` |
| **Missing 13th Month** | Final pay too low | Include pro-rated 13th month in calculation |
| **Wrong Tax Adjustment** | Tax over/under withheld | Use annualized income, not monthly |
| **Double-Counted Advances** | Final pay negative | Verify advances are not already deducted in payslip |
| **Unreturned Assets Not Deducted** | IT clearance shows missing laptop | Manually add asset value to deductions |

## Odoo Configuration

**Required Payslip Lines**:
```xml
<record id="hr_payslip_line_final_pay_prorated" model="hr.salary.rule">
    <field name="code">PRORATED</field>
    <field name="name">Pro-Rated Basic Salary</field>
    <field name="category_id" ref="hr_payroll.ALW"/>
    <field name="sequence">10</field>
    <field name="appears_on_payslip">True</field>
    <field name="python_compute">result = contract.wage / 22 * worked_days.WORK100.number_of_days</field>
</record>

<record id="hr_payslip_line_final_pay_leave" model="hr.salary.rule">
    <field name="code">LEAVECNV</field>
    <field name="name">Leave Credit Conversion</field>
    <field name="category_id" ref="hr_payroll.ALW"/>
    <field name="sequence">20</field>
    <field name="appears_on_payslip">True</field>
    <field name="python_compute">
        # Calculate leave conversion (VL + SL)
        daily_rate = contract.wage / 22
        vl_balance = employee.remaining_leaves  # Vacation Leave balance
        sl_balance = employee.sick_leaves  # Sick Leave balance (if convertible)
        result = (vl_balance + sl_balance) * daily_rate
    </field>
</record>

<record id="hr_payslip_line_final_pay_13th" model="hr.salary.rule">
    <field name="code">13THPRO</field>
    <field name="name">Pro-Rated 13th Month Pay</field>
    <field name="category_id" ref="hr_payroll.ALW"/>
    <field name="sequence">30</field>
    <field name="appears_on_payslip">True</field>
    <field name="python_compute">
        # Calculate pro-rated 13th month
        # Sum all basic salary from Jan to separation date / 12
        result = payslip.get_ytd_basic_salary() / 12
    </field>
</record>
```

## Verification Queries

**Check Pending Expenses**:
```sql
SELECT
    e.name AS expense_name,
    e.total_amount,
    e.state,
    e.employee_id
FROM hr_expense e
JOIN hr_expense_sheet s ON e.sheet_id = s.id
WHERE e.employee_id = <employee_id>
    AND s.state = 'approve'
    AND e.payment_mode = 'own_account'
    AND s.liquidation_status != 'completed';
```

**Check Outstanding Advances**:
```sql
SELECT
    sheet.name AS advance_name,
    sheet.total_amount,
    sheet.state,
    sheet.liquidation_status
FROM hr_expense_sheet sheet
WHERE sheet.employee_id = <employee_id>
    AND sheet.is_advance = TRUE
    AND (sheet.state = 'post' AND sheet.liquidation_status != 'completed');
```

**Check Leave Balances**:
```sql
SELECT
    lt.name AS leave_type,
    SUM(al.number_of_days) AS balance
FROM hr_leave_allocation al
JOIN hr_leave_type lt ON al.holiday_status_id = lt.id
WHERE al.employee_id = <employee_id>
    AND al.state = 'validate'
    AND lt.name IN ('Vacation Leave', 'Sick Leave')
GROUP BY lt.name;
```

## Next Steps

1. Configure Odoo payroll rules for final pay calculation
2. Test calculation with sample separation scenarios
3. Review tax adjustment logic with Finance Director
4. Validate leave conversion formula with HR Ops
5. Set up approval workflow in Odoo `hr.payslip` with Finance Director as approver

---

**Author**: Jake Tolentino
**Last Updated**: 2025-12-29
**Version**: 1.0
**Applies To**: Odoo CE 18.0 + OCA Modules (Single Agency, Philippine Operations)
