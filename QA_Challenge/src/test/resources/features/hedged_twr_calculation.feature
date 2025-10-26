Feature: Hedged TWR Calculation Validation
  As a QA engineer
  I want to validate hedged TWR calculations across multiple portfolio configurations
  So that I can ensure calculation accuracy for different scenarios

  Background:
    Given the system is running and accessible
    And I am authenticated as user "test-manager@iam.com"
    And hedging is enabled

  @AC1 @Calculation @ParameterizedTest
  Scenario Outline: Validate hedged TWR calculation for various portfolio configurations
    Given a portfolio "<portfolio_id>" exists in the database with:
      | account_currency | <account_currency> |
      | asset_currencies | <asset_currencies> |
    And the portfolio has the following periods:
      | portfolio_value   | cash_flow   | hedge_ratio   | hedge_factor   |
      | <start_value>     | 0.0         | <hedge_ratio> | <hedge_factor> |
      | <end_value>       | <cash_flow> | <hedge_ratio> | <hedge_factor> |
    When I open the "Performance" page for portfolio "<portfolio_id>"
    Then the chart should display hedged TWR
    And the displayed TWR value should be approximately <expected_twr>%
    And an audit event should be logged in audit.fx_hedge_requests

    Examples:
      | portfolio_id | account_currency | asset_currencies | start_value | end_value | cash_flow | hedge_ratio | hedge_factor | expected_twr |
      | qa-calc-001  | EUR             | USD              | 100000.0    | 105000.0  | 1000.0    | 0.5         | 0.95         | 3.97         |
      | qa-calc-002  | EUR             | USD              | 100000.0    | 110000.0  | 0.0       | 0.5         | 0.95         | 9.75         |
      | qa-calc-003  | EUR             | GBP              | 100000.0    | 105000.0  | 2000.0    | 0.7         | 0.98         | 2.94         |
      | qa-calc-004  | EUR             | CHF              | 100000.0    | 108000.0  | 1500.0    | 0.6         | 0.96         | 6.14         |
      | qa-calc-005  | USD             | EUR              | 100000.0    | 103000.0  | 0.0       | 0.5         | 0.95         | 2.85         |
      | qa-calc-006  | EUR             | JPY              | 100000.0    | 112000.0  | 3000.0    | 0.8         | 0.97         | 8.73         |
      | qa-calc-007  | GBP             | USD              | 100000.0    | 106000.0  | 500.0     | 0.55        | 0.96         | 5.23         |
      | qa-calc-008  | EUR             | CAD              | 100000.0    | 104000.0  | 1000.0    | 0.65        | 0.95         | 2.92         |
      | qa-calc-009  | CHF             | EUR              | 100000.0    | 109000.0  | 2000.0    | 0.75        | 0.98         | 6.86         |
      | qa-calc-010  | EUR             | AUD              | 100000.0    | 107000.0  | 1200.0    | 0.6         | 0.94         | 5.52         |

  @AC1 @Calculation @EdgeCases
  Scenario Outline: Validate hedged TWR calculation for edge cases
    Given a portfolio "<portfolio_id>" exists in the database with:
      | account_currency | <account_currency> |
      | asset_currencies | <asset_currencies> |
    And the portfolio has the following periods:
      | portfolio_value   | cash_flow   | hedge_ratio   | hedge_factor   |
      | <start_value>     | 0.0         | <hedge_ratio> | <hedge_factor> |
      | <end_value>       | <cash_flow> | <hedge_ratio> | <hedge_factor> |
    When I open the "Performance" page for portfolio "<portfolio_id>"
    Then the chart should display hedged TWR
    And the displayed TWR value should be approximately <expected_twr>%

    Examples:
      | portfolio_id | account_currency | asset_currencies | start_value | end_value | cash_flow | hedge_ratio | hedge_factor | expected_twr | notes                    |
      | qa-edge-001  | EUR             | USD              | 100000.0    | 100000.0  | 0.0       | 0.5         | 0.95         | 0.0          | No change                |
      | qa-edge-002  | EUR             | USD              | 100000.0    | 95000.0   | 0.0       | 0.5         | 0.95         | -5.25        | Negative return          |
      | qa-edge-003  | EUR             | USD              | 100000.0    | 105000.0  | 0.0       | 1.0         | 1.0          | 5.0          | Full hedge               |
      | qa-edge-004  | EUR             | USD              | 100000.0    | 105000.0  | 0.0       | 0.0         | 1.0          | 5.0          | No hedge                 |
      | qa-edge-005  | EUR             | USD              | 100000.0    | 150000.0  | 0.0       | 0.5         | 0.95         | 48.75        | Large gain               |
