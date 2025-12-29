# Hire-to-Retire Process Overview

## Purpose

This section documents the end-to-end employee lifecycle management process from hiring to retirement/separation, with Philippine DOLE statutory compliance and internal SLA tracking integrated with Odoo CE 18.0.

## Process Scope

**In Scope**:
- Employee lifecycle from requisition to termination
- Philippine DOLE statutory compliance (Final Pay, COE)
- Internal SLA tracking (7-day Final Pay, 3-day COE)
- Leave credit conversion and final pay calculation
- Multi-department clearance workflows (HR, Finance, IT, Admin)

**Out of Scope**:
- Multi-agency or multi-company employee management
- International labor law compliance (non-Philippine)
- Recruitment marketing or applicant tracking systems (ATS)
- Performance management systems (separate module)

## Process Phases

The hire-to-retire process consists of 5 distinct phases:

### Phase 1: Hiring
- Staffing need identification
- Requisition submission and approval
- Budget approval (Finance Director)
- Candidate selection and offer
- Employee master data creation

### Phase 2: First Pay
- Payroll master setup
- 7-day eligibility check (internal SLA)
- Include in current payroll run
- First salary disbursement

### Phase 3: Active Employment
- Salary changes and adjustments
- Promotions and transfers
- Leave management (VL, SL, Emergency)
- Performance reviews
- Training records

### Phase 4: Clearance
- Exit request or resignation
- Offboarding ticket creation
- Parallel clearance collection:
  - HR clearance
  - Finance clearance (advances, reimbursements)
  - IT clearance (access revocation, asset return)
  - Admin clearance (IDs, keys, badges)
- Leave balance calculation
- Clearance completion milestone

### Phase 5: Last Pay (Final Pay)
- Final pay calculation (pro-rated salary, leave conversion, 13th month)
- Finance Director approval
- Payment execution
- Certificate of Employment (COE) issuance
- Employee status update: Terminated

## Key Stakeholders

| Role | Responsibility |
|------|---------------|
| **HR Director** | Employee master data, leave policies, COE approval |
| **Finance Director** | Payroll, final pay calculation, final pay approval |
| **HR Operations** | Leave balance verification, clearance coordination |
| **IT Administrator** | System access revocation, asset return tracking |
| **Admin Manager** | Physical asset clearance (IDs, keys, badges) |

## Statutory Compliance Requirements

### DOLE (Department of Labor and Employment) Requirements

| Requirement | Type | Deadline | Legal Reference |
|-------------|------|----------|-----------------|
| **Final Pay** | Statutory | ≤30 calendar days | Labor Advisory No. 06-20 |
| **Certificate of Employment (COE)** | Statutory | ≤3 calendar days | Labor Code of the Philippines |
| **Pay Frequency** | Statutory | ≥2x per month (≤16 day interval) | Labor Code Article 103 |
| **Leave Credit Conversion** | Statutory | Required in final pay | Company Leave Policy + Labor Code |

### Internal SLA (TBWA\SMP Champion Standard)

| Requirement | Type | Deadline | Trigger Event |
|-------------|------|----------|--------------|
| **Final Pay** | Internal | ≤7 calendar days | Clearance Completed |
| **First Pay** | Internal | ≥7 days worked | Before payroll cutoff |
| **Clearance** | Internal | ≤5 business days | Last Working Day (LWD) |

## Success Metrics

| Metric | Target | Measurement Frequency |
|--------|--------|---------------------|
| Final Pay within 7 days | 95%+ | Monthly |
| COE within 3 days | 100% | Per request |
| Clearance within 5 days | 90%+ | Per separation |
| Zero DOLE complaints | 100% | Annually |
| First Pay within cycle | 100% | Per hire |

## Integration Points

**Odoo CE 18.0 Modules**:
- `hr` - Employee master data
- `hr_holidays` - Leave management and accrual
- `hr_payroll` - Payroll processing and final pay
- `project` - Clearance task tracking
- `account` - Final pay accounting entries

**OCA Modules**:
- `date_range` - Holiday calendar and workday calculation
- `hr_employee_service_contract` - Employment contract tracking
- `hr_expense` - Pending reimbursements in final pay

## Document Navigation

- [Final Pay Calculation](final-pay-calculation.md) - Detailed final pay computation rules
- [Clearance Workflow](clearance-workflow.md) - Multi-department clearance process
- [COE Generation](coe-generation.md) - Certificate of Employment issuance
- [Leave Conversion](leave-conversion.md) - Leave credit to cash conversion
- [Holiday Calendar](holiday-calendar.md) - Philippine holidays and workday calculation

## Approval Workflow Summary

```
Employee Resignation
        ↓
HR Director Acknowledgment
        ↓
Clearance Task Creation (HR, Finance, IT, Admin) [Parallel]
        ↓
All Clearances Completed
        ↓
Leave Balance Verified by HR Ops
        ↓
Final Pay Calculated by Finance Shared Services
        ↓
Final Pay Reviewed by Finance Director
        ↓
Final Pay Approved by Finance Director
        ↓
Payment Execution
        ↓
COE Request (if employee initiates)
        ↓
COE Generated within 3 days
        ↓
Employee Status: Terminated
```

## Common Issues and Solutions

| Issue | Root Cause | Solution |
|-------|-----------|----------|
| Final Pay delayed beyond 7 days | Clearance not completed | Implement SLA breach alerts at Day 5 |
| Leave balance mismatch | Manual tracking errors | Use Odoo `hr_holidays` leave balance API |
| Outstanding advances not deducted | Missing sync with Cash Advance module | Query `hr.expense.sheet` for unapproved advances |
| COE delayed beyond 3 days | Manual template creation | Automate COE generation from employee master |
| Tax calculation errors in final pay | Manual computation | Use Odoo payroll tax engine with BIR rules |

## Next Steps

1. Review [Final Pay Calculation](final-pay-calculation.md) for detailed computation rules
2. Configure [Holiday Calendar](holiday-calendar.md) for Philippine holidays
3. Set up [Clearance Workflow](clearance-workflow.md) for multi-department coordination
4. Test [Leave Conversion](leave-conversion.md) formulas with sample data
5. Generate [COE Templates](coe-generation.md) for Legal review

---

**Author**: Jake Tolentino
**Last Updated**: 2025-12-29
**Version**: 1.0
**Applies To**: Odoo CE 18.0 + OCA Modules (Single Agency, Philippine Operations)
