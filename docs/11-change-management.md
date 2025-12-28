# 11 - Change Management and Governance

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director
**Classification**: Internal - Governance

---

## Executive Summary

This document establishes the **governance framework for financial close process changes**, ensuring controlled evolution while maintaining compliance, audit readiness, and operational stability. All modifications to close procedures, system configurations, role assignments, and control frameworks must follow this structured approval and implementation methodology.

**Core Objectives**:
- **Risk Mitigation**: Prevent unintended consequences from process or system changes
- **Audit Compliance**: Maintain audit trail for all control modifications
- **Stakeholder Alignment**: Ensure changes align with business needs and regulatory requirements
- **Continuity Assurance**: Minimize disruption to close operations during transitions

**Change Categories**:
1. **Administrative Changes**: Minor procedural updates, documentation corrections (Finance Manager approval)
2. **Operational Changes**: Task reassignments, timeline adjustments, tool changes (Finance Director approval)
3. **Control Changes**: SoD modifications, RLS policy updates, authority limit changes (Finance Director + Board approval)
4. **System Changes**: Odoo module installations, database schema changes (Finance Director + IT approval)
5. **Emergency Changes**: Critical fixes during close period (Finance Director authorization with post-approval review)

**Key Metrics**:
- Change success rate: ≥95% (implemented without rollback)
- Audit finding closure rate: 100% (remediated by target date)
- Change cycle time: ≤10 business days (request to implementation)

---

## 1. Change Management Framework

### 1.1 Change Classification Matrix

| Change Type | Definition | Examples | Approval Authority | Implementation Window |
|-------------|------------|----------|-------------------|----------------------|
| **Administrative** | Documentation updates, minor clarifications with no control impact | Procedure wording changes, glossary updates, template formatting | Finance Manager | Immediate |
| **Operational** | Process improvements, task reassignments, timeline adjustments | Close task resequencing, workload balancing, calendar adjustments | Finance Director | Next close cycle |
| **Control** | Modifications to segregation of duties, approval authorities, RLS policies | Role authority limit changes, new approval workflow, RLS policy updates | Finance Director + Board | Next quarter |
| **System** | Technical changes to Odoo, Supabase, integrations, or data structures | Module installation, database schema changes, API integrations | Finance Director + IT Manager + External Auditor notification | Next quarter (after UAT) |
| **Emergency** | Critical fixes required during active close period to prevent failure | Period unlock for error correction, urgent RLS fix, critical bug patch | Finance Director emergency authorization + post-approval review | Immediate (with rollback plan) |

### 1.2 Change Request Lifecycle

```
1. REQUEST INITIATION
   → Requester submits change request form (Supabase `change_request` table)
   → Automatic notification to Finance Manager
   ↓

2. IMPACT ASSESSMENT
   → Finance Manager (or assigned analyst) evaluates:
      - Business justification and expected benefits
      - Risk assessment (operational, compliance, audit)
      - Effort estimation (hours, resources, cost)
      - Stakeholder impact (roles affected, training needs)
   → Recommendation: Approve / Reject / Request More Information
   ↓

3. APPROVAL WORKFLOW
   → Route to appropriate approver based on change type:
      - Administrative → Finance Manager
      - Operational → Finance Director
      - Control/System → Finance Director + Board (if material)
   → Approval decision: Approved / Rejected / Deferred
   ↓

4. IMPLEMENTATION PLANNING
   → Develop implementation plan:
      - Detailed task breakdown with owners and deadlines
      - Rollback plan (if change fails or causes issues)
      - User Acceptance Testing (UAT) plan (for system changes)
      - Training and communication plan
   → Finance Director approval of implementation plan
   ↓

5. EXECUTION
   → Implement change per approved plan
   → Execute UAT (if applicable)
   → Monitor for issues during transition period
   ↓

6. VALIDATION
   → Validate change achieved expected benefits
   → Confirm no unintended side effects (compliance, audit, operations)
   → Update documentation (procedures, training materials)
   ↓

7. CLOSURE
   → Document lessons learned
   → Archive change request and supporting documentation
   → Communicate completion to stakeholders
```

### 1.3 Change Request Form Template

**Required Fields** (Supabase `change_request` table schema):
```sql
CREATE TABLE change_request (
  id BIGSERIAL PRIMARY KEY,
  request_number TEXT UNIQUE NOT NULL,  -- Format: CHG-YYYY-NN (e.g., CHG-2025-01)
  request_date TIMESTAMP DEFAULT NOW(),
  requester_id UUID REFERENCES auth.users,
  requester_role TEXT,

  -- Classification
  change_type TEXT CHECK (change_type IN ('administrative', 'operational', 'control', 'system', 'emergency')),
  change_category TEXT,  -- E.g., 'close_procedure', 'role_definition', 'system_config'
  priority TEXT CHECK (priority IN ('low', 'medium', 'high', 'critical')),

  -- Description
  change_title TEXT NOT NULL,
  current_state TEXT NOT NULL,  -- Detailed description of current process/configuration
  proposed_state TEXT NOT NULL,  -- Detailed description of desired future state
  business_justification TEXT NOT NULL,  -- Why is this change needed?
  expected_benefits TEXT,  -- Quantifiable benefits (cost savings, time reduction, risk mitigation)

  -- Impact Assessment
  affected_roles TEXT[],  -- Array of role names (e.g., ['gl_accountant', 'finance_manager'])
  affected_systems TEXT[],  -- Array of systems (e.g., ['odoo', 'supabase', 'n8n'])
  risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high')),
  risk_description TEXT,
  mitigation_plan TEXT,

  -- Approvals
  finance_manager_decision TEXT CHECK (finance_manager_decision IN ('approved', 'rejected', 'pending', 'deferred')),
  finance_manager_comment TEXT,
  finance_manager_decision_date TIMESTAMP,

  finance_director_decision TEXT CHECK (finance_director_decision IN ('approved', 'rejected', 'pending', 'deferred')),
  finance_director_comment TEXT,
  finance_director_decision_date TIMESTAMP,

  board_decision TEXT CHECK (board_decision IN ('approved', 'rejected', 'pending', 'not_required')),
  board_decision_date TIMESTAMP,

  -- Implementation
  implementation_plan TEXT,
  implementation_owner_id UUID REFERENCES auth.users,
  planned_implementation_date DATE,
  actual_implementation_date DATE,
  rollback_plan TEXT,

  -- Closure
  status TEXT CHECK (status IN ('draft', 'submitted', 'under_review', 'approved', 'rejected', 'implemented', 'closed', 'cancelled')),
  validation_results TEXT,
  lessons_learned TEXT,
  closure_date TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Audit log trigger for all change request updates
CREATE TRIGGER change_request_audit
  AFTER INSERT OR UPDATE OR DELETE ON change_request
  FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();
```

---

## 2. Approval Workflows and Escalation Paths

### 2.1 Administrative Change Workflow

**Scope**: Documentation updates, template modifications, glossary additions

**Approval Authority**: Finance Manager

**Process**:
1. Requester submits change request (can be informal email for minor changes)
2. Finance Manager reviews for accuracy and consistency
3. Finance Manager approves (email confirmation) or requests revisions
4. Requester implements change and notifies Finance Manager
5. Change logged in `change_request` table (status: 'closed')

**Timeline**: ≤2 business days from request to implementation

**Example**: Updating close procedure wording for clarity, adding new account to chart of accounts glossary

### 2.2 Operational Change Workflow

**Scope**: Process improvements, task reassignments, close calendar adjustments

**Approval Authority**: Finance Director

**Process**:
1. Requester submits formal change request (Supabase form)
2. Finance Manager conducts impact assessment (1-2 days)
3. Finance Manager recommendation to Finance Director
4. Finance Director reviews and decides (approve/reject/defer)
5. If approved:
   - Implementation owner assigned (typically Finance Manager)
   - Implementation plan developed (including rollback plan)
   - Finance Director approves implementation plan
   - Change implemented at start of next close cycle
   - Post-implementation review (validate benefits achieved)
6. Change logged and archived

**Timeline**: ≤10 business days from request to implementation

**Example**: Shifting variance analysis from Day 4 to Day 3, reassigning bank reconciliation from GL Accountant to AR Clerk

### 2.3 Control Change Workflow

**Scope**: Segregation of duties modifications, approval authority changes, RLS policy updates

**Approval Authority**: Finance Director + Board (if material)

**Materiality Threshold**:
- **Material control change** (requires Board approval): Changes affecting >₱1,000,000 transaction authority, new role creation, SoD framework restructure
- **Non-material control change** (Finance Director only): Authority limit adjustments <20%, RLS policy optimization (no scope change)

**Process**:
1. Requester submits formal change request with control impact analysis
2. Finance Manager conducts detailed risk assessment:
   - SoD conflict check (identify any prohibited duty combinations)
   - Compliance impact (BIR, audit, regulatory requirements)
   - Audit trail adequacy (ensure change is logged and traceable)
   - Compensating control evaluation (if SoD conflict unavoidable)
3. Finance Director reviews risk assessment
4. If material:
   - Finance Director prepares board memo with recommendation
   - Board reviews and approves/rejects (typically at quarterly board meeting)
   - External auditor notified of approved control changes
5. If approved:
   - Implementation plan developed (including UAT for system changes)
   - Training plan for affected roles
   - Communication to all finance team members
   - Change implemented at start of next quarter
   - Post-implementation control testing (validate effectiveness)
6. Change logged and archived

**Timeline**: ≤30 days from request to implementation (longer if board meeting schedule requires)

**Example**: Increasing Finance Manager vendor bill approval authority from ₱1M to ₱1.2M, modifying RLS policy to allow AR Clerk read-only access to payroll data

### 2.4 System Change Workflow

**Scope**: Odoo module installations, database schema changes, API integrations, infrastructure modifications

**Approval Authority**: Finance Director + IT Manager (+ External Auditor notification for control-relevant changes)

**Process**:
1. Requester submits formal change request with technical specification
2. IT Manager conducts technical feasibility assessment:
   - Compatibility with existing systems (Odoo version, Supabase schema)
   - Performance impact (database load, API rate limits)
   - Security implications (authentication, authorization, data encryption)
   - Backup and recovery plan
3. Finance Manager conducts business impact assessment:
   - Close process impact (task dependencies, timeline effects)
   - User training needs
   - Data migration requirements (if schema changes)
4. Finance Director reviews technical and business assessments
5. If control-relevant (affects financial data integrity, approval workflows, audit trail):
   - External auditor notified and consulted
   - Auditor may request control testing post-implementation
6. If approved:
   - Development environment (sandbox) change implementation
   - UAT by Finance Manager and key users (test cases covering all affected workflows)
   - UAT approval required before production deployment
   - Production deployment during non-close period (avoid Days -5 to 7)
   - Monitoring for 1 week post-deployment (daily system health checks)
   - Post-implementation review (validate functionality and performance)
7. Change logged and archived

**Timeline**: ≤20 business days from request to production deployment (excluding UAT duration)

**Rollback Requirement**: All system changes MUST have tested rollback plan (database backup, code revert, configuration restore)

**Example**: Installing new Odoo module for enhanced bank reconciliation, modifying Supabase RLS policies for new role, integrating n8n workflow for automated variance alerts

### 2.5 Emergency Change Workflow

**Scope**: Critical fixes required during active close period (Days -5 to 7) to prevent close failure

**Trigger Conditions**:
- System outage preventing transaction processing or reconciliation
- Data corruption requiring immediate correction
- Critical security vulnerability requiring urgent patch
- Period unlock needed for material error correction

**Approval Authority**: Finance Director emergency authorization (verbal or email)

**Process**:
1. **Discovery**: Issue identified and escalated immediately to Finance Director
2. **Emergency Authorization**:
   - Finance Director evaluates urgency and impact
   - If critical, grants verbal/email emergency authorization (documented in email)
   - Assigns implementation owner and sets deadline
3. **Implementation**:
   - Change implemented immediately with minimal delay
   - Rollback plan prepared concurrently (in case change fails)
   - All actions logged in real-time (audit trail)
4. **Post-Approval Review** (within 48 hours):
   - Formal change request submitted retroactively
   - Root cause analysis conducted (why did issue occur?)
   - Finance Director reviews emergency action for appropriateness
   - If emergency authorization was unjustified, document as exception and prevent recurrence
   - External auditor notified of emergency change (if control-relevant)
5. **Lessons Learned**:
   - Document preventive measures to avoid future emergencies
   - Update procedures or controls as needed
6. Change logged with "emergency" flag

**Timeline**: Immediate (within hours of issue discovery)

**Audit Trail Requirements**:
- Emergency authorization email/message archived
- All actions logged with timestamp and user ID
- Root cause analysis documented
- Preventive measures implemented and validated

**Example**: Period unlock to correct ₱5M journal entry error discovered on Day 6, emergency RLS policy fix for user unable to access critical reconciliation data on Day 2

---

## 3. Risk Assessment Framework

### 3.1 Risk Evaluation Criteria

**Risk Level Scoring**:
```
Risk Level = (Likelihood × Impact) ÷ 2

Likelihood Scale:
- Low (1): Unlikely to occur (<10% probability)
- Medium (2): Possible to occur (10-50% probability)
- High (3): Likely to occur (>50% probability)

Impact Scale:
- Low (1): Minimal disruption, no compliance impact, <₱50K financial exposure
- Medium (2): Moderate disruption, minor compliance concern, ₱50K-₱500K exposure
- High (3): Severe disruption, material compliance breach, >₱500K exposure

Risk Level Calculation:
- 1.0-1.5: Low risk (green)
- 2.0-2.5: Medium risk (yellow)
- 3.0: High risk (red)
```

**Risk Categories**:
1. **Operational Risk**: Disruption to close process, deadline misses, workload bottlenecks
2. **Compliance Risk**: BIR non-compliance, audit finding, regulatory penalty
3. **Financial Risk**: Material misstatement, loss of funds, revenue leakage
4. **Security Risk**: Data breach, unauthorized access, privacy violation
5. **Reputational Risk**: Stakeholder trust erosion, audit opinion qualification

### 3.2 Risk Mitigation Planning

**Required for**: All changes with Medium or High risk level

**Mitigation Plan Components**:
1. **Preventive Controls**: Actions to reduce likelihood of risk occurring
   - Example: UAT for system changes reduces likelihood of production errors
2. **Detective Controls**: Monitoring to identify risk occurrence early
   - Example: Daily reconciliation variance alerts detect data integrity issues
3. **Corrective Controls**: Response plan if risk materializes
   - Example: Rollback plan restores system to prior state if change fails
4. **Contingency Plans**: Alternative approaches if primary plan fails
   - Example: Manual workaround if automated reconciliation tool fails

**Risk Acceptance**:
- **Low risk**: Automatic acceptance (no formal mitigation required)
- **Medium risk**: Finance Director approval of mitigation plan required
- **High risk**: Board approval of mitigation plan required (or change rejected)

### 3.3 Control Impact Analysis Template

**Required for**: All Control and System change types

**Analysis Components**:
1. **Current Control Environment**:
   - Existing controls affected by change (list with references to `03-roles-and-sod-matrix.md`)
   - Control effectiveness rating (satisfactory / needs improvement / unsatisfactory)
   - Audit findings related to current controls (if any)

2. **Proposed Control Environment**:
   - Modified controls after change
   - New controls introduced (if any)
   - Removed controls (with justification)
   - Expected control effectiveness rating

3. **Gap Analysis**:
   - Control gaps introduced by change (if any)
   - Compensating controls to address gaps
   - Residual risk after mitigation

4. **Audit Implications**:
   - Impact on external audit scope (additional testing required?)
   - Notification requirements (when to inform auditor?)
   - Expected audit opinion impact (none / qualified / adverse)

**Example Control Impact Analysis**:
```
Change: Increase Finance Manager vendor bill approval authority from ₱1M to ₱1.5M

Current Control: Dual approval required for vendor bills >₱1M (AP Clerk prepares, Finance Manager approves)
Control Effectiveness: Satisfactory

Proposed Control: Dual approval threshold increases to ₱1.5M
New Authority Limit: Finance Manager approves ₱50K-₱1.5M, Finance Director approves >₱1.5M

Gap Analysis:
- Gap: Finance Manager now approves larger amounts without Finance Director oversight
- Compensating Control: Monthly supervisory review by Finance Director of all vendor bills ₱1M-₱1.5M
- Residual Risk: Low (monthly review detects anomalies within 30 days)

Audit Implications:
- External auditor notification required (change affects significant transaction threshold)
- No additional audit testing expected (compensating control adequate)
- Audit opinion impact: None (control remains effective)
```

---

## 4. Implementation and Testing Procedures

### 4.1 User Acceptance Testing (UAT) Framework

**Required for**: All System change types (Operational/Control changes may require UAT at Finance Director discretion)

**UAT Phases**:
1. **Test Case Development** (Finance Manager + Implementation Owner):
   - Identify all affected workflows (e.g., vendor bill approval, bank reconciliation, period close)
   - Develop test cases covering:
     - **Happy path**: Normal expected usage
     - **Edge cases**: Boundary conditions, unusual scenarios
     - **Error scenarios**: Invalid inputs, permission violations
   - Document expected results for each test case

2. **Test Environment Preparation** (IT Manager):
   - Provision UAT environment (separate from production):
     - Odoo UAT database (copy of production schema, anonymized data)
     - Supabase UAT project (separate RLS policies, test data)
   - Deploy change to UAT environment
   - Validate UAT environment stability

3. **UAT Execution** (Finance Manager + Key Users):
   - Assign test cases to users (preferably users who will use feature in production)
   - Execute test cases systematically (document results in test log)
   - Log defects in defect tracking system (Supabase `uat_defect_log` table):
     - Severity: Critical (blocks usage) / High (major functionality broken) / Medium (workaround exists) / Low (cosmetic)
     - Responsible party for fix (typically implementation owner or IT)
   - Retest after defect fixes

4. **UAT Sign-Off** (Finance Manager):
   - Review test results (all test cases passed or defects resolved)
   - Validate change meets requirements
   - Approve production deployment or request additional fixes
   - Document UAT approval in `change_request` table

**UAT Success Criteria**:
- ✅ All critical and high severity defects resolved
- ✅ ≥95% of test cases passed (medium/low defects acceptable if documented)
- ✅ Performance acceptable (no degradation >10% vs. baseline)
- ✅ Finance Manager sign-off obtained

**UAT Timeline**: Allocate ≥5 business days for UAT (3 days execution, 2 days defect resolution)

### 4.2 Production Deployment Procedures

**Deployment Windows**:
- **Allowed**: Mid-month (Days 10-20 of monthly close cycle), non-close periods
- **Prohibited**: Close period (Days -5 to 7), quarter-end +7 days, year-end +15 days

**Pre-Deployment Checklist**:
```
□ UAT completed and approved (Finance Manager sign-off)
□ Production deployment plan reviewed and approved (Finance Director)
□ Rollback plan tested in UAT environment (successful rollback verified)
□ Production database backup completed (within 24 hours of deployment)
□ User communication sent (notification of change, training materials, support contact)
□ IT support team briefed (aware of change, ready to respond to issues)
□ Deployment scheduled during low-usage window (e.g., Saturday 6AM-12PM)
```

**Deployment Steps** (IT Manager):
1. **Final backup**: Snapshot production database and configurations
2. **Deployment execution**: Apply change per deployment plan (scripts, configuration files, code releases)
3. **Smoke testing**: Validate core functionality post-deployment:
   - User authentication (login successful)
   - Critical workflows (create invoice, post journal entry, reconcile bank)
   - Reports generation (trial balance, income statement)
4. **Monitoring**: Monitor system for ≥2 hours post-deployment:
   - Error logs (no new critical errors)
   - Performance metrics (response time, database load)
   - User feedback (no widespread complaints)
5. **Rollback decision**: If critical issues detected, execute rollback plan immediately

**Post-Deployment Validation** (Finance Manager, within 2 business days):
- Re-execute subset of UAT test cases in production (confirm functionality)
- Review first close cycle after deployment (validate no disruption)
- Document post-deployment validation results

### 4.3 Rollback Planning and Execution

**Rollback Plan Requirements** (mandatory for all System and Emergency changes):
1. **Rollback Trigger Conditions**:
   - Critical defect discovered in production (blocks close process)
   - Data corruption or loss detected
   - Performance degradation >30% vs. baseline
   - Security vulnerability introduced
   - Finance Director decision to rollback (for any reason)

2. **Rollback Procedure**:
   - **Database rollback**: Restore from pre-deployment backup (tested recovery time <1 hour)
   - **Configuration rollback**: Revert system configurations to prior state (version-controlled)
   - **Code rollback**: Revert application code to prior version (git revert)
   - **User notification**: Inform users of rollback and temporary unavailability

3. **Rollback Testing** (required during UAT):
   - Simulate rollback in UAT environment
   - Validate data integrity after rollback (no data loss)
   - Measure rollback execution time
   - Document rollback procedure with screenshots/commands

**Rollback Authorization**:
- **Planned rollback** (during deployment window): IT Manager decision
- **Emergency rollback** (after deployment window): Finance Director authorization required

**Post-Rollback Actions**:
- Root cause analysis (why did change fail?)
- Defect resolution in UAT environment
- Re-UAT with fixes
- Reschedule production deployment (only after successful re-UAT)

---

## 5. Communication and Training

### 5.1 Stakeholder Communication Plan

**Communication Triggers**:
- Change request submitted (notify Finance Manager)
- Change approved (notify requester, implementation owner, affected users)
- UAT scheduled (notify UAT participants)
- Production deployment scheduled (notify all finance team, external auditor if control-relevant)
- Change implemented (notify all stakeholders, provide training materials)
- Change rolled back (notify all stakeholders, explain reason)

**Communication Channels**:
- **Email**: Formal notifications (approvals, deployment schedules, training invitations)
- **Mattermost**: Real-time updates (deployment in progress, issues detected, rollback decisions)
- **Monthly Team Meeting**: Change portfolio review (upcoming changes, lessons learned)

**Communication Templates**:

**Template 1: Change Approval Notification**
```
Subject: [CHG-2025-XX] Change Request Approved - [Change Title]

Dear [Affected Users],

Your change request [CHG-2025-XX: Change Title] has been approved by [Finance Director / Board].

Summary: [1-2 sentence description of change]

Expected Benefits: [Key benefits]

Implementation Schedule:
- UAT: [Start Date] - [End Date]
- Production Deployment: [Date and Time]
- Training Session: [Date and Time] (optional, register here: [Link])

Impact on Your Role: [Specific impact, e.g., "You will now approve vendor bills up to ₱1.5M instead of ₱1M"]

Action Required:
- Participate in UAT testing (test cases assigned: [Link])
- Attend training session (if applicable)
- Review updated procedures: [Link to documentation]

Support Contact: [Implementation Owner Name and Email]

Thank you,
[Finance Manager]
```

**Template 2: Production Deployment Notification**
```
Subject: [DEPLOYMENT] [Change Title] - Scheduled for [Date/Time]

Dear Finance Team,

We will deploy [Change Title] to production on [Date] at [Time].

System Downtime: [Expected downtime duration, e.g., "30 minutes" or "No downtime expected"]

What's Changing: [Brief description]

What You Need to Do:
- [Action 1, e.g., "Log out of Odoo by 5:45 PM on Friday"]
- [Action 2, e.g., "Review updated procedure before Monday: [Link]"]

Support During Deployment: [IT Support contact, Mattermost channel]

Rollback Plan: If critical issues are detected, we will rollback to prior version. You will be notified via Mattermost.

Questions: Contact [Implementation Owner] at [Email]

Thank you,
[Finance Manager]
```

### 5.2 Training Requirements

**Training Triggers**:
- **Operational changes**: If change affects >3 users OR modifies critical workflow (e.g., bank reconciliation process)
- **Control changes**: All changes (users must understand new approval authorities, SoD boundaries)
- **System changes**: All changes (users must learn new features, workflows, UI changes)

**Training Delivery Methods**:
1. **Formal Training Session** (for complex changes):
   - Duration: 1-2 hours
   - Format: Live demonstration + hands-on practice in UAT environment
   - Participants: All affected users
   - Materials: Training slides, step-by-step guides, FAQ document
   - Recording: Session recorded and archived for future reference

2. **Self-Paced Training** (for simple changes):
   - Format: Written guide with screenshots, video tutorial (5-10 minutes)
   - Delivery: Email to affected users with link to training materials
   - Support: Office hours for questions (Finance Manager available for 1 week post-deployment)

3. **On-the-Job Training** (for minor changes):
   - Format: Updated procedure documentation, quick reference guide
   - Delivery: Email notification with link to updated docs
   - Support: Email support from implementation owner

**Training Materials Repository**:
- Location: Supabase Storage `training_materials/` or shared drive
- Structure: `training_materials/[change_number]/[material_type]`
  - Example: `training_materials/CHG-2025-01/slides.pdf`, `training_materials/CHG-2025-01/demo_video.mp4`

**Training Effectiveness Measurement**:
- Post-training quiz (for formal sessions, passing score ≥80%)
- User survey (satisfaction rating, clarity rating)
- Helpdesk ticket volume (track post-deployment support requests, target: <5 tickets per change)

### 5.3 Documentation Update Requirements

**Documentation Scope**:
- All changes MUST update relevant documentation before implementation
- Documentation review is part of UAT sign-off (Finance Manager validates documentation accuracy)

**Affected Documents** (by change type):
- **Administrative**: Procedure documents, glossaries, templates
- **Operational**: Close calendar (`04-close-calendar-and-phases.md`), close checklists, task assignments
- **Control**: Roles and SoD matrix (`03-roles-and-sod-matrix.md`), approval authorities, RLS policies
- **System**: Technical documentation (data dictionary `99-appendix-data-dictionary.md`, integration guides, API specs)

**Documentation Standards**:
- **Version Control**: All documents version-controlled (Git or document management system)
- **Change Tracking**: Use track changes or version comparison (highlight what changed)
- **Revision History**: Update revision history table at end of document (version, date, author, changes summary)
- **Cross-References**: Update cross-references (if change affects multiple documents)

**Example Revision History Entry**:
```
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.1 | 2025-02-15 | Finance Manager | Updated Finance Manager vendor bill approval authority from ₱1M to ₱1.5M (CHG-2025-05) |
```

---

## 6. Audit Trail and Compliance

### 6.1 Change Log Requirements

**Mandatory Change Logging**:
- All changes MUST be logged in `change_request` table (Supabase)
- Administrative changes CAN be logged retrospectively (within 7 days)
- All other change types MUST be logged before implementation

**Change Log Data Retention**:
- Retention period: 10 years (aligns with BIR statute of limitations)
- Archive location: Supabase (live data) + annual export to secure storage

**Change Log Accessibility**:
- **Finance Team**: Read-only access to all change requests
- **External Auditor**: Read-only access to all change requests (via Supabase RLS policy)
- **Board Audit Committee**: Quarterly change report (summary of all changes by type, risk level, status)

### 6.2 Audit Trail Completeness

**Required Audit Trail Elements** (for each change):
1. **Request Documentation**:
   - Change request form (all fields completed)
   - Business justification (documented rationale)
   - Risk assessment (completed risk evaluation matrix)

2. **Approval Documentation**:
   - Approval emails or electronic signatures
   - Board meeting minutes (for control changes requiring board approval)
   - External auditor notification (if applicable)

3. **Implementation Documentation**:
   - Implementation plan (task breakdown, timeline)
   - UAT test cases and results (test log with pass/fail status)
   - Deployment checklist (signed off by IT Manager)
   - Rollback plan (tested and documented)

4. **Validation Documentation**:
   - Post-implementation validation results (benefits achieved?)
   - User training completion log (who attended, quiz scores)
   - Updated documentation (procedure documents, technical specs)

5. **Closure Documentation**:
   - Lessons learned summary
   - Process improvement recommendations
   - Change request closure sign-off (Finance Manager or Finance Director)

**Audit Trail Storage**:
- Primary: Supabase `change_request` table + related tables (`uat_test_log`, `training_log`)
- Secondary: Shared drive folder `change_management/[year]/[change_number]/`
  - All supporting documents (emails, meeting minutes, test results, training materials)

### 6.3 Regulatory Compliance

**BIR Compliance**:
- Changes to tax calculation logic, BIR form generation, or withholding tax workflows require **pre-approval from Tax Compliance Officer**
- Tax-related changes must be documented with supporting references to BIR regulations (Revenue Regulations, Revenue Memorandum Circulars)
- External tax consultant review recommended for complex tax changes

**Audit Compliance**:
- **Control-relevant changes** (affecting financial data integrity, approval workflows, audit trail) require **external auditor notification within 10 business days**
- Auditor may request:
  - Change request documentation
  - UAT results and defect log
  - Post-implementation control testing results
- Auditor feedback incorporated into lessons learned

**Data Privacy Compliance** (if applicable):
- Changes affecting personal data (employee information, customer data) require **Data Protection Officer review**
- Privacy impact assessment conducted for changes introducing new data collection or processing
- Data subject consent obtained if required

---

## 7. Continuous Improvement and Metrics

### 7.1 Change Management KPIs

**Success Metrics**:
- **Change Success Rate**: (Changes implemented without rollback / Total changes implemented) × 100
  - Target: ≥95%
- **Change Cycle Time**: Average days from request submission to implementation completion
  - Target: ≤10 business days (operational changes), ≤30 days (control/system changes)
- **UAT Defect Escape Rate**: (Defects found in production / Total defects found) × 100
  - Target: ≤5% (i.e., 95% of defects caught in UAT)
- **Training Effectiveness**: Post-training quiz average score
  - Target: ≥85%
- **User Satisfaction**: Post-implementation survey rating (1-5 scale)
  - Target: ≥4.0 average

**Efficiency Metrics**:
- **Time to Value**: Days from implementation to expected benefits realized
- **Rework Rate**: (Changes requiring post-implementation fixes / Total changes) × 100
  - Target: ≤10%
- **Documentation Accuracy**: (Documentation updates completed before implementation / Total changes) × 100
  - Target: 100%

**Compliance Metrics**:
- **Audit Finding Closure Rate**: (Audit findings remediated by target date / Total audit findings) × 100
  - Target: 100%
- **Regulatory Compliance**: Number of BIR penalties or audit qualifications due to change management failures
  - Target: 0

### 7.2 Change Portfolio Management

**Quarterly Change Review** (Finance Director):
- Review all changes implemented in quarter (aggregate metrics, trends)
- Identify high-impact changes (delivered expected benefits?)
- Identify failed changes (rolled back or required significant rework)
- Assess change capacity (are we overwhelming users with too many changes?)
- Adjust change approval thresholds or processes based on learnings

**Change Portfolio Dashboard**:
```sql
-- Quarterly change summary view
CREATE VIEW quarterly_change_summary AS
SELECT
  DATE_TRUNC('quarter', actual_implementation_date) AS quarter,
  change_type,
  COUNT(*) AS total_changes,
  COUNT(CASE WHEN status = 'implemented' THEN 1 END) AS implemented,
  COUNT(CASE WHEN status = 'rolled_back' THEN 1 END) AS rolled_back,
  ROUND(AVG(EXTRACT(DAY FROM (actual_implementation_date - request_date)))::NUMERIC, 1) AS avg_cycle_time_days,
  ROUND(COUNT(CASE WHEN status = 'implemented' THEN 1 END)::NUMERIC / COUNT(*)::NUMERIC * 100, 1) AS success_rate_pct
FROM change_request
WHERE actual_implementation_date IS NOT NULL
GROUP BY DATE_TRUNC('quarter', actual_implementation_date), change_type
ORDER BY quarter DESC, change_type;
```

### 7.3 Lessons Learned Repository

**Purpose**: Capture learnings from each change to improve future change management

**Lessons Learned Template** (captured in `change_request.lessons_learned` field):
```
What Went Well:
- [Aspect 1, e.g., "UAT identified critical defect before production"]
- [Aspect 2, e.g., "Training materials were clear and comprehensive"]

What Could Be Improved:
- [Issue 1, e.g., "Rollback plan not tested thoroughly, took longer than expected"]
- [Issue 2, e.g., "Communication timeline too short, users felt rushed"]

Recommendations for Future Changes:
- [Recommendation 1, e.g., "Allocate 1 day for rollback plan testing in UAT phase"]
- [Recommendation 2, e.g., "Send deployment notification 10 days in advance, not 5 days"]

Root Causes of Issues:
- [Root cause 1, e.g., "Incomplete impact assessment (missed affected workflow)"]
- [Root cause 2, e.g., "Insufficient UAT test case coverage (edge cases not tested)"]
```

**Lessons Learned Review Cadence**:
- **Immediate** (within 48 hours of implementation): Capture lessons while fresh
- **Monthly**: Finance Manager reviews all lessons learned, identifies recurring themes
- **Quarterly**: Finance Director reviews aggregated lessons, approves process improvements

**Process Improvement Loop**:
1. Lessons learned captured for each change
2. Monthly review identifies recurring issues (e.g., "UAT consistently finds issues with bank reconciliation changes")
3. Root cause analysis conducted (e.g., "Insufficient technical expertise in UAT team")
4. Corrective action defined (e.g., "Engage IT specialist in UAT for technical changes")
5. Corrective action implemented and validated
6. This change management document updated with new best practice

---

## 8. Special Scenarios and Exceptions

### 8.1 Period Unlock Procedures

**Trigger**: Material error discovered in closed period requiring correction

**Authorization Hierarchy**:
- **Non-material error** (<₱50,000 impact): Document as prior period adjustment, correct in current period (no period unlock required)
- **Material error** (₱50,000-₱500,000): Finance Director authorization required
- **Highly material error** (>₱500,000): Finance Director + External Auditor notification required

**Period Unlock Process**:
1. **Error Discovery and Documentation**:
   - GL Accountant discovers error and documents:
     - Nature of error (e.g., "Depreciation not recorded for 2 assets in January 2025")
     - Financial statement impact (affected accounts, amounts)
     - Root cause (why did error occur?)
     - Proposed correction (journal entry or transaction reversal)

2. **Approval Request**:
   - GL Accountant submits period unlock request to Finance Manager (via `change_request` table, type: 'emergency')
   - Finance Manager validates error and proposes corrective action
   - Finance Manager escalates to Finance Director with recommendation

3. **Finance Director Review**:
   - Validates materiality and impact
   - Reviews proposed correction for accuracy
   - Approves or rejects unlock request
   - If approved and >₱500,000 impact, notifies external auditor

4. **Period Unlock Execution**:
   - GL Accountant unlocks period in Odoo (Accounting > Configuration > Lock Dates)
   - Period unlock logged in audit trail (timestamp, unlocking user, justification)
   - Correcting journal entry posted
   - Affected financial statements regenerated
   - Period re-locked immediately after correction

5. **Validation and Documentation**:
   - Finance Manager reviews corrected financial statements (validate error resolved)
   - Updated financial statements distributed to stakeholders (with disclosure of prior period adjustment)
   - Root cause analysis conducted and preventive measures identified
   - Lessons learned documented

**Audit Trail Requirements**:
- Period unlock justification (detailed explanation of error and correction)
- Finance Director approval email archived
- Before/after financial statements (comparison showing impact)
- External auditor notification (if applicable)

**Frequency Monitoring**: Track period unlocks per year (target: ≤2 unlocks per year for material errors)

### 8.2 Control Deficiency Remediation

**Trigger**: Audit finding or internal control assessment identifies control deficiency

**Severity Classification**:
- **Material Weakness**: Significant deficiency or combination of significant deficiencies creating reasonable possibility of material misstatement not prevented or detected
- **Significant Deficiency**: Control deficiency or combination of deficiencies less severe than material weakness but important enough to merit attention
- **Deficiency**: Control design or operation shortcoming that does not rise to significant deficiency level

**Remediation Process**:
1. **Deficiency Documentation** (External Auditor or Finance Director):
   - Description of control deficiency (what control failed or is missing?)
   - Impact assessment (financial statement accounts affected, risk of misstatement)
   - Classification (material weakness / significant deficiency / deficiency)

2. **Remediation Plan Development** (Finance Manager):
   - Root cause analysis (why did deficiency occur?)
   - Proposed remediation (control design changes, personnel changes, system changes)
   - Implementation timeline (target completion date)
   - Responsible party (owner of remediation)

3. **Approval and Implementation**:
   - Finance Director approves remediation plan
   - If material weakness or significant deficiency, board notification required
   - Remediation implemented per approved plan (tracked as change request)

4. **Control Testing**:
   - Finance Manager tests remediated control (sample transactions, validate control operating effectively)
   - If control test fails, re-remediation required
   - If control test passes, control deficiency marked as "remediated"

5. **External Auditor Validation**:
   - External auditor re-tests control (typically in next audit cycle)
   - Auditor confirms remediation effective
   - Deficiency formally closed

**Remediation Timeline Expectations**:
- **Material Weakness**: ≤90 days from identification to implementation
- **Significant Deficiency**: ≤120 days
- **Deficiency**: ≤180 days

**Escalation**: If remediation timeline at risk, Finance Director escalates to board audit committee

### 8.3 Disaster Recovery and Business Continuity

**Change Management During Disaster Recovery**:
- Emergency changes required to restore close operations after disaster (system outage, data loss, natural disaster)
- **Approval**: Finance Director emergency authorization (post-approval review not required if disaster declared)
- **Process**: Minimal documentation, focus on restoring operations
- **Post-Recovery**: Full change request submitted retroactively (within 30 days of recovery), audit trail reconstructed

**Business Continuity Plan Integration**:
- Change management procedures included in BCP documentation (ensure change approvers and implementation owners have alternates)
- Disaster recovery drills test change management during crisis (e.g., can Finance Director approve emergency change from remote location?)

---

## 9. Governance and Oversight

### 9.1 Change Management Committee

**Charter**: Oversight body for complex or high-risk changes (optional, recommended for organizations with >20 changes per quarter)

**Membership**:
- **Chair**: Finance Director
- **Members**: Finance Manager, IT Manager, Tax Compliance Officer, GL Accountant (senior)
- **Advisors**: External Auditor (invited for control-relevant changes), Legal Counsel (invited for regulatory changes)

**Responsibilities**:
- Review and approve high-risk changes (risk level = high, or change amount >₱5M impact)
- Resolve change conflicts (e.g., competing priorities, resource constraints)
- Provide strategic guidance on change portfolio (alignment with business objectives)
- Escalate unresolved issues to board audit committee

**Meeting Frequency**: Monthly (or ad-hoc for urgent changes)

### 9.2 Board Audit Committee Reporting

**Reporting Cadence**: Quarterly

**Report Contents**:
1. **Change Portfolio Summary**:
   - Total changes by type (administrative, operational, control, system, emergency)
   - Total changes by status (approved, implemented, rolled back, rejected)
   - Change success rate and cycle time metrics

2. **High-Impact Changes**:
   - List of control changes approved in quarter (with risk level and mitigation summary)
   - List of emergency changes (with justification and post-approval review outcome)
   - Material weaknesses or significant deficiencies remediated

3. **Risk Summary**:
   - Open high-risk changes (approved but not yet implemented)
   - Failed changes (rolled back or requiring significant rework)
   - Audit findings related to change management

4. **Continuous Improvement**:
   - Key lessons learned
   - Process improvements implemented
   - Change management KPI trends

**Audit Committee Actions**:
- Approve material control changes (if not previously approved by board)
- Escalate concerns to full board (if change management process deficient)
- Request additional reporting or audits (if high-risk changes increasing)

### 9.3 Policy Review and Updates

**Review Frequency**: Annual (or upon trigger event)

**Trigger Events**:
- Audit finding related to change management
- Regulatory change (new BIR rules, accounting standards)
- Organizational restructure (new roles, departments)
- Technology change (new systems, integrations)

**Review Process**:
1. Finance Director reviews change management policy (this document)
2. Identifies updates needed based on:
   - Lessons learned from past year
   - Audit recommendations
   - Industry best practices
3. Proposes policy updates to board audit committee
4. Board audit committee approves updates
5. Updated policy communicated to finance team
6. Policy revision history updated

**Version Control**:
- Policy version format: `[Major].[Minor]` (e.g., 1.0, 1.1, 2.0)
- Major version increment: Significant policy restructure or new approval authorities
- Minor version increment: Clarifications, template updates, process improvements

---

## 10. Appendix

### 10.1 Glossary of Terms

- **Compensating Control**: Alternative control implemented to mitigate risk when primary control cannot be implemented
- **Control Deficiency**: Weakness in internal control design or operation
- **Material Weakness**: Severe control deficiency with reasonable possibility of material misstatement
- **Rollback**: Reverting system or process to prior state after failed change
- **User Acceptance Testing (UAT)**: Testing performed by end users to validate change meets requirements

### 10.2 Change Request Form (Printable Template)

```
============================================================
CHANGE REQUEST FORM
============================================================

REQUEST INFORMATION
-----------------------------------------------------------
Request Number: CHG-______-_____  (Auto-generated)
Request Date: _____________________
Requester Name: _____________________
Requester Role: _____________________

CHANGE CLASSIFICATION
-----------------------------------------------------------
Change Type: □ Administrative  □ Operational  □ Control  □ System  □ Emergency
Change Category: _____________________
Priority: □ Low  □ Medium  □ High  □ Critical

CHANGE DESCRIPTION
-----------------------------------------------------------
Change Title:
_________________________________________________________

Current State (Detailed description of current process/configuration):
_________________________________________________________
_________________________________________________________
_________________________________________________________

Proposed State (Detailed description of desired future state):
_________________________________________________________
_________________________________________________________
_________________________________________________________

Business Justification (Why is this change needed?):
_________________________________________________________
_________________________________________________________

Expected Benefits (Quantifiable benefits):
_________________________________________________________
_________________________________________________________

IMPACT ASSESSMENT
-----------------------------------------------------------
Affected Roles: _____________________
Affected Systems: _____________________
Risk Level: □ Low  □ Medium  □ High
Risk Description: _____________________
Mitigation Plan: _____________________

APPROVALS
-----------------------------------------------------------
Finance Manager Decision: □ Approved  □ Rejected  □ Pending
Finance Manager Comment: _____________________
Finance Manager Signature: ________________  Date: _______

Finance Director Decision: □ Approved  □ Rejected  □ Pending
Finance Director Comment: _____________________
Finance Director Signature: ________________  Date: _______

Board Decision (if required): □ Approved  □ Rejected  □ Not Required
Board Meeting Date: _____________________

IMPLEMENTATION
-----------------------------------------------------------
Implementation Owner: _____________________
Planned Implementation Date: _____________________
Rollback Plan Summary: _____________________

============================================================
FOR OFFICIAL USE ONLY (Finance Manager to complete)
============================================================
Status: □ Draft  □ Submitted  □ Under Review  □ Approved  □ Rejected  □ Implemented  □ Closed
Actual Implementation Date: _____________________
Validation Results: _____________________
Lessons Learned: _____________________
Closure Date: _____________________
```

### 10.3 Related Documents

- `03-roles-and-sod-matrix.md` - Role definitions and authority limits affected by changes
- `04-close-calendar-and-phases.md` - Close process timeline affected by operational changes
- `99-appendix-data-dictionary.md` - Technical data model for change tracking tables

### 10.4 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director | Initial change management framework creation |

---

**Document Classification**: Internal - Governance
**Review Frequency**: Annual (or upon trigger event)
**Next Review Date**: 2026-01-31
**Approver**: Finance Director (signature required)

**End of Document**