# IT Asset Management

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: IT Asset Manager + IT Market Director
**Classification**: Internal - Operations

---

## Overview

This document defines the IT asset management controls and procedures. These controls address findings from the IT Audit 2025 related to asset attributes, lifecycle tracking, and reconciliation between CMDB and local records.

---

## 1. Asset Classification

### 1.1 Asset Categories

| Category | Description | Examples | Criticality Default |
|----------|-------------|----------|---------------------|
| End User Computing | Devices assigned to employees | Laptops, desktops, tablets | Medium |
| Mobile Devices | Portable communication devices | Smartphones, mobile hotspots | Low |
| Peripherals | Supporting devices | Monitors, keyboards, mice, docks | Low |
| Network Equipment | Infrastructure connectivity | Switches, routers, access points | High |
| Servers | Computing infrastructure | Physical servers, storage arrays | Critical |
| Software Licenses | Purchased software rights | Office 365, Adobe, specialized apps | Medium |

### 1.2 Criticality Levels

| Level | Definition | Recovery Time Objective |
|-------|------------|------------------------|
| Critical | Business stops if unavailable | < 4 hours |
| High | Major impact to operations | < 24 hours |
| Medium | Moderate impact, workarounds exist | < 72 hours |
| Low | Minimal impact | < 1 week |

---

## 2. Standard Asset Attributes

### 2.1 Required Fields

Every IT asset record MUST contain the following attributes:

| Field | Description | Format | Required |
|-------|-------------|--------|----------|
| Asset ID | Unique identifier | CATEGORY-YYYYNNN | Yes |
| Asset Type | Classification category | Dropdown | Yes |
| Make/Model | Manufacturer and model | Text | Yes |
| Serial Number | Manufacturer serial | Text | Yes |
| Owner | Assigned user or department | Lookup | Yes |
| Location | Physical/logical location | Dropdown | Yes |
| Criticality | Business impact level | Critical/High/Medium/Low | Yes |
| Status | Current state | Active/Not In Use/Disposed | Yes |
| Issued Date | Date assigned to current owner | YYYY-MM-DD | Yes |
| Purchase Date | Original acquisition date | YYYY-MM-DD | Yes |
| Purchase Cost | Original cost | Currency | Yes |
| Warranty Expiry | End of warranty coverage | YYYY-MM-DD | Yes |

### 2.2 Lifecycle Fields

| Field | Description | Required When |
|-------|-------------|---------------|
| Issued Date | Date asset assigned to user | On issue |
| Return Date | Date asset returned | On return |
| Reassigned Date | Date asset transferred | On transfer |
| Wiped Date | Date data wipe completed | Before reissue/disposal |
| Disposed Date | Date asset disposed | On disposal |
| Disposal Method | How asset was disposed | On disposal |
| Disposal Certificate | Reference to certificate | On disposal |

### 2.3 Asset ID Format

```
Format: [CATEGORY]-[YEAR][SEQUENCE]

Categories:
  LT = Laptop
  DT = Desktop
  TB = Tablet
  MO = Monitor
  PH = Phone
  NE = Network Equipment
  SV = Server
  PE = Peripheral

Example: LT-2025001 (first laptop acquired in 2025)
```

---

## 3. Asset Lifecycle Management

### 3.1 Lifecycle States

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Ordered    │───▶│  Received   │───▶│   Active    │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                             │
                         ┌───────────────────┼───────────────────┐
                         ▼                   ▼                   ▼
                 ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                 │ Not In Use  │    │ Reassigned  │    │   Repair    │
                 └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
                        │                  │                  │
                        ▼                  ▼                  ▼
                 ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                 │   Wiped     │    │   Active    │    │   Active    │
                 └──────┬──────┘    │ (new owner) │    │     or      │
                        │           └─────────────┘    │  Disposed   │
                        ▼                              └─────────────┘
                 ┌─────────────┐
                 │  Disposed   │
                 └─────────────┘
```

### 3.2 Lifecycle Event Documentation

#### 3.2.1 Asset Issuance

**Trigger**: New hire, replacement, upgrade

**Required Documentation**:
| Document | Description |
|----------|-------------|
| Issue Form | Signed by recipient |
| Asset Details | Serial, asset ID, condition |
| Accessories | List of included items |
| Policy Acknowledgment | User accepts IT use policy |

**Process**:
1. IT prepares asset (install standard image, register)
2. Generate issue form with asset details
3. User signs acknowledgment
4. Update inventory: Status = Active, Owner = User
5. Archive signed form

#### 3.2.2 Asset Return

**Trigger**: Employee departure, upgrade, end of life

**Required Documentation**:
| Document | Description |
|----------|-------------|
| Return Form | Signed by employee and IT |
| Condition Assessment | Physical inspection notes |
| Accessories Checklist | Items returned |
| Data Status | Confirmed backed up or wiped |

**Process**:
1. Employee schedules return with IT
2. IT inspects asset and accessories
3. Both parties sign return form
4. Update inventory: Status = Not In Use, Return Date = Today
5. Archive signed form

#### 3.2.3 Asset Reassignment

**Trigger**: Role change, department transfer, temporary assignment

**Required Documentation**:
| Document | Description |
|----------|-------------|
| Transfer Form | Old and new owner signatures |
| Condition Assessment | State at transfer |
| Data Handling | How old user data was handled |

**Process**:
1. Obtain approval for transfer
2. Complete data backup/wipe as appropriate
3. Both users sign transfer form
4. Update inventory: Owner = New User, Reassigned Date = Today
5. Archive signed form

#### 3.2.4 Data Wipe Confirmation

**Trigger**: Before reissue, before disposal, end of assignment

**Required Documentation**:
| Document | Description |
|----------|-------------|
| Wipe Certificate | IT confirmation of secure wipe |
| Wipe Method | Tool/method used (DBAN, manufacturer reset) |
| Verification | Confirmation data irrecoverable |

**Process**:
1. Remove asset from network
2. Perform secure wipe using approved tool
3. Verify wipe completed successfully
4. Generate wipe certificate
5. Update inventory: Wiped Date = Today, attach certificate
6. **IMPORTANT**: Asset cannot be marked "Disposed" without wipe confirmation

#### 3.2.5 Asset Disposal

**Trigger**: End of life, beyond repair, obsolete

**Required Documentation**:
| Document | Description |
|----------|-------------|
| Disposal Request | Manager approval |
| Wipe Certificate | Must exist before disposal |
| Disposal Method | E-waste, donation, destruction |
| Certificate of Destruction | From disposal vendor (if applicable) |

**Process**:
1. Verify asset is wiped (check Wiped Date exists)
2. Obtain disposal approval
3. Transfer to approved disposal vendor or method
4. Obtain certificate of destruction
5. Update inventory: Status = Disposed, Disposed Date = Today
6. Archive all documentation

---

## 4. Inventory Reconciliation

### 4.1 Reconciliation Sources

| Source | System | Export Method | Frequency |
|--------|--------|---------------|-----------|
| CMDB | ServiceNow | CSV export | Quarterly |
| Local Inventory | Excel/Google Sheet | Current file | Quarterly |
| Physical Storage | Manual count | Walkthrough | Quarterly |

### 4.2 Reconciliation Procedure

**Task**: Quarterly Asset Reconciliation

**Frequency**: Quarterly (by 15th of first month following quarter end)

**Steps**:

1. **Export Data Sources**
   ```
   Day 1:
   [ ] Export ServiceNow CMDB (all assets, current status)
   [ ] Export local inventory spreadsheet
   [ ] Prepare physical count sheets for storage
   ```

2. **Physical Verification**
   ```
   Day 2-3:
   [ ] Count all assets in "Not In Use" storage
   [ ] Verify serial numbers match records
   [ ] Note any assets not on list
   [ ] Note any listed assets not found
   ```

3. **Reconcile Records**
   ```
   Day 4-5:
   [ ] Compare CMDB vs. Local Inventory
   [ ] Compare Local Inventory vs. Physical Count
   [ ] Document all discrepancies
   [ ] Investigate root cause of each variance
   ```

4. **Remediate Gaps**
   ```
   Day 6-7:
   [ ] Update incorrect records in source systems
   [ ] Locate or write off missing assets
   [ ] Add newly discovered assets to inventory
   [ ] Document remediation actions
   ```

5. **Sign-Off**
   ```
   Day 8:
   [ ] Prepare reconciliation report
   [ ] IT Asset Manager signs attestation
   [ ] IT Market Director reviews and approves
   [ ] Archive evidence package
   ```

### 4.3 Reconciliation Report Template

```markdown
# Asset Reconciliation Report

**Quarter**: Q[X] [YEAR]
**Prepared By**: [Name]
**Date**: [YYYY-MM-DD]

## Summary

| Source | Total Assets | Active | Not In Use | Disposed |
|--------|--------------|--------|------------|----------|
| ServiceNow CMDB | | | | |
| Local Inventory | | | | |
| Physical Count | | | | |

## Discrepancies Found

| # | Asset ID | Issue | Root Cause | Remediation |
|---|----------|-------|------------|-------------|
| 1 | | | | |
| 2 | | | | |

## Reconciliation Status

- [ ] All discrepancies investigated
- [ ] All records updated
- [ ] Systems aligned

## Sign-Off

IT Asset Manager: _________________ Date: _________

IT Market Director: _________________ Date: _________
```

---

## 5. System Integration

### 5.1 ServiceNow CMDB Configuration

**Required CI (Configuration Item) Attributes**:

| CMDB Field | Mapped To | Sync Direction |
|------------|-----------|----------------|
| Asset Tag | Asset ID | Bidirectional |
| Serial Number | Serial Number | CMDB → Local |
| Assigned To | Owner | CMDB → Local |
| Location | Location | CMDB → Local |
| Install Status | Status | Bidirectional |
| Operational Status | Criticality | Local → CMDB |
| Acquisition Date | Purchase Date | CMDB → Local |

### 5.2 Local Inventory Fields

**Excel/Google Sheets Template**:

| Column | Type | Validation |
|--------|------|------------|
| Asset ID | Text | Required, unique |
| Asset Type | Dropdown | From category list |
| Make/Model | Text | Required |
| Serial Number | Text | Required |
| Owner | Text | From HR lookup |
| Department | Dropdown | From org structure |
| Location | Dropdown | From location list |
| Criticality | Dropdown | Critical/High/Medium/Low |
| Status | Dropdown | Active/Not In Use/Disposed |
| Issued Date | Date | Required if Active |
| Return Date | Date | Required if Not In Use |
| Reassigned Date | Date | If transferred |
| Wiped Date | Date | Required before Disposed |
| Disposed Date | Date | If Disposed |
| Purchase Date | Date | Required |
| Purchase Cost | Currency | Required |
| Warranty Expiry | Date | Required |
| Last Reconciliation | Date | Auto-updated |
| Notes | Text | Optional |

---

## 6. Odoo Integration (Future State)

### 6.1 Asset Module Fields

When Odoo asset management is fully deployed, map fields as follows:

| Odoo Field | Current Field | Notes |
|------------|--------------|-------|
| name | Asset ID | Auto-generated |
| category_id | Asset Type | Create categories |
| model_id | Make/Model | Create asset models |
| serial_no | Serial Number | |
| partner_id | Owner | Link to employee record |
| location_id | Location | |
| acquisition_date | Purchase Date | |
| original_value | Purchase Cost | |
| state | Status | Map to Odoo states |

### 6.2 Recurring Tasks

```
Odoo Recurring Task:
─────────────────────
Project: IT Operations
Task: Quarterly Asset Reconciliation
Recurrence: Quarterly

Checklist:
[ ] Export ServiceNow CMDB
[ ] Export local inventory
[ ] Physical verification of storage
[ ] Reconcile all three sources
[ ] Document discrepancies
[ ] Remediate gaps
[ ] Prepare reconciliation report
[ ] Obtain sign-off
[ ] Archive evidence
```

---

## 7. Evidence Requirements

### 7.1 Per Audit Period

| Evidence | Format | Retention |
|----------|--------|-----------|
| Asset inventory (complete) | Excel/CSV | 7 years |
| Reconciliation report | PDF | 7 years |
| Signed attestation | PDF | 7 years |
| Issue forms (samples) | PDF | 7 years |
| Return forms (samples) | PDF | 7 years |
| Wipe certificates (all) | PDF | 10 years |
| Disposal certificates (all) | PDF | 10 years |

### 7.2 Evidence Repository

```
IT-Asset-Management/
├── Inventory/
│   ├── Current-Inventory.xlsx
│   ├── CMDB-Exports/
│   │   ├── 2025-Q1-CMDB.csv
│   │   └── ...
│   └── Historical/
│
├── Reconciliation/
│   ├── 2025-Q1/
│   │   ├── Reconciliation-Report.pdf
│   │   ├── Discrepancy-Log.xlsx
│   │   ├── Physical-Count-Sheets.pdf
│   │   └── Signed-Attestation.pdf
│   └── ...
│
├── Lifecycle/
│   ├── Issue-Forms/
│   ├── Return-Forms/
│   ├── Transfer-Forms/
│   └── Wipe-Certificates/
│
└── Disposal/
    ├── Approval-Requests/
    └── Destruction-Certificates/
```

---

## 8. Controls Summary

| Control | Objective | Frequency | Owner | Evidence |
|---------|-----------|-----------|-------|----------|
| Asset Registration | Complete records | Per event | IT Asset Manager | Inventory entry |
| Lifecycle Tracking | Audit trail | Per event | IT Asset Manager | Forms, certificates |
| Quarterly Reconciliation | Accuracy | Quarterly | IT Asset Manager | Reconciliation report |
| Wipe Before Disposal | Data protection | Per event | IT Asset Manager | Wipe certificate |
| Sign-Off | Accountability | Quarterly | IT Market Director | Signed attestation |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | IT Asset Manager | Initial procedures documentation |

---

**Document Classification**: Internal - Operations
**Review Frequency**: Annually
**Next Review Date**: 2026-01-31
**Approver**: IT Market Director
