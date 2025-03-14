---
title: Component-Testing-Framework
description: '## Overview'
topics:
  - development
  - testing
  - component-testing-framework
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - table-of-contents
  - testing-objectives
  - testing-tools
  - test-environment-setup
  - test-categories
  - component-test-suite
  - automated-test-implementation
  - visual-regression-testing
  - performance-testing
  - accessibility-testing
  - test-documentation
  - continuous-integration
  - '-github-workflows-component-tests-yml'
  - component-test-coverage-requirements
  - common-testing-challenges
  - test-coverage-strategy
  - component-specific-testing-patterns
  - conclusion
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Component-Testing-Framework

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Component-Testing-Framework.


---
title: Component Testing Framework
description: A comprehensive framework for testing components migrated to the robust component system
category: development
subcategory: testing
order: 1
---

# Component Testing Framework

This document outlines the comprehensive testing framework for validating components migrated to the robust component system. It provides standardized approaches, tools, and methodologies to ensure that migrated components meet quality, performance, and accessibility requirements.

## Table of Contents

1. [Testing Objectives](#testing-objectives)
2. [Testing Tools](#testing-tools)
3. [Test Environment Setup](#test-environment-setup)
4. [Test Categories](#test-categories)
5. [Component Test Suite](#component-test-suite)
6. [Automated Test Implementation](#automated-test-implementation)
7. [Visual Regression Testing](#visual-regression-testing)
8. [Performance Testing](#performance-testing)
9. [Accessibility Testing](#accessibility-testing)
10. [Test Documentation](#test-documentation)
11. [Continuous Integration](#continuous-integration)
12. [Common Testing Challenges](#common-testing-challenges)
13. [Test Coverage Strategy](#test-coverage-strategy)
14. [Component-Specific Testing Patterns](#component-specific-testing-patterns)

## Testing Objectives

The primary objectives of component testing are to verify:

1. **Functional Correctness**: Components behave as expected after migration
2. **Resource Management**: Components properly manage DOM elements, event listeners, and other resources
3. **Isolation**: Components function correctly in isolation and multiple instances
4. **Accessibility**: Components meet accessibility requirements
5. **Performance**: Components maintain or improve performance after migration

## Testing Tools

### Core Testing Libraries

- **Jest**: Primary JavaScript testing framework
- **Testing Library**: DOM testing utilities with user-centric approach
- **Sinon.js**: Spies, stubs, and mocks for JavaScript tests
- **Chai**: Assertion library with multiple assertion styles

### Accessibility Testing

- **axe-core**: Automated accessibility testing library
- **pa11y**: Command-line accessibility testing
- **Storybook a11y addon**: Visual accessibility testing

### Performance Testing

- **Lighthouse**: Performance, accessibility, and best practices testing
- **Chrome DevTools**: Memory profiling and performance analysis
- **webpack-bundle-analyzer**: Bundle size analysis

### Visual Testing

- **Percy**: Visual regression testing
- **Storybook**: Component isolation and visual testing
- **Chromatic**: Visual testing and UI review

## Test Environment Setup

### Basic Setup

Create a standardized test environment for component testing:

```javascript
// test/js/setup.js
import '@testing-library/jest-dom';
import sinon from 'sinon';

// Mock browser APIs not available in Jest DOM environment
global.ResizeObserver = class ResizeObserver {
  constructor(callback) {
    this.callback = callback;
  }
  observe() {}
  unobserve() {}
  disconnect() {}
};

// Create storage for global test artifacts
global.testElements = [];

// Setup DOM cleanup between tests
afterEach(() => {
  // Clean up any DOM elements created during testing
  global.testElements.forEach(el => {
    if (el && el.parentNode) {
      el.parentNode.removeChild(el);
    }
  });
  global.testElements = [];
  
  // Clean up any Sinon mocks/stubs
  sinon.restore();
});

// Helper to create and track test containers
global.createTestContainer = () => {
  const container = document.createElement('div');
  container.className = 'test-container';
  document.body.appendChild(container);
  global.testElements.push(container);
  return container;
};
```markdown

### Component Test Utility

Use and extend the `ComponentTestUtility` from the Component Migration Plan for testing migrated components:

```javascript
// test/js/component_test_utility.js
import sinon from 'sinon';
import { fireEvent } from '@testing-library/dom';

export default class ComponentTestUtility {
  // ... [existing code from migration plan] ...
  
  // Additional test helpers
  
  simulateUserInteraction(element, event, options = {}) {
    return fireEvent[event](element, options) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->;
  }
  
  waitForAnimation(ms = 300) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  spyOnMethod(instance, methodName) {
    return sinon.spy(instance, methodName);
  }
  
  stubMethod(instance, methodName, returnValue) {
    return sinon.stub(instance, methodName).returns(returnValue);
  }
  
  async testEventCleaning(options = {}) {
    // Create instance
    const instance = this.createInstance(options);
    
    // Get all elements that should have events
    const elements = Object.values(instance.elements).filter(el => el && el.nodeType === 1);
    
    // Add spy to addEventListener
    const addEventSpy = sinon.spy(EventTarget.prototype, 'addEventListener');
    const removeEventSpy = sinon.spy(EventTarget.prototype, 'removeEventListener');
    
    // Destroy instance
    this.destroyInstance(instance);
    
    // Check if all added events were removed
    const eventBalance = addEventSpy.callCount - removeEventSpy.callCount;
    
    // Restore spies
    addEventSpy.restore();
    removeEventSpy.restore();
    
    return eventBalance === 0;
  }
}
```markdown

## Test Categories

### 1. Unit Tests

Test individual methods and properties of the component class:

- Constructor and options handling
- Public methods
- State management
- Event handler methods
- DOM building methods
- Cleanup methods

### 2. Integration Tests

Test component interaction with other parts of the system:

- Interaction with LiveView hooks
- Interaction with other components
- Interaction with the EventManager
- Interaction with the DOMCleanup utility

### 3. Behavioral Tests

Test the component's behavior from a user perspective:

- User interactions (clicks, keyboard, etc.)
- Visual changes in response to user actions
- Proper event handling and responses
- Accessibility behaviors

### 4. Resource Management Tests

Test the component's resource management:

- Memory usage
- Event listener cleanup
- DOM element cleanup
- External resource cleanup (timers, observers, etc.)

### 5. Visual Tests

Test the component's visual appearance:

- Baseline appearance matches design
- Correct appearance in different themes
- Correct appearance in different viewport sizes
- Animation correctness

## Component Test Suite

Each migrated component should have a comprehensive test suite with the following structure:

```javascript
// test/js/components/your_component_test.js
import ComponentTestUtility from '../component_test_utility';
import { YourComponentClass } from '../assets/js/components/your_component';
import sinon from 'sinon';
import { expect } from 'chai';

describe('YourComponent', () => {
  let testUtil;
  
  beforeEach(() => {
    testUtil = new ComponentTestUtility(YourComponentClass);
  });
  
  afterEach(() => {
    testUtil.cleanup();
  });
  
  describe('Initialization', () => {
    it('should initialize with default options', () => {
      const instance = testUtil.createInstance();
      expect(instance.options).to.include({
        // Default option values
      });
    });
    
    it('should merge user options with defaults', () => {
      const instance = testUtil.createInstance({
        // Custom options
      });
      
      expect(instance.options).to.include({
        // Expected merged options
      });
    });
    
    it('should create required DOM elements', () => {
      const instance = testUtil.createInstance();
      
      expect(instance.elements.root).to.exist;
      // Check other required elements
    });
  });
  
  describe('Public Methods', () => {
    // Test all public methods
  });
  
  describe('Event Handling', () => {
    // Test event handlers
  });
  
  describe('Resource Management', () => {
    it('should clean up all DOM elements on destroy', () => {
      const instance = testUtil.createInstance();
      const containerEl = instance.elements.container;
      
      // Get initial child count
      const initialChildCount = containerEl.querySelectorAll('*').length;
      expect(initialChildCount).to.be.greaterThan(0);
      
      // Destroy instance
      testUtil.destroyInstance(instance);
      
      // Verify children are removed
      const finalChildCount = containerEl.querySelectorAll('*').length;
      expect(finalChildCount).to.equal(0);
    });
    
    it('should clean up all event listeners on destroy', async () => {
      const cleaned = await testUtil.testEventCleaning();
      expect(cleaned).to.be.true;
    });
    
    it('should not leak memory after multiple instantiations', async () => {
      const noLeaks = await testUtil.detectMemoryLeaks(20);
      expect(noLeaks).to.be.true;
    });
  });
  
  describe('Accessibility', () => {
    // Test accessibility features
  });
});
```markdown

## Automated Test Implementation

### Unit Test Examples

```javascript
// Testing state management
it('should update state correctly', () => {
  const instance = testUtil.createInstance();
  
  // Use private method directly for testing
  instance._setState({ count: 5 });
  
  expect(instance._state.count).to.equal(5);
  
  // Test render happened
  const counterEl = instance.elements.counterValue;
  expect(counterEl.textContent).to.equal('5');
});

// Testing event handlers
it('should handle click events', () => {
  const instance = testUtil.createInstance();
  const spy = testUtil.spyOnMethod(instance, '_handleIncrementClick');
  
  // Simulate click
  testUtil.simulateUserInteraction(instance.elements.incrementButton, 'click');
  
  expect(spy.calledOnce).to.be.true;
});
```markdown

### Integration Test Examples

```javascript
// Testing LiveView hook integration
it('should integrate with LiveView hooks', () => {
  // Create mock LiveView hook environment
  const hookEl = document.createElement('div');
  document.body.appendChild(hookEl);
  global.testElements.push(hookEl);
  
  // Create LiveView hook context
  const hook = {
    el: hookEl,
    component: null
  };
  
  // Import the hook
  const CounterHook = require('../../assets/js/components/counter').default;
  
  // Call the hook methods
  CounterHook.mounted.call(hook);
  
  // Verify component was initialized
  expect(hook.component).to.exist;
  expect(hook.component.options.container).to.equal(hookEl);
  
  // Test cleanup
  CounterHook.destroyed.call(hook);
  expect(hook.component).to.be.null;
});
```markdown

## Visual Regression Testing

Implement visual testing with Percy or similar tool:

```javascript
// Percy example
import { percySnapshot } from '@percy/cypress';

describe('Component Visual Tests', () => {
  it('should match the visual baseline', () => {
    // Create component instance
    const instance = testUtil.createInstance();
    
    // Take snapshot
    percySnapshot('YourComponent - Default State');
    
    // Interact with component
    testUtil.simulateUserInteraction(instance.elements.incrementButton, 'click');
    
    // Take snapshot of updated state
    percySnapshot('YourComponent - Updated State');
  });
});
```markdown

## Performance Testing

### Memory Usage Tests

```javascript
it('should maintain stable memory usage', async () => {
  // Start performance monitoring
  const memoryStart = performance.memory.usedJSHeapSize;
  
  // Create and destroy 50 instances
  for (let i = 0; i < 50; i++) {
    const instance = testUtil.createInstance();
    
    // Simulate some interactions
    for (let j = 0; j < 10; j++) {
      testUtil.simulateUserInteraction(instance.elements.incrementButton, 'click');
    }
    
    testUtil.destroyInstance(instance);
  }
  
  // Force garbage collection if possible
  if (window.gc) {
    window.gc();
  }
  
  // Check memory after test
  const memoryEnd = performance.memory.usedJSHeapSize;
  const memoryIncrease = memoryEnd - memoryStart;
  
  // Memory usage should not increase dramatically
  // Allow for some small increase due to test environment
  expect(memoryIncrease).to.be.lessThan(5000000); // Less than 5MB growth
});
```markdown

### Render Performance Tests

```javascript
it('should render efficiently', () => {
  const instance = testUtil.createInstance();
  
  // Measure render time
  const start = performance.now();
  
  // Trigger multiple renders
  for (let i = 0; i < 100; i++) {
    instance._setState({ count: i });
  }
  
  const end = performance.now();
  const averageRenderTime = (end - start) / 100;
  
  // Average render should be fast
  expect(averageRenderTime).to.be.lessThan(5); // Less than 5ms per render
});
```markdown

## Accessibility Testing

### Automated Tests with axe

```javascript
import { axe } from 'jest-axe';

it('should meet accessibility standards', async () => {
  const instance = testUtil.createInstance();
  const container = instance.elements.container;
  
  // Run axe
  const results = await axe(container);
  
  // No violations should be found
  expect(results.violations.length).to.equal(0);
});
```markdown

### Keyboard Navigation Tests

```javascript
it('should be fully keyboard navigable', () => {
  const instance = testUtil.createInstance();
  
  // Test focus handling
  instance.elements.incrementButton.focus();
  expect(document.activeElement).to.equal(instance.elements.incrementButton);
  
  // Test keyboard operation
  testUtil.simulateUserInteraction(instance.elements.incrementButton, 'keyDown', { key: 'Enter' });
  expect(instance._state.count).to.equal(1);
  
  // Test tab order
  // ...
});
```markdown

## Test Documentation

For each migrated component, create a test report that includes:

1. **Test Coverage**: Percentage of code covered by tests
2. **Performance Metrics**: Memory usage, render times, bundle size impact
3. **Accessibility Audit**: Results of automated and manual accessibility tests
4. **Visual Regression**: Before/after screenshots of the component
5. **Browser Compatibility**: Test results across supported browsers

## Continuous Integration

Integrate component testing into CI/CD pipeline:

```yaml
# .github/workflows/component-tests.yml
name: Component Tests

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'assets/js/components/**'
      - 'test/js/components/**'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'assets/js/components/**'
      - 'test/js/components/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm run test:components
      
    - name: Run Percy visual tests
      run: npm run test:visual
      env:
        PERCY_TOKEN: ${{ secrets.PERCY_TOKEN }}
        
    - name: Run accessibility tests
      run: npm run test:accessibility
      
    - name: Check bundle size
      run: npm run analyze-bundle
      
    - name: Upload test artifacts
      uses: actions/upload-artifact@v2
      with:
        name: test-reports
        path: |
          coverage/
          bundle-analysis/
          accessibility-report/
```markdown

## Component Test Coverage Requirements

All migrated components must meet the following test coverage requirements:

1. **Unit Test Coverage**: Minimum 90% code coverage
2. **Visual Test Coverage**: All states and variations captured
3. **Accessibility Test Coverage**: All interactive elements tested
4. **Browser Coverage**: Tests run on Chrome, Firefox, Safari, and Edge

## Common Testing Challenges

### ES Modules and Jest

Jest can have difficulties with ES modules. Here are strategies to handle these issues:

1. **Babel Configuration for ES Modules**

   ```javascript
   // babel.config.js
   module.exports = {
     presets: [
       ['@babel/preset-env', { targets: { node: 'current' } }]
     ]
   };
   ```markdown

2. **Avoid ES Module Imports in Jest Setup Files**
   - Use CommonJS `require()` instead of ES module imports in setup files:

   ```javascript
   // Incorrect - may cause issues
   import '@testing-library/jest-dom';
   
   // Correct - use this approach
   const testingLibrary = require('@testing-library/jest-dom');
   ```markdown

3. **Handling Module Mocking**
   - Avoid DOM manipulation in `jest.mock()` factory functions:

   ```javascript
   // Incorrect - will cause errors
   jest.mock('../utils/dom_cleanup', () => ({
     createElement: () => document.createElement('div') // Error: document not available
   }));
   
   // Correct approach
   jest.mock('../utils/dom_cleanup', () => ({
     createElement: jest.fn().mockImplementation(() => ({}))
   }));
   
   // Then in the test:
   const mockElement = document.createElement('div');
   require('../utils/dom_cleanup').createElement.mockReturnValue(mockElement);
   ```markdown

### Testing DOM Manipulation

Components that extensively manipulate the DOM, like Toast, require special handling:

1. **Mocking DOM Creation**
   - Mock DOM creation methods but implement actual DOM manipulation in tests
   - Use document fragment when needed to avoid hierarchy errors

2. **Testing DOM Events**
   - When testing events, create and dispatch real events on actual DOM elements
   - Use Testing Library's `fireEvent` or `userEvent` for higher-level event simulation

3. **Handling Animation Timers**
   - Use Jest's timer mocks for components with animations or delays:

   ```javascript
   jest.useFakeTimers();
   
   // After triggering an animation
   jest.advanceTimersByTime(300); // Advance by animation duration
   ```markdown

### Dependency Handling

For components with complex dependencies:

1. **Utility Mocking**
   - Create dedicated mock factories for commonly used utilities
   - Establish patterns for mocking components with shared dependencies

2. **Browser API Simulation**
   - For browser APIs not implemented in jsdom, create property descriptors:

   ```javascript
   // Mock scrollHeight which isn't implemented in jsdom
   Object.defineProperty(HTMLElement.prototype, 'scrollHeight', {
     configurable: true,
     get: function() {
       return parseFloat(this.dataset.mockScrollHeight || '100');
     }
   });
   ```markdown

## Test Coverage Strategy

To achieve the 80% coverage target, follow this incremental approach:

1. **Component Prioritization**
   - Core UI components used across the application (highest priority)
   - Components with complex state management or DOM manipulation
   - Utility components used by multiple features
   - Feature-specific components (lowest priority)

2. **Test Prioritization for Each Component**
   - Initialization and mounting (baseline tests)
   - Core functionality and public API methods
   - Event handling and user interactions
   - Resource cleanup and memory management
   - Edge cases and error handling

3. **Incremental Coverage Goals**
   - Initial Phase: 25% coverage with fundamental tests
   - Second Phase: 50% coverage adding interaction tests
   - Third Phase: 65% coverage with edge case handling
   - Final Phase: 80%+ coverage with comprehensive tests

## Component-Specific Testing Patterns

Some components present unique testing challenges. Here are patterns for testing specific component types:

### Testing Toast Components

Toast components are particularly challenging to test due to their dynamic DOM manipulation and animation timing. Here's an effective testing strategy:

1. **Setup and Mocking**

   ```javascript
   // Mock the DOMCleanup module to avoid direct DOM manipulation in mock
   jest.mock('../../assets/js/utils/dom_cleanup', () => {
     return {
       register: jest.fn().mockReturnValue({
         registerElement: jest.fn(),
         registerTimeout: jest.fn(),
         cleanup: jest.fn()
       }),
       createElement: jest.fn().mockImplementation(() => {
         // Return a mock element that will be replaced in the test
         return {};
       })
     };
   });
   
   // Mock timers for testing animations
   jest.useFakeTimers();
   
   describe('Toast Component', () => {
     let container;
     let mockToastContainer;
     let mockToastElement;
     
     beforeEach(() => {
       // Create real DOM elements
       container = document.createElement('div');
       document.body.appendChild(container);
       
       // Create mock toast container
       mockToastContainer = document.createElement('div');
       mockToastContainer.className = 'toast-container';
       
       // Create mock toast element for testing
       mockToastElement = document.createElement('div');
       mockToastElement.className = 'toast';
       
       // Set up return values for mocks
       const domCleanup = require('../../assets/js/utils/dom_cleanup');
       domCleanup.createElement.mockImplementation((tag, attrs) => {
         if (attrs && attrs.className && attrs.className.includes('toast-container')) {
           return mockToastContainer;
         } else if (attrs && attrs.className && attrs.className.includes('toast')) {
           return mockToastElement;
         }
         return document.createElement(tag);
       });
     });
     
     // Test initialization
     test('initializes properly', () => {
       const toast = new ToastComponent({
         container: container
       }).mount();
       
       expect(toast.elements.container).toBe(container);
       expect(toast.elements.toastContainer).toBe(mockToastContainer);
     });
     
     // Test showing a toast
     test('shows a toast with correct properties', () => {
       const toast = new ToastComponent({
         container: container
       }).mount();
       
       // Before showing toast, set up parent-child relationship
       container.appendChild(mockToastContainer);
       mockToastContainer.appendChild(mockToastElement);
       
       // Show a toast
       const toastId = toast.show({
         message: 'Test message',
         type: 'success'
       });
       
       // Verify the toast was shown
       expect(toastId).toBeTruthy();
       expect(mockToastElement.classList.contains('toast-success')).toBe(true);
     });
     
     // Test toast auto-dismissal
     test('automatically dismisses toast after duration', () => {
       const toast = new ToastComponent({
         container: container,
         duration: 1000
       }).mount();
       
       // Set up DOM structure
       container.appendChild(mockToastContainer);
       mockToastContainer.appendChild(mockToastElement);
       
       // Keep reference to remove spy
       const removeSpy = jest.spyOn(mockToastElement, 'remove');
       
       // Show a toast
       toast.show({ message: 'Test message' });
       
       // Advance timers to trigger auto-dismissal
       jest.advanceTimersByTime(1000);
       
       // Opacity should be set to 0 for fade-out
       expect(mockToastElement.style.opacity).toBe('0');
       
       // Advance through animation
       jest.advanceTimersByTime(300);
       
       // Element should be removed
       expect(removeSpy).toHaveBeenCalled();
     });
   });
   ```markdown

2. **Key Patterns for Toast Testing**

   - Mock creation but test manipulation directly
   - Manually set up parent-child relationships to avoid hierarchy errors
   - Use jest.advanceTimersByTime() to test animations
   - Focus on behavior verification rather than implementation details
   - Test each toast variant (success, error, warning, info)

## Conclusion

This testing framework ensures that all components migrated to the robust component system meet high standards of quality, performance, and accessibility. By following these guidelines, we can maintain a consistent approach to testing across all components and identify potential issues early in the migration process. 

## References

- [Project Documentation](../README.md)
