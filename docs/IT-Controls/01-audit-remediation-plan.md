# IT Audit 2025 - Remediation Plan

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owners**: Khalil (Finance Director) + Marvin (IT Market Director)
**Classification**: Internal - Governance
**Target Completion**: Q1 2026

---

## Executive Summary

This document provides the comprehensive remediation plan for findings from the IT Audit 2025. Each finding is tracked as an Odoo project task with structured subtasks following the **Design → Implement → Evidence → Close** workflow.

**Audit Response Project**: `IT Audit 2025 – Remediation`

### Finding Summary

| Finding Area | Count | Priority | Target Date |
|-------------|-------|----------|-------------|
| Physical Security | 4 | High | Q1 2026 |
| IT Asset Management | 3 | High | Q1 2026 |
| IT Access Management / SoD | 4 | Critical | Q1 2026 |
| GITC Controls | 2 | High | Q1 2026 |
| AI Training Compliance | 1 | Medium | Q1 2026 |

---

## 1. Physical Security Findings

### 1.1 Visitor Identification & Badge Process

**Audit Finding**: Inadequate visitor access controls at office premises.

**Control Objective**: Ensure all visitors are properly identified, badged, and escorted while on premises.

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 1.1.1 | Write 1-page SOP: visitor registration, badge issuance, visible wear, escort rules | Facilities Lead | One-time | SOP PDF |
| 1.1.2 | Implement visitor registration process at reception | Facilities Lead | Daily | Visitor log samples |
| 1.1.3 | Install signage for visitor protocols | Facilities Lead | One-time | Photo of signage |
| 1.1.4 | Monthly physical security review (visitor log + badges) | Facilities Lead | Monthly | Review checklist |

**Odoo Task Template**:
```
Project: IT Audit 2025 – Remediation
Task: Physical Security - Visitor Badge Process
Subtasks:
  - [Design] Draft visitor SOP
  - [Implement] Deploy registration process
  - [Evidence] Collect photos + sample logs
  - [Close] Finance Director sign-off
```

---

### 1.2 Key Register & Restricted Areas

**Audit Finding**: Missing formal key/access register for restricted areas.

**Control Objective**: Maintain auditable records of key issuance and access to restricted areas.

**Control Implementation**:

| Field | Description |
|-------|-------------|
| Key ID | Unique identifier for each physical key |
| Holder | Current assigned person |
| Area | Restricted area the key grants access to |
| Request Log | Date and approval of key request |
| Reason | Business justification for access |
| Return Date | Date key was returned (if applicable) |

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 1.2.1 | Create key/access register spreadsheet | Facilities Lead | One-time | Register template |
| 1.2.2 | Populate register with current key assignments | Facilities Lead | One-time | Completed register |
| 1.2.3 | Update & review key register | Facilities Lead | Monthly | Updated register + review notes |

---

### 1.3 CCTV Access for Local IT

**Audit Finding**: Local IT staff lack read-only CCTV access for security monitoring.

**Control Objective**: Enable IT staff to review CCTV footage for security incident investigation.

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 1.3.1 | Submit request to OMC Physical Security for local read-only CCTV access | IT Market Director | One-time | Request email |
| 1.3.2 | Receive confirmation of access provisioning | IT Market Director | One-time | Confirmation email from OMC |
| 1.3.3 | Verify access to CCTV console | Local IT Lead | One-time | Screenshot of console access |

---

### 1.4 MDF Room & Clean Desk Policy

**Audit Finding**: Cardboard storage in MDF room; inconsistent clean desk practice.

**Control Objective**: Maintain secure, organized data center and office environment.

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 1.4.1 | Remove cardboard from MDF; replace with plastic storage | IT Market Director | One-time | Before/after photos |
| 1.4.2 | Implement clean desk policy | HR Manager | One-time | Policy document |
| 1.4.3 | Quarterly clean-desk walkthrough + reminder email to staff | Facilities Lead | Quarterly | Walkthrough checklist + email copy |

---

## 2. IT Asset Management Findings

### 2.1 Standard Asset Attributes

**Audit Finding**: Missing ownership, criticality, and lifecycle data for IT assets.

**Control Objective**: Maintain comprehensive asset records with standard attributes.

**Required Fields for All Assets**:

| Field | Description | Required |
|-------|-------------|----------|
| Asset ID | Unique identifier | Yes |
| Owner | Assigned employee/department | Yes |
| Location | Physical/logical location | Yes |
| Criticality | Business criticality (High/Medium/Low) | Yes |
| Status | Active/Not In Use/Disposed | Yes |
| Issued Date | Date asset was issued | Yes |
| Return Date | Date asset was returned | Conditional |
| Reassigned Date | Date asset changed hands | Conditional |
| Wiped Date | Date data wipe completed | Conditional |

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 2.1.1 | Update local Excel/Sheet with required fields | IT Asset Manager | One-time | Updated template |
| 2.1.2 | Mirror fields in ServiceNow CMDB | IT Asset Manager | One-time | CMDB field configuration |
| 2.1.3 | Populate existing assets with new attributes | IT Asset Manager | One-time | Completed inventory |

---

### 2.2 Quarterly Asset Reconciliation

**Audit Finding**: No formal reconciliation between CMDB, local records, and physical storage.

**Control Objective**: Ensure asset records are accurate and complete through regular reconciliation.

**Reconciliation Procedure**:

1. Export ServiceNow CMDB asset list
2. Compare with local Excel/Sheet inventory
3. Physically verify "Not In Use" storage items
4. Document discrepancies
5. Remediate gaps
6. Sign reconciliation sheet

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 2.2.1 | Create reconciliation procedure document | IT Asset Manager | One-time | Procedure SOP |
| 2.2.2 | Quarterly asset reconciliation (ServiceNow vs Local vs Storage) | IT Asset Manager | Quarterly | Diff report + signed reconciliation sheet |

**Odoo Recurring Task**:
```
Task: Quarterly Asset Reconciliation
Recurrence: Every 3 months
Owner: IT Asset Manager
Checklist:
  - [ ] Export ServiceNow list
  - [ ] Export local inventory
  - [ ] Physical verification of storage
  - [ ] Document discrepancies
  - [ ] Remediate and update records
  - [ ] Sign reconciliation sheet
```

---

### 2.3 Lifecycle Tracking

**Audit Finding**: No tracking of asset lifecycle events (issue, return, reassign, wipe).

**Control Objective**: Maintain complete lifecycle history for all IT assets.

**Lifecycle Events**:

| Event | Trigger | Required Documentation |
|-------|---------|----------------------|
| Issued | New employee or replacement | Issue form + recipient signature |
| Returned | Employee departure or upgrade | Return form + condition assessment |
| Reassigned | Asset transferred between users | Transfer form + both signatures |
| Wiped | Prior to disposal or reissue | Wipe confirmation certificate |
| Disposed | End of life | Disposal certificate + method |

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 2.3.1 | Add lifecycle date fields to inventory | IT Asset Manager | One-time | Updated template |
| 2.3.2 | Implement "Device wipe confirmation" checkbox requirement before disposal | IT Asset Manager | One-time | Workflow documentation |
| 2.3.3 | Backfill lifecycle dates for existing assets | IT Asset Manager | One-time | Updated inventory |

---

## 3. IT Access Management & SoD Matrix

### 3.1 Formal SoD Matrix Creation

**Audit Finding**: No formal SoD matrix mapping roles to systems and identifying conflicts.

**Control Objective**: Establish single source of truth for segregation of duties.

**Matrix Structure**:

| Column | Description |
|--------|-------------|
| Process | Business process (e.g., GL Journals, Vendor Master, Payroll) |
| Risk | Risk being mitigated (e.g., post unapproved JE) |
| Role Code | R1-R9 from role framework |
| Role Name | Human-readable role name |
| System | Application (Mediaocean, Odoo, AD, ServiceNow, Banking) |
| Allowed Permissions | What the role CAN do |
| Forbidden Combinations | Conflicting role pairs |
| Compensating Control | Mitigation if conflict exists |
| Review Frequency | Quarterly/Annually |

**Reference**: See [SoD Matrix CSV](./sod-matrix.csv) and [03-roles-and-sod-matrix.md](../03-roles-and-sod-matrix.md)

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 3.1.1 | Build SoD matrix artifact (CSV + markdown) | Finance Director | One-time | Matrix file |
| 3.1.2 | Validate matrix against actual system configurations | IT Market Director | One-time | Validation report |
| 3.1.3 | Publish matrix to docs site | IT Market Director | One-time | Published URL |

---

### 3.2 Role-to-Person Mapping

**Audit Finding**: No mapping of SoD roles to actual personnel.

**Control Objective**: Maintain current mapping of roles to staff members.

**Mapping Structure**:

| Field | Description |
|-------|-------------|
| role_code | Role identifier (R1-R9) |
| role_name | Role description |
| person_name | Staff member name |
| email | Staff email address |
| systems_assigned | Comma-separated list of systems |
| effective_date | When assignment became effective |
| reviewed_date | Last review date |

**Reference**: See [Role Assignments CSV](./role-assignments.csv)

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 3.2.1 | Create role-to-person mapping CSV | Finance Director | One-time | Mapping file |
| 3.2.2 | Validate against HR roster | HR Manager | Quarterly | Validation checklist |

---

### 3.3 Annual SoD Review Process

**Control Objective**: Ensure SoD matrix remains accurate and conflicts are remediated.

**Odoo Recurring Task**:
```
Task: Annual SoD Matrix Review & Sign-off
Recurrence: Annually (January)
Owners: Finance Director + IT Market Director
Deliverables:
  - [ ] Updated SoD matrix
  - [ ] Sign-off PDF
  - [ ] List of remediated conflicts
  - [ ] Training completion records
```

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 3.3.1 | Conduct annual SoD matrix review | Finance Director | Annually | Review minutes |
| 3.3.2 | Document remediated conflicts | Finance Director | Annually | Conflict resolution log |
| 3.3.3 | Obtain sign-off from stakeholders | Finance Director | Annually | Signed attestation |

---

### 3.4 Access Review Integration with GITC

**Control Objective**: Link SoD review to GITC quarterly access review process.

**IT S05 (Quarterly User Access Review) Requirements**:

| Artifact | Source | Purpose |
|----------|--------|---------|
| HR Roster Export | HRIS | Validate active employees |
| Network/AD Access List | Active Directory | Current system access |
| SoD Matrix Reference | This document | Identify conflicts |
| Signed Review Form | Reviewer | Attestation of review |

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 3.4.1 | Create access review procedure document | IT Market Director | One-time | Procedure SOP |
| 3.4.2 | Quarterly user access review | IT Market Director | Quarterly | Review package |
| 3.4.3 | Archive access review in Month-End/Year-End close task | Finance Manager | Quarterly | Archived package |

---

## 4. GITC Controls (IT S01, IT S05)

### 4.1 Standard Test Checklist

**Audit Finding**: "YES" recorded where evidence was insufficient.

**Control Objective**: Ensure consistent, evidence-based control testing.

**IT S01 (Account Creation) Required Evidence**:

| Evidence Item | Source | Retention |
|--------------|--------|-----------|
| HR request/email with supervisor approval | Email/ITSM | 3 years |
| Proof of IT security policies delivery | LMS/Email | 3 years |
| Training completion certificate | LMS | 3 years |
| Account creation confirmation | AD/Odoo | 3 years |

**IT S05 (Access Review) Required Evidence**:

| Evidence Item | Source | Retention |
|--------------|--------|-----------|
| HR roster (active employees) | HRIS | 3 years |
| ACL / system access list | AD/Applications | 3 years |
| Signed review/approval sheet | Reviewer | 3 years |
| Remediation log (if gaps found) | Reviewer | 3 years |

---

### 4.2 Evidence Sufficiency Rule

**Local Rule**: SBOX answer MUST be "NO + RAP (Remediation Action Plan)" if all required evidence artifacts aren't attached.

**GITC Testing Decision Tree**:

```
Is all required evidence available?
├── YES → Is evidence from the correct period?
│         ├── YES → Is evidence complete and legible?
│         │         ├── YES → Answer: YES (compliant)
│         │         └── NO  → Answer: NO + RAP
│         └── NO  → Answer: NO + RAP
└── NO  → Answer: NO + RAP
```

---

### 4.3 GITC Testing Playbook

**Reference**: See [GITC Testing Playbook](./02-gitc-testing-playbook.md)

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 4.3.1 | Create GITC Testing Playbook (1-2 pages) | IT Market Director | One-time | Playbook document |
| 4.3.2 | Train IT staff on evidence requirements | IT Market Director | One-time | Training attendance |
| 4.3.3 | Quarterly GITC evidence pack preparation | IT Market Director | Quarterly | Evidence package |

**Odoo Recurring Task**:
```
Task: Quarterly GITC Evidence Pack Preparation (IT S01, IT S05)
Recurrence: Every 3 months
Owner: IT Market Director
Checklist:
  - [ ] Collect IT S01 evidence (new accounts)
  - [ ] Collect IT S05 evidence (access review)
  - [ ] Validate evidence completeness
  - [ ] Archive in designated location
  - [ ] Update SBOX responses
```

---

## 5. AI Training Compliance

### 5.1 Training Gap Analysis

**Audit Finding**: 30% of staff hadn't completed mandatory Global AI risk e-learning.

**Control Objective**: Achieve 100% AI training compliance before granting access to AI tools.

---

### 5.2 HR Control Implementation

**Blocking Rule**: No access to generative AI tools without completed AI risk training.

**Remediation Actions**:

| # | Task | Owner | Frequency | Evidence Required |
|---|------|-------|-----------|-------------------|
| 5.2.1 | Generate monthly HR report with training status | HR Manager | Monthly | Training status report |
| 5.2.2 | Send reminder emails to overdue personnel | HR Manager | Monthly | Email copies |
| 5.2.3 | Review and escalate non-compliant cases | HR Manager | Monthly | Escalation log |
| 5.2.4 | Disable AI tool access for non-compliant users | IT Market Director | As needed | Access change records |

**Odoo Recurring Task**:
```
Task: Monthly AI Training Compliance Review
Recurrence: Monthly
Owner: HR Manager
Checklist:
  - [ ] Export LMS training status report
  - [ ] Identify overdue personnel
  - [ ] Send reminder emails
  - [ ] Escalate to managers (if >30 days overdue)
  - [ ] Coordinate with IT for access restrictions
  - [ ] Archive evidence
```

---

## 6. Implementation Tracking

### 6.1 Odoo Project Structure

**Project**: IT Audit 2025 – Remediation

**Stages**:
1. **Backlog** - Tasks awaiting assignment
2. **In Design** - Control design in progress
3. **In Implementation** - Control being implemented
4. **Evidence Collection** - Gathering proof of implementation
5. **Review** - Finance Director/IT Director review
6. **Closed** - Remediated and verified

**Tags**:
- `physical-security`
- `asset-management`
- `access-management`
- `sod`
- `gitc`
- `ai-training`

---

### 6.2 Progress Dashboard

| Finding Area | Design | Implement | Evidence | Closed | Overall |
|-------------|--------|-----------|----------|--------|---------|
| Physical Security | ⬜ | ⬜ | ⬜ | ⬜ | 0% |
| IT Asset Management | ⬜ | ⬜ | ⬜ | ⬜ | 0% |
| IT Access / SoD | ⬜ | ⬜ | ⬜ | ⬜ | 0% |
| GITC Controls | ⬜ | ⬜ | ⬜ | ⬜ | 0% |
| AI Training | ⬜ | ⬜ | ⬜ | ⬜ | 0% |

*Update this dashboard as tasks progress through stages.*

---

### 6.3 Evidence Repository

**Location**: SharePoint / Odoo Documents

**Folder Structure**:
```
IT-Audit-2025-Remediation/
├── 01-Physical-Security/
│   ├── Visitor-SOP.pdf
│   ├── Key-Register.xlsx
│   ├── CCTV-Access-Confirmation.pdf
│   └── Clean-Desk-Evidence/
├── 02-Asset-Management/
│   ├── Asset-Inventory.xlsx
│   ├── Reconciliation-Reports/
│   └── Lifecycle-Evidence/
├── 03-Access-SoD/
│   ├── SoD-Matrix.csv
│   ├── Role-Assignments.csv
│   ├── Access-Review-Reports/
│   └── Conflict-Remediation/
├── 04-GITC/
│   ├── Testing-Playbook.pdf
│   ├── IT-S01-Evidence/
│   └── IT-S05-Evidence/
└── 05-AI-Training/
    ├── Training-Reports/
    └── Compliance-Evidence/
```

---

## 7. Audit Response Timeline

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Remediation Plan Approved | 2025-02-15 | ⬜ Pending |
| Physical Security Complete | 2025-03-31 | ⬜ Pending |
| Asset Management Complete | 2025-03-31 | ⬜ Pending |
| SoD Matrix Published | 2025-02-28 | ⬜ Pending |
| GITC Playbook Complete | 2025-02-28 | ⬜ Pending |
| AI Training 100% | 2025-03-31 | ⬜ Pending |
| Final Evidence Package | 2025-04-15 | ⬜ Pending |
| Internal Audit Follow-up | 2025-04-30 | ⬜ Pending |

---

## Appendix A: Control Templates

### A.1 Standard Control Documentation Template

```markdown
## Control: [Control Name]

**Control ID**: [Unique ID]
**Control Objective**: [What the control aims to achieve]
**Risk Addressed**: [Risk being mitigated]

### Control Description
[Detailed description of the control activity]

### Control Owner
- **Primary**: [Name, Title]
- **Backup**: [Name, Title]

### Frequency
[Daily / Weekly / Monthly / Quarterly / Annually / Event-driven]

### Evidence Requirements
| Evidence Item | Source | Format | Retention |
|--------------|--------|--------|-----------|
| | | | |

### Testing Procedure
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Exceptions and Escalation
[How to handle exceptions]

### Related Documents
- [Link to SOP]
- [Link to form template]
```

---

## Appendix B: Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial remediation plan creation |

---

**Document Classification**: Internal - Governance
**Review Frequency**: Quarterly (during remediation) / Annually (post-completion)
**Next Review Date**: 2025-04-30
**Approvers**: Finance Director, IT Market Director
