---
title: Performance Testing Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - performance-testing-guide
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - table-of-contents
  - performance-testing-philosophy
  - setting-up-the-performance-testing-environment
  - key-performance-metrics
  - device-testing-matrix
  - automated-performance-testing
  - manual-performance-testing
  - testing-specific-components
  - start-the-performance-test-server
  - run-terminal-performance-test
  - resource-management-ui
  - run-resource-management-performance-test
  - event-system
  - run-event-system-performance-test
  - interpreting-results
  - performance-budgets
  - reporting-and-documenting-issues
  - conclusion
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# Performance Testing Guide

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Performance Testing Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about PERFORMANCE TESTING GUIDE.


This guide provides comprehensive instructions for testing the performance of Hydepwns across various environments, devices, and scenarios. It's intended to help developers identify and resolve performance bottlenecks to maintain optimal user experience.

## Table of Contents

1. [Performance Testing Philosophy](#performance-testing-philosophy)
2. [Setting Up the Performance Testing Environment](#setting-up-the-performance-testing-environment)
3. [Key Performance Metrics](#key-performance-metrics)
4. [Device Testing Matrix](#device-testing-matrix)
5. [Automated Performance Testing](#automated-performance-testing)
6. [Manual Performance Testing](#manual-performance-testing)
7. [Testing Specific Components](#testing-specific-components)
8. [Interpreting Results](#interpreting-results)
9. [Performance Budgets](#performance-budgets)
10. [Reporting and Documenting Issues](#reporting-and-documenting-issues)

## Performance Testing Philosophy

Our performance testing strategy is built on these principles:

1. **Real-world benchmarking**: Test on actual devices rather than just emulators
2. **Progressive enhancement**: Ensure functionality across all devices, with enhancements on capable devices
3. **Perceived performance**: Focus on user-perceived performance metrics (TTI, FCP, etc.)
4. **Continuous monitoring**: Integrate performance testing into the CI/CD pipeline
5. **Performance budgets**: Establish clear thresholds for key metrics

## Setting Up the Performance Testing Environment

### Required Tools

1. **Lighthouse CLI**: For automated performance audits

   ```bash
   npm install -g lighthouse
   ```markdown

2. **WebPageTest**: For comprehensive performance analysis
   Set up account at [WebPageTest.org](https://www.webpagetest.org/)

3. **Chrome DevTools Performance Panel**: For detailed runtime performance analysis
   - Accessible in Chrome via F12 → Performance tab

4. **Puppeteer**: For automated browser testing

   ```bash
   npm install puppeteer
   ```markdown

5. **Firebase Test Lab** (optional): For testing on real device fleet
   Set up via Google Cloud Console

### Environment Configuration

Create a `performance_testing.exs` configuration file in the `config` directory with the following content:

```elixir
import Config

config :hydepwns, Hydepwns.PerformanceTesting,
  lighthouse_flags: "--throttling-method=provided --chrome-flags=\"--headless\"",
  connection_throttling: %{
    "slow3G" => %{
      download: 500_000,
      upload: 500_000,
      latency: 300
    },
    "fast3G" => %{
      download: 1_600_000,
      upload: 750_000,
      latency: 150
    },
    "4G" => %{
      download: 9_000_000,
      upload: 3_000_000,
      latency: 75
    }
  },
  device_emulation: %{
    "low_end_mobile" => %{
      user_agent: "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N)",
      viewport: %{
        width: 360,
        height: 640,
        device_scale_factor: 2,
        mobile: true
      }
    },
    "mid_range_mobile" => %{
      user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X)",
      viewport: %{
        width: 375,
        height: 667,
        device_scale_factor: 2,
        mobile: true
      }
    },
    "high_end_mobile" => %{
      user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X)",
      viewport: %{
        width: 390,
        height: 844,
        device_scale_factor: 3,
        mobile: true
      }
    },
    "tablet" => %{
      user_agent: "Mozilla/5.0 (iPad; CPU OS 13_2_3 like Mac OS X)",
      viewport: %{
        width: 768,
        height: 1024,
        device_scale_factor: 2,
        mobile: true
      }
    }
  }
```markdown

## Key Performance Metrics

### Core Web Vitals

1. **Largest Contentful Paint (LCP)**:
   - Good: < 2.5s
   - Needs Improvement: 2.5s - 4s
   - Poor: > 4s

2. **First Input Delay (FID)**:
   - Good: < 100ms
   - Needs Improvement: 100ms - 300ms
   - Poor: > 300ms

3. **Cumulative Layout Shift (CLS)**:
   - Good: < 0.1
   - Needs Improvement: 0.1 - 0.25
   - Poor: > 0.25

### Application-Specific Metrics

1. **Terminal Input Latency**: Time from keypress to character appearance
   - Target: < 50ms

2. **Animation Frame Rate**:
   - Target: 60fps for high-end devices, > 30fps for low-end devices

3. **Memory Usage**:
   - Target: < 100MB for all devices

4. **Battery Impact**:
   - Target: < 5% battery drain for 10 minutes of active usage

5. **JavaScript Execution Time**:
   - Target: < 200ms for any single user interaction

## Device Testing Matrix

We test across a matrix of devices to ensure optimal performance across different capabilities.

### Required Test Devices

| Category | Example Devices | Notes |
|----------|----------------|-------|
| Low-end Mobile | Moto G7 Play, Samsung Galaxy A10 | Focus on JavaScript performance |
| Mid-range Mobile | iPhone SE (2020), Google Pixel 4a | Balance of performance testing |
| High-end Mobile | iPhone 13 Pro, Samsung Galaxy S22 | Test full feature experience |
| Tablet | iPad (9th gen), Samsung Galaxy Tab S7 | Focus on layout and rendering |
| Desktop | Various Windows/Mac/Linux | Test at multiple viewport sizes |

### Browsers to Test

- **Mobile**: Chrome, Safari, Firefox, Samsung Internet
- **Desktop**: Chrome, Firefox, Safari, Edge

## Automated Performance Testing

### Lighthouse CI Integration

1. Install Lighthouse CI

   ```bash
   npm install -g @lhci/cli
   ```markdown

2. Configure `.lighthouserc.js` file:

   ```javascript
   module.exports = {
     ci: {
       collect: {
         url: ['http://localhost:4000'],
         numberOfRuns: 3,
         settings: {
           throttlingMethod: 'devtools',
           formFactor: 'mobile',
           throttling: {
             rttMs: 150,
             throughputKbps: 1600,
             cpuSlowdownMultiplier: 2
           }
         }
       },
       upload: {
         target: 'filesystem',
         outputDir: './lighthouse-results'
       },
       assert: {
         assertions: {
           'categories:performance': ['warn', {minScore: 0.8}],
           'first-contentful-paint': ['error', {maxNumericValue: 2000}],
           'interactive': ['error', {maxNumericValue: 3500}],
           'cumulative-layout-shift': ['error', {maxNumericValue: 0.1}],
           'largest-contentful-paint': ['error', {maxNumericValue: 2500}]
         }
       }
     }
   };
   ```markdown

3. Run Lighthouse CI as part of your GitHub workflow:

   ```yaml
   - name: Run Lighthouse CI
     run: |
       npm install -g @lhci/cli
       lhci autorun
   ```markdown

### Custom Performance Test Scripts

We've created custom test scripts for application-specific performance metrics:

1. **Terminal Performance Test**:

   ```bash
   mix test.performance terminal --device=low_end_mobile
   ```markdown

2. **Resource System Performance Test**:

   ```bash
   mix test.performance resources --operations=1000
   ```markdown

3. **Event Processing Performance Test**:

   ```bash
   mix test.performance events --concurrent_handlers=10
   ```markdown

## Manual Performance Testing

For certain aspects, manual testing is still required:

### Visual Performance Inspection

1. Enable the performance monitor in the application:
   - Navigate to `/dev/performance`
   - Click "Start Monitoring"
   - Perform the actions you want to test

2. Look for:
   - Janky animations/scrolling
   - Delayed responses to user input
   - UI freezes during complex operations

### Device Testing Protocol

1. Clear browser cache and close all other applications
2. Launch application in fresh browser instance
3. Wait for full page load without interacting
4. Perform standardized test actions:
   - Toggle theme
   - Open terminal and type 50 characters
   - Create a new resource
   - Navigate between main sections
5. Record subjective performance observations

## Testing Specific Components

### Terminal Component

```bash
# Start the performance test server
mix phx.server --mode=perf

# Run terminal performance test
cd test/performance
node terminal_test.js
```markdown

The terminal performance test evaluates:

- Input latency
- Rendering performance with large outputs
- Memory usage during continuous operation
- Scrolling performance

## Resource Management UI

```bash
# Run resource management performance test
mix test.performance resources
```markdown

This test evaluates:

- Loading time for large resource collections
- Filtering/sorting performance
- Relationship graph rendering
- Form validation performance

## Event System

```bash
# Run event system performance test
mix test.performance events
```markdown

This test evaluates:

- Event dispatch performance
- Handler execution time
- Backpressure handling
- Memory usage during high event volume

## Interpreting Results

### Performance Reports

Results from automated tests are saved to:

- Lighthouse results: `./lighthouse-results`
- Custom test results: `./test/performance/results`

Each test run generates a JSON report and performance traces that can be loaded into Chrome DevTools.

### Key indicators to look for

1. **Regressions from baseline**:
   - Compare with previous test runs to identify degradation

2. **Long tasks in JavaScript**:
   - Any task taking > 50ms should be investigated

3. **Memory leaks**:
   - Look for consistently increasing memory usage

4. **Render bottlenecks**:
   - Identify expensive paint/layout operations

## Performance Budgets

We enforce the following performance budgets:

| Metric | Budget |
|--------|--------|
| Total JavaScript bundle size | 300KB (gzipped) |
| CSS size | 150KB (gzipped) |
| Initial load time (4G) | < 2s |
| Time to Interactive (4G) | < 3s |
| Total HTTP requests | < 30 |
| Memory usage (runtime) | < 100MB |

Any pull request that exceeds these budgets requires performance optimization before approval.

## Reporting and Documenting Issues

### Documenting Performance Issues

When filing a performance-related issue, include:

1. Test environment details
   - Device/browser
   - Network conditions
   - Test script or steps to reproduce

2. Performance traces
   - Attach Chrome DevTools performance profile
   - Include screenshots of metrics

3. Regression information
   - When did the issue first appear?
   - What were the previous metrics?

4. Potential causes
   - Recent code changes in the area
   - Dependencies that might impact performance

### Addressing Performance Regressions

1. Identify the root cause through bisection testing
2. Create a focused test case that demonstrates the issue
3. Apply optimization and verify improvement
4. Document the fix and add regression tests

## Conclusion

Following this performance testing guide will help maintain the high-performance standards of Hydepwns across all devices and environments. Performance testing should be integrated into the development workflow rather than treated as a separate activity.

For questions or suggestions regarding performance testing, contact the performance working group on the project Slack channel (#performance).


## References

- [Project Documentation](../README.md)
