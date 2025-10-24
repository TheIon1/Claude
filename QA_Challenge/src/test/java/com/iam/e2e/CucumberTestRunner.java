package com.iam.e2e;

import org.junit.platform.suite.api.*;

/**
 * Cucumber test runner for E2E black-box testing.
 *
 * This runner executes all Cucumber feature files and generates reports.
 *
 * Usage:
 *   mvn test                              - Run all E2E tests
 *   mvn test -Dcucumber.filter.tags="@AC1" - Run only AC1 tests
 *   mvn test -Dcucumber.filter.tags="@E2E and not @Performance" - Run E2E tests excluding performance
 */
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@ConfigurationParameter(key = "cucumber.plugin", value = "pretty, html:target/cucumber-reports/cucumber.html, json:target/cucumber-reports/cucumber.json, junit:target/cucumber-reports/cucumber.xml")
@ConfigurationParameter(key = "cucumber.publish.enabled", value = "false")
@ConfigurationParameter(key = "cucumber.glue", value = "com.iam.e2e")
public class CucumberTestRunner {
    // This class serves as the entry point for Cucumber tests
    // All configuration is done via annotations
}
