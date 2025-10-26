# Refactoring Candidates for E2E Test Framework

This document maps out code quality improvements identified during the X-HEDGE-ENABLED property refactoring.

**Status**: Documented only - NO changes made yet

---

## 1. Database Connection Management

### Current State
- Direct JDBC usage with `DriverManager.getConnection()` (StepDefinitions.java:84)
- Single connection per test scenario
- No connection pooling
- No retry logic for transient failures

### Proposed Refactoring
- **Implement HikariCP connection pooling**
- Use properties from test.properties:
  ```properties
  test.db.pool.min=2
  test.db.pool.max=10
  ```
- Benefits:
  - Connection reuse across test steps
  - Better resource management
  - Built-in connection validation
  - Thread-safe connection handling

### Impact
- Files: `StepDefinitions.java`
- Lines: 84 (setUp method), 99-103 (tearDown method)

---

## 2. Hard-coded Database Table Names

### Current State
Table names hard-coded in SQL strings throughout StepDefinitions.java:

| Table Name | Occurrences | Lines |
|------------|-------------|-------|
| `audit.fx_hedge_requests` | 5 | 327, 358, 446, 507, 598 |
| `ops_config` | 1 | 582 |

### Proposed Refactoring
Add to test.properties:
```properties
# Database schema/tables
test.db.table.audit=audit.fx_hedge_requests
test.db.table.ops_config=ops_config
```

Load as fields in StepDefinitions:
```java
private final String AUDIT_TABLE = System.getProperty("test.db.table.audit", "audit.fx_hedge_requests");
private final String OPS_CONFIG_TABLE = System.getProperty("test.db.table.ops_config", "ops_config");
```

### Benefits
- Environment-specific table names (dev, int, prod-like)
- Easier schema evolution
- Single source of truth for database structure

### Impact
- Files: `StepDefinitions.java`, `test.properties`
- Methods: `verifyAuditEventExists`, `setConfigFlag`, audit-related Then steps

---

## 3. Hard-coded API Endpoints

### Current State
Endpoint paths hard-coded in code:

| Endpoint | Location | Lines |
|----------|----------|-------|
| `/pricing/v2/hedged` | Route interception, comments | 22, 350, 351 |
| `/portfolios/` | URL construction | 244, 285 |

### Proposed Refactoring
Add to test.properties (note: some already exist):
```properties
# API endpoint paths
test.api.hedged.endpoint=/pricing/v2/hedged
test.web.portfolios.path=/portfolios
```

Load as fields:
```java
private final String HEDGED_API_ENDPOINT = System.getProperty("test.api.hedged.endpoint", "/pricing/v2/hedged");
private final String PORTFOLIOS_PATH = System.getProperty("test.web.portfolios.path", "/portfolios");
```

### Note
- `test.api.hedged.endpoint` already exists in test.properties:20 but is NOT used in code
- Currently mixing hard-coded paths with URL construction

### Impact
- Files: `StepDefinitions.java`
- Methods: `iOpenThePageForPortfolio`, `iNavigateToPortfolio`, route interceptors

---

## 4. Feature File Gherkin Step Text

### Current State
Step definitions tightly coupled to specific text like:
```gherkin
Given hedging is enabled via X-HEDGE-ENABLED flag
```

If the flag name changes in properties, the feature file text becomes misleading (still says "X-HEDGE-ENABLED" but might use different flag).

### Proposed Refactoring
**Option A**: Parameterize the step
```gherkin
Given hedging is enabled
```

**Option B**: Make it more generic
```gherkin
Given the hedging feature flag is enabled
```

**Option C**: Add dynamic step matching (complex)
```java
@Given("hedging is enabled via {word} flag")
public void hedgingIsEnabledViaFlag(String flagName) {
    // Validate flagName matches HEDGE_FLAG_NAME
    setConfigFlag(HEDGE_FLAG_NAME, true);
}
```

### Recommendation
- Use **Option A** for clarity and decoupling
- The implementation detail (flag name) belongs in properties, not BDD scenarios

### Impact
- Files: `hedged_twr_reporting.feature`, `StepDefinitions.java`
- All scenarios using flag-related steps (12 scenarios)

---

## 5. Test Data Management

### Current State
Test portfolio IDs defined in test.properties but only partially used:
```properties
test.portfolio.basic=qa-hedge-001
test.portfolio.multicurrency=qa-hedge-003
test.portfolio.bug101=qa-hedge-003
```

Feature files still hard-code portfolio IDs:
```gherkin
When I open the "Performance" page for portfolio "qa-hedge-001"
```

### Proposed Refactoring
**Option A**: Use scenario outline with examples tables
```gherkin
Scenario Outline: Test basic calculation
  When I open the "Performance" page for portfolio "<portfolio>"

  Examples:
    | portfolio     |
    | qa-hedge-001  |
```

**Option B**: Create background data setup steps
```gherkin
Background:
  Given I am testing portfolio "basic"  # Resolves to test.portfolio.basic
```

### Benefits
- Single source of truth for test data
- Easier test data management across environments

### Impact
- Files: All feature files, potentially StepDefinitions.java

---

## 6. Magic Numbers and Timeouts

### Current State
Some timeouts defined in properties:
```properties
test.timeout.pageload.ms=30000
test.timeout.element.ms=10000
test.timeout.api.ms=5000
```

But code still has hard-coded timeouts:
```java
page.waitForSelector("[data-testid='hedged-twr-chart']",
    new Page.WaitForSelectorOptions().setTimeout(10000));
```

### Proposed Refactoring
Load timeout properties:
```java
private final int TIMEOUT_ELEMENT_MS = Integer.parseInt(
    System.getProperty("test.timeout.element.ms", "10000")
);
```

Use in code:
```java
page.waitForSelector("[data-testid='hedged-twr-chart']",
    new Page.WaitForSelectorOptions().setTimeout(TIMEOUT_ELEMENT_MS));
```

### Benefits
- Consistent timeout handling
- Environment-specific tuning (CI/CD vs local)
- Single place to adjust timing issues

### Impact
- Files: `StepDefinitions.java`
- Methods: Multiple Playwright wait operations

---

## 7. Error Handling and Logging

### Current State
Inconsistent exception handling:
- Some methods throw raw `RuntimeException`
- Some methods catch and wrap `SQLException`
- No structured logging framework (would need to check dependencies)

### Proposed Refactoring
- Add SLF4J/Logback for structured logging
- Create custom exception types: `TestDatabaseException`, `TestApiException`
- Use log level from properties: `test.log.level=INFO`
- Add contextual information to exceptions (portfolio ID, test scenario)

### Benefits
- Better debugging when tests fail
- Consistent error handling patterns
- CI/CD friendly log output

### Impact
- Files: `StepDefinitions.java`, potentially new exception classes
- Would need to add logging dependencies to pom.xml

---

## Implementation Priority

1. **High Priority** (blocking issues):
   - Database Connection Management (HikariCP) - prevents connection leaks
   - Hard-coded Database Table Names - environment portability

2. **Medium Priority** (code quality):
   - Hard-coded API Endpoints - maintainability
   - Feature File Gherkin refinement - readability

3. **Low Priority** (nice-to-have):
   - Magic Numbers/Timeouts - convenience
   - Error Handling/Logging - debugging
   - Test Data Management - scalability

---

## Notes

- All refactorings should maintain backward compatibility where possible
- Properties should have sensible defaults (fail-safe)
- Changes should be tested incrementally
- Document any breaking changes in test.properties comments

**Remember**: This is a map only - no changes implemented yet!
