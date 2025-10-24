# E2E Test Design: Hedged TWR Performance Reporting

## Overview

This document describes the **End-to-End (E2E) black-box testing approach** for the Hedged Time-Weighted Return (TWR) feature, covering the complete data flow from **Database → API → Web UI**.

**Approach**: BDD using Cucumber with Playwright for browser automation, testing the real system without knowledge of internal implementation.

---

## Architecture

### System Under Test

```
┌─────────────────────────────┐
│  PostgreSQL Database        │ ← Portfolio data, audit events
└──────────┬──────────────────┘
           │ JDBC
           ↓
┌─────────────────────────────┐
│  ProdX API (Docker)         │ ← GET /pricing/v2/hedged
│  Vendor-supplied            │
└──────────┬──────────────────┘
           │ HTTPS/REST
           ↓
┌─────────────────────────────┐
│  React Front-End (WebCo)    │ ← Vite + TypeScript
│  Browser-based UI           │
└─────────────────────────────┘
```

### Test Stack

```
┌─────────────────────────────┐
│  Cucumber BDD Framework     │ ← Given/When/Then scenarios
└──────────┬──────────────────┘
           │
           ├─→ Playwright (Java) ← Browser automation (Chromium)
           │
           ├─→ REST Assured ← API testing (HTTP calls)
           │
           └─→ JDBC ← Database setup & validation
```

---

## Test Levels

### Comparison: Unit vs E2E

| Aspect | Unit Tests (Current) | E2E Tests (New) |
|--------|---------------------|-----------------|
| **Scope** | Pure formula validation | Full system workflow |
| **Dependencies** | None (isolated calculator) | DB + API + Web UI + Browser |
| **Speed** | <1 second | 5-30 seconds per scenario |
| **Environment** | In-memory | Real test environment |
| **Data Source** | Hardcoded test values | PostgreSQL test database |
| **Validation** | Mathematical correctness | Business workflow correctness |
| **CI/CD** | Every commit | Pre-release / regression |

**Philosophy**: Unit tests verify **formulas**, E2E tests verify **user experience**.

---

## BDD Scenarios

### Acceptance Criteria Coverage

All 5 acceptance criteria are covered with multiple scenarios:

| AC | Feature | Scenarios | Tags |
|----|---------|-----------|------|
| **AC1** | EUR account shows hedged TWR | 2 scenarios | `@AC1`, `@E2E` |
| **AC2** | Feature flag toggles hedging | 2 scenarios | `@AC2`, `@FeatureFlag` |
| **AC3** | PDF export with 4dp precision | 2 scenarios | `@AC3`, `@PDF` |
| **AC4** | API latency & retry handling | 3 scenarios | `@AC4`, `@Performance` |
| **AC5** | Audit events logging | 3 scenarios | `@AC5`, `@Audit` |

**Total**: 12+ E2E scenarios covering happy paths, edge cases, and error conditions.

---

## Test Execution Flow

### Example: AC1 Scenario

```gherkin
Scenario: AC1 - EUR account with USD assets shows hedged TWR on Performance chart
  Given a portfolio "qa-hedge-001" exists in the database with:
    | account_currency | EUR |
    | asset_currencies | USD |
  And the portfolio has the following periods:
    | portfolio_value | cash_flow | hedge_ratio | hedge_factor |
    | 100000.0        | 0.0       | 0.5         | 0.95         |
    | 105000.0        | 1000.0    | 0.5         | 0.95         |
  And hedging is enabled via X-HEDGE-ENABLED flag
  When I open the "Performance" page for portfolio "qa-hedge-001"
  Then the chart should display hedged TWR
  And the displayed TWR value should be approximately 3.97%
  And an audit event should be logged in audit.fx_hedge_requests
```

### Step-by-Step Execution

**Given Steps (Test Data Setup):**
1. **Database**: Insert portfolio `qa-hedge-001` into `portfolios` table
2. **Database**: Insert period data into `portfolio_periods` table
3. **Database**: Set `X-HEDGE-ENABLED = true` in `ops_config` table

**When Steps (User Actions):**
4. **Browser**: Playwright navigates to `/portfolios/qa-hedge-001/performance`
5. **API**: Web UI calls `GET /pricing/v2/hedged?portfolio=qa-hedge-001`
6. **Database**: API reads periods from `portfolio_periods`
7. **Calculation**: API calculates hedged TWR (using the formula)
8. **Response**: API returns `{"twr": 0.0397, "hedged": true}`
9. **Rendering**: Web UI displays chart with 3.97% value

**Then Steps (Validation):**
10. **Browser**: Playwright verifies chart element exists with `data-chart-type="hedged"`
11. **Browser**: Playwright extracts TWR value from `[data-testid='twr-value']`
12. **Assertion**: Assert `3.97% ± 0.01%`
13. **Database**: Query `audit.fx_hedge_requests` for event with:
    - `portfolio_id = qa-hedge-001`
    - `user_id = test-manager@iam.com`
    - `operation = GET_HEDGED_TWR`
    - `timestamp_ms` within last 5 seconds
    - `elapsed_ms > 0`

---

## Test Infrastructure

### Configuration Files

#### `test.properties`
```properties
# Database
test.db.url=jdbc:postgresql://localhost:5432/iam_test
test.db.user=test_user
test.db.password=test_pass

# API
test.api.url=http://localhost:8080

# Web UI
test.web.url=http://localhost:3000

# Browser
test.browser.type=chromium
test.browser.headless=true
```

### Running Tests

```bash
# Install Playwright browsers (first time only)
mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install"

# Run all E2E tests
mvn test

# Run specific acceptance criteria
mvn test -Dcucumber.filter.tags="@AC1"
mvn test -Dcucumber.filter.tags="@AC3 and @PDF"

# Run smoke tests
mvn test -Dcucumber.filter.tags="@Smoke"

# Run without headless mode (for debugging)
mvn test -Dtest.browser.headless=false
```

### Reports

After test execution, reports are generated in `target/cucumber-reports/`:

- **HTML**: `cucumber.html` (interactive report with screenshots)
- **JSON**: `cucumber.json` (for CI/CD integration)
- **JUnit**: `cucumber.xml` (for Jenkins/GitLab CI)

---

## Key Testing Patterns

### 1. Database Setup (Given Steps)

```java
@Given("a portfolio {string} exists in the database with:")
public void aPortfolioExistsInTheDatabaseWith(String portfolioId, Map<String, String> data) {
    String sql = "INSERT INTO portfolios (portfolio_id, account_currency, asset_currencies) " +
                 "VALUES (?, ?, ?) ON CONFLICT (portfolio_id) DO UPDATE ...";

    PreparedStatement stmt = dbConnection.prepareStatement(sql);
    stmt.setString(1, portfolioId);
    stmt.setString(2, data.get("account_currency"));
    stmt.setString(3, data.get("asset_currencies"));
    stmt.executeUpdate();
}
```

### 2. Browser Automation (When Steps)

```java
@When("I open the {string} page for portfolio {string}")
public void iOpenThePageForPortfolio(String pageName, String portfolioId) {
    String url = WEB_BASE_URL + "/portfolios/" + portfolioId + "/" + pageName.toLowerCase();
    page.navigate(url);
    page.waitForLoadState(LoadState.NETWORKIDLE);
}
```

### 3. UI Validation (Then Steps)

```java
@Then("the chart should display hedged TWR")
public void theChartShouldDisplayHedgedTWR() {
    Locator chartElement = page.locator("[data-testid='hedged-twr-chart']");
    assertTrue(chartElement.isVisible(), "Hedged TWR chart should be visible");

    String chartType = chartElement.getAttribute("data-chart-type");
    assertEquals("hedged", chartType, "Chart should display hedged data");
}
```

### 4. Database Validation (Then Steps)

```java
@Then("an audit event should be logged in audit.fx_hedge_requests")
public void anAuditEventShouldBeLoggedInAuditTable() {
    String sql = "SELECT COUNT(*) FROM audit.fx_hedge_requests " +
                 "WHERE portfolio_id = ? AND user_id = ? AND timestamp_ms > ?";

    PreparedStatement stmt = dbConnection.prepareStatement(sql);
    stmt.setString(1, currentPortfolioId);
    stmt.setString(2, currentUserId);
    stmt.setLong(3, testStartTime);

    ResultSet rs = stmt.executeQuery();
    rs.next();
    int count = rs.getInt(1);

    assertTrue(count > 0, "Audit event should exist");
}
```

---

## AC-Specific Test Approaches

### AC1: Hedged TWR Display

**Test Approach:**
- Insert portfolio with EUR base currency and USD assets
- Verify chart renders with correct hedged TWR value
- Cross-verify with manual formula calculation

**Key Assertions:**
- Chart element exists and is visible
- Chart type attribute = "hedged"
- TWR value matches expected calculation (within tolerance)

---

### AC2: Feature Flag Toggle

**Test Approach:**
- Toggle `X-HEDGE-ENABLED` flag in database
- Verify UI behavior changes accordingly
- Ensure no API calls to `/pricing/v2/hedged` when disabled

**Key Assertions:**
- Flag OFF → unhedged chart displayed
- Flag OFF → no audit events logged
- Flag ON → hedged chart displayed

**Network Interception:**
```java
page.route("**/pricing/v2/hedged", route -> {
    if (!hedgingEnabled) {
        fail("API should not call /pricing/v2/hedged when hedging is disabled");
    }
    route.continue_();
});
```

---

### AC3: PDF Export Precision

**Test Approach:**
- Generate PDF export via UI button click
- Parse PDF using Apache PDFBox
- Verify all TWR values are displayed to 4 decimal places

**PDF Validation:**
```java
@Then("the PDF table should display TWR as {string} (4 decimal places)")
public void thePDFTableShouldDisplayTWRAs(String expectedValue) {
    PDDocument document = PDDocument.load(new File(downloadedPdfPath));
    PDFTextStripper stripper = new PDFTextStripper();
    String text = stripper.getText(document);

    assertTrue(text.contains(expectedValue),
        "PDF should contain TWR value: " + expectedValue);
}
```

---

### AC4: Latency & Retry Handling

**Test Approach:**
- Simulate API latency using test proxy or mock
- Verify loading indicator appears within 100ms
- Verify retry logic triggers on failure (max 3 attempts)

**Latency Simulation:**
```java
// Configure test API proxy to introduce delay
page.route("**/pricing/v2/hedged", route -> {
    Thread.sleep(1500); // Simulate 1.5s latency
    route.continue_();
});
```

**Retry Validation:**
```java
int apiCallCount = 0;
page.route("**/pricing/v2/hedged", route -> {
    apiCallCount++;
    if (apiCallCount < 3) {
        route.abort(); // Simulate failure
    } else {
        route.continue_(); // Succeed on 3rd attempt
    }
});

// Verify retry happened
assertEquals(3, apiCallCount, "API should be retried 3 times");
```

---

### AC5: Audit Event Logging

**Test Approach:**
- Perform operations (view chart, export PDF)
- Query `audit.fx_hedge_requests` table
- Verify all required fields are populated correctly

**Key Assertions:**
```sql
SELECT user_id, portfolio_id, timestamp_ms, elapsed_ms, operation
FROM audit.fx_hedge_requests
WHERE portfolio_id = 'qa-hedge-010'
  AND timestamp_ms > {test_start_time}
ORDER BY timestamp_ms;
```

**Validation:**
- `user_id` matches authenticated user
- `timestamp_ms` is in milliseconds since epoch
- `elapsed_ms > 0` and `< 5000` (reasonable API response time)
- `operation` matches action (e.g., "GET_HEDGED_TWR", "EXPORT_PDF")

---

## Test Data Management

### Database Schema (Simplified)

```sql
-- Portfolio metadata
CREATE TABLE portfolios (
    portfolio_id VARCHAR(50) PRIMARY KEY,
    account_currency VARCHAR(3),
    asset_currencies TEXT,
    created_at TIMESTAMP
);

-- Portfolio periods (for TWR calculation)
CREATE TABLE portfolio_periods (
    portfolio_id VARCHAR(50) REFERENCES portfolios(portfolio_id),
    period_index INT,
    portfolio_value NUMERIC(15, 2),
    cash_flow NUMERIC(15, 2),
    hedge_ratio NUMERIC(5, 4),
    hedge_factor NUMERIC(5, 4),
    PRIMARY KEY (portfolio_id, period_index)
);

-- Audit events (AC5)
CREATE TABLE audit.fx_hedge_requests (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255),
    portfolio_id VARCHAR(50),
    timestamp_ms BIGINT,
    elapsed_ms BIGINT,
    operation VARCHAR(50)
);

-- Ops configuration (AC2)
CREATE TABLE ops_config (
    flag_name VARCHAR(100) PRIMARY KEY,
    enabled BOOLEAN
);
```

### Test Data Cleanup

```java
@After
public void tearDown() {
    // Clean up test data after each scenario
    String[] tables = {
        "audit.fx_hedge_requests",
        "portfolio_periods",
        "portfolios"
    };

    for (String table : tables) {
        String sql = "DELETE FROM " + table + " WHERE portfolio_id LIKE 'qa-hedge-%'";
        dbConnection.createStatement().execute(sql);
    }
}
```

---

## CI/CD Integration

### Pipeline Stages

```yaml
stages:
  - build
  - unit-test
  - e2e-test
  - report

unit-test:
  stage: unit-test
  script:
    - mvn test -Dtest=HedgedTWRCalculatorTest
  artifacts:
    reports:
      junit: target/surefire-reports/*.xml

e2e-test:
  stage: e2e-test
  services:
    - postgres:14
  before_script:
    - docker-compose up -d api web
    - mvn exec:java -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install chromium"
  script:
    - mvn test -Dtest=CucumberTestRunner
  artifacts:
    reports:
      junit: target/cucumber-reports/cucumber.xml
    paths:
      - target/cucumber-reports/
      - target/screenshots/
  when: manual  # Run on-demand for regression
```

---

## Benefits of E2E Approach

| Benefit | Description |
|---------|-------------|
| ✅ **User-Centric** | Tests verify actual user workflows, not just code correctness |
| ✅ **Integration Coverage** | Validates DB → API → Web flow end-to-end |
| ✅ **Regression Safety** | Catches breaking changes across system boundaries |
| ✅ **BDD Clarity** | Cucumber scenarios serve as living documentation |
| ✅ **Black-Box** | No knowledge of internal implementation required |
| ✅ **Audit Trail** | Verifies audit logging (AC5) in real database |
| ✅ **Performance** | Tests API latency and retry logic (AC4) in realistic conditions |

---

## Limitations & Trade-offs

| Limitation | Mitigation |
|------------|------------|
| ⚠️ **Slower Execution** | Run E2E tests nightly or pre-release, not every commit |
| ⚠️ **Environment Dependency** | Use Docker Compose for consistent test environment |
| ⚠️ **Test Data Fragility** | Implement robust cleanup in `@After` hooks |
| ⚠️ **Flakiness Risk** | Use explicit waits, retry mechanisms, and screenshots on failure |
| ⚠️ **Debugging Difficulty** | Enable non-headless mode, capture network traces, save screenshots |

---

## Running Tests Locally

### Prerequisites

```bash
# 1. Start test environment (PostgreSQL, API, Web UI)
docker-compose -f docker-compose.test.yml up -d

# 2. Install Playwright browsers (one-time)
mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install chromium"

# 3. Run database migrations
psql -h localhost -U test_user -d iam_test -f src/test/resources/db/schema.sql
```

### Execute Tests

```bash
# Run all E2E tests
mvn test -Dtest=CucumberTestRunner

# Run specific tag
mvn test -Dcucumber.filter.tags="@AC1"

# Debug mode (non-headless browser)
mvn test -Dtest.browser.headless=false -Dcucumber.filter.tags="@AC3"

# View HTML report
open target/cucumber-reports/cucumber.html
```

---

## Troubleshooting

### Common Issues

**Issue**: `Connection refused to localhost:5432`
**Fix**: Ensure PostgreSQL is running: `docker-compose ps`

**Issue**: `Element not found: [data-testid='hedged-twr-chart']`
**Fix**: Check UI selectors match actual implementation, update test.properties

**Issue**: `Audit event not found in database`
**Fix**: Verify API is configured to log events, check `ops_config` table

---

## Next Steps

1. **Implement UI Selectors**: Update web UI with `data-testid` attributes for stable test selectors
2. **API Mocking**: Add test proxy for simulating latency/failures (AC4)
3. **PDF Parsing**: Complete PDFBox integration for AC3 validation
4. **Parallel Execution**: Enable Cucumber parallel execution for faster test runs
5. **Screenshot Comparison**: Add visual regression testing for charts

---

## References

- **Cucumber**: https://cucumber.io/docs/cucumber/
- **Playwright Java**: https://playwright.dev/java/
- **REST Assured**: https://rest-assured.io/
- **Apache PDFBox**: https://pdfbox.apache.org/

---

**Authored by**: QA Team
**Last Updated**: 2025-10-24
**Status**: Ready for Implementation
