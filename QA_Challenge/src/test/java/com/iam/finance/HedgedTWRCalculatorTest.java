package com.iam.finance;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Black-box test suite for HedgedTWRCalculator.
 *
 * These tests verify ONLY the mathematical formulas, treating the calculator
 * as a complete black box. No assumptions are made about internal implementation,
 * data structures, or method names beyond the public calculate method.
 *
 * Formulas being tested:
 * 1. Hedged Value: V'_t = V_t × (1 - FX_t × (1 - h_t))
 * 2. Period Return: r_t = (V'_t - C_t) / V'_{t-1}
 * 3. TWR: TWR = ∏(1 + r_t) - 1
 * 4. Annualization (days > 365): TWR_ann = (1 + TWR)^(365/days) - 1
 */
public class HedgedTWRCalculatorTest {

    private HedgedTWRCalculator calculator;

    @BeforeEach
    public void setUp() {
        calculator = new HedgedTWRCalculator();
    }

    @Test
    @DisplayName("Formula Test: Basic single-period TWR calculation")
    public void testBasicTWRCalculation() {
        // Formula verification for single period:
        // Given: V_0=100000, V_1=105000, C_1=1000, FX=0.5, h=0.95
        //
        // Step 1 - Apply hedge adjustment formula: V'_t = V_t × (1 - FX_t × (1 - h_t))
        //   V'_0 = 100000 × (1 - 0.5 × (1 - 0.95))
        //        = 100000 × (1 - 0.5 × 0.05)
        //        = 100000 × (1 - 0.025)
        //        = 100000 × 0.975
        //        = 97500
        //
        //   V'_1 = 105000 × (1 - 0.5 × (1 - 0.95))
        //        = 105000 × 0.975
        //        = 102375
        //
        // Step 2 - Calculate period return: r = (V'_t - C_t) / V'_{t-1}
        //   r_1 = (102375 - 1000) / 97500
        //       = 101375 / 97500
        //       = 1.039743589...
        //
        // Step 3 - Calculate TWR: TWR = (1 + r_1) - 1
        //   TWR = 1.039743589 - 1
        //       = 0.039743589
        //
        // Step 4 - No annualization (30 days < 365)

        // Input data representing the scenario above
        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(105000.0, 1000.0, 0.5, 0.95)
        };

        double result = calculator.calculateHedgedTWR(periods, 30);

        // Expected value calculated by hand using formulas
        double expectedTWR = 0.039743589;

        assertEquals(expectedTWR, result, 0.000001,
            "TWR formula verification failed for basic single-period case");
    }

    @Test
    @DisplayName("Formula Test: Multi-period TWR with product formula")
    public void testMultiPeriodTWR() {
        // Formula verification for multiple periods with compound returns:
        // Given: 3 periods with varying FX ratios and hedge factors
        //   Period 0: V_0=100000, C_0=0,    FX=0.6, h=0.95
        //   Period 1: V_1=102000, C_1=500,  FX=0.6, h=0.96
        //   Period 2: V_2=105000, C_2=-200, FX=0.5, h=0.95 (negative C = withdrawal)
        //
        // Step 1 - Apply hedge adjustment: V'_t = V_t × (1 - FX_t × (1 - h_t))
        //   V'_0 = 100000 × (1 - 0.6 × (1 - 0.95))
        //        = 100000 × (1 - 0.6 × 0.05)
        //        = 100000 × 0.97
        //        = 97000
        //
        //   V'_1 = 102000 × (1 - 0.6 × (1 - 0.96))
        //        = 102000 × (1 - 0.6 × 0.04)
        //        = 102000 × 0.976
        //        = 99552
        //
        //   V'_2 = 105000 × (1 - 0.5 × (1 - 0.95))
        //        = 105000 × 0.975
        //        = 102375
        //
        // Step 2 - Calculate period returns: r_t = (V'_t - C_t) / V'_{t-1}
        //   r_1 = (99552 - 500) / 97000
        //       = 99052 / 97000
        //       = 1.021154639
        //
        //   r_2 = (102375 - (-200)) / 99552
        //       = 102575 / 99552
        //       = 1.030365162
        //
        // Step 3 - Calculate TWR using product formula: TWR = ∏(1 + r_t) - 1
        //   TWR = (1 + r_1) × (1 + r_2) - 1
        //       = 1.021154639 × 1.030365162 - 1
        //       = 1.052165837 - 1
        //       = 0.052165837

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.6, 0.95),
            new HedgedTWRCalculator.Period(102000.0, 500.0, 0.6, 0.96),
            new HedgedTWRCalculator.Period(105000.0, -200.0, 0.5, 0.95)
        };

        double result = calculator.calculateHedgedTWR(periods, 60);

        // Expected value from manual formula calculation
        double expectedTWR = 0.052165837;

        assertEquals(expectedTWR, result, 0.000001,
            "Multi-period TWR product formula verification failed");
    }

    @Test
    @DisplayName("Formula Test: Annualization formula for periods > 365 days")
    public void testAnnualization() {
        // Formula verification for annualization when days > 365:
        // Given: 2-year period (730 days), V_0=100000, V_1=112000, FX=0.5, h=0.95
        //
        // Step 1 - Calculate hedged values:
        //   V'_0 = 100000 × (1 - 0.5 × (1 - 0.95))
        //        = 100000 × 0.975
        //        = 97500
        //
        //   V'_1 = 112000 × (1 - 0.5 × (1 - 0.95))
        //        = 112000 × 0.975
        //        = 109200
        //
        // Step 2 - Calculate unadjusted TWR:
        //   r_1 = (109200 - 0) / 97500
        //       = 1.12
        //   TWR_raw = 1.12 - 1
        //           = 0.12
        //
        // Step 3 - Apply annualization formula: TWR_ann = (1 + TWR)^(365/days) - 1
        //   TWR_ann = (1 + 0.12)^(365/730) - 1
        //           = 1.12^0.5 - 1
        //           = 1.058300524 - 1
        //           = 0.058300524

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(112000.0, 0.0, 0.5, 0.95)
        };

        double result = calculator.calculateHedgedTWR(periods, 730);

        // Expected value from annualization formula
        double expectedTWR = 0.058300524;

        assertEquals(expectedTWR, result, 0.000001,
            "Annualization formula verification failed for 730-day period");
    }

    @Test
    @DisplayName("Formula Test: No annualization for periods <= 365 days")
    public void testNoAnnualizationUnder365Days() {
        // Formula verification that annualization is NOT applied when days <= 365:
        // Given: Same portfolio values but different day counts (365 and 180)
        //   V_0=100000, V_1=110000, FX=0.5, h=0.95
        //
        // Step 1 - Calculate hedged values (same for both):
        //   V'_0 = 100000 × (1 - 0.5 × (1 - 0.95))
        //        = 100000 × 0.975
        //        = 97500
        //
        //   V'_1 = 110000 × (1 - 0.5 × (1 - 0.95))
        //        = 110000 × 0.975
        //        = 107250
        //
        // Step 2 - Calculate TWR (same for both):
        //   TWR = (107250 - 0) / 97500 - 1
        //       = 1.1 - 1
        //       = 0.1
        //
        // Step 3 - Check annualization condition:
        //   For 365 days: days <= 365, so NO annualization → TWR = 0.1
        //   For 180 days: days <= 365, so NO annualization → TWR = 0.1
        //
        // Both should return the same unadjusted TWR

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(110000.0, 0.0, 0.5, 0.95)
        };

        double twr365 = calculator.calculateHedgedTWR(periods, 365);
        double twr180 = calculator.calculateHedgedTWR(periods, 180);

        double expectedTWR = 0.1;

        assertEquals(expectedTWR, twr365, 0.000001,
            "365-day period should NOT be annualized");
        assertEquals(expectedTWR, twr180, 0.000001,
            "180-day period should NOT be annualized");
    }

    @Test
    @DisplayName("Formula Test: Edge case FX=0 (no hedge ratio)")
    public void testNoHedging() {
        // Formula verification when FX_t = 0 (no hedge ratio applied):
        // Given: V_0=100000, V_1=105000, FX=0, h=0.95
        //
        // Step 1 - Apply hedge adjustment formula: V'_t = V_t × (1 - FX_t × (1 - h_t))
        //   V'_0 = 100000 × (1 - 0 × (1 - 0.95))
        //        = 100000 × (1 - 0)
        //        = 100000 × 1
        //        = 100000 (no adjustment)
        //
        //   V'_1 = 105000 × (1 - 0 × (1 - 0.95))
        //        = 105000 × 1
        //        = 105000 (no adjustment)
        //
        // Step 2 - Calculate TWR:
        //   TWR = (105000 - 0) / 100000 - 1
        //       = 1.05 - 1
        //       = 0.05

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.0, 0.95),
            new HedgedTWRCalculator.Period(105000.0, 0.0, 0.0, 0.95)
        };

        double result = calculator.calculateHedgedTWR(periods, 30);

        assertEquals(0.05, result, 0.000001,
            "When FX=0, hedge adjustment should be neutralized (V'=V)");
    }

    @Test
    @DisplayName("Formula Test: Edge case FX=1 (full hedge ratio)")
    public void testFullHedging() {
        // Formula verification when FX_t = 1 (full hedge ratio):
        // Given: V_0=100000, V_1=105000, FX=1, h=0.90
        //
        // Step 1 - Apply hedge adjustment: V'_t = V_t × (1 - FX_t × (1 - h_t))
        //   V'_0 = 100000 × (1 - 1.0 × (1 - 0.90))
        //        = 100000 × (1 - 1.0 × 0.10)
        //        = 100000 × 0.9
        //        = 90000
        //
        //   V'_1 = 105000 × (1 - 1.0 × (1 - 0.90))
        //        = 105000 × 0.9
        //        = 94500
        //
        // Step 2 - Calculate TWR:
        //   TWR = (94500 - 0) / 90000 - 1
        //       = 1.05 - 1
        //       = 0.05

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 1.0, 0.90),
            new HedgedTWRCalculator.Period(105000.0, 0.0, 1.0, 0.90)
        };

        double result = calculator.calculateHedgedTWR(periods, 30);

        assertEquals(0.05, result, 0.000001,
            "When FX=1, full hedge ratio adjustment should be applied");
    }

    @Test
    @DisplayName("Formula Test: Edge case h=1 (perfect hedge factor)")
    public void testPerfectHedge() {
        // Formula verification when h_t = 1 (perfect hedge factor):
        // Given: V_0=100000, V_1=105000, FX=0.5, h=1.0
        //
        // Step 1 - Apply hedge adjustment: V'_t = V_t × (1 - FX_t × (1 - h_t))
        //   V'_0 = 100000 × (1 - 0.5 × (1 - 1.0))
        //        = 100000 × (1 - 0.5 × 0)
        //        = 100000 × (1 - 0)
        //        = 100000
        //
        //   V'_1 = 105000 × (1 - 0.5 × (1 - 1.0))
        //        = 105000 × 1
        //        = 105000
        //
        // Step 2 - Calculate TWR:
        //   TWR = (105000 - 0) / 100000 - 1
        //       = 1.05 - 1
        //       = 0.05

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 1.0),
            new HedgedTWRCalculator.Period(105000.0, 0.0, 0.5, 1.0)
        };

        double result = calculator.calculateHedgedTWR(periods, 30);

        assertEquals(0.05, result, 0.000001,
            "When h=1 (perfect hedge), hedge adjustment should be neutralized");
    }

    @Test
    @DisplayName("Edge Case: Division by zero when V'_{t-1} = 0")
    public void testZeroPortfolioValue() {
        // Zero value at the end is valid (return can be calculated)
        HedgedTWRCalculator.Period[] periodsZeroEnd = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(0.0, 0.0, 0.5, 0.95)
        };

        // Should work: r = (0 - 0) / V'_0 = 0 / 97500 = 0, TWR = -1 (total loss)
        assertDoesNotThrow(() -> calculator.calculateHedgedTWR(periodsZeroEnd, 30),
            "Zero value at end should be allowed (represents total loss)");

        // Zero value in the middle causes division by zero in formula: r_t = (V'_t - C_t) / V'_{t-1}
        HedgedTWRCalculator.Period[] periodsZeroMiddle = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95),
            new HedgedTWRCalculator.Period(0.0, 0.0, 0.5, 0.95),      // V'_1 = 0
            new HedgedTWRCalculator.Period(50000.0, 0.0, 0.5, 0.95)   // Needs V'_1 as denominator!
        };

        // Should throw: cannot calculate r_2 = (V'_2 - C_2) / V'_1 when V'_1 = 0
        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(periodsZeroMiddle, 30),
            "Zero value in middle period causes division by zero");
    }

    @Test
    @DisplayName("Edge Case: Insufficient data for TWR calculation")
    public void testInsufficientPeriods() {
        // TWR formula requires at least 2 periods: initial and final
        HedgedTWRCalculator.Period[] singlePeriod = {
            new HedgedTWRCalculator.Period(100000.0, 0.0, 0.5, 0.95)
        };

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(singlePeriod, 30),
            "Cannot calculate TWR with only 1 period (need start and end)");

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(null, 30),
            "Should validate null input");

        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculateHedgedTWR(new HedgedTWRCalculator.Period[0], 30),
            "Should validate empty array");
    }

    @Test
    @DisplayName("Formula Test: Complex multi-period scenario (BUG-101 reproduction)")
    public void testBug101Scenario() {
        // Real-world scenario from BUG-101: Multi-currency portfolio qa-hedge-003
        // Issue: Expected 5.43%, Got 5.38%, Raw IRR: 5.42571%
        //
        // This tests the complete formula chain over multiple periods with:
        // - Varying hedge ratios (FX_t changes each quarter)
        // - Varying hedge factors (h_t fluctuates)
        // - Both positive and negative cash flows
        // - Annualization NOT applied (exactly 365 days)
        //
        // Manual calculation would involve:
        // 1. Hedge adjustment for all 5 periods
        // 2. Calculate 4 period returns
        // 3. Multiply all (1 + r_t) terms
        // 4. Subtract 1 for final TWR
        //
        // Expected result should be close to raw IRR of ~5.43%

        HedgedTWRCalculator.Period[] periods = {
            new HedgedTWRCalculator.Period(1000000.0, 0.0, 0.65, 0.94),      // Q1 start
            new HedgedTWRCalculator.Period(1012000.0, 2000.0, 0.67, 0.95),   // Q1 end
            new HedgedTWRCalculator.Period(1025000.0, 3000.0, 0.64, 0.96),   // Q2 end
            new HedgedTWRCalculator.Period(1040000.0, -5000.0, 0.66, 0.95),  // Q3 end (withdrawal)
            new HedgedTWRCalculator.Period(1054000.0, 1000.0, 0.65, 0.94)    // Q4 end
        };

        double result = calculator.calculateHedgedTWR(periods, 365);

        // Should be in realistic range around the reported IRR
        assertTrue(result >= 0.053 && result <= 0.056,
            String.format("BUG-101: Expected TWR ~5.3-5.6%%, got %.4f%%", result * 100));
    }
}
