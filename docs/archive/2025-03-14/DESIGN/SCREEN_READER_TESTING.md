---
title: Screen Reader Testing Guide for Hydepwns
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - design
  - screen-reader-testing-guide-for-hydepwns
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - preparation
  - testing-scenarios
  - common-screen-reader-commands-reference
  - issues-tracking
  - test-results-summary
  - references
  - testing
last_updated: '2025-03-14'
---
# Screen Reader Testing Guide for Hydepwns

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

# Screen Reader Testing Guide for Hydepwns


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about SCREEN READER TESTING.


This document provides a structured approach for testing the Hydepwns monospace website with various screen readers to ensure accessibility compliance.

## Preparation

1. **Set up screen readers:**
   - **NVDA**: Download and install from [nvaccess.org](https://www.nvaccess.org/download/)
   - **JAWS**: Download trial version from [freedomscientific.com](https://www.freedomscientific.com/products/software/jaws/)
   - **VoiceOver**: Already included on macOS (activate with Command+F5)

2. **Testing environment:**
   - Test on different browsers (Chrome, Firefox, Safari)
   - Test with different screen reader + browser combinations

## Testing Scenarios

### 1. General Navigation

| Test Case | Expected Result | NVDA | JAWS | VoiceOver |
|-----------|-----------------|------|------|-----------|
| Tab through page | Focus moves logically through elements | | | |
| Skip to content | Works on first tab press | | | |
| Heading navigation | Can navigate between headings with screen reader commands (h/Shift+h) | | | |
| Landmark navigation | Can navigate between landmarks/regions | | | |

### 2. Interactive Elements

| Test Case | Expected Result | NVDA | JAWS | VoiceOver |
|-----------|-----------------|------|------|-----------|
| Buttons state | Screen reader announces button state | | | |
| Form controls | All form controls are properly labeled | | | |
| Custom components | Complex components are navigable and states announced | | | |
| Animation controls | Animation controls are properly labeled and functional | | | |

### 3. ASCII Art and Diagrams

| Test Case | Expected Result | NVDA | JAWS | VoiceOver |
|-----------|-----------------|------|------|-----------|
| ASCII art | Has appropriate alt text or is hidden from screen readers | | | |
| Charts/diagrams | Has descriptive text alternatives | | | |
| Complex visualizations | Provides text summary of key information | | | |

### 4. Keyboard Navigation

| Test Case | Expected Result | NVDA | JAWS | VoiceOver |
|-----------|-----------------|------|------|-----------|
| Keyboard shortcuts | All shortcuts work and are announced | | | |
| Focus visibility | Focus is clearly visible at all times | | | |
| No keyboard traps | Can navigate away from all elements | | | |
| Modal dialogs | Focus is trapped appropriately in modals | | | |

### 5. Theme and Display

| Test Case | Expected Result | NVDA | JAWS | VoiceOver |
|-----------|-----------------|------|------|-----------|
| High contrast mode | Works correctly with screen readers | | | |
| Text resizing | Content remains accessible when text is enlarged | | | |
| Reduced motion | Respects user preferences | | | |

## Common Screen Reader Commands Reference

### NVDA

- **Navigate headings**: H (forward), Shift+H (backward)
- **Navigate landmarks**: D (forward), Shift+D (backward)
- **List all headings**: Insert+F7
- **List all links**: Insert+F7, then tab
- **Turn browse mode on/off**: Insert+Space

### JAWS

- **Navigate headings**: H (forward), Shift+H (backward)
- **Navigate landmarks**: R (forward), Shift+R (backward)
- **List all headings**: Insert+F6
- **List all links**: Insert+F7
- **Turn virtual cursor on/off**: Insert+Z

### VoiceOver (macOS)

- **Navigate headings**: Control+Option+Command+H
- **Navigate landmarks**: Control+Option+Command+; then arrow to landmarks
- **List all headings**: Control+Option+U, then arrow to headings
- **List all links**: Control+Option+U, then press Tab to get to links
- **Turn on/off**: Command+F5

## Issues Tracking

Use this section to document any issues found during testing.

| Issue | Screen Reader | Browser | Description | Priority | Status |
|-------|--------------|---------|-------------|----------|--------|
| | | | | | |
| | | | | | |

## Test Results Summary

After completing testing, summarize key findings and recommendations here. 

## References

- [Project Documentation](../README.md)
