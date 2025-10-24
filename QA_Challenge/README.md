# QA Challenge - IAM Team

This directory contains solutions for the QA take-home challenge focused on testing approaches, critical thinking, and effective communication.

**Time-box**: ~4 hours of effort, return within 5 days
**Output**: Git repo (Markdown) or PDF

---

## Assignment Tasks Overview

> Be concise – reviewers will not read > 5 pages.

### Task A - "Release-0" Plan
**Create a pragmatic release checklist for enabling hedged reporting in next month's window.**

Include:
- Smoke & regression scope
- Environments (DEV → INT → PROD)
- Cut-off dates
- Owner matrix
- Communications plan
- Rollback/flag strategy

### Task B - Defect-Triage Matrix
**For BUG-101/102/103: Analyze and document triage decisions.**

For each bug, provide:
- Guess origin (FE, API, Ops, unclear)
- Next investigative step
- Evidence needed
- SLA class (P0/P1/P2)
- Block/Ship decision

### Task C - Finance QA Snippet ✅ **(COMPLETED)**
**Design and describe one automated (or semi-automated) test that verifies the hedged TWR calculation end-to-end.**

Requirements:
- Use any programming language, pseudo-code, or structured test design
- Keep the solution concise, without full framework boilerplate
- Include:
  - Test data setup
  - Expected value calculation
  - Where the test would fit in QA process
  - Validation of correctness

**Solutions**:
- `TASK_C_SOLUTION.md` - Unit-level formula validation (black-box, pure mathematical)
- `E2E_TEST_DESIGN.md` - **E2E BDD testing** (Database → API → Web with Cucumber + Playwright) ✨ **NEW**

---

## System Context

### High-Level Architecture
```
┌─────────────────────────┐
│ React Front-End (WebCo) │ ← Vite + TypeScript
└────────────▲────────────┘
             │ HTTPS/REST
┌────────────┴────────────┐
│ "ProdX" API image       │ ← Vendor-supplied Docker
│ (pricing, orders, rpt)  │
└────────────▲────────────┘
             │ Internal connection
┌────────────┴────────────┐
│ Postgres (managed)      │
└─────────────────────────┘
```

**Cloud**: Private OpenShift *or* Public AWS EKS
**Release Cadence**: **One production release per month** (typically first Tuesday)
**Business Context**: Platform used by Independent Asset Managers (IAMs) to onboard, monitor, and advise private-bank clients via browser-based portal.

---

## Feature: Enable Live Currency-Hedged Reporting

### User Story
```
As an IAM portfolio manager accessing the web portal
I want reports to show returns after FX hedging in real-time
So that clients see performance net of currency risk.
```

### Acceptance Criteria

| ID | Description |
|----|-------------|
| **AC1** | Given a EUR account with USD assets, When I open "Performance", Then the chart shows hedged time-weighted return (TWR) |
| **AC2** | Given hedging is disabled via Ops config flag, Then UI behaves exactly as today |
| **AC3** | Given hedging is enabled, When I export a PDF, Then both chart & table reflect hedged figures to 4 decimal places |
| **AC4** | UI must gracefully handle API latency > 1s (loader + max 3 retries) |
| **AC5** | Audit events stored in `audit.fx_hedge_requests` with user-ID, timestamp ms, elapsed ms |

### Tech Touch-Points

| Component | Change |
|-----------|--------|
| **API** | Call existing endpoint `GET /pricing/v2/hedged` (already GA) |
| **FE** | Add toggle logic, loader, chart values, PDF template tweak |
| **Ops** | Introduce flag `X-HEDGE-ENABLED`; run vendor migration script 238 to ensure audit table exists |

---

## Known Quirks & Constraints

- **ProdX sandbox quota**: Only 10 test portfolios; resets nightly at 02:00 UTC
- **WebCo cadence**: Merges to main Tuesday & Friday 16:00 CET (WebCo is external consultant)
- **Ops release window**: One release per month (first Tuesday, 18:00-20:00 CET)
- **Logging**: FE logs in Loki via X-Request-ID; API logs stdout; vendor has no remote access
- **Browser mix**: 85% Chrome, 10% Edge, 5% Safari (no IE)
- **SLA**: P0 = block release; P1 = ship with workaround; P2 = sprint backlog

---

## Sample Bug Reports (For Task B)

### BUG-101: Wrong IRR on PDF for multi-currency account
**Details**: Portfolio `qa-hedge-003`, hedged flag ON, export PDF
**Expected**: 5.43%
**Got**: 5.38%
**Raw JSON**: `irr:5.42571`

### BUG-102: 502 from /pricing/v2/hedged spikes > 30%
**Details**: Observed 21-Jul-2025 17:40-18:10 UTC
**Logs**: Show upstream reset

### BUG-103: Dashboard caches stale data after blue-green switch
**Details**: After release-223, some users see yesterday's values until hard refresh
**Suspected**: CloudFlare page-rule

---

## Finance Reporting Spec (For Task C)

### Hedged Time-Weighted Return (TWR) Formula

**Definitions:**
```
V_t  : portfolio value at time t (base currency)
C_t  : net cash flow at time t
FX_t : hedge ratio at time t (0-1)
h_t  : hedge factor at time t
```

**Calculation Steps:**
```
Step 1: V'_t = V_t × (1 − FX_t × (1 − h_t))
Step 2: TWR = Π_{i=1}^{n} [(V'_i − C_i) / V'_{i-1}] − 1
Step 3: Annualize if > 365 days: TWR_ann = (1+TWR)^(365/days) − 1
```

**Edge Cases to Consider:**
- Zero-value period
- Missing FX data
- FX > 1
- Rounding (4 dp display, 6 dp internal)

---

## Progress Tracker

- [x] Upload QA Challenge PDF
- [ ] **Task A**: Release-0 Plan
- [ ] **Task B**: Defect-Triage Matrix
- [x] **Task C**: Finance QA Snippet (Automated Test) ✅ **COMPLETED**

---

## QA/Release Manager Coordination Steps

| Step | Responsibility |
|------|----------------|
| 1 - Gather builds | Ask WebCo for latest signed-off FE image; ask ProdX vendor for latest API image and migration script |
| 2 - Deploy & test | Work with IT Ops to deploy both images to DEV → INT → PROD; run smoke + regression packs at each stage |
| 3 - Go/No-Go | Hold async checklist; verify ticket closure; sign-offs from Product, Ops, Vendor |
| 4 - Prod push | Coordinate IT Ops during the monthly window; monitor dashboards; run post-deploy checks |
| 5 - Follow-up | Confirm success, file retro items, raise vendor tickets if defects surface |

---

## Notes

This challenge reflects real-world QA scenarios for a financial platform handling currency-hedged performance reporting for asset managers.
