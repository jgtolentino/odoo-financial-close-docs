# Certificate of Employment (COE) Generation

## Purpose

This document defines the process for generating Certificates of Employment (COE) for current and former employees, ensuring compliance with Philippine Labor Code requirements and TBWA\SMP Champion quality standards.

## Statutory Requirement

**Legal Basis**: Article 285, Labor Code of the Philippines

**Deadline**: ≤3 calendar days from employee request

**Penalty for Non-Compliance**: DOLE violation, potential labor case filing

## COE Request Workflow

### Trigger Events

1. **Employee Request**: Current or former employee requests COE via HR
2. **External Request**: Bank, embassy, or government agency requests employment verification
3. **Final Pay Process**: COE automatically generated upon separation

### Request Channels

- **Email**: hr@company.com with subject "COE Request - [Employee Name]"
- **Odoo Portal**: Employee self-service portal (if implemented)
- **Walk-in**: Physical request at HR Operations desk
- **Mattermost**: Direct message to HR Ops

## COE Types

### Type 1: Basic COE (Employment Verification)

**Purpose**: Verify employment status only

**Contents**:
- Employee name
- Position/job title
- Employment period (hire date to current/separation date)
- Employment status (active, resigned, terminated)

**Template**:
```
CERTIFICATE OF EMPLOYMENT

TO WHOM IT MAY CONCERN:

This is to certify that [EMPLOYEE NAME] is/was employed with [COMPANY NAME] as [JOB TITLE] from [START DATE] to [END DATE/present].

This certification is issued upon the request of the employee for whatever legal purpose it may serve.

Issued this [DAY] day of [MONTH], [YEAR] at [CITY], Philippines.


_______________________________
[HR DIRECTOR NAME]
HR Director
[COMPANY NAME]
```

### Type 2: COE with Compensation

**Purpose**: Bank loans, visa applications, credit applications

**Contents**:
- Employee name
- Position/job title
- Employment period
- Monthly basic salary
- Employment status

**Template**:
```
CERTIFICATE OF EMPLOYMENT

TO WHOM IT MAY CONCERN:

This is to certify that [EMPLOYEE NAME] is/was employed with [COMPANY NAME] as [JOB TITLE] from [START DATE] to [END DATE/present], with a monthly basic salary of [CURRENCY] [AMOUNT].

This certification is issued upon the request of the employee for whatever legal purpose it may serve.

Issued this [DAY] day of [MONTH], [YEAR] at [CITY], Philippines.


_______________________________
[HR DIRECTOR NAME]
HR Director
[COMPANY NAME]
```

### Type 3: COE with Detailed Compensation (Separation Only)

**Purpose**: DOLE compliance, final pay documentation

**Contents**:
- Employee name
- Position/job title
- Employment period
- Monthly basic salary
- Final pay components (pro-rated salary, leave conversion, 13th month)
- Total final pay amount
- Final pay release date

**Template**:
```
CERTIFICATE OF EMPLOYMENT

TO WHOM IT MAY CONCERN:

This is to certify that [EMPLOYEE NAME] was employed with [COMPANY NAME] as [JOB TITLE] from [START DATE] to [END DATE].

During employment, [EMPLOYEE NAME] received a monthly basic salary of [CURRENCY] [AMOUNT].

Upon separation, [EMPLOYEE NAME] received final pay totaling [CURRENCY] [FINAL PAY AMOUNT] on [PAYMENT DATE], comprising:
- Pro-rated basic salary: [AMOUNT]
- Leave credit conversion: [AMOUNT]
- Pro-rated 13th month pay: [AMOUNT]
- Other benefits: [AMOUNT]

This certification is issued upon the request of the employee for whatever legal purpose it may serve.

Issued this [DAY] day of [MONTH], [YEAR] at [CITY], Philippines.


_______________________________
[HR DIRECTOR NAME]
HR Director
[COMPANY NAME]
```

## COE Generation Process

### Step 1: Request Receipt

**Action**: HR Ops receives COE request

**Validation**:
- Verify employee identity (ID, email, employee number)
- Confirm employment status (active or separated)
- Determine COE type required

**Odoo Field Reference**:
- `hr.employee.name` (Employee Name)
- `hr.employee.job_id.name` (Job Title)
- `hr.employee.contract_id.date_start` (Employment Start Date)
- `hr.employee.contract_id.date_end` (Employment End Date, if separated)

### Step 2: Data Verification

**Action**: HR Ops verifies employee data accuracy

**Verification Queries**:
```sql
-- Verify Employment Period
SELECT
    e.name AS employee_name,
    j.name AS job_title,
    c.date_start AS hire_date,
    c.date_end AS separation_date,
    c.wage AS monthly_basic_salary,
    e.active AS employment_status
FROM hr_employee e
JOIN hr_contract c ON e.contract_id = c.id
JOIN hr_job j ON e.job_id = j.id
WHERE e.id = <employee_id>;

-- Verify Final Pay (for separated employees)
SELECT
    p.name AS payslip_name,
    p.date_from,
    p.date_to,
    p.net_wage AS final_pay_amount,
    p.date AS payment_date
FROM hr_payslip p
WHERE p.employee_id = <employee_id>
    AND p.struct_id.code = 'FINAL_PAY'  -- Final pay structure
    AND p.state = 'done';
```

### Step 3: COE Generation

**Automated Generation (Odoo)**:
```python
def generate_coe(self, employee_id, coe_type='basic'):
    """
    Generate Certificate of Employment
    """
    employee = self.env['hr.employee'].browse(employee_id)
    contract = employee.contract_id

    # Prepare data
    data = {
        'employee_name': employee.name,
        'job_title': employee.job_id.name,
        'hire_date': contract.date_start.strftime('%B %d, %Y'),
        'separation_date': contract.date_end.strftime('%B %d, %Y') if contract.date_end else 'present',
        'monthly_basic_salary': f"₱{contract.wage:,.2f}",
        'company_name': self.env.company.name,
        'hr_director_name': self.env['res.users'].search([('groups_id', 'in', self.env.ref('hr.group_hr_manager').id)], limit=1).name,
        'issue_date': fields.Date.today().strftime('%B %d, %Y'),
        'issue_city': 'Makati',  # Adjust as needed
    }

    # Add final pay data if separated employee
    if coe_type == 'detailed' and contract.date_end:
        final_payslip = self.env['hr.payslip'].search([
            ('employee_id', '=', employee_id),
            ('struct_id.code', '=', 'FINAL_PAY'),
            ('state', '=', 'done')
        ], limit=1)

        if final_payslip:
            data.update({
                'final_pay_amount': f"₱{final_payslip.net_wage:,.2f}",
                'payment_date': final_payslip.date.strftime('%B %d, %Y'),
                # Extract payslip line amounts
                'prorated_salary': self._get_payslip_line_amount(final_payslip, 'PRORATED'),
                'leave_conversion': self._get_payslip_line_amount(final_payslip, 'LEAVECNV'),
                'thirteenth_month': self._get_payslip_line_amount(final_payslip, '13THPRO'),
            })

    # Render COE template
    template = self.env['ir.qweb'].render('hr_coe.coe_template', data)

    # Generate PDF
    pdf = self.env['ir.actions.report']._render_qweb_pdf('hr_coe.coe_template', employee_id, data=data)

    # Attach to employee record
    attachment = self.env['ir.attachment'].create({
        'name': f'COE_{employee.name}_{fields.Date.today()}.pdf',
        'type': 'binary',
        'datas': pdf[0],
        'res_model': 'hr.employee',
        'res_id': employee_id,
        'mimetype': 'application/pdf'
    })

    return attachment
```

**QWeb Template (Odoo)**:
```xml
<template id="coe_template">
    <div class="page">
        <div class="text-center">
            <h3><strong>CERTIFICATE OF EMPLOYMENT</strong></h3>
        </div>
        <br/>
        <p><strong>TO WHOM IT MAY CONCERN:</strong></p>
        <br/>
        <p style="text-align: justify; text-indent: 50px;">
            This is to certify that <strong><span t-esc="employee_name"/></strong>
            <t t-if="separation_date != 'present'">was</t>
            <t t-else="">is</t>
            employed with <strong><span t-esc="company_name"/></strong>
            as <strong><span t-esc="job_title"/></strong>
            from <strong><span t-esc="hire_date"/></strong>
            to <strong><span t-esc="separation_date"/></strong>
            <t t-if="monthly_basic_salary">,
                with a monthly basic salary of <strong><span t-esc="monthly_basic_salary"/></strong>
            </t>.
        </p>

        <t t-if="final_pay_amount">
            <p style="text-align: justify; text-indent: 50px;">
                Upon separation, <strong><span t-esc="employee_name"/></strong>
                received final pay totaling <strong><span t-esc="final_pay_amount"/></strong>
                on <strong><span t-esc="payment_date"/></strong>, comprising:
            </p>
            <ul>
                <li>Pro-rated basic salary: <span t-esc="prorated_salary"/></li>
                <li>Leave credit conversion: <span t-esc="leave_conversion"/></li>
                <li>Pro-rated 13th month pay: <span t-esc="thirteenth_month"/></li>
            </ul>
        </t>

        <br/>
        <p style="text-align: justify; text-indent: 50px;">
            This certification is issued upon the request of the employee
            for whatever legal purpose it may serve.
        </p>
        <br/>
        <p>
            Issued this <strong><span t-esc="issue_date"/></strong>
            at <strong><span t-esc="issue_city"/></strong>, Philippines.
        </p>
        <br/><br/><br/>
        <div class="text-center">
            <p>_______________________________</p>
            <p><strong><span t-esc="hr_director_name"/></strong></p>
            <p>HR Director</p>
            <p><strong><span t-esc="company_name"/></strong></p>
        </div>
    </div>
</template>
```

### Step 4: HR Director Review and Signature

**Action**: HR Director reviews COE for accuracy

**Review Checklist**:
- ✅ Employee name correct
- ✅ Job title correct
- ✅ Employment dates accurate
- ✅ Compensation amount accurate (if included)
- ✅ Final pay details correct (if separated employee)
- ✅ Company letterhead and signature present

**Digital Signature (if implemented)**:
```python
def sign_coe_digitally(self, coe_attachment_id):
    """
    Apply digital signature to COE PDF
    """
    # Use DocuSign, Adobe Sign, or local PKI certificate
    # Implementation depends on company signing solution
    pass
```

### Step 5: COE Release

**Action**: HR Ops releases COE to employee

**Release Channels**:
- **Email**: PDF attachment to employee's personal email
- **Odoo Portal**: Download from employee self-service portal
- **Physical**: Printed copy with HR Director signature and company seal

**Email Template**:
```
Subject: Certificate of Employment - [Employee Name]

Dear [Employee Name],

Please find attached your Certificate of Employment as requested.

This COE was issued on [Issue Date] and contains:
- Employment period: [Start Date] to [End Date/present]
- Position: [Job Title]
- [Compensation details if applicable]

If you require any corrections or additional information, please contact HR Operations within 5 business days.

Best regards,
HR Operations
[Company Name]
```

## SLA Tracking

**3-Day SLA Monitoring**:
```sql
-- Query COE Requests Nearing SLA Breach
SELECT
    cr.id,
    cr.employee_id,
    e.name AS employee_name,
    cr.request_date,
    cr.issue_date,
    cr.state,
    CASE
        WHEN cr.issue_date IS NULL AND CURRENT_DATE - cr.request_date >= 2 THEN 'CRITICAL'
        WHEN cr.issue_date IS NULL AND CURRENT_DATE - cr.request_date = 1 THEN 'WARNING'
        ELSE 'OK'
    END AS sla_status
FROM hr_coe_request cr
JOIN hr_employee e ON cr.employee_id = e.id
WHERE cr.state != 'done'
    AND CURRENT_DATE - cr.request_date <= 3;
```

**n8n SLA Alert Workflow**:
```javascript
// Day 2: Send reminder to HR Ops
if (daysElapsed === 2) {
    await $http.post('https://mattermost.insightpulseai.net/hooks/xxxxxxxxx', {
        text: `⚠️ **COE SLA Alert**\n\nEmployee: ${employee_name}\nRequest Date: ${request_date}\nDue Date: ${due_date}\n\nAction Required: Issue COE by tomorrow to meet 3-day SLA.`
    });
}

// Day 3: Escalate to HR Director
if (daysElapsed === 3) {
    await $http.post('https://mattermost.insightpulseai.net/hooks/xxxxxxxxx', {
        text: `🚨 **COE SLA BREACH**\n\nEmployee: ${employee_name}\nRequest Date: ${request_date}\nDue Date: ${due_date} (TODAY)\n\n@hr_director Immediate action required.`
    });
}
```

## Quality Gates

Before COE release:
- ✅ Employee data verified against Odoo HR records
- ✅ Employment dates accurate (hire date, separation date if applicable)
- ✅ Job title correct
- ✅ Compensation amount accurate (if included)
- ✅ Final pay details verified (if separated employee)
- ✅ HR Director review and signature obtained
- ✅ PDF generated and attached to employee record
- ✅ SLA met (≤3 days from request)

## Common Issues and Solutions

| Issue | Root Cause | Solution |
|-------|-----------|----------|
| **COE issued beyond 3 days** | HR Ops overloaded | Implement automated COE generation |
| **Incorrect employment dates** | Manual data entry errors | Validate against Odoo `hr.contract` table |
| **Missing HR Director signature** | Manual signature workflow | Implement digital signature workflow |
| **Final pay details wrong** | Final payslip not finalized | Generate COE only after final pay release |
| **Employee cannot access COE** | Email not delivered | Provide alternative download via Odoo portal |

## Odoo Configuration

**Custom Model: `hr.coe.request`**:
```python
class HrCoeRequest(models.Model):
    _name = 'hr.coe.request'
    _description = 'Certificate of Employment Request'

    employee_id = fields.Many2one('hr.employee', string='Employee', required=True)
    request_date = fields.Date(string='Request Date', default=fields.Date.today, required=True)
    issue_date = fields.Date(string='Issue Date')
    coe_type = fields.Selection([
        ('basic', 'Basic COE'),
        ('with_compensation', 'COE with Compensation'),
        ('detailed', 'COE with Detailed Compensation (Separation Only)')
    ], string='COE Type', default='basic', required=True)
    state = fields.Selection([
        ('requested', 'Requested'),
        ('in_review', 'In Review'),
        ('done', 'Issued')
    ], string='Status', default='requested', required=True)
    coe_attachment_id = fields.Many2one('ir.attachment', string='COE PDF')
    sla_status = fields.Selection([
        ('ok', 'Within SLA'),
        ('warning', 'Day 2 Warning'),
        ('critical', 'Day 3 Critical'),
        ('breached', 'SLA Breached')
    ], string='SLA Status', compute='_compute_sla_status')

    @api.depends('request_date', 'issue_date')
    def _compute_sla_status(self):
        for rec in self:
            if rec.issue_date:
                rec.sla_status = 'ok'
            else:
                days_elapsed = (fields.Date.today() - rec.request_date).days
                if days_elapsed >= 3:
                    rec.sla_status = 'breached'
                elif days_elapsed == 2:
                    rec.sla_status = 'critical'
                elif days_elapsed == 1:
                    rec.sla_status = 'warning'
                else:
                    rec.sla_status = 'ok'
```

## Next Steps

1. Create custom `hr.coe.request` model in Odoo
2. Design QWeb COE template with company letterhead
3. Configure automated COE generation workflow
4. Set up n8n SLA alert workflow
5. Train HR Ops on COE request handling and SLA monitoring
6. Test COE generation with sample employee data

---

**Author**: Jake Tolentino
**Last Updated**: 2025-12-29
**Version**: 1.0
**Applies To**: Odoo CE 18.0 + OCA Modules (Single Agency, Philippine Operations)
