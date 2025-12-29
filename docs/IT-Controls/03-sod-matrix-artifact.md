# SoD Matrix Artifact

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director + IT Market Director
**Classification**: Internal - Governance

---

## Overview

This document provides the formal Separation of Duties (SoD) matrix mapping roles to systems and identifying conflicts. This is the **single source of truth** for SoD controls referenced by:

- IT Audit 2025 Remediation
- GITC Controls (IT S05)
- Annual SoD Review Process
- Odoo RBAC Configuration

**Data Files**:
- [SoD Matrix CSV](./sod-matrix.csv) - Machine-readable conflict matrix
- [Role Assignments CSV](./role-assignments.csv) - Current staff assignments

---

## Role Code Reference

| Code | Role Name | Reporting To |
|------|-----------|--------------|
| R1 | AP Clerk | Finance Manager |
| R2 | AR Clerk | Finance Manager |
| R3 | GL Accountant | Finance Manager |
| R4 | Fixed Asset Accountant | Finance Manager |
| R5 | Payroll Specialist | Finance Manager |
| R6 | Tax Compliance Officer | Finance Manager |
| R7 | Finance Manager | Finance Director |
| R8 | Finance Director | Executive/Board |
| R9 | External Auditor | Independent |
| IT | IT Market Director | Managing Director |

---

## Critical SoD Conflicts

### Prohibited Role Combinations

The following role combinations are **strictly prohibited** and must never be assigned to the same person:

| Conflict ID | Role A | Role B | Risk | Severity |
|-------------|--------|--------|------|----------|
| SOD-001 | AP Clerk (R1) | Vendor Master Maintenance | Fictitious vendor creation | Critical |
| SOD-002 | AR Clerk (R2) | Customer Master Maintenance | Revenue manipulation | Critical |
| SOD-003 | GL Accountant (R3) | Payment Approval | Unauthorized fund transfer | Critical |
| SOD-004 | Payroll Specialist (R5) | Employee Master Maintenance | Ghost employee fraud | Critical |
| SOD-005 | Tax Officer (R6) | Tax Return Signing | Unapproved tax positions | High |
| SOD-006 | Finance Manager (R7) | Period Unlock (without FD approval) | Backdated manipulation | High |
| SOD-007 | Any Role | Own Transaction Approval | Maker-checker violation | Critical |

---

## System-Role Permission Matrix

### Odoo ERP

| Permission | R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 |
|------------|----|----|----|----|----|----|----|----|----|----|
| View Transactions | R | R | R | R | R | R | R | R | R |
| Create Draft Bills | W | - | R | - | - | - | W | W | - |
| Create Invoices | - | W | R | - | - | - | W | W | - |
| Post Journal Entries | - | - | W | - | - | W | W | W | - |
| Approve Transactions | - | - | - | - | - | - | A | A | - |
| Manage Chart of Accounts | - | - | W | - | - | - | W | W | - |
| Create Vendors/Customers | - | - | - | - | - | - | W | W | - |
| Process Payroll | - | - | - | - | W | - | A | A | - |
| Manage Fixed Assets | - | - | R | W | - | - | A | A | - |
| Lock/Unlock Periods | - | - | - | - | - | - | L | U | - |
| System Administration | - | - | - | - | - | - | L | F | - |

**Legend**: R = Read, W = Write, A = Approve, L = Limited, U = Unlimited, F = Full

### Active Directory / Network

| Permission | R1-R6 | R7 | R8 | IT |
|------------|-------|----|----|------|
| Standard User Access | Y | Y | Y | Y |
| Group Policy Modification | - | - | - | Y |
| User Provisioning | - | - | - | Y |
| Password Reset | - | L | L | Y |
| Admin Group Membership | - | - | - | Y |

### Banking Portal

| Permission | R1 | R2 | R3 | R7 | R8 |
|------------|----|----|----|----|----|----|
| View Statements | - | - | R | R | R |
| Initiate Transfers | - | - | - | W | W |
| Approve Transfers | - | - | - | A1 | A2 |
| Manage Beneficiaries | - | - | - | W | A |

**Note**: A1 = First Approver, A2 = Second Approver (dual control)

### ServiceNow CMDB

| Permission | IT Asset Mgr | IT Director | R7 | R8 |
|------------|--------------|-------------|----|----|
| View Assets | Y | Y | Y | Y |
| Create/Modify Assets | Y | Y | - | - |
| Approve Changes | - | Y | - | - |
| Run Reports | Y | Y | Y | Y |

---

## Compensating Controls

When a SoD conflict is unavoidable (e.g., small team size), the following compensating controls must be implemented:

### For Small Teams (<10 Finance Staff)

| Conflict | Compensating Control | Evidence Required |
|----------|---------------------|-------------------|
| Combined AP/Vendor roles | Monthly supervisory review of all vendor additions | Signed review sheet |
| Combined GL/Payment roles | Dual signature for all payments | Bank statements showing dual approval |
| Combined Payroll/HR access | HR roster reconciliation before each payroll | Reconciliation report |

### Enhanced Monitoring Requirements

1. **Weekly Review**: Finance Manager reviews all transactions by conflict-pair roles
2. **System Alerts**: Automated notification for transactions by combined-role users
3. **Rotation**: Rotate conflicting duties every 6 months
4. **Escalation**: Any anomaly triggers immediate Finance Director review

---

## Current Role Assignments

### Finance Department

| Role | Assigned To | Systems | Effective |
|------|-------------|---------|-----------|
| Finance Director (R8) | Khalil Ibrahim | All Systems | 2021-06-01 |
| Finance Manager (R7) | Jerald Lim | Odoo Full, Bank, ServiceNow | 2022-01-15 |
| GL Accountant (R3) | Rey Gonzales | Odoo GL, Bank Portal | 2023-06-01 |
| GL Accountant (R3) | Beng Reyes | Odoo GL, Bank Portal | 2023-08-15 |
| Fixed Asset Accountant (R4) | Sally Mendoza | Odoo Assets | 2024-03-01 |
| Payroll Specialist (R5) | Cliff Aquino | Odoo Payroll, HRIS | 2023-05-01 |
| Tax Compliance Officer (R6) | Jake Torres | Odoo Accounting, eFPS | 2023-04-01 |
| AR Clerk (R2) | Jinky Cruz | Odoo AR | 2024-02-01 |
| AP Clerk (R1) | Amor Santos | Odoo AP | 2024-01-15 |

### IT Department

| Role | Assigned To | Systems | Effective |
|------|-------------|---------|-----------|
| IT Market Director | Marvin Ramos | AD Admin, ServiceNow Admin | 2022-03-01 |
| IT Asset Manager | TBD (Pending) | ServiceNow, Asset Tracker | 2025-01-01 |

---

## Review and Attestation

### Quarterly Access Review (IT S05)

**Process**:
1. Export HR active employee roster
2. Export system access lists (AD, Odoo, Banking)
3. Cross-reference with SoD matrix for conflicts
4. Document any exceptions with compensating controls
5. Sign attestation form
6. Archive evidence package

**Due Dates**: Q1 (April 15), Q2 (July 15), Q3 (October 15), Q4 (January 15)

### Annual SoD Matrix Review

**Process**:
1. Review matrix for accuracy against current org structure
2. Validate all role assignments against HR records
3. Identify any unmitigated conflicts
4. Update compensating controls as needed
5. Obtain Finance Director + IT Director sign-off
6. Update this document

**Due Date**: January 31 each year

---

## Conflict Resolution Log

| Date | Conflict ID | Description | Resolution | Approved By |
|------|-------------|-------------|------------|-------------|
| 2025-01-29 | N/A | Initial matrix creation | N/A - Baseline | Khalil Ibrahim |

---

## Appendix: SoD Matrix Data Schema

### sod-matrix.csv Structure

| Column | Type | Description |
|--------|------|-------------|
| process | string | Business process name |
| risk | string | Risk being mitigated |
| role_code | string | Role identifier (R1-R9, IT) |
| role_name | string | Human-readable role name |
| system | string | Application/system |
| allowed_permissions | string | What the role CAN do |
| forbidden_combinations | string | Conflicting actions/roles |
| compensating_control | string | Mitigation if conflict exists |
| review_frequency | string | How often to review |

### role-assignments.csv Structure

| Column | Type | Description |
|--------|------|-------------|
| role_code | string | Role identifier |
| role_name | string | Role description |
| person_name | string | Staff member name |
| email | string | Staff email |
| department | string | Department name |
| systems_assigned | string | Comma-separated systems |
| effective_date | date | When assignment started |
| reviewed_date | date | Last review date |
| status | string | Active/Inactive/Pending |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial SoD matrix creation |

---

**Document Classification**: Internal - Governance
**Review Frequency**: Annually
**Next Review Date**: 2026-01-31
**Approvers**: Finance Director, IT Market Director
