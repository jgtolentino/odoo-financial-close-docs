# HR-to-Finance Close Integration

## Purpose

This document maps the detailed linkages between HR lifecycle events (hire-to-retire) and financial close activities, ensuring proper accounting treatment, period-end accruals, and compliance with Philippine accounting standards.

## Integration Architecture

```
HR Event (Hiring/Separation/Leave/Payroll)
        ↓
Trigger Financial Close Task
        ↓
Month-End/Year-End Close Checklist
        ↓
Journal Entries & Reconciliation
        ↓
BIR Tax Compliance
```

## HR Event → Financial Close Task Mapping

### 1. New Employee Hiring → Month-End Close Tasks

#### HR Event: New Employee Hired

**Trigger**: Employee master data created in Odoo `hr.employee`

**Financial Close Impact**:

| Month-End Task | Detailed Activity | Accounting Entry | Responsible |
|----------------|-------------------|------------------|-------------|
| **Payroll Accrual** | Include new hire in payroll accrual calculation | DR: Salaries Expense (5101)<br>CR: Salaries Payable (2101) | Finance Supervisor |
| **Government Contributions** | Register employee with SSS, PhilHealth, Pag-IBIG | DR: Payroll Taxes Expense (5102)<br>CR: SSS Payable (2131)<br>CR: PhilHealth Payable (2132)<br>CR: Pag-IBIG Payable (2133) | Finance Supervisor |
| **Withholding Tax Setup** | Setup BIR withholding tax table for new employee | No JE (setup only) | Finance Supervisor |
| **First Pay Accrual** | Accrue pro-rated salary from hire date to month-end | DR: Salaries Expense (5101)<br>CR: Salaries Payable (2101) | Finance Supervisor |

**Example Scenario**:
```
New Hire: Jane Doe
Hire Date: November 15, 2025
Monthly Salary: ₱30,000
Days Worked in Nov: 15 days (Nov 15-30)

Pro-Rated Salary Accrual:
  Daily Rate: ₱30,000 / 22 = ₱1,363.64
  Accrued Salary: ₱1,363.64 × 15 = ₱20,454.60

Month-End Journal Entry (November 30, 2025):
  DR: Salaries Expense (5101)         ₱20,454.60
      CR: Salaries Payable (2101)                 ₱20,454.60
  Memo: Accrued salary for Jane Doe (Nov 15-30)
```

**Odoo Configuration**:
```python
# Auto-create month-end accrual task on new hire
def create_hire_accrual_task(self):
    """
    Create month-end accrual task when new employee hired
    """
    if self.contract_id.date_start:
        hire_month_end = self.contract_id.date_start + relativedelta(day=31)

        # Create accrual task in Month-End Close project
        self.env['project.task'].create({
            'name': f'Accrual: New Hire - {self.name}',
            'project_id': self.env.ref('project_month_end_close').id,
            'date_deadline': hire_month_end,
            'description': f"""
                New Hire: {self.name}
                Hire Date: {self.contract_id.date_start}
                Monthly Salary: ₱{self.contract_id.wage:,.2f}

                Action Required:
                1. Calculate pro-rated salary from hire date to month-end
                2. Accrue salaries payable
                3. Register with SSS/PhilHealth/Pag-IBIG
                4. Setup BIR withholding tax
            """,
            'user_id': self.env.ref('hr.group_hr_manager').id,
            'tag_ids': [(6, 0, [self.env.ref('tag_payroll_accrual').id])]
        })
```

---

### 2. Employee Separation → Final Pay Close Tasks

#### HR Event: Employee Resignation/Termination

**Trigger**: Employee `last_working_date` set in Odoo `hr.employee`

**Financial Close Impact**:

| Month-End Task | Detailed Activity | Accounting Entry | Responsible |
|----------------|-------------------|------------------|-------------|
| **Final Pay Accrual** | Accrue all final pay components (salary, leave, 13th month) | DR: Salaries Expense (5101)<br>DR: Leave Expense (5103)<br>DR: 13th Month Expense (5104)<br>CR: Final Pay Payable (2102) | Finance Supervisor |
| **Advances Recovery** | Reverse outstanding advances from final pay | DR: Final Pay Payable (2102)<br>CR: Advances Receivable - Employee (1201) | Finance Supervisor |
| **Asset Deduction** | Deduct unreturned asset value from final pay | DR: Final Pay Payable (2102)<br>CR: Asset Disposal Gain (4102) | Finance Supervisor |
| **Tax Adjustment** | Calculate and accrue final withholding tax adjustment | DR: Withholding Tax Expense (5105)<br>CR: Withholding Tax Payable (2134) | Finance Supervisor |
| **Government Contributions** | Accrue pro-rated SSS/PhilHealth/Pag-IBIG | DR: Payroll Taxes Expense (5102)<br>CR: SSS Payable (2131)<br>CR: PhilHealth Payable (2132)<br>CR: Pag-IBIG Payable (2133) | Finance Supervisor |

**Example Scenario**:
```
Separated Employee: John Smith
Last Working Day: November 15, 2025
Monthly Salary: ₱30,000
VL Balance: 10 days
SL Balance: 5 days (convertible)
Outstanding Advance: ₱10,000
Unreturned Asset: ₱0 (all returned)

Final Pay Calculation (November 30 Close):

ADDITIONS:
  Pro-Rated Salary (Nov 1-15): ₱30,000/22 × 15 = ₱20,454.55
  VL Conversion: 10 days × ₱1,363.64 = ₱13,636.40
  SL Conversion: 5 days × ₱1,363.64 = ₱6,818.20
  13th Month (Pro-Rated): ₱320,454.55 / 12 = ₱26,704.55
  SUBTOTAL: ₱67,613.70

DEDUCTIONS:
  Outstanding Advance: ₱10,000.00
  Tax Adjustment: ₱5,000.00
  SSS/PhilHealth/Pag-IBIG: ₱1,244.32
  SUBTOTAL: ₱16,244.32

NET FINAL PAY: ₱51,369.38

Month-End Journal Entries (November 30, 2025):

JE1 - Final Pay Accrual:
  DR: Salaries Expense (5101)         ₱20,454.55
  DR: Leave Expense (5103)            ₱20,454.60
  DR: 13th Month Expense (5104)       ₱26,704.55
      CR: Final Pay Payable (2102)                ₱67,613.70
  Memo: Final pay accrual for John Smith

JE2 - Advances Recovery:
  DR: Final Pay Payable (2102)        ₱10,000.00
      CR: Advances Receivable (1201)              ₱10,000.00
  Memo: Recovery of outstanding advance

JE3 - Tax Adjustment:
  DR: Withholding Tax Expense (5105)  ₱5,000.00
      CR: Withholding Tax Payable (2134)          ₱5,000.00
  Memo: Final tax adjustment for John Smith

JE4 - Government Contributions:
  DR: Payroll Taxes Expense (5102)    ₱1,244.32
      CR: SSS Payable (2131)                      ₱767.05
      CR: PhilHealth Payable (2132)               ₱340.91
      CR: Pag-IBIG Payable (2133)                 ₱136.36
  Memo: Pro-rated government contributions
```

**Odoo Configuration**:
```python
# Auto-create final pay tasks on employee separation
def create_separation_close_tasks(self):
    """
    Create month-end close tasks when employee separated
    """
    if self.last_working_date:
        separation_month_end = self.last_working_date + relativedelta(day=31)

        # Task 1: Final Pay Accrual
        self.env['project.task'].create({
            'name': f'Final Pay Accrual - {self.name}',
            'project_id': self.env.ref('project_month_end_close').id,
            'date_deadline': separation_month_end,
            'description': f"""
                Separated Employee: {self.name}
                Last Working Day: {self.last_working_date}

                Action Required:
                1. Calculate final pay (salary, leave, 13th month)
                2. Verify outstanding advances with Finance
                3. Verify unreturned assets with IT
                4. Calculate tax adjustment
                5. Accrue final pay payable
                6. Create journal entries (JE1-JE4)
            """,
            'user_id': self.env.ref('account.group_account_manager').id,
            'tag_ids': [(6, 0, [self.env.ref('tag_final_pay').id])]
        })

        # Task 2: Advances Recovery
        outstanding_advances = self.env['hr.expense.sheet'].search([
            ('employee_id', '=', self.id),
            ('is_advance', '=', True),
            ('liquidation_status', '!=', 'completed')
        ])

        if outstanding_advances:
            self.env['project.task'].create({
                'name': f'Advances Recovery - {self.name}',
                'project_id': self.env.ref('project_month_end_close').id,
                'date_deadline': separation_month_end,
                'description': f"""
                    Outstanding Advances: {len(outstanding_advances)}
                    Total Amount: ₱{sum(outstanding_advances.mapped('total_amount')):,.2f}

                    Action Required:
                    1. Verify advances with Finance Supervisor
                    2. Create recovery journal entry (JE2)
                    3. Update advances receivable balance
                """,
                'user_id': self.env.ref('account.group_account_manager').id,
                'tag_ids': [(6, 0, [self.env.ref('tag_advances_recovery').id])]
            })
```

---

### 3. Leave Accrual → Month-End Close Tasks

#### HR Event: Leave Accrual Period (Monthly)

**Trigger**: End of month

**Financial Close Impact**:

| Month-End Task | Detailed Activity | Accounting Entry | Responsible |
|----------------|-------------------|------------------|-------------|
| **Leave Accrual Calculation** | Calculate monthly leave accrual for all active employees | DR: Leave Expense (5103)<br>CR: Leave Liability (2103) | Finance Supervisor |
| **Leave Utilization** | Record leave taken during the month | DR: Leave Liability (2103)<br>CR: Salaries Payable (2101) | Finance Supervisor |
| **Leave Balance Reconciliation** | Reconcile leave balance: Opening + Accrual - Utilization = Closing | Reconciliation only (no JE) | Finance Supervisor |

**Example Scenario**:
```
Total Active Employees: 50
Monthly Leave Accrual per Employee: 1.25 days VL + 1.25 days SL = 2.5 days
Average Daily Rate: ₱1,500

Monthly Leave Accrual:
  Total Days Accrued: 50 employees × 2.5 days = 125 days
  Total Amount: 125 days × ₱1,500 = ₱187,500

Leave Taken in November:
  Total Days Taken: 30 days
  Total Amount: 30 days × ₱1,500 = ₱45,000

Month-End Journal Entries (November 30, 2025):

JE1 - Leave Accrual:
  DR: Leave Expense (5103)            ₱187,500.00
      CR: Leave Liability (2103)                   ₱187,500.00
  Memo: November leave accrual (50 employees × 2.5 days)

JE2 - Leave Utilization:
  DR: Leave Liability (2103)          ₱45,000.00
      CR: Salaries Payable (2101)                  ₱45,000.00
  Memo: Leave taken in November (30 days)

Leave Balance Reconciliation:
  Opening Balance (Oct 31): ₱500,000
  + Accrual (November): ₱187,500
  - Utilization (November): ₱45,000
  = Closing Balance (Nov 30): ₱642,500
```

**Odoo Configuration**:
```python
# Monthly leave accrual calculation
def calculate_monthly_leave_accrual(self):
    """
    Calculate leave accrual for all active employees
    """
    active_employees = self.env['hr.employee'].search([
        ('active', '=', True),
        ('contract_id.state', '=', 'open')
    ])

    total_accrual = 0
    for emp in active_employees:
        # Calculate leave accrual (1.25 VL + 1.25 SL = 2.5 days/month)
        daily_rate = emp.contract_id.wage / 22
        monthly_accrual = 2.5 * daily_rate
        total_accrual += monthly_accrual

    # Create journal entry
    move = self.env['account.move'].create({
        'journal_id': self.env.ref('account.general_journal').id,
        'date': fields.Date.today(),
        'ref': f'Leave Accrual - {fields.Date.today().strftime("%B %Y")}',
        'line_ids': [
            (0, 0, {
                'account_id': self.env.ref('account_leave_expense').id,  # 5103
                'name': 'Leave Accrual',
                'debit': total_accrual,
                'credit': 0,
            }),
            (0, 0, {
                'account_id': self.env.ref('account_leave_liability').id,  # 2103
                'name': 'Leave Accrual',
                'debit': 0,
                'credit': total_accrual,
            })
        ]
    })
    move.action_post()
```

---

### 4. Payroll Processing → Month-End Close Tasks

#### HR Event: Payroll Run (Bi-Monthly)

**Trigger**: Payroll cutoff (15th and 30th of month)

**Financial Close Impact**:

| Month-End Task | Detailed Activity | Accounting Entry | Responsible |
|----------------|-------------------|------------------|-------------|
| **Payroll Accrual** | Accrue payroll for cutoff 1 (1st-15th) and cutoff 2 (16th-30th) | DR: Salaries Expense (5101)<br>CR: Salaries Payable (2101) | Finance Supervisor |
| **Government Contributions Accrual** | Accrue SSS, PhilHealth, Pag-IBIG (employer + employee share) | DR: Payroll Taxes Expense (5102)<br>CR: SSS Payable (2131)<br>CR: PhilHealth Payable (2132)<br>CR: Pag-IBIG Payable (2133) | Finance Supervisor |
| **Withholding Tax Accrual** | Accrue monthly withholding tax | DR: Withholding Tax Expense (5105)<br>CR: Withholding Tax Payable (2134) | Finance Supervisor |
| **13th Month Accrual** | Accrue pro-rated 13th month pay (1/12 of monthly basic) | DR: 13th Month Expense (5104)<br>CR: 13th Month Payable (2104) | Finance Supervisor |

**Example Scenario**:
```
Payroll Period: November 1-30, 2025
Total Employees: 50
Total Gross Salary: ₱1,500,000
Total Withholding Tax: ₱150,000
Total SSS (Employee): ₱56,250
Total PhilHealth (Employee): ₱25,000
Total Pag-IBIG (Employee): ₱10,000
Total SSS (Employer): ₱84,375
Total PhilHealth (Employer): ₱25,000
Total Pag-IBIG (Employer): ₱10,000

Month-End Journal Entries (November 30, 2025):

JE1 - Payroll Accrual:
  DR: Salaries Expense (5101)         ₱1,500,000.00
      CR: Salaries Payable (2101)                   ₱1,500,000.00
  Memo: November payroll accrual

JE2 - Government Contributions (Employee Share):
  DR: Salaries Payable (2101)         ₱91,250.00
      CR: SSS Payable (2131)                        ₱56,250.00
      CR: PhilHealth Payable (2132)                 ₱25,000.00
      CR: Pag-IBIG Payable (2133)                   ₱10,000.00
  Memo: Employee share of government contributions

JE3 - Government Contributions (Employer Share):
  DR: Payroll Taxes Expense (5102)    ₱119,375.00
      CR: SSS Payable (2131)                        ₱84,375.00
      CR: PhilHealth Payable (2132)                 ₱25,000.00
      CR: Pag-IBIG Payable (2133)                   ₱10,000.00
  Memo: Employer share of government contributions

JE4 - Withholding Tax:
  DR: Salaries Payable (2101)         ₱150,000.00
      CR: Withholding Tax Payable (2134)            ₱150,000.00
  Memo: November withholding tax

JE5 - 13th Month Accrual:
  DR: 13th Month Expense (5104)       ₱125,000.00
      CR: 13th Month Payable (2104)                 ₱125,000.00
  Memo: November 13th month accrual (₱1,500,000 / 12)
```

---

### 5. Year-End 13th Month Pay → Year-End Close Tasks

#### HR Event: 13th Month Pay Release (December)

**Trigger**: December payroll run

**Financial Close Impact**:

| Year-End Task | Detailed Activity | Accounting Entry | Responsible |
|--------------|-------------------|------------------|-------------|
| **13th Month Reversal** | Reverse year-to-date 13th month accrual | DR: 13th Month Payable (2104)<br>CR: 13th Month Expense (5104) | Finance Supervisor |
| **13th Month Actual Payment** | Record actual 13th month payment | DR: 13th Month Expense (5104)<br>CR: Salaries Payable (2101) | Finance Supervisor |
| **13th Month Withholding Tax** | Accrue withholding tax on 13th month | DR: Withholding Tax Expense (5105)<br>CR: Withholding Tax Payable (2134) | Finance Supervisor |

**Example Scenario**:
```
Total Employees: 50
Total 13th Month Pay: ₱1,500,000
Year-to-Date Accrual (Jan-Nov): ₱1,375,000 (₱125,000 × 11 months)
December Adjustment: ₱125,000
Withholding Tax on 13th Month: ₱30,000

Year-End Journal Entries (December 31, 2025):

JE1 - Reverse Accrual:
  DR: 13th Month Payable (2104)       ₱1,375,000.00
      CR: 13th Month Expense (5104)                 ₱1,375,000.00
  Memo: Reversal of Jan-Nov accrual

JE2 - Actual 13th Month Payment:
  DR: 13th Month Expense (5104)       ₱1,500,000.00
      CR: Salaries Payable (2101)                   ₱1,500,000.00
  Memo: Actual 13th month payment

JE3 - Withholding Tax on 13th Month:
  DR: Withholding Tax Expense (5105)  ₱30,000.00
      CR: Withholding Tax Payable (2134)            ₱30,000.00
  Memo: Withholding tax on 13th month
```

---

## Month-End Close Checklist Integration

### Updated Month-End Close Task Template (44 Tasks)

**NEW HR-Specific Tasks Added**:

| Task # | Task Name | Trigger | Accounting Entry | Timeline |
|--------|-----------|---------|------------------|----------|
| 45 | **New Hire Accrual** | New employee hired | DR: Salaries Expense<br>CR: Salaries Payable | Day 1 |
| 46 | **Final Pay Accrual** | Employee separated | DR: Multiple<br>CR: Final Pay Payable | Day 2 |
| 47 | **Advances Recovery** | Employee separated with outstanding advances | DR: Final Pay Payable<br>CR: Advances Receivable | Day 2 |
| 48 | **Leave Accrual** | End of month | DR: Leave Expense<br>CR: Leave Liability | Day 3 |
| 49 | **Leave Utilization** | Leave taken during month | DR: Leave Liability<br>CR: Salaries Payable | Day 3 |
| 50 | **Payroll Accrual** | Bi-monthly payroll cutoff | DR: Salaries Expense<br>CR: Salaries Payable | Day 4 |
| 51 | **Government Contributions** | Payroll processing | DR: Payroll Taxes Expense<br>CR: SSS/PhilHealth/Pag-IBIG Payable | Day 4 |
| 52 | **Withholding Tax Accrual** | Payroll processing | DR: Withholding Tax Expense<br>CR: Withholding Tax Payable | Day 4 |
| 53 | **13th Month Accrual** | Monthly | DR: 13th Month Expense<br>CR: 13th Month Payable | Day 5 |

**Total Month-End Tasks**: 53 (44 original + 9 HR-specific)

---

## BIR Tax Filing Integration

### HR Events → BIR Forms Mapping

| HR Event | BIR Form | Filing Deadline | Data Source |
|----------|----------|-----------------|-------------|
| **Monthly Payroll** | 1601-C (Monthly Withholding Tax) | 10th of following month | `hr.payslip` withholding tax summary |
| **Quarterly Payroll** | 1601-EQ (Quarterly Withholding Tax) | 60 days after quarter | `hr.payslip` quarterly summary |
| **Annual Payroll** | 1604-CF (Annual Information Return) | January 31 of following year | `hr.payslip` annual summary |
| **Annual Payroll** | 2316 (Certificate of Compensation) | January 31 of following year | `hr.payslip` per employee |

**Example: 1601-C Integration**:
```python
def generate_bir_1601c(self, period_start, period_end):
    """
    Generate BIR 1601-C from payroll data
    """
    payslips = self.env['hr.payslip'].search([
        ('date_from', '>=', period_start),
        ('date_to', '<=', period_end),
        ('state', '=', 'done')
    ])

    total_compensation = sum(payslips.mapped('line_ids').filtered(
        lambda l: l.code == 'GROSS').mapped('total'))

    total_withholding = sum(payslips.mapped('line_ids').filtered(
        lambda l: l.code == 'WTAX').mapped('total'))

    # Generate BIR 1601-C PDF
    bir_form = self.env['bir.form.1601c'].create({
        'period_start': period_start,
        'period_end': period_end,
        'total_compensation': total_compensation,
        'total_withholding': total_withholding,
        'state': 'draft'
    })

    return bir_form
```

---

## Reconciliation Requirements

### HR-Specific Reconciliations

**Monthly Reconciliations**:
1. **Salaries Payable**: Payroll accrual vs. bank payments
2. **Leave Liability**: Leave accrual vs. leave taken
3. **Government Contributions Payable**: Accrual vs. remittances
4. **Withholding Tax Payable**: Accrual vs. BIR payments
5. **Advances Receivable**: Advances issued vs. liquidations

**Reconciliation Query (Salaries Payable)**:
```sql
-- Salaries Payable Reconciliation
SELECT
    'Opening Balance' AS description,
    COALESCE(SUM(debit - credit), 0) AS amount
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2101')
    AND date < '2025-11-01'

UNION ALL

SELECT
    'Payroll Accrual' AS description,
    COALESCE(SUM(credit - debit), 0) AS amount
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2101')
    AND date BETWEEN '2025-11-01' AND '2025-11-30'
    AND move_id IN (SELECT id FROM account_move WHERE ref ILIKE '%payroll%')

UNION ALL

SELECT
    'Bank Payments' AS description,
    COALESCE(SUM(debit - credit), 0) AS amount
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2101')
    AND date BETWEEN '2025-11-01' AND '2025-11-30'
    AND move_id IN (SELECT id FROM account_move WHERE journal_id IN (SELECT id FROM account_journal WHERE type = 'bank'))

UNION ALL

SELECT
    'Closing Balance' AS description,
    COALESCE(SUM(debit - credit), 0) AS amount
FROM account_move_line
WHERE account_id = (SELECT id FROM account_account WHERE code = '2101')
    AND date <= '2025-11-30';
```

---

## Quality Gates

### HR-Finance Integration Quality Checklist

Before closing the month, verify:

- ✅ All new hires have salary accrual entries
- ✅ All separated employees have final pay accrual entries
- ✅ All outstanding advances are recovered or accrued as receivable
- ✅ Leave accrual matches HR leave balance report
- ✅ Payroll accrual matches payroll register
- ✅ Government contributions match SSS/PhilHealth/Pag-IBIG reports
- ✅ Withholding tax matches BIR alphalist
- ✅ 13th month accrual is 1/12 of monthly gross salary
- ✅ All HR-triggered journal entries are posted
- ✅ Salaries payable reconciliation completed

---

## Next Steps

1. Configure Odoo to auto-create month-end tasks on HR events
2. Set up automated journal entry creation from payroll processing
3. Create reconciliation reports for HR-specific accounts
4. Test end-to-end integration with sample hire and separation scenarios
5. Train Finance team on HR-Finance integration workflows

---

**Author**: Jake Tolentino
**Last Updated**: 2025-12-29
**Version**: 1.0
**Applies To**: Odoo CE 18.0 + OCA Modules (Single Agency, Philippine Operations)
