# GITC Testing Playbook

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: IT Market Director
**Classification**: Internal - Governance

---

## Purpose

This playbook provides standardized testing procedures for General IT Controls (GITC) to ensure consistent, evidence-based control assessments. It addresses the audit finding that "YES" responses were recorded where evidence was insufficient.

**Key Rule**: SBOX answer MUST be "NO + RAP" (Remediation Action Plan) if all required evidence artifacts aren't attached.

---

## Control Testing Framework

### Decision Tree for Control Assessment

```
START: Is the control designed appropriately?
│
├── NO → Answer: Design Deficiency
│         Action: Document gap, create remediation plan
│
└── YES → Is all required evidence available?
          │
          ├── NO → Answer: NO + RAP
          │         Action: Document missing items, set collection timeline
          │
          └── YES → Is evidence from the correct period?
                    │
                    ├── NO → Answer: NO + RAP
                    │         Action: Request evidence for correct period
                    │
                    └── YES → Is evidence complete and legible?
                              │
                              ├── NO → Answer: NO + RAP
                              │         Action: Request replacement evidence
                              │
                              └── YES → Does evidence demonstrate control operation?
                                        │
                                        ├── NO → Answer: Operating Deficiency
                                        │         Action: Document failure, root cause
                                        │
                                        └── YES → Answer: YES (Compliant)
                                                  Action: Archive evidence
```

---

## IT S01: User Account Creation

### Control Objective

Ensure new user accounts are created only with proper authorization and that users receive security awareness training before system access.

### Testing Period

Quarterly (sample all new accounts in the period)

### Required Evidence Checklist

| # | Evidence Item | Source | Format | Acceptable? |
|---|--------------|--------|--------|-------------|
| 1 | Access request form/email | ITSM / Email | PDF/Screenshot | Must show: requester, approver, date, systems requested |
| 2 | Supervisor/Manager approval | Email / ITSM | PDF/Screenshot | Must be dated before account creation |
| 3 | IT security policy acknowledgment | LMS / Email | PDF | Signed or electronic acknowledgment |
| 4 | Security awareness training completion | LMS | Certificate/Report | Must be dated within 30 days of account creation |
| 5 | Account creation confirmation | AD / Odoo | Screenshot / Log | Must show account created date |

### Sample Selection

| Total New Accounts | Sample Size |
|--------------------|-------------|
| 1-10 | 100% (all) |
| 11-25 | 10 accounts |
| 26-50 | 15 accounts |
| 51+ | 25 accounts |

### Testing Procedure

1. **Obtain Population**
   - Request IT new user account list for testing period
   - Verify completeness against HR new hire report

2. **Select Sample**
   - Use random selection method (e.g., every nth account)
   - Document selection methodology

3. **For Each Sample Item**
   - Collect all 5 evidence items
   - Verify dates are in correct sequence:
     - Request → Approval → Training → Account Creation
   - Document any gaps or exceptions

4. **Evaluate Results**
   - Calculate compliance rate: (Compliant samples / Total samples) × 100
   - Document all exceptions

5. **Conclude**
   - If 100% compliant with all evidence → YES
   - If any sample missing evidence → NO + RAP
   - If pattern of failures → Escalate to Finance Director

### Common Deficiencies

| Issue | Acceptable? | Remediation |
|-------|-------------|-------------|
| Missing request form | NO | Implement ITSM ticketing requirement |
| Approval after account created | NO | Add workflow gate in ITSM |
| Training not completed | NO | Block access until training done |
| Evidence undated | NO | Request dated confirmation |

---

## IT S05: Quarterly User Access Review

### Control Objective

Ensure user access rights are reviewed periodically to verify appropriateness and that terminated users are promptly deprovisioned.

### Testing Period

Quarterly

### Required Evidence Checklist

| # | Evidence Item | Source | Format | Acceptable? |
|---|--------------|--------|--------|-------------|
| 1 | HR active employee roster (as of review date) | HRIS | Export (CSV/PDF) | Must be dated within review period |
| 2 | System access list (AD/Odoo) | AD / Odoo | Export | Must be dated within review period |
| 3 | SoD matrix reference | This docs site | Link/PDF | Current version |
| 4 | Access comparison/reconciliation | Reviewer | Spreadsheet | Must show HR vs. System comparison |
| 5 | Signed review/approval sheet | Reviewer | PDF | Must have reviewer signature and date |
| 6 | Termination deprovision evidence (if applicable) | AD / ITSM | Screenshot / Log | For any terminated users found |
| 7 | Exception log (if applicable) | Reviewer | Spreadsheet | For any SoD conflicts identified |

### Testing Procedure

1. **Verify Timeliness**
   - Confirm review was completed within 30 days of quarter end
   - Document review completion date

2. **Validate HR Roster**
   - Confirm roster is from HRIS (not manually created)
   - Verify date is within the review period

3. **Validate System Access List**
   - Confirm export is from authoritative source
   - Verify includes all in-scope systems

4. **Review Reconciliation**
   - Check that all HR employees appear in system access
   - Check that no system accounts exist for non-employees
   - Verify SoD conflicts were identified and documented

5. **Verify Remediation**
   - For terminated users: confirm account disabled/deleted
   - For SoD conflicts: verify compensating controls documented
   - For inappropriate access: confirm access removed

6. **Validate Sign-off**
   - Confirm reviewer has appropriate authority
   - Verify signature is genuine (not typed name)
   - Confirm date is within review period

### Termination Testing

For any terminated employees in the period:

| Check | Source | Pass Criteria |
|-------|--------|---------------|
| Account disabled in AD | AD screenshot | Disabled within 24 hours of termination |
| Odoo access revoked | Odoo user list | No active access after termination |
| Email access removed | Exchange/O365 | Mailbox disabled or removed |
| VPN access revoked | VPN logs | No connection after termination |

### SoD Conflict Testing

For identified SoD conflicts:

| Conflict Type | Evidence Required | Remediation |
|---------------|-------------------|-------------|
| Prohibited combination | Compensating control documentation | Access separation or enhanced monitoring |
| Excessive privilege | Justification from manager | Access reduction or documented exception |
| Orphan account | Deprovisioning confirmation | Account disabled |

### Common Deficiencies

| Issue | Acceptable? | Remediation |
|-------|-------------|-------------|
| Review not completed | NO | Schedule immediate catch-up review |
| HR roster outdated | NO | Request current roster, re-review |
| No signature on approval | NO | Obtain signature, document delay |
| Terminated user still active | NO | Immediately disable, investigate gap |
| SoD conflict unaddressed | NO | Implement compensating control |

---

## Evidence Quality Standards

### What Makes Evidence Acceptable

| Attribute | Requirement | Example |
|-----------|-------------|---------|
| Dated | Clear date visible | Timestamp on screenshot, date on form |
| Complete | All required fields populated | No blank required sections |
| Legible | Readable without enhancement | Clear text, adequate resolution |
| Authentic | From authoritative source | System export, not manual recreation |
| Relevant | Pertains to control being tested | Correct period, correct system |
| Traceable | Can be verified if needed | Reference number, file path |

### Unacceptable Evidence

- Screenshots with dates cropped out
- Manually typed lists (unless signed attestation)
- Evidence from wrong period
- Partial documents (page 2 of 3 only)
- Unsigned forms requiring signature
- Evidence that cannot be independently verified

---

## Documentation Requirements

### Test Workpaper Structure

```
IT-Controls-Testing/
├── Q1-2025/
│   ├── IT-S01-Account-Creation/
│   │   ├── 01-Population.xlsx
│   │   ├── 02-Sample-Selection.xlsx
│   │   ├── 03-Evidence/
│   │   │   ├── Sample-01-Request.pdf
│   │   │   ├── Sample-01-Approval.pdf
│   │   │   ├── Sample-01-Training.pdf
│   │   │   ├── Sample-01-Account.pdf
│   │   │   └── ...
│   │   ├── 04-Testing-Results.xlsx
│   │   └── 05-Conclusion.pdf
│   │
│   └── IT-S05-Access-Review/
│       ├── 01-HR-Roster.csv
│       ├── 02-AD-Export.csv
│       ├── 03-Odoo-Users.csv
│       ├── 04-Reconciliation.xlsx
│       ├── 05-Signed-Review.pdf
│       ├── 06-Exceptions-Log.xlsx
│       └── 07-Conclusion.pdf
│
└── Q2-2025/
    └── ...
```

### Retention Requirements

| Document Type | Retention Period | Storage Location |
|--------------|------------------|------------------|
| Test workpapers | 7 years | SharePoint / Odoo Documents |
| Evidence files | 7 years | SharePoint / Odoo Documents |
| Signed attestations | 10 years | Secure archive |
| Exception logs | 10 years | Secure archive |

---

## Quarterly Testing Calendar

| Quarter | Testing Period | Evidence Due | Review Due | SBOX Update |
|---------|---------------|--------------|------------|-------------|
| Q1 | Jan 1 - Mar 31 | Apr 10 | Apr 15 | Apr 20 |
| Q2 | Apr 1 - Jun 30 | Jul 10 | Jul 15 | Jul 20 |
| Q3 | Jul 1 - Sep 30 | Oct 10 | Oct 15 | Oct 20 |
| Q4 | Oct 1 - Dec 31 | Jan 10 | Jan 15 | Jan 20 |

---

## Escalation Procedures

### When to Escalate

| Condition | Escalate To | Timeline |
|-----------|-------------|----------|
| Missing evidence >5 business days | IT Market Director | Immediate |
| Control failure (any instance) | Finance Director | Within 24 hours |
| Terminated user still active | IT Market Director + Finance Director | Immediate |
| SoD conflict without compensating control | Finance Director | Within 24 hours |
| Pattern of recurring failures | Finance Director + External Auditor | Within 48 hours |

### Escalation Format

```
Subject: [URGENT] GITC Control Failure - [Control ID]

Control: [IT S01 / IT S05]
Testing Period: [Quarter, Year]
Finding: [Brief description]
Impact: [Potential risk]
Immediate Action Taken: [Steps taken]
Remediation Required: [What needs to happen]
Owner: [Who is responsible]
Target Date: [When it will be fixed]
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | IT Market Director | Initial playbook creation |

---

**Document Classification**: Internal - Governance
**Review Frequency**: Annually
**Next Review Date**: 2026-01-31
**Approver**: IT Market Director
