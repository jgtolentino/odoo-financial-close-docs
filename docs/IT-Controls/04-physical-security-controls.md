# Physical Security Controls

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Facilities Lead + IT Market Director
**Classification**: Internal - Operations

---

## Overview

This document defines the physical security controls for office premises and IT infrastructure areas. These controls address findings from the IT Audit 2025 related to visitor management, access control, CCTV monitoring, and clean desk practices.

---

## 1. Visitor Management

### 1.1 Control Objective

Ensure all visitors are properly identified, registered, badged, and escorted while on company premises.

### 1.2 Visitor Registration Process

```
Visitor Arrives
       │
       ▼
Reception Greets & Verifies ID
       │
       ▼
Complete Visitor Registration Form
  - Full name
  - Company/Organization
  - Purpose of visit
  - Host employee name
  - Time in
       │
       ▼
Issue Visitor Badge
  - Date printed
  - Visitor type (Client/Vendor/Guest)
  - Expiry (end of day)
       │
       ▼
Contact Host for Escort
       │
       ▼
Host Escorts Visitor at All Times
       │
       ▼
On Departure:
  - Record time out
  - Collect badge
  - Return any temporary access devices
```

### 1.3 Visitor Badge Types

| Badge Type | Color | Access Level | Escort Required |
|------------|-------|--------------|-----------------|
| Client | Blue | Public areas only | Yes |
| Vendor | Orange | Work area with escort | Yes |
| Contractor | Yellow | Designated project areas | First visit only |
| VIP | White | Executive areas | No (with prior approval) |

### 1.4 Visitor Log Fields

| Field | Description | Required |
|-------|-------------|----------|
| Date | Visit date | Yes |
| Visitor Name | Full legal name | Yes |
| Organization | Company or affiliation | Yes |
| ID Type/Number | Government ID reference | Yes |
| Purpose | Reason for visit | Yes |
| Host | Employee hosting the visit | Yes |
| Time In | Arrival time | Yes |
| Time Out | Departure time | Yes |
| Badge Number | Assigned badge number | Yes |
| Signature | Visitor acknowledgment | Yes |

### 1.5 Monthly Review Process

**Task**: Monthly Physical Security Review (Visitor Log + Badges)

**Frequency**: Monthly (by 5th business day of following month)

**Procedure**:
1. Export visitor log for the month
2. Verify all entries are complete (no blank fields)
3. Reconcile badge issuance vs. returns
4. Identify any badges not returned
5. Report exceptions to IT Market Director
6. Archive log and review notes

**Evidence Required**:
- Visitor log export (PDF)
- Badge reconciliation count
- Exception report (if any)
- Reviewer signature

---

## 2. Key and Access Control

### 2.1 Control Objective

Maintain auditable records of physical key issuance and access to restricted areas.

### 2.2 Restricted Areas

| Area | Security Level | Key Type | Access Approved By |
|------|---------------|----------|-------------------|
| Main Data Center (MDF) | Critical | Physical key + badge | IT Market Director |
| Server Room | High | Physical key + badge | IT Market Director |
| Finance Records Room | High | Physical key | Finance Manager |
| Executive Offices | Medium | Physical key | Office Manager |
| Storage / Archives | Low | Physical key | Facilities Lead |

### 2.3 Key Register Structure

| Field | Description |
|-------|-------------|
| Key ID | Unique identifier (format: AREA-NNN) |
| Area | Room/area the key grants access to |
| Key Holder | Current assigned person |
| Issue Date | Date key was issued |
| Request Reference | ITSM ticket or email reference |
| Approver | Manager who approved access |
| Return Date | Date key was returned (if applicable) |
| Reason for Access | Business justification |
| Status | Issued / Returned / Lost / Replaced |

### 2.4 Key Request Process

1. Employee submits request via ITSM or email
   - Specify area needing access
   - Provide business justification
   - Indicate expected duration (permanent/temporary)

2. Facilities Lead verifies:
   - Employee is active in HR system
   - Request is for valid restricted area
   - Justification is reasonable

3. Approving Manager reviews:
   - For MDF/Server Room: IT Market Director
   - For Finance areas: Finance Manager
   - For General areas: Department Manager

4. Upon approval:
   - Facilities Lead issues key
   - Updates key register
   - Provides area access rules to employee

5. Key holder responsibilities:
   - Never duplicate keys
   - Report lost keys immediately
   - Return upon role change or termination

### 2.5 Key Register Review

**Task**: Monthly Key Register Update & Review

**Frequency**: Monthly

**Procedure**:
1. Cross-reference key holders against HR active roster
2. Identify any keys held by terminated employees
3. Verify all issued keys are accounted for
4. Update register with any changes
5. Report exceptions for immediate remediation

---

## 3. MDF / Server Room Security

### 3.1 Control Objective

Maintain a secure, organized data center environment free from fire hazards and unauthorized materials.

### 3.2 MDF Room Standards

| Requirement | Standard | Current Status |
|-------------|----------|----------------|
| Flooring | Raised floor or solid (no carpet) | Compliant |
| Fire suppression | FM-200 or equivalent | Compliant |
| Temperature | 18-27°C (64-80°F) | Monitored |
| Humidity | 40-60% RH | Monitored |
| Storage containers | Plastic or metal only (no cardboard) | In remediation |
| Cable management | Labeled, organized, documented | Compliant |
| Access log | Electronic badge reader | Compliant |

### 3.3 Prohibited Items in MDF

- Cardboard boxes or paper packaging
- Food and beverages
- Personal items not required for work
- Flammable materials
- Unsealed liquids
- Non-essential equipment

### 3.4 MDF Access Procedure

1. Request access via IT Market Director
2. Sign MDF access log (purpose, time)
3. Badge in at door reader
4. Perform authorized work only
5. Badge out when leaving
6. Log completion of work

---

## 4. CCTV Monitoring

### 4.1 Control Objective

Enable local IT staff to review CCTV footage for security incident investigation and monitoring.

### 4.2 CCTV Coverage Areas

| Location | Camera Type | Retention | Local Access |
|----------|-------------|-----------|--------------|
| Main entrance | PTZ | 90 days | Read-only |
| Reception | Fixed | 90 days | Read-only |
| Server room entrance | Fixed | 180 days | Read-only |
| MDF room | Fixed | 180 days | Read-only |
| Emergency exits | Fixed | 90 days | Read-only |
| Parking area | PTZ | 30 days | Read-only |

### 4.3 CCTV Access Request

**For Local IT Read-Only Access**:

1. IT Market Director submits request to OMC Physical Security
2. Specify:
   - Personnel requiring access
   - Business justification
   - Areas requiring visibility
3. OMC reviews and provisions access
4. Local IT receives credentials and console access
5. Annual revalidation required

**Access Responsibilities**:
- View only for security monitoring purposes
- No recording or exporting without authorization
- Report any suspicious activity observed
- Maintain confidentiality of footage

---

## 5. Clean Desk Policy

### 5.1 Control Objective

Protect sensitive information by ensuring work areas are cleared of confidential materials when unattended.

### 5.2 Clean Desk Requirements

**At End of Each Day**:

| Area | Requirement | Applies To |
|------|-------------|------------|
| Desk surface | Clear of all documents | All employees |
| Computer screen | Locked or logged off | All employees |
| Filing cabinets | Locked | All employees |
| Whiteboards | Erased or covered | Meeting rooms |
| Printers/copiers | No documents left | All areas |
| Trash/recycling | Sensitive docs shredded | All employees |

**When Leaving Desk (Even Briefly)**:

- Lock computer (Win+L or Ctrl+Cmd+Q)
- Flip over or cover sensitive documents
- Remove from visible display

### 5.3 Sensitive Information Categories

| Category | Examples | Handling |
|----------|----------|----------|
| Financial | Budgets, forecasts, bank details | Lock in cabinet |
| Personal | Employee records, salary info | Locked storage |
| Client | Contracts, proposals, contact info | Secure folder |
| System | Passwords, access credentials | Never written down |

### 5.4 Quarterly Walkthrough

**Task**: Quarterly Clean Desk Walkthrough

**Frequency**: Quarterly (last week of quarter)

**Procedure**:
1. Schedule walkthrough after business hours
2. Facilities Lead + Security walks all work areas
3. Document violations:
   - Desk location/owner
   - Type of violation
   - Photo (if appropriate)
4. Send reminder email to all staff (pre-walkthrough)
5. Address violations with individual managers

**Evidence Required**:
- Walkthrough checklist (signed)
- Pre-walkthrough reminder email (copy)
- Summary of findings
- Follow-up actions (if violations found)

---

## 6. Recurring Task Templates

### 6.1 Monthly Physical Security Review

```
Odoo Task Template:
─────────────────────
Project: IT Audit 2025 – Remediation
Task: Monthly Physical Security Review
Recurrence: Monthly (1st week)
Owner: Facilities Lead

Checklist:
[ ] Review visitor log for completeness
[ ] Reconcile badge issuance/returns
[ ] Update key register
[ ] Cross-reference keys against HR roster
[ ] Document any exceptions
[ ] Archive evidence
[ ] Sign review attestation
```

### 6.2 Quarterly Clean Desk Walkthrough

```
Odoo Task Template:
─────────────────────
Project: IT Audit 2025 – Remediation
Task: Quarterly Clean Desk Walkthrough
Recurrence: Quarterly (last week)
Owner: Facilities Lead

Checklist:
[ ] Send reminder email (1 week prior)
[ ] Schedule walkthrough date/time
[ ] Complete walkthrough checklist
[ ] Document any violations
[ ] Report findings to department managers
[ ] Archive evidence
```

---

## 7. Evidence Repository

**Storage Location**: SharePoint / Odoo Documents

```
Physical-Security/
├── Visitor-Management/
│   ├── SOPs/
│   │   └── Visitor-Registration-SOP.pdf
│   ├── Logs/
│   │   ├── 2025-01-Visitor-Log.pdf
│   │   └── ...
│   └── Monthly-Reviews/
│       ├── 2025-01-Review.pdf
│       └── ...
│
├── Key-Register/
│   ├── Current-Register.xlsx
│   ├── Request-Forms/
│   └── Monthly-Reviews/
│
├── MDF-Room/
│   ├── Before-After-Photos/
│   ├── Access-Logs/
│   └── Maintenance-Records/
│
├── CCTV/
│   ├── Access-Request.pdf
│   ├── Confirmation.pdf
│   └── Access-Console-Screenshot.pdf
│
└── Clean-Desk/
    ├── Policy-Document.pdf
    ├── Reminder-Emails/
    └── Walkthrough-Reports/
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Facilities Lead | Initial controls documentation |

---

**Document Classification**: Internal - Operations
**Review Frequency**: Annually
**Next Review Date**: 2026-01-31
**Approver**: IT Market Director
