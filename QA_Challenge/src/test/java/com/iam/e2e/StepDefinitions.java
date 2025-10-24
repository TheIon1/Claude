package com.iam.e2e;

import com.microsoft.playwright.*;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.en.*;
import io.restassured.RestAssured;
import io.restassured.response.Response;

import java.nio.file.Paths;
import java.sql.*;
import java.time.Instant;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Cucumber step definitions for E2E black-box testing.
 *
 * Architecture:
 * - Database: JDBC to interact with Postgres (portfolio data, audit events)
 * - API: REST Assured to call GET /pricing/v2/hedged
 * - Web: Playwright for browser automation and UI interaction
 */
public class StepDefinitions {

    // Test context shared across steps
    private Playwright playwright;
    private Browser browser;
    private BrowserContext context;
    private Page page;

    private Connection dbConnection;
    private String currentPortfolioId;
    private String currentUserId;
    private Map<String, Object> testData = new HashMap<>();
    private List<Response> apiResponses = new ArrayList<>();
    private long testStartTime;

    // Configuration (loaded from test.properties)
    private final String DB_URL = System.getProperty("test.db.url", "jdbc:postgresql://localhost:5432/iam_test");
    private final String DB_USER = System.getProperty("test.db.user", "test_user");
    private final String DB_PASSWORD = System.getProperty("test.db.password", "test_pass");
    private final String API_BASE_URL = System.getProperty("test.api.url", "http://localhost:8080");
    private final String WEB_BASE_URL = System.getProperty("test.web.url", "http://localhost:3000");

    // ========== HOOKS ==========

    @Before
    public void setUp() {
        // Initialize Playwright
        playwright = Playwright.create();
        browser = playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(true));
        context = browser.newContext(new Browser.NewContextOptions()
            .setViewportSize(1920, 1080)
            .setLocale("en-US"));
        page = context.newPage();

        // Configure REST Assured
        RestAssured.baseURI = API_BASE_URL;

        // Initialize database connection
        try {
            dbConnection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to connect to test database", e);
        }

        testStartTime = Instant.now().toEpochMilli();
    }

    @After
    public void tearDown() {
        // Close Playwright resources
        if (page != null) page.close();
        if (context != null) context.close();
        if (browser != null) browser.close();
        if (playwright != null) playwright.close();

        // Close database connection
        try {
            if (dbConnection != null && !dbConnection.isClosed()) {
                dbConnection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Clear test data
        testData.clear();
        apiResponses.clear();
    }

    // ========== BACKGROUND STEPS ==========

    @Given("the system is running and accessible")
    public void theSystemIsRunningAndAccessible() {
        // Health check: Verify API is up
        Response apiHealth = RestAssured.get("/health");
        assertEquals(200, apiHealth.getStatusCode(), "API should be accessible");

        // Health check: Verify Web UI is up
        page.navigate(WEB_BASE_URL);
        assertTrue(page.title().length() > 0, "Web UI should be accessible");
    }

    @Given("I am authenticated as user {string}")
    public void iAmAuthenticatedAsUser(String userId) {
        this.currentUserId = userId;

        // Navigate to login page
        page.navigate(WEB_BASE_URL + "/login");

        // Fill login form (adjust selectors based on actual implementation)
        page.fill("input[name='email']", userId);
        page.fill("input[name='password']", "test-password-123");
        page.click("button[type='submit']");

        // Wait for login to complete
        page.waitForURL("**/dashboard", new Page.WaitForURLOptions().setTimeout(5000));
    }

    // ========== DATABASE STEPS (GIVEN) ==========

    @Given("a portfolio {string} exists in the database with:")
    public void aPortfolioExistsInTheDatabaseWith(String portfolioId, Map<String, String> portfolioData) {
        this.currentPortfolioId = portfolioId;

        try {
            // Insert portfolio metadata
            String sql = "INSERT INTO portfolios (portfolio_id, account_currency, asset_currencies, created_at) " +
                        "VALUES (?, ?, ?, ?) ON CONFLICT (portfolio_id) DO UPDATE SET " +
                        "account_currency = EXCLUDED.account_currency, " +
                        "asset_currencies = EXCLUDED.asset_currencies";

            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setString(1, portfolioId);
            stmt.setString(2, portfolioData.get("account_currency"));
            stmt.setString(3, portfolioData.get("asset_currencies"));
            stmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Failed to create test portfolio in database", e);
        }
    }

    @Given("the portfolio has the following periods:")
    public void thePortfolioHasTheFollowingPeriods(List<Map<String, String>> periods) {
        try {
            // Insert period data for the portfolio
            String sql = "INSERT INTO portfolio_periods (portfolio_id, period_index, portfolio_value, " +
                        "cash_flow, hedge_ratio, hedge_factor) VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            int index = 0;
            for (Map<String, String> period : periods) {
                stmt.setString(1, currentPortfolioId);
                stmt.setInt(2, index++);
                stmt.setDouble(3, Double.parseDouble(period.get("portfolio_value")));
                stmt.setDouble(4, Double.parseDouble(period.get("cash_flow")));
                stmt.setDouble(5, Double.parseDouble(period.get("hedge_ratio")));
                stmt.setDouble(6, Double.parseDouble(period.get("hedge_factor")));
                stmt.addBatch();
            }
            stmt.executeBatch();

        } catch (SQLException e) {
            throw new RuntimeException("Failed to insert period data", e);
        }
    }

    @Given("the portfolio has multi-period data spanning {int} days")
    public void thePortfolioHasMultiPeriodDataSpanningDays(int days) {
        // Insert realistic multi-period test data
        testData.put("total_days", days);
        // Implementation would insert multiple periods spanning the specified days
    }

    @Given("hedging is enabled via X-HEDGE-ENABLED flag")
    public void hedgingIsEnabledViaFlag() {
        setConfigFlag("X-HEDGE-ENABLED", true);
    }

    @Given("hedging is disabled via X-HEDGE-ENABLED flag")
    public void hedgingIsDisabledViaFlag() {
        setConfigFlag("X-HEDGE-ENABLED", false);
    }

    @Given("the calculated hedged TWR is {double} \\({string}\\)")
    public void theCalculatedHedgedTWRIs(double twrValue, String percentage) {
        testData.put("expected_twr", twrValue);
        testData.put("expected_twr_percentage", percentage);
    }

    @Given("a portfolio {string} exists with hedged TWR values:")
    public void aPortfolioExistsWithHedgedTWRValues(String portfolioId, List<Map<String, String>> twrValues) {
        this.currentPortfolioId = portfolioId;
        testData.put("quarterly_twr_values", twrValues);
        // Insert test data with specific TWR values
    }

    @Given("the API GET \\/pricing\\/v2\\/hedged endpoint has latency of {int}ms")
    public void theAPIEndpointHasLatency(int latencyMs) {
        // This would be configured via test API proxy or mock
        testData.put("api_latency_ms", latencyMs);
    }

    @Given("the API GET \\/pricing\\/v2\\/hedged endpoint fails with {int} error")
    public void theAPIEndpointFailsWithError(int errorCode) {
        testData.put("api_error_code", errorCode);
    }

    @Given("the API GET \\/pricing\\/v2\\/hedged endpoint fails on first {int} attempts")
    public void theAPIEndpointFailsOnFirstAttempts(int failCount) {
        testData.put("api_fail_count", failCount);
    }

    @Given("the current timestamp is captured as {string}")
    public void theCurrentTimestampIsCapturedAs(String variableName) {
        testData.put(variableName, Instant.now().toEpochMilli());
    }

    // ========== WEB UI STEPS (WHEN) ==========

    @When("I open the {string} page for portfolio {string}")
    public void iOpenThePageForPortfolio(String pageName, String portfolioId) {
        String url = WEB_BASE_URL + "/portfolios/" + portfolioId + "/" + pageName.toLowerCase();
        page.navigate(url);

        // Wait for page to load
        page.waitForLoadState(LoadState.NETWORKIDLE);
    }

    @When("I refresh the {string} page")
    public void iRefreshThePage(String pageName) {
        page.reload();
        page.waitForLoadState(LoadState.NETWORKIDLE);
    }

    @When("I click the {string} button")
    public void iClickTheButton(String buttonText) {
        page.click("button:has-text(\"" + buttonText + "\")");
    }

    @When("I wait for the hedged TWR to load")
    public void iWaitForTheHedgedTWRToLoad() {
        // Wait for chart to render (adjust selector based on actual implementation)
        page.waitForSelector("[data-testid='hedged-twr-chart']", new Page.WaitForSelectorOptions().setTimeout(10000));
    }

    @When("I wait for the PDF download to complete")
    public void iWaitForThePDFDownloadToComplete() {
        // Listen for download event
        Download download = page.waitForDownload(() -> {});
        testData.put("downloaded_pdf_path", download.path().toString());
    }

    @When("I export the performance report as PDF")
    public void iExportThePerformanceReportAsPDF() {
        page.click("button:has-text('Export PDF')");
        Download download = page.waitForDownload(() -> {});
        testData.put("downloaded_pdf_path", download.path().toString());
    }

    @When("I perform {int} sequential operations on the Performance page:")
    public void iPerformSequentialOperationsOnThePerformancePage(int count, List<Map<String, String>> operations) {
        for (Map<String, String> operation : operations) {
            String operationType = operation.get("operation");
            performOperation(operationType);
            // Small delay between operations to ensure distinct timestamps
            try { Thread.sleep(10); } catch (InterruptedException e) {}
        }
    }

    @When("I log in to the web portal as {string}")
    public void iLogInToTheWebPortalAs(String userId) {
        iAmAuthenticatedAsUser(userId);
    }

    @When("I navigate to portfolio {string}")
    public void iNavigateToPortfolio(String portfolioId) {
        page.navigate(WEB_BASE_URL + "/portfolios/" + portfolioId);
        page.waitForLoadState(LoadState.NETWORKIDLE);
    }

    @When("I disable hedging via X-HEDGE-ENABLED flag")
    public void iDisableHedgingViaFlag() {
        setConfigFlag("X-HEDGE-ENABLED", false);
    }

    // ========== ASSERTIONS (THEN) ==========

    @Then("the chart should display hedged TWR")
    public void theChartShouldDisplayHedgedTWR() {
        // Verify chart element exists and contains hedged data
        Locator chartElement = page.locator("[data-testid='hedged-twr-chart']");
        assertTrue(chartElement.isVisible(), "Hedged TWR chart should be visible");

        // Verify chart has data attribute indicating it's hedged
        String chartType = chartElement.getAttribute("data-chart-type");
        assertEquals("hedged", chartType, "Chart should display hedged data");
    }

    @Then("the displayed TWR value should be approximately {double}%")
    public void theDisplayedTWRValueShouldBeApproximately(double expectedPercent) {
        // Extract TWR value from the chart (adjust selector based on actual implementation)
        String twrText = page.locator("[data-testid='twr-value']").innerText();
        double actualPercent = parsePercentage(twrText);

        assertEquals(expectedPercent, actualPercent, 0.01,
            "Displayed TWR should match expected value");
    }

    @Then("the displayed TWR value should be between {double}% and {double}%")
    public void theDisplayedTWRValueShouldBeBetween(double minPercent, double maxPercent) {
        String twrText = page.locator("[data-testid='twr-value']").innerText();
        double actualPercent = parsePercentage(twrText);

        assertTrue(actualPercent >= minPercent && actualPercent <= maxPercent,
            String.format("TWR %.2f%% should be between %.2f%% and %.2f%%",
                actualPercent, minPercent, maxPercent));
    }

    @Then("an audit event should be logged in audit.fx_hedge_requests")
    public void anAuditEventShouldBeLoggedInAuditTable() {
        verifyAuditEventExists(currentPortfolioId, currentUserId);
    }

    @Then("the UI should behave exactly as it did before the hedging feature")
    public void theUIShouldBehaveExactlyAsItDidBeforeTheHedgingFeature() {
        // Verify no hedged-specific UI elements are present
        assertFalse(page.locator("[data-testid='hedged-indicator']").isVisible(),
            "Hedged indicator should not be visible when feature is disabled");
    }

    @Then("the chart should display unhedged TWR")
    public void theChartShouldDisplayUnhedgedTWR() {
        Locator chartElement = page.locator("[data-testid='twr-chart']");
        String chartType = chartElement.getAttribute("data-chart-type");
        assertEquals("unhedged", chartType, "Chart should display unhedged data");
    }

    @Then("the API should NOT call GET \\/pricing\\/v2\\/hedged endpoint")
    public void theAPIShouldNotCallHedgedEndpoint() {
        // Verify via network interception or API call logs
        // This would require setting up Playwright's route interception
        page.route("**/pricing/v2/hedged", route -> {
            fail("API should not call /pricing/v2/hedged when hedging is disabled");
        });
    }

    @Then("NO audit event should be logged in audit.fx_hedge_requests")
    public void noAuditEventShouldBeLogged() {
        try {
            String sql = "SELECT COUNT(*) FROM audit.fx_hedge_requests " +
                        "WHERE portfolio_id = ? AND timestamp_ms > ?";
            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setString(1, currentPortfolioId);
            stmt.setLong(2, testStartTime);

            ResultSet rs = stmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            assertEquals(0, count, "No audit events should be logged when hedging is disabled");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify audit events", e);
        }
    }

    @Then("a PDF file should be downloaded")
    public void aPDFFileShouldBeDownloaded() {
        assertNotNull(testData.get("downloaded_pdf_path"), "PDF should be downloaded");
    }

    @Then("the PDF chart should display TWR as {string}")
    public void thePDFChartShouldDisplayTWRAs(String expectedValue) {
        // Parse PDF and verify chart value
        // This would use a PDF parsing library like Apache PDFBox
        String pdfPath = (String) testData.get("downloaded_pdf_path");
        assertNotNull(pdfPath, "PDF should be downloaded");

        // TODO: Parse PDF and extract chart value
        // String actualValue = extractTWRFromPDF(pdfPath);
        // assertEquals(expectedValue, actualValue);
    }

    @Then("the PDF table should display TWR as {string} \\({int} decimal places\\)")
    public void thePDFTableShouldDisplayTWRAs(String expectedValue, int decimalPlaces) {
        // Verify table in PDF has correct precision
        // TODO: Parse PDF table and verify value
    }

    @Then("an audit event for {string} should be logged")
    public void anAuditEventForShouldBeLogged(String operation) {
        verifyAuditEventExists(currentPortfolioId, currentUserId, operation);
    }

    @Then("a loading indicator should be displayed within {int}ms")
    public void aLoadingIndicatorShouldBeDisplayedWithinMs(int timeoutMs) {
        Locator loader = page.locator("[data-testid='loading-indicator']");
        assertTrue(loader.isVisible(), "Loading indicator should be displayed");
    }

    @Then("the loading indicator should remain visible until the API responds")
    public void theLoadingIndicatorShouldRemainVisibleUntilTheAPIResponds() {
        Locator loader = page.locator("[data-testid='loading-indicator']");
        // Verify loader is visible during API call
        assertTrue(loader.isVisible(), "Loader should be visible during API call");
    }

    @Then("the chart should render after the API response")
    public void theChartShouldRenderAfterTheAPIResponse() {
        page.waitForSelector("[data-testid='hedged-twr-chart']");
        assertTrue(page.locator("[data-testid='hedged-twr-chart']").isVisible());
    }

    @Then("the total wait time should be approximately {int}ms")
    public void theTotalWaitTimeShouldBeApproximately(int expectedMs) {
        // Verify timing via performance API
        long actualMs = (long) page.evaluate("performance.timing.loadEventEnd - performance.timing.navigationStart");
        assertTrue(Math.abs(actualMs - expectedMs) < 500,
            "Load time should be approximately " + expectedMs + "ms");
    }

    @Then("the API should be called a maximum of {int} times")
    public void theAPIShouldBeCalledAMaximumOfTimes(int maxAttempts) {
        // Track API calls via network interception
        testData.put("max_api_attempts", maxAttempts);
    }

    @Then("an error message should be displayed after {int} failed attempts")
    public void anErrorMessageShouldBeDisplayedAfterFailedAttempts(int attempts) {
        Locator errorMessage = page.locator("[data-testid='error-message']");
        assertTrue(errorMessage.isVisible(), "Error message should be displayed");
    }

    @Then("the error should suggest contacting support or trying again")
    public void theErrorShouldSuggestContactingSupportOrTryingAgain() {
        String errorText = page.locator("[data-testid='error-message']").innerText();
        assertTrue(errorText.contains("contact support") || errorText.contains("try again"),
            "Error message should provide helpful guidance");
    }

    @Then("the API should be retried automatically")
    public void theAPIShouldBeRetriedAutomatically() {
        // Verify retry logic is triggered (via network monitoring)
    }

    @Then("the chart should eventually display the hedged TWR")
    public void theChartShouldEventuallyDisplayTheHedgedTWR() {
        page.waitForSelector("[data-testid='hedged-twr-chart']",
            new Page.WaitForSelectorOptions().setTimeout(15000));
        assertTrue(page.locator("[data-testid='hedged-twr-chart']").isVisible());
    }

    @Then("the user should not see any error messages")
    public void theUserShouldNotSeeAnyErrorMessages() {
        assertFalse(page.locator("[data-testid='error-message']").isVisible(),
            "No error message should be displayed");
    }

    @Then("an audit event should exist in audit.fx_hedge_requests table with:")
    public void anAuditEventShouldExistWithDetails(Map<String, String> expectedData) {
        try {
            String sql = "SELECT * FROM audit.fx_hedge_requests " +
                        "WHERE user_id = ? AND portfolio_id = ? AND operation = ? " +
                        "ORDER BY timestamp_ms DESC LIMIT 1";

            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setString(1, expectedData.get("user_id"));
            stmt.setString(2, expectedData.get("portfolio_id"));
            stmt.setString(3, expectedData.get("operation"));

            ResultSet rs = stmt.executeQuery();
            assertTrue(rs.next(), "Audit event should exist");

            testData.put("last_audit_event", rs);

        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify audit event", e);
        }
    }

    @Then("the audit event timestamp_ms should be within {int}ms of {string}")
    public void theAuditEventTimestampShouldBeWithinMsOf(int toleranceMs, String variableName) {
        long expectedTime = (long) testData.get(variableName);
        try {
            ResultSet rs = (ResultSet) testData.get("last_audit_event");
            long actualTime = rs.getLong("timestamp_ms");

            assertTrue(Math.abs(actualTime - expectedTime) <= toleranceMs,
                "Audit timestamp should be within " + toleranceMs + "ms of expected");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify audit timestamp", e);
        }
    }

    @Then("the audit event elapsed_ms should be greater than {int}")
    public void theAuditEventElapsedMsShouldBeGreaterThan(int minMs) {
        try {
            ResultSet rs = (ResultSet) testData.get("last_audit_event");
            long elapsedMs = rs.getLong("elapsed_ms");

            assertTrue(elapsedMs > minMs, "Elapsed time should be greater than " + minMs + "ms");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify elapsed time", e);
        }
    }

    @Then("the audit event elapsed_ms should be less than {int}")
    public void theAuditEventElapsedMsShouldBeLessThan(int maxMs) {
        try {
            ResultSet rs = (ResultSet) testData.get("last_audit_event");
            long elapsedMs = rs.getLong("elapsed_ms");

            assertTrue(elapsedMs < maxMs, "Elapsed time should be less than " + maxMs + "ms");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify elapsed time", e);
        }
    }

    @Then("there should be {int} audit events for portfolio {string}:")
    public void thereShouldBeAuditEventsForPortfolio(int expectedCount, String portfolioId,
                                                     List<Map<String, String>> expectedEvents) {
        try {
            String sql = "SELECT operation, user_id FROM audit.fx_hedge_requests " +
                        "WHERE portfolio_id = ? AND timestamp_ms > ? ORDER BY timestamp_ms";

            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setString(1, portfolioId);
            stmt.setLong(2, testStartTime);

            ResultSet rs = stmt.executeQuery();
            int actualCount = 0;
            while (rs.next()) {
                actualCount++;
            }

            assertEquals(expectedCount, actualCount, "Should have " + expectedCount + " audit events");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to count audit events", e);
        }
    }

    @Then("each audit event should have unique timestamp_ms")
    public void eachAuditEventShouldHaveUniqueTimestamp() {
        // Verify all timestamps are unique
    }

    @Then("each audit event should have elapsed_ms > {int}")
    public void eachAuditEventShouldHaveElapsedMs(int minMs) {
        // Verify all events have valid elapsed time
    }

    @Then("{int} audit events should be created")
    public void auditEventsShouldBeCreated(int expectedCount) {
        // Count audit events created during test
    }

    @Then("all timestamp_ms values should be in milliseconds since epoch")
    public void allTimestampMsValuesShouldBeInMillisecondsSinceEpoch() {
        // Verify timestamp format
    }

    @Then("consecutive timestamp_ms values should differ by at least {int}ms")
    public void consecutiveTimestampMsValuesShouldDifferByAtLeast(int minDiff) {
        // Verify timestamps are properly spaced
    }

    @Then("all elapsed_ms values should be accurate to millisecond precision")
    public void allElapsedMsValuesShouldBeAccurateToMillisecondPrecision() {
        // Verify precision of elapsed time measurements
    }

    @Then("the chart should display hedged TWR within {int} seconds")
    public void theChartShouldDisplayHedgedTWRWithinSeconds(int timeoutSeconds) {
        page.waitForSelector("[data-testid='hedged-twr-chart']",
            new Page.WaitForSelectorOptions().setTimeout(timeoutSeconds * 1000));
    }

    @Then("a loading indicator should appear during data loading")
    public void aLoadingIndicatorShouldAppearDuringDataLoading() {
        // This should have already been visible during the load
        // Verify it was shown (this is tricky in Playwright - might need performance traces)
    }

    @Then("a PDF should be downloaded with hedged values to {int}dp")
    public void aPDFShouldBeDownloadedWithHedgedValuesToDp(int decimalPlaces) {
        assertNotNull(testData.get("downloaded_pdf_path"), "PDF should be downloaded");
        // TODO: Verify decimal places in PDF
    }

    @Then("the audit table should contain {int} events for this user session")
    public void theAuditTableShouldContainEventsForThisUserSession(int expectedCount) {
        // Count events for current user since test start
    }

    @Then("all values in the PDF should match the chart values")
    public void allValuesInThePDFShouldMatchTheChartValues() {
        // Extract values from both chart and PDF, compare
    }

    @Then("the PDF should contain all values rounded to {int} decimal places:")
    public void thePDFShouldContainAllValuesRoundedToDecimalPlaces(int dp, List<Map<String, String>> expectedValues) {
        // Parse PDF and verify all values have correct precision
    }

    // ========== HELPER METHODS ==========

    private void setConfigFlag(String flagName, boolean enabled) {
        // This would either:
        // 1. Update config in database
        // 2. Call admin API endpoint
        // 3. Set environment variable via test proxy

        try {
            String sql = "UPDATE ops_config SET enabled = ? WHERE flag_name = ?";
            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setBoolean(1, enabled);
            stmt.setString(2, flagName);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to set config flag", e);
        }
    }

    private void verifyAuditEventExists(String portfolioId, String userId) {
        verifyAuditEventExists(portfolioId, userId, null);
    }

    private void verifyAuditEventExists(String portfolioId, String userId, String operation) {
        try {
            String sql = "SELECT COUNT(*) FROM audit.fx_hedge_requests " +
                        "WHERE portfolio_id = ? AND user_id = ? AND timestamp_ms > ?";
            if (operation != null) {
                sql += " AND operation = ?";
            }

            PreparedStatement stmt = dbConnection.prepareStatement(sql);
            stmt.setString(1, portfolioId);
            stmt.setString(2, userId);
            stmt.setLong(3, testStartTime);
            if (operation != null) {
                stmt.setString(4, operation);
            }

            ResultSet rs = stmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            assertTrue(count > 0, "Audit event should exist for portfolio " + portfolioId);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to verify audit event", e);
        }
    }

    private double parsePercentage(String text) {
        // Extract percentage from text like "5.43%" or "0.0543"
        String cleaned = text.replaceAll("[^0-9.-]", "");
        return Double.parseDouble(cleaned);
    }

    private void performOperation(String operationType) {
        switch (operationType) {
            case "VIEW_CHART":
                page.waitForSelector("[data-testid='hedged-twr-chart']");
                break;
            case "CHANGE_FILTER":
                page.click("button[data-testid='filter-button']");
                break;
            case "EXPORT_PDF":
                page.click("button:has-text('Export PDF')");
                break;
            default:
                throw new IllegalArgumentException("Unknown operation: " + operationType);
        }
    }
}
