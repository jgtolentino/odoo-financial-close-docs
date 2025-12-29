# Clearance Workflow

## Purpose

This document defines the multi-department clearance process for separating employees, ensuring all company assets are returned, outstanding obligations are settled, and system access is revoked before final pay release.

## Clearance Trigger

**Event**: Employee resignation accepted or termination confirmed

**Action**: HR creates offboarding ticket with parallel clearance tasks for HR, Finance, IT, and Admin departments

**SLA**: Clearance must be completed within **5 business days** of Last Working Day (LWD)

## Clearance Departments

### HR Clearance

**Responsible**: HR Operations

**Checklist Items**:
- [ ] Exit interview conducted and documented
- [ ] Employee resignation letter on file
- [ ] Notice period compliance verified (30 days for rank-and-file, 60 days for managerial)
- [ ] Leave balance verified and documented
- [ ] Employment contract reviewed for post-employment obligations
- [ ] Final performance review completed (if applicable)
- [ ] Training records updated
- [ ] Employee handbook returned (if physical copy issued)

**Odoo Field Reference**:
- `hr.employee.last_working_date` (Last Working Day)
- `hr_holidays.hr_leave_allocation.number_of_days` (Leave Balance)
- `hr.employee.notice_period` (Notice Period in Days)

**Completion Criteria**: HR Supervisor signature on clearance form

### Finance Clearance

**Responsible**: Finance Shared Services

**Checklist Items**:
- [ ] All cash advances fully liquidated
- [ ] No outstanding salary loans
- [ ] No pending reimbursement claims (or documented for final pay inclusion)
- [ ] Company credit card returned and cancelled
- [ ] Petty cash accountability cleared
- [ ] Final expense report submitted
- [ ] Tax clearance (BIR Form 2316) preparation confirmed

**Outstanding Liabilities Check**:
```sql
-- Query Outstanding Advances
SELECT
    sheet.name AS advance_name,
    sheet.total_amount,
    sheet.state,
    sheet.liquidation_status
FROM hr_expense_sheet sheet
WHERE sheet.employee_id = <employee_id>
    AND sheet.is_advance = TRUE
    AND (sheet.state = 'post' AND sheet.liquidation_status != 'completed');

-- Query Pending Salary Loans
SELECT
    loan.name AS loan_name,
    loan.balance AS outstanding_balance,
    loan.state
FROM hr_loan loan
WHERE loan.employee_id = <employee_id>
    AND loan.state = 'approve'
    AND loan.balance > 0;
```

**Odoo Field Reference**:
- `hr.expense.sheet.is_advance` (Cash Advance Flag)
- `hr.expense.sheet.liquidation_status` (Liquidation Status)
- `hr.loan.balance` (Salary Loan Balance)

**Completion Criteria**: Finance Supervisor signature confirming zero outstanding liabilities or documented deductions for final pay

### IT Clearance

**Responsible**: IT Administrator

**Checklist Items**:
- [ ] Company laptop/desktop returned
- [ ] Mobile phone returned
- [ ] Odoo user account deactivated
- [ ] Email account deactivated (or converted to alias)
- [ ] VPN access revoked
- [ ] Cloud storage access revoked (Google Drive, Dropbox)
- [ ] Slack/Mattermost account deactivated
- [ ] All company files backed up and transferred
- [ ] Personal files removed from company devices
- [ ] Software licenses released
- [ ] Remote access credentials revoked

**Asset Return Verification**:
```sql
-- Query Assigned Assets
SELECT
    a.name AS asset_name,
    a.value AS book_value,
    a.state,
    a.employee_id
FROM asset_asset a
WHERE a.employee_id = <employee_id>
    AND a.state != 'sold';  -- Not yet returned/sold
```

**Odoo Field Reference**:
- `asset.asset.employee_id` (Assets Assigned to Employee)
- `asset.asset.value` (Current Book Value)
- `res.users.active` (Odoo User Account Status)

**System Access Revocation**:
```python
# Odoo XML-RPC: Deactivate User Account
import xmlrpc.client

url = 'https://odoo.insightpulseai.net'
db = 'production'
username = 'admin'
password = 'admin_password'

common = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/common')
uid = common.authenticate(db, username, password, {})

models = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/object')

# Deactivate user
employee_id = 123  # Replace with actual employee ID
user_id = models.execute_kw(db, uid, password,
    'res.users', 'search',
    [[['employee_ids', '=', employee_id]]])

if user_id:
    models.execute_kw(db, uid, password,
        'res.users', 'write',
        [user_id, {'active': False}])
```

**Completion Criteria**: IT Administrator signature confirming all assets returned and system access revoked

**Unreturned Asset Handling**: If employee fails to return assets, IT Administrator documents asset value for deduction from final pay

### Admin Clearance

**Responsible**: Admin Manager

**Checklist Items**:
- [ ] Company ID returned
- [ ] Office keys returned
- [ ] Access cards returned (building, parking)
- [ ] Uniforms returned (if applicable)
- [ ] Office supplies returned (staplers, hole punchers, etc.)
- [ ] Locker emptied and keys returned
- [ ] Parking sticker removed from vehicle
- [ ] Office desk and drawers cleared
- [ ] Personal belongings removed from office

**Physical Asset Inventory**:
```
Employee: <Name>
Last Working Day: <Date>

ITEMS TO RETURN:
☐ Company ID (#________)
☐ Office Keys (Set #________)
☐ Building Access Card (#________)
☐ Parking Access Card (#________)
☐ Uniform (Qty: ____)
☐ Locker Key (#________)
☐ Other: ___________________

CONDITION NOTES:
_______________________________
_______________________________

Admin Manager Signature: _______________  Date: ___________
```

**Odoo Field Reference**: Custom `hr.clearance.checklist` model (if implemented)

**Completion Criteria**: Admin Manager signature confirming all physical assets returned

## Clearance Workflow Automation

### Odoo Project Tasks Configuration

**Clearance Project Template**:
```xml
<record id="project_clearance_template" model="project.project">
    <field name="name">TEMPLATE – Employee Clearance</field>
    <field name="description">Clearance workflow for separating employees</field>
    <field name="use_tasks">True</field>
</record>

<!-- HR Clearance Task -->
<record id="task_clearance_hr" model="project.task">
    <field name="name">HR Clearance</field>
    <field name="project_id" ref="project_clearance_template"/>
    <field name="user_id" ref="hr.group_hr_manager"/>  <!-- Assigned to HR Manager -->
    <field name="description">Complete HR clearance checklist</field>
    <field name="date_deadline" eval="(datetime.now() + timedelta(days=5)).strftime('%Y-%m-%d')"/>
</record>

<!-- Finance Clearance Task -->
<record id="task_clearance_finance" model="project.task">
    <field name="name">Finance Clearance</field>
    <field name="project_id" ref="project_clearance_template"/>
    <field name="user_id" ref="account.group_account_manager"/>  <!-- Assigned to Finance Supervisor -->
    <field name="description">Verify zero outstanding liabilities</field>
    <field name="date_deadline" eval="(datetime.now() + timedelta(days=5)).strftime('%Y-%m-%d')"/>
</record>

<!-- IT Clearance Task -->
<record id="task_clearance_it" model="project.task">
    <field name="name">IT Clearance</field>
    <field name="project_id" ref="project_clearance_template"/>
    <field name="user_id" ref="base.group_system"/>  <!-- Assigned to IT Admin -->
    <field name="description">Revoke system access and collect assets</field>
    <field name="date_deadline" eval="(datetime.now() + timedelta(days=5)).strftime('%Y-%m-%d')"/>
</record>

<!-- Admin Clearance Task -->
<record id="task_clearance_admin" model="project.task">
    <field name="name">Admin Clearance</field>
    <field name="project_id" ref="project_clearance_template"/>
    <field name="user_id" ref="base.group_user"/>  <!-- Assigned to Admin Manager -->
    <field name="description">Collect physical assets (ID, keys, cards)</field>
    <field name="date_deadline" eval="(datetime.now() + timedelta(days=5)).strftime('%Y-%m-%d')"/>
</record>
```

### Clearance Completion Trigger

**Python Code (Odoo)**:
```python
def check_clearance_completion(self):
    """
    Trigger final pay calculation when all clearances completed
    """
    clearance_tasks = self.env['project.task'].search([
        ('project_id.name', 'ilike', 'Clearance'),
        ('name', 'in', ['HR Clearance', 'Finance Clearance', 'IT Clearance', 'Admin Clearance']),
        ('stage_id.is_closed', '=', True)
    ])

    if len(clearance_tasks) == 4:
        # All clearances completed
        self.state = 'clearance_completed'
        self.clearance_completion_date = fields.Date.today()

        # Trigger final pay calculation
        self.create_final_pay_wizard()
```

## SLA Monitoring

**Clearance SLA**: 5 business days from Last Working Day

**SLA Breach Alerts**:
- **Day 3**: Reminder sent to department heads with pending clearances
- **Day 4**: Escalation to HR Director
- **Day 5**: Critical alert to COO/MD

**n8n Workflow (SLA Alert)**:
```javascript
// n8n HTTP Request Node: Query Overdue Clearances
const response = await $http.request({
    method: 'POST',
    url: 'https://odoo.insightpulseai.net/xmlrpc/2/object',
    body: `<?xml version="1.0"?>
    <methodCall>
        <methodName>execute_kw</methodName>
        <params>
            <param><string>production</string></param>
            <param><int>${uid}</int></param>
            <param><string>${password}</string></param>
            <param><string>project.task</string></param>
            <param><string>search_read</string></param>
            <param>
                <array>
                    <data>
                        <value>
                            <array>
                                <data>
                                    <value><string>project_id.name</string></value>
                                    <value><string>ilike</string></value>
                                    <value><string>Clearance</string></value>
                                </data>
                            </array>
                        </value>
                        <value>
                            <array>
                                <data>
                                    <value><string>date_deadline</string></value>
                                    <value><string>&lt;</string></value>
                                    <value><string>${new Date().toISOString().split('T')[0]}</string></value>
                                </data>
                            </array>
                        </value>
                        <value>
                            <array>
                                <data>
                                    <value><string>stage_id.is_closed</string></value>
                                    <value><string>=</string></value>
                                    <value><boolean>0</boolean></value>
                                </data>
                            </array>
                        </value>
                    </data>
                </array>
            </param>
        </params>
    </methodCall>`
});

// n8n Mattermost Node: Send Alert
if (response.result && response.result.length > 0) {
    await $http.request({
        method: 'POST',
        url: 'https://mattermost.insightpulseai.net/hooks/xxxxxxxxx',
        body: {
            text: `⚠️ **Clearance SLA Breach**\n\nOverdue clearance tasks: ${response.result.length}\n\nDetails:\n${response.result.map(t => `- ${t.name} (Employee: ${t.employee_id[1]}, Due: ${t.date_deadline})`).join('\n')}`
        }
    });
}
```

## Common Issues and Solutions

| Issue | Root Cause | Solution |
|-------|-----------|----------|
| **Clearance delayed beyond 5 days** | Department not aware of deadline | Implement n8n SLA alerts at Day 3 |
| **IT assets not returned** | Employee refuses to return | Document unreturned assets for final pay deduction |
| **Outstanding advances not cleared** | Employee did not submit liquidation | Deduct from final pay after Finance clearance |
| **HR clearance pending exit interview** | Employee unavailable | Conduct exit interview via Zoom/email |
| **Admin clearance pending locker items** | Employee forgot locker contents | Schedule special access with Admin Manager |

## Integration with Final Pay

**Clearance Completion → Final Pay Trigger**:
```
All Clearances Completed
        ↓
Clearance Completion Date Recorded
        ↓
Finance Shared Services Notified (Mattermost)
        ↓
Final Pay Calculation Initiated
        ↓
Final Pay Wizard Opens (pre-filled with clearance data)
```

**Final Pay Wizard Pre-Fill**:
- Outstanding advances from Finance clearance
- Unreturned asset values from IT clearance
- Leave balance from HR clearance

## Quality Gates

Before marking clearance as completed:
- ✅ All 4 department clearances signed off
- ✅ Outstanding liabilities documented (if any)
- ✅ Unreturned assets documented (if any)
- ✅ Leave balance verified by HR Ops
- ✅ System access revocation confirmed by IT
- ✅ Physical assets return confirmed by Admin

## Next Steps

1. Configure Odoo project template for clearance workflow
2. Create custom `hr.clearance.checklist` model for checklist items
3. Set up n8n workflow for SLA breach alerts
4. Test clearance completion trigger with sample separation
5. Train department heads on clearance process and SLA

---

**Author**: Jake Tolentino
**Last Updated**: 2025-12-29
**Version**: 1.0
**Applies To**: Odoo CE 18.0 + OCA Modules (Single Agency, Philippine Operations)
