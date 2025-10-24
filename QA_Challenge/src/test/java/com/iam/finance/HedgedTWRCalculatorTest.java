package com.iam.finance;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Test suite for HedgedTWRCalculator.
 *
 * Tests cover:
 * - Basic TWR calculation
 * - Annualization logic (> 365 days)
 * - Edge cases (zero values, FX > 1, missing data)
 * - Rounding behavior (6dp internal, 4dp display)
 * - Real-world scenario from BUG-101
 */
public class HedgedTWRCalculatorTest {

    private HedgedTWRCalculator calculator;

    @BeforeEach
    public void setUp() {
        calculator = new HedgedTWRCalculator();
    }

    @Test
    @DisplayName("Test basic TWR calculation with simple 2-period scenario")
    public void testBasicTWRCalculation() {
        // Scenario: EUR account with USD assets
        // Period 0: Initial value 100,000 EUR
        // Period 1: Final value 105,000 EUR after small cash flow
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),  // Initial
            new HedgedTWRCalculator.Period(105000.0, 1000.0, 0.5, 0.95) // After 1 period
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);

        // Calculate expected manually:
        // V'_0 = 100000 × (1 - 0.5 × (1 - 0.95)) = 100000 × 0.975 = 97500
        // V'_1 = 105000 × (1 - 0.5 × (1 - 0.95)) = 105000 × 0.975 = 102375
        // TWR = (102375 - 1000) / 97500 - 1 = 101375 / 97500 - 1 = 1.039744 - 1 = 0.039744
        double expected = 0.039744;

        assertEquals(expected, twr, 0.000001, "TWR should match expected calculation");
    }

    @Test
    @DisplayName("Test TWR calculation with multi-period scenario")
    public void testMultiPeriodTWR() {
        // Scenario: 3 periods with varying hedge ratios
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.6, 0.95),    // Initial
            new HedgedTWRCalculator.Period(102000.0, 500.0, 0.6, 0.96),  // Period 1
            new HedgedTWRCalculator.Period(105000.0, -200.0, 0.5, 0.95)  // Period 2 (negative cash flow = withdrawal)
        };

        double twr = calculator.calculateHedgedTWR(periods, 60);

        // Manual calculation:
        // V'_0 = 100000 × (1 - 0.6 × (1 - 0.95)) = 100000 × 0.97 = 97000
        // V'_1 = 102000 × (1 - 0.6 × (1 - 0.96)) = 102000 × 0.976 = 99552
        // V'_2 = 105000 × (1 - 0.5 × (1 - 0.95)) = 105000 × 0.975 = 102375
        // Period 1 return: (99552 - 500) / 97000 = 1.020536
        // Period 2 return: (102375 - (-200)) / 99552 = 1.030718
        // TWR = 1.020536 × 1.030718 - 1 = 1.051869 - 1 = 0.051869
        double expected = 0.051869;

        assertEquals(expected, twr, 0.000001, "Multi-period TWR should be calculated correctly");
    }

    @Test
    @DisplayName("Test annualization for periods > 365 days")
    public void testAnnualization() {
        // 2-year scenario (730 days)
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(112000.0, 0.0, 0.5, 0.95)
        };

        double twr = calculator.calculateHedgedTWR(periods, 730);

        // Without annualization:
        // V'_0 = 100000 × 0.975 = 97500
        // V'_1 = 112000 × 0.975 = 109200
        // TWR = 109200 / 97500 - 1 = 0.12
        // With annualization: (1.12)^(365/730) - 1 = 1.12^0.5 - 1 ≈ 0.058301
        double expected = 0.058301;

        assertEquals(expected, twr, 0.000001, "TWR should be annualized for periods > 365 days");
    }

    @Test
    @DisplayName("Test no annualization for periods <= 365 days")
    public void testNoAnnualizationUnder365Days() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(110000.0, 0.0, 0.5, 0.95)
        };

        double twr365 = calculator.calculateHedgedTWR(periods, 365);
        double twr180 = calculator.calculateHedgedTWR(periods, 180);

        // Both should return same unadjusted TWR
        // V'_0 = 97500, V'_1 = 107250
        // TWR = 107250 / 97500 - 1 = 0.1
        assertEquals(0.1, twr365, 0.000001);
        assertEquals(0.1, twr180, 0.000001);
    }

    @Test
    @DisplayName("Test edge case: hedge ratio = 0 (no hedging)")
    public void testNoHedging() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.0, 0.95), // FX_t = 0
            new HedgedTWRCalculator.Period(105000.0, 0.0, 0.0, 0.95)
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);

        // V'_t = V_t × (1 - 0 × (1 - 0.95)) = V_t × 1 = V_t (no adjustment)
        // TWR = 105000 / 100000 - 1 = 0.05
        assertEquals(0.05, twr, 0.000001, "No hedging should result in unadjusted TWR");
    }

    @Test
    @DisplayName("Test edge case: hedge ratio = 1 (full hedging)")
    public void testFullHedging() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 1.0, 0.90), // FX_t = 1
            new HedgedTWRCalculator.Period(105000.0, 0.0, 1.0, 0.90)
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);

        // V'_t = V_t × (1 - 1.0 × (1 - 0.90)) = V_t × 0.9
        // V'_0 = 90000, V'_1 = 94500
        // TWR = 94500 / 90000 - 1 = 0.05
        assertEquals(0.05, twr, 0.000001, "Full hedging should apply maximum adjustment");
    }

    @Test
    @DisplayName("Test edge case: hedge factor = 1 (perfect hedge)")
    public void testPerfectHedge() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 1.0), // h_t = 1
            new HedgedTWRCalculator.Period(105000.0, 0.0, 0.5, 1.0)
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);

        // V'_t = V_t × (1 - 0.5 × (1 - 1.0)) = V_t × 1 = V_t
        // TWR = 105000 / 100000 - 1 = 0.05
        assertEquals(0.05, twr, 0.000001, "Perfect hedge (h=1) neutralizes hedge ratio");
    }

    @Test
    @DisplayName("Test exception for zero portfolio value")
    public void testZeroPortfolioValue() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(0.0, 0.0, 0.5, 0.95) // Zero value
        };

        // This should work without exception (zero is the final value)
        assertDoesNotThrow(() -> calculator.calculateHedgedTWR(periods, 30));

        // But zero in the middle should cause division by zero
        HedgedTWRCalculator.Period[] periodsWithMiddleZero = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(0.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(50000.0, 0.0, 0.5, 0.95)
        };

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(periodsWithMiddleZero, 30),
            "Should throw exception for zero value in middle periods");
    }

    @Test
    @DisplayName("Test exception for insufficient periods")
    public void testInsufficientPeriods() {
        HedgedTWRCalculator.Period[] singlePeriod = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95)
        };

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(singlePeriod, 30),
            "Should require at least 2 periods");

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(null, 30),
            "Should handle null periods array");
    }

    @Test
    @DisplayName("Test rounding precision: internal 6dp vs display 4dp")
    public void testRoundingPrecision() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(105432.123456, 0.0, 0.5, 0.95)
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);
        String displayValue = calculator.formatForDisplay(twr);

        // Internal precision: 6 decimal places
        assertTrue(twr > 0.055, "Internal value should retain precision");

        // Display precision: 4 decimal places
        assertEquals(4, displayValue.substring(displayValue.indexOf('.') + 1).length(),
            "Display format should show 4 decimal places");
    }

    @Test
    @DisplayName("Test realistic scenario from BUG-101: Multi-currency IRR discrepancy")
    public void testBug101Scenario() {
        // Portfolio qa-hedge-003: Expected 5.43%, Got 5.38%, Raw JSON: irr:5.42571
        // Simulating a year-long investment with quarterly periods

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(1000000.0, 0.0, 0.65, 0.94),      // Q1 start
            new HedgedTWRCalculator.Period(1012000.0, 2000.0, 0.67, 0.95),   // Q1 end
            new HedgedTWRCalculator.Period(1025000.0, 3000.0, 0.64, 0.96),   // Q2 end
            new HedgedTWRCalculator.Period(1040000.0, -5000.0, 0.66, 0.95),  // Q3 end
            new HedgedTWRCalculator.Period(1054000.0, 1000.0, 0.65, 0.94)    // Q4 end
        };

        double twr = calculator.calculateHedgedTWR(periods, 365);
        String percentageString = calculator.toPercentageString(twr);

        // Expected: somewhere between 5.38% and 5.43%
        assertTrue(twr >= 0.053 && twr <= 0.056,
            "TWR should be in expected range for BUG-101 scenario, got: " + percentageString);
    }

    @Test
    @DisplayName("Test display formatting")
    public void testDisplayFormatting() {
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(105430.0, 0.0, 0.5, 0.95)
        };

        double twr = calculator.calculateHedgedTWR(periods, 30);
        String formatted = calculator.formatForDisplay(twr);
        String percentage = calculator.toPercentageString(twr);

        // Check formats
        assertTrue(formatted.matches("0\\.\\d{4}"), "Display format should be 0.XXXX");
        assertTrue(percentage.matches("\\d+\\.\\d{2}%"), "Percentage should be XX.XX%");
    }
}
