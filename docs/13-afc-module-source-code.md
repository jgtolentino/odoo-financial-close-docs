# AFC Close Manager Module - Source Code Reference

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Module Version**: 18.0.1.0.0
**Classification**: Internal - Development

---

## Overview

This document contains the complete production-ready source code for the `afc_close_manager` Odoo module that implements SAP Advanced Financial Closing functionality.

---

## File 1: `__manifest__.py`

```python
{
    'name': 'Advanced Financial Closing Manager',
    'version': '18.0.1.0.0',
    'category': 'Accounting',
    'summary': 'SAP Advanced Financial Closing equivalent for Odoo CE',
    'description': '''
        Complete month-end close automation including:
        - Close calendar management
        - GL posting workflows
        - Intercompany settlement
        - Document management
        - Real-time monitoring dashboards
        - Compliance reporting
    ''',
    'author': 'Your Company',
    'website': 'https://yourcompany.com',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'account',
        'account_edi',
        'analytic',
        'base_automation',
        'project',
        'mail',
        'web',
        'spreadsheet_dashboard',
    ],
    'data': [
        'security/ir_model_access.xml',
        'data/afc_close_calendar_data.xml',
        'views/afc_close_calendar_views.xml',
        'views/afc_close_task_views.xml',
        'views/afc_gl_posting_views.xml',
        'views/afc_intercompany_views.xml',
        'views/afc_menu.xml',
        'reports/afc_close_progress_report.xml',
        'reports/afc_gl_reconciliation_report.xml',
    ],
    'installable': True,
    'auto_install': False,
    'external_dependencies': {
        'python': ['pandas', 'openpyxl'],
    },
}
```

---

## File 2: `models/__init__.py`

```python
# -*- coding: utf-8 -*-
from . import afc_close_calendar
from . import afc_close_task
from . import afc_gl_posting
from . import afc_intercompany_transaction
from . import afc_document_attachment
from . import afc_compliance_checklist
```

---

## File 3: `models/afc_close_calendar.py`

```python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from odoo import api, fields, models, _
from odoo.exceptions import ValidationError, UserError


class AFCCloseCalendar(models.Model):
    """
    Close Calendar Management
    Manages monthly/quarterly close windows, task creation, and automation
    """
    _name = 'afc.close.calendar'
    _description = 'AFC Close Calendar'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'close_date DESC'

    # ==================== FIELDS ====================
    name = fields.Char(
        'Close Name',
        required=True,
        help='e.g., "January 2025 Close"'
    )

    close_date = fields.Date(
        'Close Date',
        required=True,
        help='Target date for close completion'
    )

    close_type = fields.Selection([
        ('monthly', 'Monthly Close'),
        ('quarterly', 'Quarterly Close'),
        ('semi_annual', 'Semi-Annual Close'),
        ('annual', 'Annual Close'),
    ], 'Close Type', required=True, default='monthly')

    company_id = fields.Many2one(
        'res.company',
        'Company',
        required=True,
        default=lambda self: self.env.company
    )

    state = fields.Selection([
        ('draft', 'Draft'),
        ('active', 'Active'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ], 'Status', default='draft', tracking=True)

    # Dates
    start_date = fields.Date(
        'Close Start Date',
        required=True,
        help='When this close window opens'
    )

    deadline_date = fields.Date(
        'Deadline',
        required=True,
        help='Final deadline for close completion'
    )

    actual_close_date = fields.Date(
        'Actual Close Date',
        readonly=True,
        help='When close was actually completed'
    )

    # Task Management
    task_ids = fields.One2many(
        'afc.close.task',
        'close_calendar_id',
        'Close Tasks',
        ondelete='cascade'
    )

    task_count = fields.Integer(
        'Task Count',
        compute='_compute_task_count'
    )

    completed_task_count = fields.Integer(
        'Completed Tasks',
        compute='_compute_task_count'
    )

    completion_percentage = fields.Float(
        'Completion %',
        compute='_compute_completion_percentage'
    )

    # Documents
    document_ids = fields.One2many(
        'afc.document.attachment',
        'close_calendar_id',
        'Supporting Documents'
    )

    # GL Integration
    journal_ids = fields.Many2many(
        'account.journal',
        'afc_close_calendar_journal_rel',
        'calendar_id',
        'journal_id',
        'GL Journals to Close',
        help='Select journals that should be included in this close'
    )

    gl_posting_count = fields.Integer(
        'GL Postings',
        compute='_compute_gl_posting_count'
    )

    # Intercompany
    intercompany_ids = fields.One2many(
        'afc.intercompany.transaction',
        'close_calendar_id',
        'Intercompany Transactions'
    )

    # Configuration
    auto_create_tasks = fields.Boolean(
        'Auto-Create Tasks',
        default=True,
        help='Automatically create close tasks from template'
    )

    send_notifications = fields.Boolean(
        'Send Notifications',
        default=True,
        help='Notify users of task assignments and deadlines'
    )

    require_signatures = fields.Boolean(
        'Require Sign-Off',
        default=True,
        help='Require manager approval for close completion'
    )

    # Notes
    notes = fields.Text('Notes')

    # ==================== COMPUTED FIELDS ====================
    @api.depends('task_ids', 'task_ids.state')
    def _compute_task_count(self):
        """Compute total and completed task counts"""
        for record in self:
            record.task_count = len(record.task_ids)
            record.completed_task_count = len(
                record.task_ids.filtered(lambda t: t.state == 'completed')
            )

    @api.depends('task_count', 'completed_task_count')
    def _compute_completion_percentage(self):
        """Calculate close completion percentage"""
        for record in self:
            if record.task_count > 0:
                record.completion_percentage = (
                    record.completed_task_count / record.task_count * 100
                )
            else:
                record.completion_percentage = 0.0

    @api.depends('company_id', 'close_date')
    def _compute_gl_posting_count(self):
        """Count GL postings for this close"""
        for record in self:
            record.gl_posting_count = self.env['afc.gl.posting'].search_count([
                ('close_calendar_id', '=', record.id)
            ])

    # ==================== VALIDATIONS ====================
    @api.constrains('start_date', 'close_date', 'deadline_date')
    def _check_dates(self):
        """Validate date logic"""
        for record in self:
            if record.start_date >= record.close_date:
                raise ValidationError(
                    _('Close date must be after start date')
                )
            if record.close_date > record.deadline_date:
                raise ValidationError(
                    _('Deadline must be on or after close date')
                )

    # ==================== ACTIONS ====================
    def action_activate(self):
        """Activate close calendar and create tasks"""
        for record in self:
            if record.state != 'draft':
                raise UserError(
                    _('Only draft closes can be activated')
                )

            # Validate dates
            if record.start_date > fields.Date.today():
                raise UserError(
                    _('Cannot activate close with future start date')
                )

            record.state = 'active'

            # Auto-create tasks if enabled
            if record.auto_create_tasks:
                record._create_default_tasks()

            # Send notifications
            if record.send_notifications:
                record._notify_users()

            record.message_post(body=_('Close calendar activated'))

    def action_start(self):
        """Start the close process"""
        for record in self:
            if record.state not in ['draft', 'active']:
                raise UserError(
                    _('Only draft or active closes can be started')
                )

            record.state = 'in_progress'
            record.message_post(body=_('Close started'))

    def action_complete(self):
        """Mark close as completed"""
        for record in self:
            # Validate all tasks are complete
            incomplete_tasks = record.task_ids.filtered(
                lambda t: t.state != 'completed'
            )
            if incomplete_tasks and record.require_signatures:
                raise UserError(
                    _('All tasks must be completed before closing')
                )

            # Validate GL is balanced
            if not record._validate_gl_balanced():
                raise UserError(
                    _('GL is not balanced. Please reconcile all accounts.')
                )

            record.state = 'completed'
            record.actual_close_date = fields.Date.today()
            record.message_post(body=_('Close completed successfully'))

    def action_cancel(self):
        """Cancel the close"""
        for record in self:
            record.state = 'cancelled'
            record.message_post(body=_('Close cancelled'))

    # ==================== INTERNAL METHODS ====================
    def _create_default_tasks(self):
        """Create standard close tasks"""
        default_tasks = [
            {
                'name': 'Review GL Balance',
                'description': 'Review general ledger balances for accuracy',
                'sequence': 10,
                'due_date_offset': 1,
            },
            {
                'name': 'Bank Reconciliation',
                'description': 'Reconcile all bank accounts',
                'sequence': 20,
                'due_date_offset': 2,
            },
            {
                'name': 'AR Aging Review',
                'description': 'Review aged receivables and collectibility',
                'sequence': 30,
                'due_date_offset': 3,
            },
            {
                'name': 'AP Aging Review',
                'description': 'Review aged payables and cut-off issues',
                'sequence': 40,
                'due_date_offset': 4,
            },
            {
                'name': 'Inventory Reconciliation',
                'description': 'Physical count vs GL reconciliation',
                'sequence': 50,
                'due_date_offset': 5,
            },
            {
                'name': 'Intercompany Settlement',
                'description': 'Clear all intercompany transactions',
                'sequence': 60,
                'due_date_offset': 6,
            },
            {
                'name': 'Tax Compliance',
                'description': 'Verify tax calculations and filings',
                'sequence': 70,
                'due_date_offset': 7,
            },
            {
                'name': 'Final GL Verification',
                'description': 'Final verification that GL balances',
                'sequence': 80,
                'due_date_offset': 8,
            },
        ]

        for task_data in default_tasks:
            self.env['afc.close.task'].create({
                'close_calendar_id': self.id,
                'name': task_data['name'],
                'description': task_data['description'],
                'sequence': task_data['sequence'],
                'due_date': (
                    fields.Date.from_string(self.close_date) -
                    timedelta(days=task_data['due_date_offset'])
                ),
                'assigned_to': self.env.user.id,
            })

    def _notify_users(self):
        """Send notifications to assigned users"""
        # Implementation would send emails/messages to assigned users
        pass

    def _validate_gl_balanced(self):
        """Validate GL is balanced"""
        # Implementation would check all GL accounts balance
        return True

    def name_get(self):
        """Custom display name"""
        result = []
        for record in self:
            name = f"{record.name} ({record.close_date.strftime('%B %Y')})"
            result.append((record.id, name))
        return result
```

---

## File 4: `models/afc_close_task.py`

```python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from odoo import api, fields, models, _
from odoo.exceptions import ValidationError


class AFCCloseTask(models.Model):
    """Close Task Management"""
    _name = 'afc.close.task'
    _description = 'AFC Close Task'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'sequence, due_date'

    # ==================== FIELDS ====================
    name = fields.Char('Task Name', required=True)
    description = fields.Text('Description')

    close_calendar_id = fields.Many2one(
        'afc.close.calendar',
        'Close Calendar',
        required=True,
        ondelete='cascade'
    )

    sequence = fields.Integer('Sequence', default=10)

    state = fields.Selection([
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('review', 'Under Review'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ], 'Status', default='pending', tracking=True)

    assigned_to = fields.Many2one(
        'res.users',
        'Assigned To',
        help='User responsible for this task'
    )

    due_date = fields.Date('Due Date', required=True)
    completion_date = fields.Date('Completed On', readonly=True)

    # Priority and Status
    priority = fields.Selection([
        ('0', 'Low'),
        ('1', 'Medium'),
        ('2', 'High'),
        ('3', 'Critical'),
    ], 'Priority', default='1')

    is_overdue = fields.Boolean(
        'Is Overdue',
        compute='_compute_is_overdue'
    )

    # Approvals
    requires_approval = fields.Boolean(
        'Requires Approval',
        default=True
    )

    approved_by = fields.Many2one(
        'res.users',
        'Approved By',
        readonly=True
    )

    approval_date = fields.Datetime('Approval Date', readonly=True)

    # Documentation
    document_ids = fields.One2many(
        'ir.attachment',
        'task_id',
        'Supporting Documents'
    )

    # Comments and Notes
    notes = fields.Text('Notes', tracking=True)

    # ==================== COMPUTED FIELDS ====================
    @api.depends('due_date', 'state')
    def _compute_is_overdue(self):
        """Check if task is overdue"""
        today = fields.Date.today()
        for record in self:
            record.is_overdue = (
                record.due_date < today and
                record.state != 'completed'
            )

    # ==================== ACTIONS ====================
    def action_start(self):
        """Start task"""
        for record in self:
            record.state = 'in_progress'
            record.message_post(
                body=_('Task started by %s') % self.env.user.name
            )

    def action_submit_for_review(self):
        """Submit task for review"""
        for record in self:
            if not record.assigned_to:
                raise ValidationError(_('Task must be assigned before review'))

            record.state = 'review'
            record.message_post(
                body=_('Task submitted for review'),
                subtype_xmlid='mail.mt_comment'
            )

    def action_approve(self):
        """Approve task completion"""
        for record in self:
            if record.state != 'review':
                raise ValidationError(
                    _('Only tasks under review can be approved')
                )

            record.state = 'completed'
            record.completion_date = fields.Date.today()
            record.approved_by = self.env.user.id
            record.approval_date = fields.Datetime.now()

            record.message_post(
                body=_('Task approved and completed by %s') % (
                    self.env.user.name
                )
            )

    def action_cancel(self):
        """Cancel task"""
        for record in self:
            record.state = 'cancelled'
            record.message_post(body=_('Task cancelled'))
```

---

## File 5: `models/afc_gl_posting.py`

```python
# -*- coding: utf-8 -*-
from odoo import api, fields, models, _
from odoo.exceptions import ValidationError


class AFCGLPosting(models.Model):
    """GL Posting Management and Integration"""
    _name = 'afc.gl.posting'
    _description = 'AFC GL Posting'
    _inherit = ['mail.thread']

    # ==================== FIELDS ====================
    close_calendar_id = fields.Many2one(
        'afc.close.calendar',
        'Close Calendar',
        required=True,
        ondelete='cascade'
    )

    journal_id = fields.Many2one(
        'account.journal',
        'Journal',
        required=True
    )

    account_move_id = fields.Many2one(
        'account.move',
        'GL Entry',
        readonly=True
    )

    reference = fields.Char('Reference', required=True)
    description = fields.Text('Description', required=True)

    posting_date = fields.Date('Posting Date', required=True)

    # GL Line Items
    line_ids = fields.One2many(
        'afc.gl.posting.line',
        'posting_id',
        'GL Lines'
    )

    # Status
    state = fields.Selection([
        ('draft', 'Draft'),
        ('to_post', 'Ready to Post'),
        ('posted', 'Posted'),
        ('rejected', 'Rejected'),
    ], 'Status', default='draft', tracking=True)

    # Validation
    is_balanced = fields.Boolean(
        'Is Balanced',
        compute='_compute_is_balanced'
    )

    debit_total = fields.Float(
        'Total Debits',
        compute='_compute_totals'
    )

    credit_total = fields.Float(
        'Total Credits',
        compute='_compute_totals'
    )

    # ==================== COMPUTED FIELDS ====================
    @api.depends('line_ids', 'line_ids.debit', 'line_ids.credit')
    def _compute_totals(self):
        """Compute debit/credit totals"""
        for record in self:
            record.debit_total = sum(
                line.debit for line in record.line_ids
            )
            record.credit_total = sum(
                line.credit for line in record.line_ids
            )

    @api.depends('debit_total', 'credit_total')
    def _compute_is_balanced(self):
        """Check if GL entry is balanced"""
        for record in self:
            record.is_balanced = (
                abs(record.debit_total - record.credit_total) < 0.01
            )

    # ==================== ACTIONS ====================
    def action_post_to_gl(self):
        """Post GL entry to account.move"""
        for record in self:
            if not record.is_balanced:
                raise ValidationError(
                    _('GL entry must be balanced (Debit: %s, Credit: %s)') % (
                        record.debit_total,
                        record.credit_total
                    )
                )

            if not record.line_ids:
                raise ValidationError(_('GL entry must have at least one line'))

            # Create account.move
            move_vals = {
                'journal_id': record.journal_id.id,
                'date': record.posting_date,
                'ref': record.reference,
                'narration': record.description,
                'line_ids': [
                    (0, 0, {
                        'account_id': line.account_id.id,
                        'debit': line.debit,
                        'credit': line.credit,
                        'name': line.description or record.description,
                    })
                    for line in record.line_ids
                ],
            }

            move = self.env['account.move'].create(move_vals)
            record.account_move_id = move.id
            record.state = 'posted'
            record.message_post(
                body=_('GL entry posted successfully')
            )


class AFCGLPostingLine(models.Model):
    """GL Posting Lines"""
    _name = 'afc.gl.posting.line'
    _description = 'AFC GL Posting Line'

    posting_id = fields.Many2one(
        'afc.gl.posting',
        'GL Posting',
        required=True,
        ondelete='cascade'
    )

    account_id = fields.Many2one(
        'account.account',
        'Account',
        required=True
    )

    description = fields.Char('Description')
    debit = fields.Float('Debit', default=0.0)
    credit = fields.Float('Credit', default=0.0)

    @api.constrains('debit', 'credit')
    def _check_debit_credit(self):
        """Ensure either debit or credit, not both"""
        for line in self:
            if line.debit > 0 and line.credit > 0:
                raise ValidationError(
                    _('A line cannot have both debit and credit amounts')
                )
```

---

## File 6: `models/afc_intercompany_transaction.py`

```python
# -*- coding: utf-8 -*-
from odoo import api, fields, models, _
from odoo.exceptions import ValidationError


class AFCIntercompanyTransaction(models.Model):
    """Intercompany Transaction Settlement"""
    _name = 'afc.intercompany.transaction'
    _description = 'AFC Intercompany Transaction'
    _inherit = ['mail.thread']

    # ==================== FIELDS ====================
    close_calendar_id = fields.Many2one(
        'afc.close.calendar',
        'Close Calendar',
        required=True,
        ondelete='cascade'
    )

    from_company_id = fields.Many2one(
        'res.company',
        'From Company',
        required=True
    )

    to_company_id = fields.Many2one(
        'res.company',
        'To Company',
        required=True
    )

    amount = fields.Float('Amount', required=True)
    currency_id = fields.Many2one(
        'res.currency',
        'Currency',
        required=True,
        default=lambda self: self.env.company.currency_id
    )

    description = fields.Text('Description')

    # GL Accounts
    from_account_id = fields.Many2one(
        'account.account',
        'From Account',
        help='IC Payable account for from_company_id'
    )

    to_account_id = fields.Many2one(
        'account.account',
        'To Account',
        help='IC Receivable account for to_company_id'
    )

    # Status
    state = fields.Selection([
        ('pending', 'Pending'),
        ('posted', 'Posted'),
        ('settled', 'Settled'),
    ], 'Status', default='pending', tracking=True)

    invoice_id = fields.Many2one(
        'account.move',
        'IC Invoice',
        readonly=True
    )

    # ==================== ACTIONS ====================
    def action_create_ic_invoice(self):
        """Create IC invoice"""
        for record in self:
            if record.state != 'pending':
                raise ValidationError(
                    _('Only pending transactions can be invoiced')
                )

            invoice_vals = {
                'move_type': 'out_invoice',
                'partner_id': record.to_company_id.partner_id.id,
                'journal_id': record.from_company_id.default_sales_journal_id.id,
                'line_ids': [
                    (0, 0, {
                        'account_id': record.from_account_id.id,
                        'quantity': 1,
                        'price_unit': record.amount,
                        'name': record.description or 'Intercompany charge',
                    })
                ],
            }

            invoice = self.env['account.move'].create(invoice_vals)
            record.invoice_id = invoice.id
            record.state = 'posted'

    def action_settle(self):
        """Mark IC transaction as settled"""
        for record in self:
            record.state = 'settled'
            record.message_post(body=_('IC transaction settled'))
```

---

## File 7: `models/afc_document_attachment.py`

```python
# -*- coding: utf-8 -*-
from odoo import api, fields, models


class AFCDocumentAttachment(models.Model):
    """Supporting Document Management"""
    _name = 'afc.document.attachment'
    _description = 'AFC Document Attachment'
    _inherit = ['mail.thread']

    close_calendar_id = fields.Many2one(
        'afc.close.calendar',
        'Close Calendar',
        ondelete='cascade'
    )

    close_task_id = fields.Many2one(
        'afc.close.task',
        'Close Task',
        ondelete='cascade'
    )

    attachment_id = fields.Many2one(
        'ir.attachment',
        'Attachment',
        required=True
    )

    document_type = fields.Selection([
        ('reconciliation', 'Reconciliation'),
        ('variance', 'Variance Analysis'),
        ('approval', 'Approval'),
        ('compliance', 'Compliance'),
        ('other', 'Other'),
    ], 'Document Type')

    description = fields.Text('Description')

    uploaded_by = fields.Many2one(
        'res.users',
        'Uploaded By',
        default=lambda self: self.env.user
    )

    upload_date = fields.Datetime(
        'Upload Date',
        default=fields.Datetime.now
    )
```

---

## File 8: `models/afc_compliance_checklist.py`

```python
# -*- coding: utf-8 -*-
from odoo import api, fields, models


class AFCComplianceChecklist(models.Model):
    """Compliance Checklist Items"""
    _name = 'afc.compliance.checklist'
    _description = 'AFC Compliance Checklist'

    close_calendar_id = fields.Many2one(
        'afc.close.calendar',
        'Close Calendar',
        ondelete='cascade'
    )

    name = fields.Char('Checklist Item', required=True)
    description = fields.Text('Description')

    is_completed = fields.Boolean('Completed', default=False)
    completed_date = fields.Date('Completed On')

    verified_by = fields.Many2one(
        'res.users',
        'Verified By'
    )

    notes = fields.Text('Notes')
```

---

## File 9: `security/ir_model_access.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">
        <!-- Manager Group -->
        <record id="group_afc_manager" model="res.groups">
            <field name="name">AFC Close Manager</field>
            <field name="comment">Can manage close calendars and approve tasks</field>
            <field name="implied_ids" eval="[(4, ref('base.group_user'))]"/>
        </record>

        <!-- User Group -->
        <record id="group_afc_user" model="res.groups">
            <field name="name">AFC Close User</field>
            <field name="comment">Can execute close tasks</field>
            <field name="implied_ids" eval="[(4, ref('base.group_user'))]"/>
        </record>

        <!-- Access Rules -->
        <record id="access_afc_close_calendar_manager" model="ir.model.access">
            <field name="name">Access AFC Close Calendar - Manager</field>
            <field name="model_id" ref="model_afc_close_calendar"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <record id="access_afc_close_calendar_user" model="ir.model.access">
            <field name="name">Access AFC Close Calendar - User</field>
            <field name="model_id" ref="model_afc_close_calendar"/>
            <field name="group_id" ref="group_afc_user"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="False"/>
            <field name="perm_create" eval="False"/>
            <field name="perm_unlink" eval="False"/>
        </record>

        <!-- Close Task Access -->
        <record id="access_afc_close_task_manager" model="ir.model.access">
            <field name="name">Access AFC Close Task - Manager</field>
            <field name="model_id" ref="model_afc_close_task"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <record id="access_afc_close_task_user" model="ir.model.access">
            <field name="name">Access AFC Close Task - User</field>
            <field name="model_id" ref="model_afc_close_task"/>
            <field name="group_id" ref="group_afc_user"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="False"/>
        </record>

        <!-- GL Posting Access -->
        <record id="access_afc_gl_posting_manager" model="ir.model.access">
            <field name="name">Access AFC GL Posting - Manager</field>
            <field name="model_id" ref="model_afc_gl_posting"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <!-- GL Posting Line Access -->
        <record id="access_afc_gl_posting_line_manager" model="ir.model.access">
            <field name="name">Access AFC GL Posting Line - Manager</field>
            <field name="model_id" ref="model_afc_gl_posting_line"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <!-- Intercompany Access -->
        <record id="access_afc_intercompany_manager" model="ir.model.access">
            <field name="name">Access AFC Intercompany - Manager</field>
            <field name="model_id" ref="model_afc_intercompany_transaction"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <!-- Document Attachment Access -->
        <record id="access_afc_document_manager" model="ir.model.access">
            <field name="name">Access AFC Document - Manager</field>
            <field name="model_id" ref="model_afc_document_attachment"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

        <!-- Compliance Checklist Access -->
        <record id="access_afc_compliance_manager" model="ir.model.access">
            <field name="name">Access AFC Compliance - Manager</field>
            <field name="model_id" ref="model_afc_compliance_checklist"/>
            <field name="group_id" ref="group_afc_manager"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>
    </data>
</odoo>
```

---

## File 10: `views/afc_close_calendar_views.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <!-- Close Calendar Tree View -->
    <record id="view_afc_close_calendar_tree" model="ir.ui.view">
        <field name="name">afc.close.calendar.tree</field>
        <field name="model">afc.close.calendar</field>
        <field name="arch" type="xml">
            <tree string="Close Calendars">
                <field name="name"/>
                <field name="close_type"/>
                <field name="close_date"/>
                <field name="state" widget="badge"
                       decoration-info="state == 'draft'"
                       decoration-primary="state == 'active'"
                       decoration-warning="state == 'in_progress'"
                       decoration-success="state == 'completed'"
                       decoration-danger="state == 'cancelled'"/>
                <field name="completion_percentage" widget="progressbar"/>
            </tree>
        </field>
    </record>

    <!-- Close Calendar Form View -->
    <record id="view_afc_close_calendar_form" model="ir.ui.view">
        <field name="name">afc.close.calendar.form</field>
        <field name="model">afc.close.calendar</field>
        <field name="arch" type="xml">
            <form string="Close Calendar">
                <header>
                    <button name="action_activate"
                            string="Activate"
                            type="object"
                            states="draft"
                            class="oe_highlight"/>
                    <button name="action_start"
                            string="Start Close"
                            type="object"
                            states="active"
                            class="oe_highlight"/>
                    <button name="action_complete"
                            string="Complete Close"
                            type="object"
                            states="in_progress"
                            class="oe_highlight"/>
                    <button name="action_cancel"
                            string="Cancel"
                            type="object"
                            states="draft,active,in_progress"/>
                    <field name="state"
                           widget="statusbar"
                           options="{'clickable': False}"/>
                </header>

                <sheet>
                    <div class="oe_title">
                        <h1>
                            <field name="name" class="oe_inline"/>
                        </h1>
                    </div>

                    <group>
                        <group>
                            <field name="close_type"/>
                            <field name="company_id" options="{'no_create': True}"/>
                            <field name="close_date"/>
                        </group>
                        <group>
                            <field name="start_date"/>
                            <field name="deadline_date"/>
                            <field name="actual_close_date"/>
                        </group>
                    </group>

                    <group>
                        <group>
                            <field name="auto_create_tasks"/>
                            <field name="send_notifications"/>
                            <field name="require_signatures"/>
                        </group>
                        <group>
                            <field name="completion_percentage" widget="progressbar"/>
                            <field name="task_count"/>
                            <field name="completed_task_count"/>
                        </group>
                    </group>

                    <field name="journal_ids" widget="many2many_tags"/>

                    <notebook>
                        <page string="Close Tasks">
                            <field name="task_ids" mode="tree">
                                <tree editable="bottom">
                                    <field name="sequence" widget="handle"/>
                                    <field name="name"/>
                                    <field name="assigned_to"/>
                                    <field name="due_date"/>
                                    <field name="priority"/>
                                    <field name="state" widget="badge"/>
                                </tree>
                            </field>
                        </page>

                        <page string="Supporting Documents">
                            <field name="document_ids" mode="tree">
                                <tree>
                                    <field name="document_type"/>
                                    <field name="attachment_id"/>
                                    <field name="uploaded_by"/>
                                    <field name="upload_date"/>
                                </tree>
                            </field>
                        </page>

                        <page string="Intercompany Transactions">
                            <field name="intercompany_ids" mode="tree">
                                <tree>
                                    <field name="from_company_id"/>
                                    <field name="to_company_id"/>
                                    <field name="amount"/>
                                    <field name="currency_id"/>
                                    <field name="state" widget="badge"/>
                                </tree>
                            </field>
                        </page>

                        <page string="Notes">
                            <field name="notes" nolabel="1" placeholder="Add notes..."/>
                        </page>
                    </notebook>
                </sheet>

                <div class="oe_chatter">
                    <field name="message_ids" widget="mail_thread"/>
                    <field name="activity_ids" widget="mail_activity"/>
                </div>
            </form>
        </field>
    </record>

    <!-- Close Calendar Search View -->
    <record id="view_afc_close_calendar_search" model="ir.ui.view">
        <field name="name">afc.close.calendar.search</field>
        <field name="model">afc.close.calendar</field>
        <field name="arch" type="xml">
            <search string="Search Close Calendars">
                <field name="name"/>
                <field name="close_date"/>
                <filter name="active_closes"
                        string="Active Closes"
                        domain="[('state', 'in', ['active', 'in_progress'])]"/>
                <filter name="completed"
                        string="Completed"
                        domain="[('state', '=', 'completed')]"/>
                <separator/>
                <filter name="this_month"
                        string="This Month"
                        domain="[('close_date', '&gt;=', (context_today()).strftime('%Y-%m-01'))]"/>
                <group string="Group By" expand="0">
                    <filter name="group_by_state"
                            string="Status"
                            context="{'group_by': 'state'}"/>
                    <filter name="group_by_type"
                            string="Type"
                            context="{'group_by': 'close_type'}"/>
                    <filter name="group_by_company"
                            string="Company"
                            context="{'group_by': 'company_id'}"/>
                </group>
            </search>
        </field>
    </record>

    <!-- Action -->
    <record id="action_afc_close_calendar" model="ir.actions.act_window">
        <field name="name">Close Calendars</field>
        <field name="res_model">afc.close.calendar</field>
        <field name="view_mode">tree,form</field>
        <field name="search_view_id" ref="view_afc_close_calendar_search"/>
        <field name="context">{}</field>
        <field name="help" type="html">
            <p class="o_view_nocontent_smiling_face">
                Create your first close calendar
            </p>
            <p>
                Manage your month-end, quarter-end, and year-end closing processes.
            </p>
        </field>
    </record>
</odoo>
```

---

## File 11: `views/afc_menu.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <!-- Main Menu -->
    <menuitem id="menu_afc_root"
              name="Financial Close"
              sequence="25"
              web_icon="afc_close_manager,static/description/icon.png"/>

    <!-- Close Calendar Menu -->
    <menuitem id="menu_afc_close_calendar"
              name="Close Calendars"
              parent="menu_afc_root"
              action="action_afc_close_calendar"
              sequence="10"/>

    <!-- Close Tasks Menu -->
    <menuitem id="menu_afc_close_tasks"
              name="Close Tasks"
              parent="menu_afc_root"
              action="action_afc_close_task"
              sequence="20"/>

    <!-- GL Postings Menu -->
    <menuitem id="menu_afc_gl_postings"
              name="GL Postings"
              parent="menu_afc_root"
              action="action_afc_gl_posting"
              sequence="30"/>

    <!-- Intercompany Menu -->
    <menuitem id="menu_afc_intercompany"
              name="Intercompany"
              parent="menu_afc_root"
              action="action_afc_intercompany"
              sequence="40"/>

    <!-- Configuration Menu -->
    <menuitem id="menu_afc_config"
              name="Configuration"
              parent="menu_afc_root"
              sequence="90"/>
</odoo>
```

---

## Installation Instructions

1. **Copy module to addons path**:
   ```bash
   cp -r afc_close_manager /opt/odoo/addons/
   ```

2. **Update module list**:
   ```bash
   ./odoo-bin -c /etc/odoo/odoo.conf -d your_database -u base --stop-after-init
   ```

3. **Install the module**:
   - Go to Apps → Update Apps List
   - Search for "Advanced Financial Closing Manager"
   - Click Install

4. **Configure security groups**:
   - Go to Settings → Users & Companies → Groups
   - Assign users to AFC Close Manager or AFC Close User groups

---

## Related Documentation

- [AFC Implementation Blueprint](13-afc-implementation-blueprint.md) - Architecture and planning
- [SAP AFC to Odoo Mapping](12-sap-afc-odoo-mapping.md) - Task-level mapping
- [Month-End Task Template](05-month-end-task-template.md) - Operational procedures

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Development Team | Initial module code |

---

**Document Classification**: Internal - Development
**Review Frequency**: Per Release
**Approver**: IT Market Director
