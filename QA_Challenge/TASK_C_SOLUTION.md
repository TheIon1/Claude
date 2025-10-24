# Task C: Finance QA Snippet - Hedged TWR Automated Test

## Overview

This solution provides an automated test for verifying the **Hedged Time-Weighted Return (TWR)** calculation end-to-end.

**Approach**: Black-box, formula-based testing that validates mathematical correctness without making assumptions about internal implementation details.

**Philosophy**: Tests verify ONLY the mathematical formulas, treating the calculator as a complete black box. This ensures tests remain robust even if the implementation changes (e.g., switching from internal calculation to REST API calls).

---

## Solution Structure

```
QA_Challenge/
└── src/
    ├── main/java/com/iam/finance/
    │   └── HedgedTWRCalculator.java      ← Production code (simulated)
    └── test/java/com/iam/finance/
        └── HedgedTWRCalculatorTest.java  ← JUnit test suite
```

---

## The Calculation Logic

The `HedgedTWRCalculator` class implements the formula from the spec:

### Step 1: Adjust Portfolio Values
```
V'_t = V_t × (1 − FX_t × (1 − h_t))
```

### Step 2: Calculate TWR
```
TWR = Π_{i=1}^{n} [(V'_i − C_i) / V'_{i-1}] − 1
```

### Step 3: Annualize (if > 365 days)
```
TWR_ann = (1 + TWR)^(365/days) − 1
```

**Precision**:
- Internal: 6 decimal places
- Display: 4 decimal places

---

## Test Coverage

The `HedgedTWRCalculatorTest` suite covers **10 formula-based test cases**:

| Test Case | Formula Being Tested |
|-----------|---------------------|
| `testBasicTWRCalculation` | **Basic TWR formula**: Single-period return calculation with detailed step-by-step verification |
| `testMultiPeriodTWR` | **Product formula**: TWR = ∏(1 + r_t) - 1 across multiple periods with compounding |
| `testAnnualization` | **Annualization formula**: TWR_ann = (1 + TWR)^(365/days) - 1 when days > 365 |
| `testNoAnnualizationUnder365Days` | **Boundary condition**: Verifies annualization NOT applied when days ≤ 365 |
| `testNoHedging` | **Edge case**: V'_t = V_t when FX_t = 0 (no hedge adjustment) |
| `testFullHedging` | **Edge case**: Maximum hedge adjustment when FX_t = 1 |
| `testPerfectHedge` | **Edge case**: V'_t = V_t when h_t = 1 (perfect hedge neutralizes FX) |
| `testZeroPortfolioValue` | **Division by zero**: Validates error handling when V'_{t-1} = 0 |
| `testInsufficientPeriods` | **Input validation**: Requires ≥2 periods for TWR calculation |
| `testBug101Scenario` | **Complex real-world case**: Multi-period with varying FX_t, h_t, and cash flows |

### Key Testing Principles

✅ **Formula-First**: Each test explicitly shows the mathematical calculation steps
✅ **Black-Box**: No assumptions about internal implementation (could be REST API, database, etc.)
✅ **Deterministic**: Hand-calculated expected values with 6 decimal place precision
✅ **Traceable**: Each test maps directly to a formula from the specification

---

## Test Data Setup

Each test constructs `Period` objects with:
- **portfolioValue** (V_t): Portfolio value at time t in base currency
- **cashFlow** (C_t): Net cash flow at time t (deposits/withdrawals)
- **hedgeRatio** (FX_t): Hedge ratio 0-1 (proportion hedged)
- **hedgeFactor** (h_t): Hedge effectiveness 0-1

### Example Test Case
```java
@Test
public void testBasicTWRCalculation() {
    // EUR account with USD assets, 30-day period
    Period[] periods = {
        new Period(100000.0, 0.0, 0.5, 0.95),     // Initial: €100k, 50% hedged, 95% effective
        new Period(105000.0, 1000.0, 0.5, 0.95)   // End: €105k, €1k cash flow
    };

    double twr = calculator.calculateHedgedTWR(periods, 30);

    // Expected calculation:
    // V'_0 = 100000 × (1 - 0.5 × 0.05) = 97,500
    // V'_1 = 105000 × (1 - 0.5 × 0.05) = 102,375
    // TWR = (102375 - 1000) / 97500 - 1 = 0.039744 (3.97%)

    assertEquals(0.039744, twr, 0.000001);
}
```

---

## Expected Value Calculation

The tests use **deterministic assertions** with manually calculated expected values:

1. **Given** initial and final portfolio values, cash flows, hedge parameters
2. **When** TWR is calculated
3. **Then** result matches hand-calculated expectation within ±0.000001 tolerance

This ensures:
- Formula correctness
- Precision handling
- Edge case behavior

---

## Where This Fits in QA Process

### 1. **Unit Testing Layer** (Current Solution)
- **When**: During development, pre-commit hooks, CI/CD pipeline
- **Who**: Developers, automated build
- **Speed**: <1 second per test
- **Scope**: Validates core calculation logic in isolation

### 2. **Integration Testing** (Next Layer)
- Test against real API endpoint `GET /pricing/v2/hedged`
- Use test portfolios from ProdX sandbox (10 available, resets nightly)
- Validate end-to-end: DB → API → FE chart rendering

### 3. **Regression Testing** (Pre-Release)
- Run against known portfolios (e.g., `qa-hedge-003` from BUG-101)
- Compare results to golden dataset
- Verify PDF export shows correct 4dp values

### 4. **Smoke Testing** (Post-Deploy)
- Execute subset of critical scenarios in DEV → INT → PROD
- Confirm flag `X-HEDGE-ENABLED` toggles behavior correctly

---

## Running the Tests

### Prerequisites
```bash
# Requires JDK 11+ and JUnit 5
```

### Compile and Run
```bash
# Using Maven (if pom.xml configured)
mvn clean test

# Using Gradle (if build.gradle configured)
gradle test

# Using IDE (IntelliJ, Eclipse, VS Code)
# Right-click on HedgedTWRCalculatorTest.java → Run Tests
```

### Expected Output
```
HedgedTWRCalculatorTest
  ✓ Formula Test: Basic single-period TWR calculation
  ✓ Formula Test: Multi-period TWR with product formula
  ✓ Formula Test: Annualization formula for periods > 365 days
  ✓ Formula Test: No annualization for periods <= 365 days
  ✓ Formula Test: Edge case FX=0 (no hedge ratio)
  ✓ Formula Test: Edge case FX=1 (full hedge ratio)
  ✓ Formula Test: Edge case h=1 (perfect hedge factor)
  ✓ Edge Case: Division by zero when V'_{t-1} = 0
  ✓ Edge Case: Insufficient data for TWR calculation
  ✓ Formula Test: Complex multi-period scenario (BUG-101 reproduction)

Tests run: 10, Failures: 0, Errors: 0, Skipped: 0
```

---

## Validation of Correctness

### 1. **Assertion-Based Validation**
Each test uses `assertEquals()` with epsilon tolerance (0.000001) to verify:
- Calculated TWR matches expected value
- Rounding behaves correctly
- Edge cases handled properly

### 2. **Real-World Scenario (BUG-101)**
The `testBug101Scenario` replicates the reported bug:
- Portfolio: `qa-hedge-003`
- Expected: 5.43%
- Actual (buggy): 5.38%
- Raw value: 5.42571%

Test ensures calculation falls in valid range and helps diagnose rounding vs. formula issues.

### 3. **Edge Case Coverage**
Tests explicitly cover spec-mentioned edge cases using formula verification:
- **Division by zero**: When V'_{t-1} = 0 in formula r_t = (V'_t - C_t) / V'_{t-1}
- **Hedge adjustment boundaries**: FX=0 (no adjustment), FX=1 (full), h=1 (neutralizes)
- **Annualization threshold**: Tests boundary at 365 days
- **Input validation**: Null, empty, and insufficient period arrays

---

## Benefits of This Approach

✅ **Implementation-Agnostic**: Tests remain valid even if implementation changes (e.g., calculator → REST API → database query)
✅ **Formula-Based**: Each test explicitly shows mathematical steps, making verification transparent
✅ **Black-Box**: No coupling to internal methods, data structures, or implementation details
✅ **Fast**: Runs in milliseconds, suitable for CI/CD pipelines
✅ **Deterministic**: No external dependencies (API/DB) for unit layer
✅ **Comprehensive**: Covers all 4 core formulas + boundary conditions + validation
✅ **Traceable**: Each test maps directly to a formula from the specification
✅ **Maintainable**: Self-documenting with step-by-step formula calculations in comments
✅ **Robust**: Won't break due to internal refactoring or architectural changes

---

## Next Steps for Full E2E Testing

✅ **E2E Testing Implemented!** See `E2E_TEST_DESIGN.md` for comprehensive black-box E2E testing approach.

**The E2E solution includes:**
1. ✅ **Cucumber BDD**: Given/When/Then scenarios for AC1-AC5
2. ✅ **Playwright**: Browser automation for UI testing
3. ✅ **REST Assured**: API integration testing (`GET /pricing/v2/hedged`)
4. ✅ **JDBC**: Database setup and audit log validation
5. ✅ **PDF Validation**: Apache PDFBox for export verification
6. ✅ **Full Coverage**: 12+ scenarios covering all acceptance criteria

**Architecture**: Database → API → Web UI (complete black-box flow)

---

## Test Strategy Overview

| Test Level | Scope | Tool | Speed | When to Run |
|------------|-------|------|-------|-------------|
| **Unit Tests** (this file) | Formula validation | JUnit | <1s | Every commit |
| **E2E Tests** (`E2E_TEST_DESIGN.md`) | Full workflow | Cucumber + Playwright | 5-30s | Pre-release |

---

## File References

- **Calculator**: `src/main/java/com/iam/finance/HedgedTWRCalculator.java`
- **Tests**: `src/test/java/com/iam/finance/HedgedTWRCalculatorTest.java`
- **Spec**: See `QA_Challenge/README.md` → "Finance Reporting Spec"
