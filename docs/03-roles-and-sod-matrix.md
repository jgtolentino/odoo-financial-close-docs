# 03 - Roles and Separation of Duties Matrix

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director
**Classification**: Internal - Governance

---

## Executive Summary

This document defines the **9-role separation of duties (SoD) framework** for financial close operations in Odoo 18 CE, ensuring compliance with internal control standards, Philippine BIR requirements, and international audit frameworks (SOX, IFRS). The framework establishes clear accountability boundaries, prevents conflicts of interest, and provides audit trail transparency for all financial transactions.

**Core Principles**:
- **No single individual controls transaction lifecycle end-to-end** (initiation → approval → recording → reconciliation)
- **Duty segregation across 4 control points**: Authorization, Custody, Recording, Reconciliation
- **Role-based access control (RBAC)** enforced through Odoo security groups and Supabase Row-Level Security (RLS)
- **Minimum dual approval** for transactions exceeding materiality thresholds
- **Audit trail immutability** for all role actions and permission changes

---

## 1. Nine-Role Framework Architecture

### 1.1 Role Hierarchy and Reporting Structure

```
External Auditor (Independent)
        │
        ├─ Finance Director (Executive)
        │       │
        │       ├─ Finance Manager (Supervisory)
        │       │       │
        │       │       ├─ Tax Compliance Officer (Specialist)
        │       │       ├─ Payroll Specialist (Specialist)
        │       │       ├─ Fixed Asset Accountant (Specialist)
        │       │       ├─ GL Accountant (Specialist)
        │       │       ├─ AR Clerk (Transactional)
        │       │       └─ AP Clerk (Transactional)
```

**Escalation Path**:
- **Level 1**: Clerks/Specialists → Finance Manager (operational issues)
- **Level 2**: Finance Manager → Finance Director (exceptions, policy changes)
- **Level 3**: Finance Director → External Auditor (material misstatements, fraud)

---

## 2. Detailed Role Definitions

### 2.1 **AP Clerk** (Accounts Payable Clerk)

**Primary Responsibilities**:
- Vendor invoice receipt and validation
- Purchase order (PO) matching (2-way or 3-way)
- Payment preparation and vendor communication
- Expense report pre-approval and OCR validation

**Separation of Duties**:
- ✅ **CAN**: Create vendor bills, attach receipts, propose payments, initiate PO matching
- ❌ **CANNOT**: Approve vendor bills >₱50,000, create vendors (requires Finance Manager), post payments (requires GL Accountant), modify GL accounts

**Odoo Security Groups**:
- `account.group_account_invoice` (Bills: Create/Edit)
- `purchase.group_purchase_user` (PO: Read-only)
- `base.group_user` (Employee access)

**Supabase RLS Policies**:
```sql
-- AP Clerk can only view/edit draft vendor bills for assigned agencies
CREATE POLICY ap_clerk_vendor_bills ON account_move
  FOR ALL
  USING (
    move_type = 'in_invoice'
    AND state = 'draft'
    AND company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())
  )
  WITH CHECK (
    move_type = 'in_invoice'
    AND state = 'draft'
  );
```

**Key Performance Indicators (KPIs)**:
- Invoice processing time: ≤2 business days from receipt
- PO matching accuracy: ≥98%
- OCR validation correction rate: ≤5%

**Audit Trail Requirements**:
- All invoice edits logged with timestamp + user ID
- OCR confidence scores <0.60 flagged for manual review
- Vendor master changes require Finance Manager approval

---

### 2.2 **AR Clerk** (Accounts Receivable Clerk)

**Primary Responsibilities**:
- Customer invoice generation and delivery
- Payment application and cash receipt recording
- Aging report monitoring and customer communication
- Credit memo preparation (requires approval)

**Separation of Duties**:
- ✅ **CAN**: Create customer invoices, record payments, generate aging reports, send payment reminders
- ❌ **CANNOT**: Write off bad debts (requires Finance Manager), modify revenue accounts, approve credit memos >₱25,000, create customers (requires Finance Manager)

**Odoo Security Groups**:
- `account.group_account_invoice` (Invoices: Create/Edit)
- `sale.group_sale_user` (Sales Orders: Read-only)
- `account.group_account_readonly` (Reports: View)

**Supabase RLS Policies**:
```sql
-- AR Clerk can only manage customer invoices for assigned agencies
CREATE POLICY ar_clerk_customer_invoices ON account_move
  FOR ALL
  USING (
    move_type IN ('out_invoice', 'out_refund')
    AND state IN ('draft', 'posted')
    AND company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())
  )
  WITH CHECK (
    move_type IN ('out_invoice', 'out_refund')
  );
```

**Key Performance Indicators (KPIs)**:
- Days Sales Outstanding (DSO): ≤45 days
- Collection effectiveness: ≥95%
- Invoice error rate: ≤2%

**Audit Trail Requirements**:
- Payment application reversals logged with justification
- Credit memos >₱10,000 require supporting documentation
- Aging report snapshots archived monthly

---

### 2.3 **GL Accountant** (General Ledger Accountant)

**Primary Responsibilities**:
- Journal entry creation and posting
- Account reconciliation (bank, intercompany, suspense)
- Chart of accounts (CoA) maintenance
- Month-end close coordination and validation

**Separation of Duties**:
- ✅ **CAN**: Post journal entries, reconcile accounts, manage CoA, execute accruals/deferrals, initiate close process
- ❌ **CANNOT**: Approve journal entries >₱100,000 (requires Finance Manager), initiate payments, modify tax configurations, unlock closed periods (requires Finance Director)

**Odoo Security Groups**:
- `account.group_account_user` (Accounting: Full access)
- `account.group_account_manager` (Advanced features: Reconciliation, Journal management)

**Supabase RLS Policies**:
```sql
-- GL Accountant can create/edit journal entries for assigned agencies
CREATE POLICY gl_accountant_journal_entries ON account_move
  FOR ALL
  USING (
    state IN ('draft', 'posted')
    AND company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())
  )
  WITH CHECK (
    state = 'draft' OR (state = 'posted' AND amount_total <= 100000)
  );
```

**Key Performance Indicators (KPIs)**:
- Reconciliation completion rate: 100% by Day 5 of close
- Journal entry error rate: ≤1%
- Close cycle time contribution: ≤40% of total close time

**Audit Trail Requirements**:
- All manual journal entries require narrative explanation
- Reconciliation workpapers attached to account records
- Period-end close checklist signed off electronically

---

### 2.4 **Fixed Asset Accountant**

**Primary Responsibilities**:
- Asset capitalization and disposal management
- Depreciation schedule calculation and validation
- Asset impairment testing and write-downs
- Fixed asset register reconciliation to GL

**Separation of Duties**:
- ✅ **CAN**: Create/edit asset records, calculate depreciation, propose disposals, run impairment tests
- ❌ **CANNOT**: Approve asset acquisitions >₱500,000 (requires Finance Director), modify depreciation methods without approval, post disposal gains/losses (requires GL Accountant review)

**Odoo Security Groups**:
- `account_asset.group_account_asset` (Asset Management: Full access)
- `account.group_account_user` (Accounting: Read access)

**Supabase RLS Policies**:
```sql
-- Fixed Asset Accountant manages assets for assigned agencies
CREATE POLICY fa_accountant_assets ON account_asset
  FOR ALL
  USING (
    company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())
  )
  WITH CHECK (
    state = 'draft' OR (state = 'open' AND value <= 500000)
  );
```

**Key Performance Indicators (KPIs)**:
- Asset register accuracy: 100% (variance to GL ≤₱1,000)
- Depreciation calculation accuracy: ≥99.5%
- Annual physical verification completion: 100%

**Audit Trail Requirements**:
- Asset acquisition supporting documents (invoice, PO, delivery receipt)
- Disposal approvals and fair value assessments
- Impairment test calculations and management judgments

---

### 2.5 **Payroll Specialist**

**Primary Responsibilities**:
- Employee payroll processing and validation
- Statutory deduction calculation (SSS, PhilHealth, Pag-IBIG, BIR withholding)
- Payroll reconciliation to GL and cash disbursements
- Government remittance preparation and filing

**Separation of Duties**:
- ✅ **CAN**: Process payroll, calculate deductions, generate payslips, prepare remittance reports
- ❌ **CANNOT**: Approve payroll runs >₱1,000,000 (requires Finance Manager), create employees (requires HR), post payroll journal entries (requires GL Accountant), initiate payroll bank transfers (requires Finance Manager)

**Odoo Security Groups**:
- `hr_payroll.group_hr_payroll_user` (Payroll: Full access)
- `hr.group_hr_user` (Employee data: Read-only)

**Supabase RLS Policies**:
```sql
-- Payroll Specialist processes payroll for assigned agencies only
CREATE POLICY payroll_specialist_payslips ON hr_payslip
  FOR ALL
  USING (
    company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())
    AND state IN ('draft', 'done')
  )
  WITH CHECK (
    state = 'draft'
  );
```

**Key Performance Indicators (KPIs)**:
- Payroll processing accuracy: ≥99.9%
- On-time payroll delivery: 100%
- Government remittance timeliness: 100% (before deadlines)

**Audit Trail Requirements**:
- Payroll register signed off by Finance Manager
- Statutory deduction reconciliation to remittance returns
- Payslip distribution acknowledgment records

---

### 2.6 **Tax Compliance Officer**

**Primary Responsibilities**:
- BIR tax return preparation (1601-C, 2550Q, 1702-RT, etc.)
- Tax computation validation and optimization
- Tax audit coordination and response
- VAT compliance and eFPS filing

**Separation of Duties**:
- ✅ **CAN**: Prepare tax returns, compute withholding tax, validate tax accounts, coordinate with BIR
- ❌ **CANNOT**: Approve tax returns (requires Finance Director), modify tax rates (requires system admin), post tax journal entries (requires GL Accountant), sign tax returns (requires authorized signatory)

**Odoo Security Groups**:
- `account.group_account_user` (Accounting: Full access)
- `l10n_ph_bir.group_bir_compliance` (BIR Forms: Create/Edit)

**Supabase RLS Policies**:
```sql
-- Tax Compliance Officer manages tax returns for all agencies
CREATE POLICY tax_officer_bir_returns ON bir_return
  FOR ALL
  USING (
    state IN ('draft', 'submitted')
  )
  WITH CHECK (
    state = 'draft'
  );
```

**Key Performance Indicators (KPIs)**:
- Tax return accuracy: 100% (zero BIR penalties)
- Filing timeliness: 100% (before statutory deadlines)
- Tax audit resolution time: ≤90 days

**Audit Trail Requirements**:
- Tax computation workpapers archived for 10 years (BIR statute of limitations)
- BIR filing confirmations (eFPS acknowledgment receipts)
- Tax payment proof (bank validated deposit slips)

---

### 2.7 **Finance Manager**

**Primary Responsibilities**:
- Transaction approval and exception handling
- Financial statement review and variance analysis
- Team supervision and workflow coordination
- Internal control monitoring and policy enforcement

**Separation of Duties**:
- ✅ **CAN**: Approve transactions within authority limits, review financial statements, create/modify master data, unlock periods (with justification), assign tasks to team
- ❌ **CANNOT**: Post journal entries without GL Accountant preparation, approve own transactions, modify closed periods without Finance Director, override dual approval requirements

**Odoo Security Groups**:
- `account.group_account_manager` (Accounting: Manager privileges)
- `base.group_system` (Settings: Limited access for master data)
- All subordinate role groups (for review purposes)

**Supabase RLS Policies**:
```sql
-- Finance Manager approves transactions across all agencies
CREATE POLICY finance_manager_approvals ON account_move
  FOR UPDATE
  USING (
    state = 'draft'
    AND amount_total BETWEEN 50000 AND 1000000
  )
  WITH CHECK (
    state = 'posted' AND approved_by = auth.uid()
  );
```

**Authority Limits**:
- Vendor bills: ₱50,000 - ₱1,000,000
- Journal entries: ₱100,000 - ₱500,000
- Credit memos: ₱25,000 - ₱250,000
- Payroll runs: ₱1,000,000 - ₱5,000,000

**Key Performance Indicators (KPIs)**:
- Approval turnaround time: ≤4 hours
- Exception resolution rate: ≥95%
- Team productivity: Close cycle time ≤5 days

**Audit Trail Requirements**:
- All approvals electronically timestamped
- Exception handling documented with business justification
- Monthly control self-assessment (CSA) attestation

---

### 2.8 **Finance Director**

**Primary Responsibilities**:
- Financial statement certification and sign-off
- Strategic financial planning and policy formulation
- Audit liaison and regulatory compliance oversight
- Ultimate escalation point for financial decisions

**Separation of Duties**:
- ✅ **CAN**: Approve all transactions (no limit), unlock/modify closed periods, authorize policy changes, sign tax returns, appoint external auditors
- ❌ **CANNOT**: Execute transactions without subordinate preparation, override segregation of duties framework, modify audit trail logs

**Odoo Security Groups**:
- `base.group_system` (System: Full administrative access)
- `account.group_account_manager` (Accounting: Full privileges)
- All role groups (for oversight)

**Supabase RLS Policies**:
```sql
-- Finance Director has full read access, write requires justification
CREATE POLICY finance_director_oversight ON account_move
  FOR ALL
  USING (TRUE)  -- Can view all transactions
  WITH CHECK (
    (state = 'draft' AND amount_total > 1000000)  -- High-value approvals
    OR (state = 'posted' AND override_justification IS NOT NULL)  -- Period unlocks
  );
```

**Authority Limits**:
- Unlimited transaction approval authority
- Period unlock authority (requires documented justification)
- CoA structure modification authority
- External audit coordination authority

**Key Performance Indicators (KPIs)**:
- Financial statement accuracy: 100% (zero restatements)
- Regulatory compliance: 100% (zero penalties/fines)
- Audit opinion: Unqualified/Clean

**Audit Trail Requirements**:
- All period unlocks logged with justification and affected transactions
- Policy changes version-controlled with approval dates
- Annual financial statement certification signed and archived

---

### 2.9 **External Auditor**

**Primary Responsibilities**:
- Annual financial statement audit
- Internal control effectiveness assessment
- Independence verification and fraud risk evaluation
- Audit opinion issuance and management letter

**Separation of Duties**:
- ✅ **CAN**: Read-only access to all financial data, request supporting documents, interview personnel, issue audit findings
- ❌ **CANNOT**: Modify any data, provide advisory services on audited matters, participate in management decisions, approve transactions

**Odoo Security Groups**:
- `account.group_account_readonly` (Accounting: Read-only across all companies)
- Custom group: `audit.group_external_auditor` (Data export privileges)

**Supabase RLS Policies**:
```sql
-- External Auditor has read-only access to all historical data
CREATE POLICY external_auditor_read_only ON account_move
  FOR SELECT
  USING (
    auth.uid() IN (SELECT user_id FROM external_auditor_assignments WHERE active = TRUE)
  );
```

**Independence Requirements**:
- No financial interest in audited entities
- Rotation every 5 years (audit partner) / 7 years (audit firm)
- Pre-approval required for non-audit services
- Annual independence declaration

**Audit Trail Requirements**:
- Audit working papers retained for 10 years
- Management representation letters archived
- Audit committee communication records
- Quality control review documentation

---

## 3. RACI Matrix for Financial Close Tasks

**Legend**:
- **R** = Responsible (Does the work)
- **A** = Accountable (Ultimate decision authority)
- **C** = Consulted (Provides input)
- **I** = Informed (Kept updated)

### 3.1 Pre-Close Activities (Days -5 to -1)

| Task | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **Vendor invoice processing** | R | I | I | - | - | - | A | I | - |
| **Customer invoice generation** | - | R | I | - | - | - | A | I | - |
| **Payroll run execution** | - | - | I | - | R | C | A | I | - |
| **Asset depreciation calculation** | - | - | C | R | - | - | A | I | - |
| **Tax accrual preparation** | - | - | C | - | - | R | A | I | - |
| **Prepayment/Accrual review** | I | I | R | C | - | C | A | I | - |
| **Intercompany reconciliation** | C | C | R | - | - | - | A | I | - |

### 3.2 Close Execution (Days 1-3)

| Task | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **Period-end journal entries** | I | I | R | C | C | C | A | I | - |
| **Bank reconciliation** | I | I | R | - | - | - | A | I | - |
| **AR aging review** | - | R | C | - | - | - | A | I | - |
| **AP aging review** | R | - | C | - | - | - | A | I | - |
| **Fixed asset register reconciliation** | - | - | C | R | - | - | A | I | - |
| **Payroll reconciliation to GL** | - | - | C | - | R | - | A | I | - |
| **Tax account reconciliation** | - | - | C | - | - | R | A | I | - |

### 3.3 Review & Reconciliation (Days 4-5)

| Task | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **Trial balance validation** | I | I | R | C | C | C | A | I | - |
| **Variance analysis (vs. budget)** | I | I | R | C | C | C | A | C | - |
| **Suspense account clearance** | C | C | R | - | - | - | A | I | - |
| **Intercompany elimination review** | I | I | R | - | - | - | A | C | - |
| **Management report preparation** | I | I | R | C | C | C | A | I | - |
| **Financial statement draft** | I | I | R | C | C | C | A | C | - |

### 3.4 Approval & Lock (Days 6-7)

| Task | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **Financial statement review** | I | I | C | C | C | C | R | A | I |
| **Adjustment posting (if needed)** | I | I | R | C | C | C | A | I | - |
| **Close checklist sign-off** | I | I | R | R | R | R | A | I | - |
| **Period lock execution** | - | - | I | - | - | - | R | A | I |
| **Period unlock (exceptions)** | - | - | I | - | - | - | C | A | I |
| **Board package preparation** | I | I | C | C | C | C | R | A | I |

### 3.5 Reporting & Audit (Days 8+)

| Task | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **BIR tax return filing** | - | - | I | - | - | R | C | A | I |
| **External audit support** | C | C | C | C | C | C | R | A | R |
| **Audit working paper provision** | C | C | R | C | C | C | A | I | - |
| **Management letter response** | - | - | C | C | C | C | R | A | I |
| **Control deficiency remediation** | C | C | C | C | C | C | R | A | I |

---

## 4. Permission Levels and RLS Policies

### 4.1 Odoo Security Group Mapping

| Security Group | AP Clerk | AR Clerk | GL Acct | FA Acct | Payroll | Tax | Fin Mgr | Fin Dir | Ext Audit |
|----------------|----------|----------|---------|---------|---------|-----|---------|---------|-----------|
| **base.group_user** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **account.group_account_readonly** | - | - | - | - | - | - | - | - | ✅ |
| **account.group_account_invoice** | ✅ | ✅ | ✅ | - | - | ✅ | ✅ | ✅ | - |
| **account.group_account_user** | - | - | ✅ | - | - | ✅ | ✅ | ✅ | - |
| **account.group_account_manager** | - | - | ✅ | - | - | - | ✅ | ✅ | - |
| **account_asset.group_account_asset** | - | - | - | ✅ | - | - | ✅ | ✅ | - |
| **hr_payroll.group_hr_payroll_user** | - | - | - | - | ✅ | - | ✅ | ✅ | - |
| **base.group_system** | - | - | - | - | - | - | ✅ | ✅ | - |

### 4.2 Supabase RLS Policy Framework

**Core RLS Principles**:
1. **User identity verification**: All policies check `auth.uid()` against user assignment tables
2. **Company/agency scoping**: Multi-agency users see only assigned entities
3. **State-based restrictions**: Draft vs. posted vs. locked transactions have different permissions
4. **Amount-based approvals**: Materiality thresholds enforce dual approval
5. **Temporal restrictions**: Closed periods block modifications unless explicitly unlocked

**Example RLS Policy Template**:
```sql
-- Generic transaction access policy template
CREATE POLICY role_transaction_access ON account_move
  FOR {SELECT | INSERT | UPDATE | DELETE}
  USING (
    -- User has role assignment
    auth.uid() IN (SELECT user_id FROM user_role_assignments WHERE role = 'role_name' AND active = TRUE)

    -- Transaction is in allowed state
    AND state IN ('allowed_state_1', 'allowed_state_2')

    -- User is assigned to transaction company/agency
    AND company_id IN (SELECT company_id FROM user_agency_assignments WHERE user_id = auth.uid())

    -- Amount is within authority limit (for approvals)
    AND (amount_total <= role_authority_limit OR approver_id = auth.uid())

    -- Period is not locked (unless Finance Director)
    AND (period_locked = FALSE OR auth.uid() IN (SELECT user_id FROM user_role_assignments WHERE role = 'finance_director'))
  )
  WITH CHECK (
    -- Additional constraints for INSERT/UPDATE operations
    {specific_write_constraints}
  );
```

### 4.3 Field-Level Access Control

**Sensitive Field Restrictions**:
- **Cost prices**: Hidden from AR Clerk, visible to AP Clerk/GL Accountant
- **Salary information**: Visible only to Payroll Specialist, Finance Manager, Finance Director
- **Tax computation details**: Visible to Tax Compliance Officer, Finance Manager, Finance Director
- **Audit trail fields**: Read-only for all users except system administrators

**Implementation**: Odoo field-level security via `groups` attribute in model definitions:
```python
class AccountMove(models.Model):
    _inherit = 'account.move'

    # Only Finance Manager and above can see approval history
    approval_history = fields.Text(
        string="Approval History",
        groups="account.group_account_manager"
    )

    # Only Payroll Specialist and above can see employee salary
    employee_salary = fields.Monetary(
        string="Gross Salary",
        groups="hr_payroll.group_hr_payroll_user"
    )
```

---

## 5. Segregation of Duties Controls

### 5.1 Critical SoD Conflicts (Prohibited Combinations)

| Conflict Pair | Risk | Mitigation |
|---------------|------|------------|
| **AP Clerk + Vendor Master Maintenance** | Fictitious vendor creation → unauthorized payments | Vendor creation restricted to Finance Manager with dual approval |
| **AR Clerk + Customer Master Maintenance** | Revenue manipulation via fake customers | Customer creation restricted to Finance Manager with credit checks |
| **GL Accountant + Payment Approval** | Unauthorized fund transfer after posting JE | Payment approval restricted to Finance Manager with dual control |
| **Payroll Specialist + Employee Master Maintenance** | Ghost employee payroll fraud | Employee creation restricted to HR with Finance Manager validation |
| **Tax Compliance Officer + Tax Return Signing** | Unapproved tax positions | Tax return signing restricted to Finance Director with board authorization |
| **Finance Manager + Period Unlock (without justification)** | Backdated transaction manipulation | Period unlock requires Finance Director approval with audit trail |
| **Finance Director + Transaction Execution** | Lack of maker-checker control | All transactions require subordinate preparation before Director approval |

### 5.2 Compensating Controls for Unavoidable Conflicts

**Small Organization Challenges**: In organizations with <10 finance staff, certain role combinations may be unavoidable.

**Compensating Control Framework**:
1. **Enhanced review**: Monthly supervisory review of combined-role activities
2. **System-enforced dual approval**: Transactions require second approver outside conflict pair
3. **Periodic rotation**: Rotate conflicting duties every 6 months to limit fraud window
4. **Audit trail monitoring**: Weekly automated review of conflict-pair transactions
5. **Whistleblower mechanism**: Anonymous reporting channel for suspected irregularities

**Example Compensating Control**:
```python
# Odoo workflow constraint: GL Accountant cannot approve own journal entries
class AccountMove(models.Model):
    _inherit = 'account.move'

    @api.constrains('state', 'create_uid', 'approver_id')
    def _check_maker_checker_compliance(self):
        for move in self:
            if move.state == 'posted' and move.create_uid == move.approver_id:
                if not self.env.user.has_group('base.group_system'):  # Except Finance Director override
                    raise ValidationError(
                        "Maker-checker violation: You cannot approve your own journal entry. "
                        "Please request approval from Finance Manager."
                    )
```

---

## 6. Audit Trail and Monitoring

### 6.1 Mandatory Audit Log Events

**All roles must generate audit logs for**:
- User login/logout (session tracking)
- Transaction creation/modification/deletion (before/after values)
- Master data changes (vendor, customer, employee, CoA)
- Permission changes (role assignments, group membership)
- Period lock/unlock operations
- Exception overrides and approvals
- Report generation and export (data exfiltration monitoring)

**Audit Log Retention**: 10 years (BIR statute of limitations + 2-year buffer)

### 6.2 Anomaly Detection Rules

**Automated alerts triggered for**:
- Transaction volume >3 standard deviations from 90-day moving average
- After-hours transaction posting (weekends, holidays, 10PM-6AM)
- Sequential transaction reversals (post → cancel → re-post pattern)
- Dormant account activity (no transactions in >180 days suddenly active)
- Round-number transactions (e.g., exactly ₱100,000.00 without centavos)
- Velocity checks (same user posting >50 transactions per hour)
- Geographic anomalies (IP address outside Philippines for onshore users)

**Alert Routing**:
- **Low severity**: Email to Finance Manager (daily digest)
- **Medium severity**: Real-time Mattermost notification to Finance Manager
- **High severity**: Immediate escalation to Finance Director + External Auditor notification

---

## 7. Role Assignment and Provisioning

### 7.1 New User Onboarding Workflow

```
1. HR submits access request (form includes: role, agency assignments, start date, manager approval)
   ↓
2. Finance Manager validates business justification
   ↓
3. IT provisions Odoo user account (minimum access: base.group_user)
   ↓
4. Finance Manager assigns security groups in Odoo
   ↓
5. System Admin creates Supabase RLS user record + agency assignments
   ↓
6. Finance Manager conducts role training (2-hour session covering SoD, policies, system usage)
   ↓
7. User signs attestation (understands SoD, confidentiality, fraud reporting)
   ↓
8. 30-day probation period (enhanced monitoring, daily supervisory review)
   ↓
9. Finance Manager approves full access activation
```

**Provisioning SLA**: ≤2 business days from HR request to account activation

### 7.2 Role Change Management

**Triggers for role reassignment**:
- Promotion/transfer
- Temporary coverage (leave, illness)
- Reorganization
- Performance issues requiring access restriction

**Change Process**:
1. Manager submits role change request with effective date
2. Finance Director approves (if role elevation) or Finance Manager approves (if lateral/reduction)
3. System Admin executes changes in Odoo + Supabase
4. Previous role access automatically revoked (no legacy permission accumulation)
5. Audit log entry created with change justification
6. User re-signs attestation for new role

**Emergency Access**: Finance Director can grant temporary elevated access for ≤48 hours (e.g., key person absence), requires post-approval justification and audit review.

---

## 8. Performance Metrics and KPIs

### 8.1 Role-Specific SLAs

| Role | Metric | Target | Measurement |
|------|--------|--------|-------------|
| **AP Clerk** | Invoice processing time | ≤2 days | Median days from receipt to approval-ready |
| **AR Clerk** | DSO | ≤45 days | (AR balance / daily sales) × days in period |
| **GL Accountant** | Reconciliation completion | 100% by Day 5 | % accounts reconciled by close deadline |
| **Fixed Asset Accountant** | Register accuracy | 100% (±₱1K) | Variance between asset register and GL |
| **Payroll Specialist** | Payroll accuracy | ≥99.9% | (Correct payslips / total payslips) × 100 |
| **Tax Compliance Officer** | Filing timeliness | 100% | % tax returns filed before statutory deadline |
| **Finance Manager** | Approval TAT | ≤4 hours | Median hours from request to approval/rejection |
| **Finance Director** | Close cycle time | ≤7 days | Days from month-end to financial statement sign-off |

### 8.2 Control Effectiveness Metrics

**Monthly Dashboard**:
- **SoD violation attempts**: Count of system-blocked conflict attempts
- **Compensating control execution rate**: % of required supervisory reviews completed on time
- **Audit finding closure rate**: % of prior audit findings remediated by target date
- **User access review completion**: % of quarterly user access recertifications completed
- **Training compliance**: % of users completing annual SoD refresher training

**Thresholds for Escalation**:
- **Green** (satisfactory): ≥95% compliance with all control metrics
- **Yellow** (monitoring): 85-94% compliance, requires corrective action plan
- **Red** (unsatisfactory): <85% compliance, triggers management review and potential external audit notification

---

## 9. Training and Competency

### 9.1 Mandatory Training Programs

**Role-Specific Training** (8 hours upon hire, 4 hours annual refresher):
- SoD framework and personal responsibilities
- Odoo system navigation and security features
- Fraud red flags and reporting procedures
- BIR compliance requirements (for relevant roles)
- Audit trail and documentation standards

**Scenario-Based Training**:
- Identifying and reporting SoD conflicts
- Handling exception approval requests
- Responding to audit inquiries
- Escalating suspicious transactions

**Competency Assessment**: Post-training quiz with 80% passing score (retake allowed, max 3 attempts)

### 9.2 Annual Attestation Requirements

**All finance roles must attest annually**:
- Understanding of SoD framework and own role boundaries
- No conflicts of interest (financial relationships with vendors/customers)
- Compliance with confidentiality and data protection policies
- Awareness of fraud reporting channels and whistleblower protections
- No knowledge of unreported control deficiencies or irregularities

**Attestation Timing**: Within 30 days of fiscal year-end (aligned with financial statement certification)

**Non-Compliance Consequences**: Failure to complete attestation triggers access suspension until remediated.

---

## 10. Governance and Policy Maintenance

### 10.1 Document Review Cycle

**Annual Review** (Finance Director ownership):
- SoD matrix alignment with organizational changes
- Role definition updates based on process improvements
- Authority limit adjustments for inflation and business growth
- RLS policy optimization based on audit findings
- KPI target recalibration based on industry benchmarks

**Quarterly Review** (Finance Manager ownership):
- User access recertification (remove terminated users, validate role assignments)
- Compensating control effectiveness assessment
- Anomaly detection rule tuning (reduce false positives)
- Training material updates

### 10.2 Change Approval Authority

| Change Type | Approver | Documentation Required |
|-------------|----------|------------------------|
| **Minor role definition clarification** | Finance Manager | Email approval + change log entry |
| **Authority limit adjustment (<20% change)** | Finance Director | Board memo with business justification |
| **New role creation** | Finance Director + Board | Board resolution + SoD impact assessment |
| **Major SoD framework restructure** | Board + External Auditor consultation | Comprehensive control impact analysis |
| **RLS policy modification** | Finance Manager (technical) + Finance Director (approval) | Security impact assessment + testing results |

### 10.3 External Audit Coordination

**Annual SoD Control Testing** (External Auditor scope):
- User access review (sample 25% of active users, validate role assignments match job descriptions)
- SoD conflict testing (identify any system-allowed prohibited combinations)
- Compensating control execution testing (validate supervisory reviews performed)
- Audit trail completeness testing (sample transactions, verify all required logs present)
- Management override testing (review all Finance Director period unlocks and exception approvals)

**Audit Deliverables**:
- Management letter with control deficiencies (if any)
- SoD compliance opinion (satisfactory / needs improvement / unsatisfactory)
- Recommended policy improvements

**Remediation Tracking**: All audit findings logged in `control_deficiency_tracker` table with target closure dates and responsible parties.

---

## 11. Appendix

### 11.1 Glossary of Terms

- **Maker-Checker**: Dual control requiring transaction originator different from approver
- **Materiality Threshold**: Transaction amount triggering enhanced approval requirements
- **Period Lock**: System control preventing modifications to closed accounting periods
- **RLS (Row-Level Security)**: Database-level access control restricting visible rows per user
- **SoD (Separation of Duties)**: Control framework segregating incompatible duties across different individuals

### 11.2 Related Documents

- `04-close-calendar-and-phases.md` - Detailed timeline for role task execution
- `11-change-management.md` - Governance framework for control changes
- `99-appendix-data-dictionary.md` - Technical data model and RLS policy DDL

### 11.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial 9-role SoD framework creation |

---

**Document Classification**: Internal - Governance
**Review Frequency**: Annual (or upon organizational restructure)
**Next Review Date**: 2026-01-31
**Approver**: Finance Director (signature required)

**End of Document**