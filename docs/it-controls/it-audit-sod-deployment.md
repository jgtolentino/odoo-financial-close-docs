# IT Audit & Segregation of Duties Deployment

**Document Version**: 2.0
**Last Updated**: 2025-12-29
**Owner**: Finance Director
**Classification**: Internal - IT Controls

---

## Executive Summary

This document extends the **9-role SoD framework** (see `03-roles-and-sod-matrix.md`) with **Spectra PF-specific conflict taxonomy**, compensating controls, and automated compliance workflows. It provides the operational blueprint for deploying IT audit controls across:

- **Spectra PF** (Financial Planning & Analysis system)
- **Odoo CE 18** (ERP - Accounting, Expenses, Payroll)
- **Banking Systems** (BDO, BPI cash management)

**Key Enhancements over Base SoD Framework**:
- Spectra PF conflict codes (P2P-001, GL-001, HR-001, etc.)
- Risk severity classification (Critical, High, Medium, Low) with remediation SLAs
- Compensating control tracking with testing schedules
- Quarterly/annual review workflows with RACI integration
- Cross-system conflict detection (Spectra ↔ Odoo ↔ Bank)

---

## 1. Spectra PF Conflict Taxonomy

### 1.1 Conflict Code Structure

**Format**: `{DOMAIN}-{SEQUENCE}`

**Domains**:
- **P2P**: Procure-to-Pay (vendor management, invoicing, payments)
- **GL**: General Ledger (journal entries, reconciliations, close)
- **HR**: Human Resources (payroll, employee master, benefits)
- **AR**: Accounts Receivable (customer invoicing, collections)
- **FA**: Fixed Assets (capitalization, depreciation, disposal)

### 1.2 Critical Conflicts (Spectra PF)

| Conflict Code | Incompatible Functions | Risk Level | Remediation SLA |
|---------------|------------------------|------------|-----------------|
| **P2P-001** | Vendor Master Maintenance + Vendor Invoice Approval | Critical | Immediate |
| **P2P-004** | Purchase Order Creation + Payment Execution | Critical | Immediate |
| **GL-001** | Journal Entry Posting + Bank Reconciliation | Critical | Immediate |
| **GL-004** | Period Close Execution + Period Unlock | Critical | Immediate |
| **HR-001** | Employee Master Maintenance + Payroll Processing | Critical | Immediate |

**Critical Conflict Definition**: Enables single-person fraud with material impact (>₱500,000 or >2% of revenue).

### 1.3 High-Risk Conflicts (Spectra PF)

| Conflict Code | Incompatible Functions | Risk Level | Remediation SLA |
|---------------|------------------------|------------|-----------------|
| **P2P-002** | Receiving Goods + Vendor Invoice Approval | High | 30 days |
| **P2P-005** | Vendor Selection + Contract Approval | High | 30 days |
| **GL-002** | Revenue Recognition + AR Aging Review | High | 30 days |
| **GL-005** | Expense Accrual + Budget Variance Analysis | High | 30 days |
| **HR-002** | Time Entry Approval + Payroll Review | High | 30 days |
| **FA-001** | Asset Acquisition Approval + Asset Tagging | High | 30 days |

**High-Risk Definition**: Enables fraud or error with moderate impact (₱100K-₱500K or 0.5-2% revenue).

### 1.4 Medium-Risk Conflicts (Spectra PF)

| Conflict Code | Incompatible Functions | Risk Level | Remediation SLA |
|---------------|------------------------|------------|-----------------|
| **P2P-003** | Invoice Data Entry + Supplier Payment Run | Medium | 90 days |
| **GL-003** | Chart of Accounts Maintenance + Financial Reporting | Medium | 90 days |
| **HR-003** | Leave Approval + Payroll Variance Review | Medium | 90 days |
| **AR-001** | Credit Limit Setting + Customer Invoice Posting | Medium | 90 days |
| **FA-002** | Depreciation Schedule Review + Asset Impairment Testing | Medium | 90 days |

**Medium-Risk Definition**: Limited fraud/error opportunity (₱25K-₱100K or 0.1-0.5% revenue), mitigated by existing controls.

### 1.5 Low-Risk Conflicts (Spectra PF)

| Conflict Code | Incompatible Functions | Risk Level | Remediation SLA |
|---------------|------------------------|------------|-----------------|
| **P2P-006** | Invoice Filing + Supplier Communication | Low | Next review cycle |
| **GL-006** | Report Generation + Report Distribution | Low | Next review cycle |
| **HR-004** | Employee Self-Service Access + HR Report Viewing | Low | Next review cycle |
| **AR-002** | Customer Statement Generation + Customer Inquiry Response | Low | Next review cycle |

**Low-Risk Definition**: Negligible fraud/error risk (<₱25K), primarily process efficiency concerns.

---

## 2. Cross-System Conflict Matrix

### 2.1 Spectra PF ↔ Odoo CE Conflicts

| User | Spectra PF Function | Odoo CE Function | Conflict Code | Risk Level |
|------|---------------------|------------------|---------------|------------|
| Jake (Finance Manager) | Budget approval | Journal entry posting | **GL-007** | High |
| AP Clerk | Vendor master (Spectra) | Vendor invoice approval (Odoo) | **P2P-001** | Critical |
| GL Accountant | GL reconciliation (Spectra) | GL reconciliation (Odoo) | **GL-008** | Medium |
| Payroll Specialist | Payroll entry (Spectra) | Payroll posting (Odoo) | **HR-005** | High |

**Mitigation Strategy**: Implement **cross-system conflict rules** in `odoo_ce/addons/ipai_platform_audit/models/audit_mixin.py`.

### 2.2 Odoo CE ↔ Banking System Conflicts

| User | Odoo Function | Banking Function | Conflict Code | Risk Level |
|------|---------------|------------------|---------------|------------|
| Finance Manager | Payment approval (Odoo) | Online banking transaction execution (BDO) | **P2P-009** | Critical |
| GL Accountant | Bank reconciliation (Odoo) | Bank statement download (BPI) | **GL-009** | Low |
| AP Clerk | Payment preparation (Odoo) | Check printing authorization | **P2P-010** | High |

**Mitigation Strategy**: Enforce **dual approval** for Odoo payments + banking execution (separate users).

---

## 3. Compensating Controls Framework

### 3.1 Compensating Control Structure

When conflicts **cannot be removed** due to headcount constraints, implement compensating controls with:

- **Description**: Specific control activity description
- **Frequency**: Daily, Weekly, Monthly, Quarterly
- **Responsible Person**: Role (from 9-role framework)
- **Evidence Produced**: Artifact name/location
- **Management Approval**: Finance Director sign-off
- **Residual Risk Acceptance**: Documented in control register
- **Testing Schedule**: Quarterly internal + annual external audit

### 3.2 Compensating Control Examples

#### Control CC-P2P-001: Vendor Master + Invoice Approval Conflict

**Conflict**: AP Clerk has both Spectra vendor master maintenance AND Odoo vendor invoice approval rights.

**Compensating Controls**:

| Control Activity | Frequency | Responsible | Evidence | Next Test Date |
|------------------|-----------|-------------|----------|----------------|
| **Supervisory review of new vendor additions** | Weekly | Finance Manager | `vendor_additions_review_log.xlsx` | 2026-01-15 |
| **Duplicate vendor detection report** | Monthly | GL Accountant | `duplicate_vendor_scan.pdf` | 2026-02-01 |
| **Invoice approval limit enforcement** (≤₱50K auto, >₱50K requires Finance Manager) | Daily (automated) | System | Odoo approval workflow logs | 2026-01-15 |
| **Quarterly vendor master audit** | Quarterly | External Auditor | `vendor_master_audit_Q1_2026.pdf` | 2026-04-15 |

**Residual Risk Assessment**: **Medium** (after controls, down from Critical)
**Finance Director Approval**: ✅ Approved 2025-01-15
**Next Annual Review**: 2026-01-31

#### Control CC-GL-001: Journal Entry + Reconciliation Conflict

**Conflict**: GL Accountant posts journal entries AND performs bank reconciliations.

**Compensating Controls**:

| Control Activity | Frequency | Responsible | Evidence | Next Test Date |
|------------------|-----------|-------------|----------|----------------|
| **Finance Manager review of all manual journal entries >₱100K** | Daily | Finance Manager | Odoo approval logs | 2026-01-15 |
| **Segregated bank reconciliation review** (Finance Manager re-performs 10% sample) | Monthly | Finance Manager | `bank_recon_review_Jan2026.xlsx` | 2026-02-05 |
| **Automated reconciliation discrepancy alerts** (>₱5K variance) | Daily (automated) | System | Mattermost alerts | 2026-01-15 |

**Residual Risk Assessment**: **Low** (after controls, down from Critical)
**Finance Director Approval**: ✅ Approved 2025-01-20
**Next Annual Review**: 2026-01-31

---

## 4. Quarterly & Annual Review Workflows

### 4.1 Quarterly User Access Review (Spectra PF)

**Trigger**: 1st business day of each quarter (Jan, Apr, Jul, Oct)

**Workflow**:

```
1. n8n Job: Export Spectra PF user list → Supabase staging table
   ↓
2. n8n Job: Compare vs HR roster → Flag terminated employees with active access
   ↓
3. n8n Job: Re-run SoD conflict scan → Detect new conflicts
   ↓
4. n8n Job: Generate review pack (Excel) → Email to Finance Manager
   ↓
5. Finance Manager: Certify access or request removals → Submit to IT Market Director
   ↓
6. IT Market Director: Execute removals in Spectra PF → Update audit log
   ↓
7. n8n Job: Close review period → Archive evidence in `docs/audit/Q{X}_2026/`
```

**Review Pack Contents** (Excel workbook):
- **Tab 1**: Active Spectra users vs HR roster (highlight mismatches)
- **Tab 2**: New conflicts detected since last quarter
- **Tab 3**: Terminated employees with active access (FLAG: red)
- **Tab 4**: Users with multiple high-risk roles (requires justification)

**RACI**:
- **Responsible**: IT Market Director (executes removals)
- **Accountable**: Finance Director (signs quarterly certification)
- **Consulted**: Finance Manager (reviews and certifies)
- **Informed**: Department Managers (notified of team access changes)

**Acceptance Criteria**:
- ✅ All terminated employees deactivated within 5 business days
- ✅ No Critical/High conflicts unresolved >30 days
- ✅ Quarterly certification signed by Finance Director
- ✅ Evidence pack archived in Supabase `audit_quarterly_review` table

### 4.2 Annual SoD Matrix Review

**Trigger**: 1st business day of February (after year-end close)

**Workflow**:

```
1. Finance Manager: Pull annual transaction data → Run conflict analysis
   ↓
2. Finance Manager: Review all compensating controls → Update effectiveness ratings
   ↓
3. Finance Manager: Prepare SoD matrix update memo → Submit to Finance Director
   ↓
4. Finance Director: Review SoD changes → Approve or request revisions
   ↓
5. Finance Director: Update role definitions (if needed) → Re-publish to team
   ↓
6. External Auditor: Conduct annual SoD testing → Issue management letter
   ↓
7. Finance Director: Remediate audit findings → Track in `control_deficiency_tracker`
```

**Annual Review Deliverables**:
- Updated SoD matrix (this document)
- Compensating control effectiveness report
- Conflict remediation tracker (open items with target dates)
- Management certification letter (Finance Director signature)

**RACI**:
- **Responsible**: Finance Manager (prepares review pack)
- **Accountable**: Finance Director (approves changes, signs certification)
- **Consulted**: External Auditor (validates SoD effectiveness)
- **Informed**: Board of Directors (annual governance report)

---

## 5. Odoo CE Integration (IT Audit Module)

### 5.1 Odoo Module: `ipai_platform_audit`

**Location**: `odoo_ce/addons/ipai_platform_audit/`

**Core Models**:

1. **`audit.sod_rule`** - SoD conflict definitions
   - `conflict_code` (P2P-001, GL-001, etc.)
   - `system` (Spectra PF, Odoo, Bank)
   - `risk_level` (Critical, High, Medium, Low)
   - `sla_days` (0 for Critical, 30/90 for High/Medium)
   - `function_a` + `function_b` (incompatible roles)

2. **`audit.compensating_control`** - Compensating controls
   - `sod_rule_id` (link to conflict)
   - `description`, `frequency`, `owner`, `evidence_location`
   - `test_frequency`, `next_test_date`
   - `residual_risk_level`, `director_approved_date`

3. **`audit.quarterly_review`** - Quarterly access review records
   - `period` (Q1 2026, Q2 2026, etc.)
   - `system` (Spectra PF, Odoo, Bank)
   - `status` (not_started, in_progress, completed)
   - `terminated_users_flagged`, `conflicts_detected`
   - `certification_signed_by`, `certification_date`

4. **`audit.annual_certification`** - Annual SoD certification
   - `fiscal_year`, `certification_date`, `signed_by`
   - `sod_matrix_version`, `external_auditor_opinion`
   - `open_findings_count`, `evidence_link`

### 5.2 Automated Workflows (n8n Integration)

**n8n Workflow**: `quarterly_spectra_access_review.json`

**Trigger**: Cron (1st day of Jan/Apr/Jul/Oct at 8 AM)

**Steps**:
1. **HTTP Request**: Export Spectra PF users (API call or manual upload)
2. **Supabase Insert**: Stage users in `spectra_user_staging` table
3. **Supabase RPC**: `rpc_detect_terminated_users()` → Flag mismatches
4. **Supabase RPC**: `rpc_scan_sod_conflicts()` → Detect conflicts
5. **Excel Generator**: Create review pack workbook
6. **Supabase Insert**: Store review pack in `audit_quarterly_review` table
7. **Mattermost Notify**: Alert Finance Manager with download link
8. **Task Creator**: Create Odoo task "Q1 2026 Spectra Access Review" → assign to Finance Manager

**Mattermost Alert Example**:
```
🔍 **Quarterly Spectra PF Access Review - Q1 2026**

📊 **Summary**:
- Active users: 45
- Terminated users with access: 3 (FLAG: red)
- New conflicts detected: 2 (1 High, 1 Medium)

📥 **Review Pack**: [Download Excel](https://supabase-link)

👤 **Action Required**: Finance Manager certification by 2026-01-10

🔗 **Odoo Task**: #TASK-12345
```

---

## 6. RACI Matrix for SoD Governance

### 6.1 Quarterly Access Review

| Activity | Finance Tech Lead | Finance Manager | Finance Director | IT Market Director | Dept Managers | Ext Auditor |
|----------|-------------------|-----------------|------------------|--------------------|--------------|-|
| **Run conflict analysis** | R | A | I | C | I | - |
| **Prepare review pack** | R | A | I | C | I | - |
| **Certify team access** | C | R | A | I | R | - |
| **Execute Spectra removals** | I | C | I | R, A | I | - |
| **Sign quarterly certification** | I | C | R, A | I | I | I |
| **Archive evidence** | R | A | I | C | I | - |

### 6.2 Annual SoD Matrix Review

| Activity | Finance Tech Lead | Finance Manager | Finance Director | IT Market Director | Ext Auditor |
|----------|-------------------|-----------------|------------------|--------------------|-------------|
| **Transaction data analysis** | R | A | I | C | - |
| **Control effectiveness assessment** | R | A | C | C | C |
| **SoD matrix update** | R | A | C | I | C |
| **Approve SoD changes** | I | C | R, A | I | C |
| **Conduct annual testing** | I | C | I | I | R, A |
| **Issue management letter** | I | C | R | I | R, A |
| **Remediate findings** | R | A | C | C | I |

**Legend**: R = Responsible, A = Accountable, C = Consulted, I = Informed

---

## 7. Metrics & KPIs

### 7.1 Compliance Metrics

| Metric | Target | Measurement | Reporting Frequency |
|--------|--------|-------------|---------------------|
| **Open Critical conflicts** | 0 | Count of unresolved Critical conflicts | Weekly |
| **Open High conflicts** | ≤2 | Count of unresolved High conflicts >30 days | Weekly |
| **Quarterly review completion** | 100% | % of quarters with signed certification | Quarterly |
| **Compensating control test completion** | 100% | % of scheduled tests executed on time | Quarterly |
| **Terminated user access removal** | ≤5 days | Days from termination to Spectra deactivation | Monthly |
| **Annual external audit opinion** | Unqualified | Auditor SoD opinion classification | Annual |

### 7.2 KPI Dashboard (Apache Superset)

**Dashboard**: "IT Audit & SoD Compliance"

**Charts**:
1. **Open Conflicts by Severity** (Pie chart: Critical/High/Medium/Low)
2. **Conflict Aging Trend** (Line chart: avg days open by month)
3. **Compensating Control Effectiveness** (Bar chart: % tests passed)
4. **Quarterly Review Status** (Gantt chart: completion timeline)
5. **User Access Hygiene** (Metric: % terminated users with active access)

**Target Metrics** (displayed as KPI cards):
- **Critical Conflicts**: 0 (red if >0)
- **High Conflicts >30d**: ≤2 (orange if >2)
- **Quarterly Certification**: 100% (green if all signed)
- **Audit Opinion**: Unqualified (red if Qualified/Adverse)

---

## 8. Implementation Roadmap

### Phase 1: Spectra PF Taxonomy Integration (2 weeks)

- [ ] Extend `audit.sod_rule` model with conflict codes
- [ ] Seed Spectra PF conflicts (P2P-001 to P2P-006, GL-001 to GL-006, etc.)
- [ ] Add risk_level + sla_days fields
- [ ] Create Odoo views for conflict management

### Phase 2: Compensating Controls (2 weeks)

- [ ] Create `audit.compensating_control` model
- [ ] Link to SoD rules
- [ ] Build testing schedule workflow
- [ ] Add evidence attachment capability

### Phase 3: Quarterly Review Automation (3 weeks)

- [ ] Create `audit.quarterly_review` model
- [ ] Build n8n workflow for Spectra user export
- [ ] Implement `rpc_detect_terminated_users()` RPC
- [ ] Implement `rpc_scan_sod_conflicts()` RPC
- [ ] Excel review pack generator
- [ ] Mattermost notifications

### Phase 4: Annual Certification (2 weeks)

- [ ] Create `audit.annual_certification` model
- [ ] Build SoD matrix update workflow
- [ ] External auditor collaboration interface
- [ ] Management letter tracking

### Phase 5: Superset Dashboard (1 week)

- [ ] Create "IT Audit & SoD Compliance" dashboard
- [ ] Publish to `superset.insightpulseai.net`
- [ ] Configure drill-down capabilities

**Total Duration**: 10 weeks
**Target Completion**: 2026-03-15

---

## 9. Acceptance Criteria

Before marking SoD deployment "complete", ALL criteria must pass:

- ✅ All Spectra PF conflicts cataloged with correct risk levels
- ✅ Compensating controls documented for unavoidable conflicts
- ✅ n8n quarterly review workflow tested end-to-end
- ✅ Q1 2026 review executed successfully
- ✅ Annual certification workflow functional
- ✅ Superset dashboard live with real data
- ✅ Finance Director sign-off on deployment

---

## 10. Appendix

### 10.1 Related Documents

- **03-roles-and-sod-matrix.md**: Base 9-role SoD framework
- **04-close-calendar-and-phases.md**: Task timeline integration
- **11-change-management.md**: Governance for SoD changes
- **Odoo Module README**: `odoo_ce/addons/ipai_platform_audit/README.md`

### 10.2 SQL Schema Samples

**Compensating Control Table**:
```sql
CREATE TABLE audit_compensating_control (
  id SERIAL PRIMARY KEY,
  sod_rule_id INT REFERENCES audit_sod_rule(id),
  description TEXT NOT NULL,
  frequency VARCHAR(20) CHECK (frequency IN ('daily', 'weekly', 'monthly', 'quarterly')),
  owner VARCHAR(50) NOT NULL,  -- Role from 9-role framework
  evidence_location TEXT,
  test_frequency VARCHAR(20),
  next_test_date DATE,
  residual_risk_level VARCHAR(10) CHECK (residual_risk_level IN ('critical', 'high', 'medium', 'low')),
  director_approved_date DATE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Quarterly Review Table**:
```sql
CREATE TABLE audit_quarterly_review (
  id SERIAL PRIMARY KEY,
  period VARCHAR(10) NOT NULL,  -- 'Q1 2026', 'Q2 2026', etc.
  system VARCHAR(50) CHECK (system IN ('Spectra PF', 'Odoo', 'Bank')),
  status VARCHAR(20) CHECK (status IN ('not_started', 'in_progress', 'completed')),
  terminated_users_flagged INT DEFAULT 0,
  conflicts_detected INT DEFAULT 0,
  certification_signed_by INT REFERENCES res_users(id),
  certification_date DATE,
  evidence_link TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 10.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial Spectra PF taxonomy |
| 2.0 | 2025-12-29 | Claude Code | Added compensating controls, quarterly workflows, RACI, Odoo integration |

---

**Document Classification**: Internal - IT Controls
**Review Frequency**: Quarterly (or upon conflict detection)
**Next Review Date**: 2026-04-01
**Approver**: Finance Director (signature required)

**End of Document**
