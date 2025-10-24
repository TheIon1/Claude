package com.iam.finance;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Calculator for Hedged Time-Weighted Return (TWR) as per Finance Reporting Spec.
 *
 * Formula:
 * Step 1: V'_t = V_t × (1 − FX_t × (1 − h_t))
 * Step 2: TWR = Π_{i=1}^{n} [(V'_i − C_i) / V'_{i-1}] − 1
 * Step 3: Annualize if > 365 days: TWR_ann = (1+TWR)^(365/days) − 1
 */
public class HedgedTWRCalculator {

    private static final int INTERNAL_PRECISION = 6;
    private static final int DISPLAY_PRECISION = 4;

    /**
     * Represents a single time period in the portfolio.
     */
    public static class Period {
        public final double portfolioValue;  // V_t
        public final double cashFlow;        // C_t
        public final double hedgeRatio;      // FX_t (0-1)
        public final double hedgeFactor;     // h_t

        public Period(double portfolioValue, double cashFlow, double hedgeRatio, double hedgeFactor) {
            this.portfolioValue = portfolioValue;
            this.cashFlow = cashFlow;
            this.hedgeRatio = hedgeRatio;
            this.hedgeFactor = hedgeFactor;
        }
    }

    /**
     * Calculates hedged TWR for a series of periods.
     *
     * @param periods Array of periods (must have at least 2 periods)
     * @param totalDays Total days for annualization (if > 365, result will be annualized)
     * @return Hedged TWR as a decimal (e.g., 0.0543 for 5.43%)
     * @throws IllegalArgumentException if periods array is invalid
     */
    public double calculateHedgedTWR(Period[] periods, int totalDays) {
        if (periods == null || periods.length < 2) {
            throw new IllegalArgumentException("At least 2 periods required for TWR calculation");
        }

        // Step 1: Calculate adjusted portfolio values (V'_t)
        double[] adjustedValues = new double[periods.length];
        for (int i = 0; i < periods.length; i++) {
            adjustedValues[i] = calculateAdjustedValue(
                periods[i].portfolioValue,
                periods[i].hedgeRatio,
                periods[i].hedgeFactor
            );
        }

        // Step 2: Calculate TWR as product of period returns
        double product = 1.0;
        for (int i = 1; i < periods.length; i++) {
            double previousValue = adjustedValues[i - 1];
            double currentValue = adjustedValues[i];
            double cashFlow = periods[i].cashFlow;

            // Handle edge case: zero previous value
            if (previousValue == 0) {
                throw new IllegalArgumentException("Zero portfolio value at period " + (i - 1));
            }

            double periodReturn = (currentValue - cashFlow) / previousValue;
            product *= periodReturn;
        }

        double twr = product - 1.0;

        // Step 3: Annualize if > 365 days
        if (totalDays > 365) {
            twr = Math.pow(1 + twr, 365.0 / totalDays) - 1.0;
        }

        // Round to internal precision (6 decimal places)
        return roundToDecimalPlaces(twr, INTERNAL_PRECISION);
    }

    /**
     * Step 1: Calculate adjusted portfolio value.
     * V'_t = V_t × (1 − FX_t × (1 − h_t))
     */
    private double calculateAdjustedValue(double portfolioValue, double hedgeRatio, double hedgeFactor) {
        return portfolioValue * (1.0 - hedgeRatio * (1.0 - hedgeFactor));
    }

    /**
     * Rounds a value to specified decimal places using HALF_UP rounding.
     */
    private double roundToDecimalPlaces(double value, int decimalPlaces) {
        BigDecimal bd = new BigDecimal(Double.toString(value));
        bd = bd.setScale(decimalPlaces, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }

    /**
     * Formats the TWR for display (4 decimal places).
     */
    public String formatForDisplay(double twr) {
        return String.format("%.4f", twr);
    }

    /**
     * Converts TWR decimal to percentage string.
     */
    public String toPercentageString(double twr) {
        return String.format("%.2f%%", twr * 100);
    }
}
