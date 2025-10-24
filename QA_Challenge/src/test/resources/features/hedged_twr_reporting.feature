Feature: Hedged Time-Weighted Return (TWR) Performance Reporting
  As an IAM portfolio manager accessing the web portal
  I want reports to show returns after FX hedging in real-time
  So that clients see performance net of currency risk

  Background:
    Given the system is running and accessible
    And I am authenticated as user "test-manager@iam.com"

  @AC1 @E2E
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

  @AC1 @E2E @MultiCurrency
  Scenario: AC1 - EUR account with multiple USD assets shows correct hedged TWR
    Given a portfolio "qa-hedge-003" exists in the database with:
      | account_currency | EUR           |
      | asset_currencies | USD,GBP,CHF   |
    And the portfolio has multi-period data spanning 365 days
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I open the "Performance" page for portfolio "qa-hedge-003"
    Then the chart should display hedged TWR
    And the displayed TWR value should be between 5.3% and 5.6%

  @AC2 @E2E @FeatureFlag
  Scenario: AC2 - Hedging disabled via Ops config flag shows unhedged behavior
    Given a portfolio "qa-hedge-002" exists in the database with:
      | account_currency | EUR |
      | asset_currencies | USD |
    And hedging is disabled via X-HEDGE-ENABLED flag
    When I open the "Performance" page for portfolio "qa-hedge-002"
    Then the UI should behave exactly as it did before the hedging feature
    And the chart should display unhedged TWR
    And the API should NOT call GET /pricing/v2/hedged endpoint
    And NO audit event should be logged in audit.fx_hedge_requests

  @AC2 @E2E @FeatureToggle
  Scenario: AC2 - Toggle hedging flag updates UI behavior without code changes
    Given a portfolio "qa-hedge-004" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I open the "Performance" page for portfolio "qa-hedge-004"
    Then the chart should display hedged TWR
    When I disable hedging via X-HEDGE-ENABLED flag
    And I refresh the "Performance" page
    Then the chart should display unhedged TWR

  @AC3 @E2E @PDF
  Scenario: AC3 - PDF export shows hedged figures to 4 decimal places in chart and table
    Given a portfolio "qa-hedge-005" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    And the calculated hedged TWR is 0.054271 (5.4271%)
    When I open the "Performance" page for portfolio "qa-hedge-005"
    And I click the "Export PDF" button
    Then a PDF file should be downloaded
    And the PDF chart should display TWR as "5.4271%"
    And the PDF table should display TWR as "0.0543" (4 decimal places)
    And an audit event for "EXPORT_PDF" should be logged

  @AC3 @E2E @PDF @Precision
  Scenario: AC3 - PDF export maintains 4dp precision across all values
    Given a portfolio "qa-hedge-006" exists with hedged TWR values:
      | period | hedged_twr |
      | Q1     | 0.012345   |
      | Q2     | 0.023456   |
      | Q3     | 0.034567   |
      | Q4     | 0.045678   |
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I export the performance report as PDF
    Then the PDF should contain all values rounded to 4 decimal places:
      | period | expected_display |
      | Q1     | 0.0123          |
      | Q2     | 0.0235          |
      | Q3     | 0.0346          |
      | Q4     | 0.0457          |

  @AC4 @E2E @Performance @Latency
  Scenario: AC4 - UI handles API latency greater than 1 second with loader
    Given a portfolio "qa-hedge-007" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    And the API GET /pricing/v2/hedged endpoint has latency of 1500ms
    When I open the "Performance" page for portfolio "qa-hedge-007"
    Then a loading indicator should be displayed within 100ms
    And the loading indicator should remain visible until the API responds
    And the chart should render after the API response
    And the total wait time should be approximately 1500ms

  @AC4 @E2E @Performance @Retry
  Scenario: AC4 - UI retries API call up to 3 times on failure
    Given a portfolio "qa-hedge-008" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    And the API GET /pricing/v2/hedged endpoint fails with 502 error
    When I open the "Performance" page for portfolio "qa-hedge-008"
    Then a loading indicator should be displayed
    And the API should be called a maximum of 3 times
    And an error message should be displayed after 3 failed attempts
    And the error should suggest contacting support or trying again

  @AC4 @E2E @Performance @RetrySuccess
  Scenario: AC4 - UI successfully displays data after retry
    Given a portfolio "qa-hedge-009" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    And the API GET /pricing/v2/hedged endpoint fails on first 2 attempts
    But succeeds on the 3rd attempt
    When I open the "Performance" page for portfolio "qa-hedge-009"
    Then a loading indicator should be displayed
    And the API should be retried automatically
    And the chart should eventually display the hedged TWR
    And the user should not see any error messages

  @AC5 @E2E @Audit
  Scenario: AC5 - Audit events are stored with user-ID, timestamp ms, elapsed ms
    Given a portfolio "qa-hedge-010" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    And the current timestamp is captured as "start_time"
    When I open the "Performance" page for portfolio "qa-hedge-010"
    And I wait for the hedged TWR to load
    Then an audit event should exist in audit.fx_hedge_requests table with:
      | user_id      | test-manager@iam.com |
      | portfolio_id | qa-hedge-010         |
      | operation    | GET_HEDGED_TWR       |
    And the audit event timestamp_ms should be within 5000ms of "start_time"
    And the audit event elapsed_ms should be greater than 0
    And the audit event elapsed_ms should be less than 5000

  @AC5 @E2E @Audit @MultipleOperations
  Scenario: AC5 - Multiple operations create separate audit events
    Given a portfolio "qa-hedge-011" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I open the "Performance" page for portfolio "qa-hedge-011"
    And I wait for the hedged TWR to load
    And I click the "Export PDF" button
    And I wait for the PDF download to complete
    Then there should be 2 audit events for portfolio "qa-hedge-011":
      | operation      | user_id              |
      | GET_HEDGED_TWR | test-manager@iam.com |
      | EXPORT_PDF     | test-manager@iam.com |
    And each audit event should have unique timestamp_ms
    And each audit event should have elapsed_ms > 0

  @AC5 @E2E @Audit @Precision
  Scenario: AC5 - Audit timestamps are recorded with millisecond precision
    Given a portfolio "qa-hedge-012" exists in the database
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I perform 3 sequential operations on the Performance page:
      | operation      |
      | VIEW_CHART     |
      | CHANGE_FILTER  |
      | EXPORT_PDF     |
    Then 3 audit events should be created
    And all timestamp_ms values should be in milliseconds since epoch
    And consecutive timestamp_ms values should differ by at least 1ms
    And all elapsed_ms values should be accurate to millisecond precision

  @E2E @Integration @Smoke
  Scenario: Complete end-to-end workflow from login to PDF export
    Given a portfolio "qa-hedge-013" exists with realistic multi-period data
    And hedging is enabled via X-HEDGE-ENABLED flag
    When I log in to the web portal as "test-manager@iam.com"
    And I navigate to portfolio "qa-hedge-013"
    And I open the "Performance" page
    Then the chart should display hedged TWR within 3 seconds
    And a loading indicator should appear during data loading
    When I click "Export PDF"
    Then a PDF should be downloaded with hedged values to 4dp
    And the audit table should contain 2 events for this user session
    And all values in the PDF should match the chart values
