---
title: ES Module Compatibility in Test Environment
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - development
  - es-module-compatibility-in-test-environment
  - prerequisites
  - main-content
  - related-documents
  - overview
  - table-of-contents
  - current-challenges
  - recommended-solutions
  - implementation-guide
  - examples
  - troubleshooting
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# ES Module Compatibility in Test Environment

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Related Documents

* No references yet

# ES Module Compatibility in Test Environment


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about ES MODULE TESTING.


This document outlines the challenges and solutions for testing JavaScript components that use ES Modules in our Jest testing environment.

## Table of Contents

1. [Current Challenges](#current-challenges)
2. [Recommended Solutions](#recommended-solutions)
3. [Implementation Guide](#implementation-guide)
4. [Examples](#examples)
5. [Troubleshooting](#troubleshooting)

## Current Challenges

Our component testing environment faces several challenges with ES Modules:

1. **Import/Export Syntax**: Jest runs in Node.js which has different module resolution than browsers.
2. **Dynamic Imports**: Jest has limited support for dynamic `import()` statements.
3. **Module Mocking**: Mocking ES modules requires different approaches than CommonJS modules.
4. **Browser APIs**: Some components use browser APIs not available in the test environment.
5. **Circular Dependencies**: ES modules can create circular dependency issues that are hard to debug.

These issues manifest in our tests as:

- `SyntaxError: Cannot use import statement outside a module`
- `Error: Jest: ES Modules cannot be used with jest.mock()`
- `ReferenceError: [Browser API] is not defined`

## Recommended Solutions

### 1. Update Babel Configuration

Ensure Babel is configured to transform ES Modules to CommonJS for testing:

```javascript
// babel.config.js
module.exports = {
  presets: [
    ['@babel/preset-env', {
      targets: {
        node: 'current',
      },
      modules: 'commonjs' // Transform ES modules to CommonJS for testing
    }]
  ],
  env: {
    test: {
      plugins: [
        // Additional plugins for testing environment
        'babel-plugin-dynamic-import-node'
      ]
    }
  }
};
```markdown

### 2. Standardized Module Mocking Pattern

Use a consistent pattern for mocking ES modules:

```javascript
// For default exports
jest.mock('path/to/module', () => ({
  __esModule: true,
  default: jest.fn().mockImplementation(() => mockImplementation)
}));

// For named exports
jest.mock('path/to/module', () => ({
  __esModule: true,
  namedExport: jest.fn().mockImplementation(() => mockImplementation)
}));
```markdown

### 3. Mock Factory Functions

Create reusable mock factories for common dependencies:

```javascript
// test/hydepwns_liveview_web/js/mocks/event_manager_mock.js
export const createEventManagerMock = () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    addDelegatedEventListener: jest.fn(),
    cleanup: jest.fn()
  }),
  unregisterComponent: jest.fn()
});
```markdown

### 4. Jest Configuration Updates

Update Jest configuration to better handle ES Modules:

```javascript
// jest.config.js
module.exports = {
  // ... existing config
  
  // Improved transform configuration
  transform: {
    '^.+\\.jsx?$': ['babel-jest', { rootMode: 'upward' }]
  },
  
  // Don't ignore these ES Module packages
  transformIgnorePatterns: [
    '/node_modules/(?!(sinon|@testing-library|other-esm-packages)/)'
  ],
  
  // Handle ESM in node_modules
  extensionsToTreatAsEsm: ['.js', '.jsx'],
  
  // Improved module name mapping
  moduleNameMapper: {
    // ... existing mappings
    '^@/(.*)$': '<rootDir>/assets/js/$1'
  }
};
```markdown

## Implementation Guide

Follow these steps to update our testing environment:

1. **Update Babel Configuration**
   - Modify `babel.config.js` as shown above
   - Install additional dependencies: `npm install --save-dev babel-plugin-dynamic-import-node`

2. **Update Jest Configuration**
   - Modify `test/hydepwns_liveview_web/js/jest.config.js` as shown above
   - Install additional dependencies if needed

3. **Create Mock Factories**
   - Create mock factory files for common dependencies
   - Place them in `test/hydepwns_liveview_web/js/mocks/`

4. **Update Setup File**
   - Modify `test/hydepwns_liveview_web/js/setup.js` to include global mocks
   - Add helper functions for ES Module testing

5. **Update Existing Tests**
   - Refactor existing tests to use the new mocking patterns
   - Fix any broken imports or mocks

## Examples

### Example 1: Mocking EventManager and DOMCleanup

```javascript
// Before
jest.mock('../../assets/js/utils/dom_cleanup', () => {
  return {
    register: jest.fn().mockReturnValue({
      registerElement: jest.fn(),
      registerTimeout: jest.fn(),
      cleanup: jest.fn()
    }),
    createElement: jest.fn()
  };
});

// After
import { createDOMCleanupMock } from '../mocks/dom_cleanup_mock';
import { createEventManagerMock } from '../mocks/event_manager_mock';

jest.mock('../../assets/js/utils/dom_cleanup', () => ({
  __esModule: true,
  default: createDOMCleanupMock()
}));

jest.mock('../../assets/js/components/event_manager', () => ({
  __esModule: true,
  default: createEventManagerMock()
}));
```markdown

### Example 2: Testing a Component with Dynamic Imports

```javascript
// Component with dynamic import
class MyComponent {
  async loadPlugin() {
    const plugin = await import('./plugins/my_plugin');
    return plugin.default;
  }
}

// Test
jest.mock('../../assets/js/components/plugins/my_plugin', () => ({
  __esModule: true,
  default: jest.fn().mockImplementation(() => ({
    initialize: jest.fn(),
    process: jest.fn()
  }))
}));

test('loads plugin correctly', async () => {
  const component = new MyComponent();
  const plugin = await component.loadPlugin();
  expect(plugin.initialize).toBeDefined();
  expect(plugin.process).toBeDefined();
});
```markdown

## Troubleshooting

### Common Issues and Solutions

1. **SyntaxError: Cannot use import statement outside a module**
   - Check Babel configuration
   - Ensure the file is being transformed correctly

2. **Error: Jest: ES Modules cannot be used with jest.mock()**
   - Use the `__esModule: true` pattern shown above
   - Move mock declarations to the top of the file

3. **ReferenceError: [Browser API] is not defined**
   - Add missing browser API mocks to `setup.js`
   - Use `@testing-library/jest-dom` for DOM-related assertions

4. **Module not found errors**
   - Check import paths
   - Verify moduleNameMapper configuration in Jest config

5. **Unexpected token 'export'**
   - Check transformIgnorePatterns to ensure the module is being transformed
   - Add the package to the exceptions list

### Debugging Tips

1. Use `jest --no-cache` to force Jest to reload all files
2. Check the Babel output with `npx babel [file] --out-file /tmp/transformed.js`
3. Use `console.log(jest.isMockFunction(module))` to verify mocking
4. Run tests with `--verbose` flag for more detailed output 

## References

- [Project Documentation](../README.md)
