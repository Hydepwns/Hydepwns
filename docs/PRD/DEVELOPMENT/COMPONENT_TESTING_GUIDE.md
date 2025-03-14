# Component Testing Guide

This guide provides comprehensive documentation on testing components in the Hydepwns project. It covers everything from setting up the testing environment to writing effective tests for different component types.

## Table of Contents

1. [Introduction](#introduction)
2. [Testing Environment Setup](#testing-environment-setup)
3. [Test Structure](#test-structure)
4. [Testing Component Lifecycle](#testing-component-lifecycle)
5. [Testing DOM Interactions](#testing-dom-interactions)
6. [Testing Event Handling](#testing-event-handling)
7. [Testing Component State](#testing-component-state)
8. [Testing Accessibility](#testing-accessibility)
9. [Testing Performance](#testing-performance)
10. [Mocking Dependencies](#mocking-dependencies)
11. [Testing Edge Cases](#testing-edge-cases)
12. [Debugging Tests](#debugging-tests)
13. [Test Coverage](#test-coverage)
14. [Continuous Integration](#continuous-integration)
15. [Best Practices](#best-practices)

## Introduction

Component testing is essential for ensuring that our components work correctly, maintain their functionality over time, and provide a good user experience. This guide will help you write effective tests for components using our robust component system.

### Why Test Components?

- **Prevent Regressions**: Tests catch regressions when code changes.
- **Document Behavior**: Tests serve as documentation for how components should behave.
- **Improve Design**: Writing tests often leads to better component design.
- **Enable Refactoring**: Tests give confidence when refactoring code.
- **Ensure Accessibility**: Tests can verify that components are accessible.

### Types of Component Tests

- **Unit Tests**: Test individual functions and methods in isolation.
- **Integration Tests**: Test how components interact with each other.
- **DOM Tests**: Test how components interact with the DOM.
- **Event Tests**: Test how components handle events.
- **Accessibility Tests**: Test that components are accessible.
- **Performance Tests**: Test that components perform well.

## Testing Environment Setup

### Prerequisites

- Node.js (v14 or later)
- npm (v6 or later)

### Installation

```bash
# Install dependencies
npm install

# Install additional testing dependencies
npm install --save-dev @testing-library/dom @testing-library/jest-dom jest-environment-jsdom
```

### Configuration

Our testing environment is configured in the following files:

- `babel.config.js`: Babel configuration for transpiling ES modules
- `test/hydepwns_liveview_web/js/jest.config.js`: Jest configuration
- `test/hydepwns_liveview_web/js/setup.js`: Setup file for Jest

### Running Tests

```bash
# Run all tests
npm test

# Run tests for a specific component
npm test -- -t "Toast Component"

# Run tests with coverage
npm test -- --coverage

# Watch mode (run tests on file changes)
npm test -- --watch
```

## Test Structure

### Basic Test Structure

```javascript
// Import the component to test
import { MyComponent } from '../../../../assets/js/components/my_component';

// Import testing utilities
import { fireEvent } from '@testing-library/dom';

// Mock dependencies
jest.mock('../../../../assets/js/components/event_manager', () => ({
  __esModule: true,
  default: global.createEventManagerMock()
}));

jest.mock('../../../../assets/js/utils/dom_cleanup', () => ({
  __esModule: true,
  default: global.createDOMCleanupMock()
}));

// Test suite
describe('MyComponent', () => {
  // Setup and teardown
  let container;
  
  beforeEach(() => {
    // Create a container element
    container = global.createTestContainer();
  });
  
  afterEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
  });
  
  // Test cases
  test('initializes with default options', () => {
    // Create component
    const component = new MyComponent({
      container: container
    }).mount();
    
    // Assertions
    expect(component).toBeTruthy();
    expect(component.options.defaultOption).toBe('default value');
  });
  
  test('handles click events', () => {
    // Create component
    const component = new MyComponent({
      container: container
    }).mount();
    
    // Find button element
    const button = container.querySelector('button');
    
    // Simulate click event
    fireEvent.click(button);
    
    // Assertions
    expect(component.getState().clicked).toBe(true);
  });
});
```

### Test Organization

Organize tests by component functionality:

```javascript
describe('MyComponent', () => {
  // Initialization tests
  describe('initialization', () => {
    test('initializes with default options', () => {
      // ...
    });
    
    test('initializes with custom options', () => {
      // ...
    });
  });
  
  // Event handling tests
  describe('event handling', () => {
    test('handles click events', () => {
      // ...
    });
    
    test('handles keyboard events', () => {
      // ...
    });
  });
  
  // State management tests
  describe('state management', () => {
    test('updates state correctly', () => {
      // ...
    });
    
    test('resets state correctly', () => {
      // ...
    });
  });
  
  // Cleanup tests
  describe('cleanup', () => {
    test('cleans up DOM elements', () => {
      // ...
    });
    
    test('cleans up event listeners', () => {
      // ...
    });
  });
});
```

## Testing Component Lifecycle

### Testing Initialization

```javascript
test('initializes with default options', () => {
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Check that component was created and mounted
  expect(component).toBeTruthy();
  expect(component.elements.container).toBe(container);
  
  // Check default options
  expect(component.options.defaultOption).toBe('default value');
  
  // Check that EventManager was called
  const eventManager = require('../../../../assets/js/components/event_manager').default;
  expect(eventManager.registerComponent).toHaveBeenCalledWith(expect.any(String));
  
  // Check that DOMCleanup was called
  const domCleanup = require('../../../../assets/js/utils/dom_cleanup').default;
  expect(domCleanup.register).toHaveBeenCalledWith(expect.any(String));
});
```

### Testing Destruction

```javascript
test('cleans up properly on destroy', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get mock instances
  const eventManager = require('../../../../assets/js/components/event_manager').default;
  const domCleanup = require('../../../../assets/js/utils/dom_cleanup').default;
  const cleanupRegistry = domCleanup.register.mock.results[0].value;
  
  // Destroy component
  component.destroy();
  
  // Verify cleanup was called
  expect(cleanupRegistry.cleanup).toHaveBeenCalled();
  expect(eventManager.unregisterComponent).toHaveBeenCalledWith(expect.any(String));
});
```

### Testing Updates

```javascript
test('updates correctly when options change', () => {
  // Create component
  const component = new MyComponent({
    container: container,
    initialValue: 'initial'
  }).mount();
  
  // Update component
  component.update({
    initialValue: 'updated'
  });
  
  // Verify component was updated
  expect(component.options.initialValue).toBe('updated');
  expect(container.querySelector('.value')).toHaveTextContent('updated');
});
```

## Testing DOM Interactions

### Testing Element Creation

```javascript
test('creates the correct DOM structure', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Check that elements were created with correct attributes
  expect(container.querySelector('.my-component')).toBeInTheDocument();
  expect(container.querySelector('.my-component-header')).toHaveTextContent('Header');
  
  // Check for nested elements
  const list = container.querySelector('.my-component-list');
  expect(list).toBeInTheDocument();
  expect(list.children.length).toBe(3);
  
  // Check for correct attributes
  expect(container.querySelector('button')).toHaveAttribute('aria-expanded', 'false');
});
```

### Testing Element Manipulation

```javascript
test('manipulates DOM elements correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const button = container.querySelector('button');
  const panel = container.querySelector('.panel');
  
  // Check initial state
  expect(panel).toHaveClass('hidden');
  
  // Trigger action
  fireEvent.click(button);
  
  // Check updated state
  expect(panel).not.toHaveClass('hidden');
  expect(panel).toHaveClass('visible');
});
```

### Testing Element Removal

```javascript
test('removes elements correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const item = container.querySelector('.item');
  const removeButton = container.querySelector('.remove-button');
  
  // Check initial state
  expect(item).toBeInTheDocument();
  
  // Trigger action
  fireEvent.click(removeButton);
  
  // Check updated state
  expect(item).not.toBeInTheDocument();
});
```

## Testing Event Handling

### Testing Click Events

```javascript
test('handles click events correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const button = container.querySelector('button');
  
  // Spy on component method
  const handleClickSpy = jest.spyOn(component, '_handleClick');
  
  // Trigger click event
  fireEvent.click(button);
  
  // Check that handler was called
  expect(handleClickSpy).toHaveBeenCalled();
  
  // Check that state was updated
  expect(component.getState().clicked).toBe(true);
  
  // Check that DOM was updated
  expect(button).toHaveClass('clicked');
});
```

### Testing Keyboard Events

```javascript
test('handles keyboard events correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const input = container.querySelector('input');
  
  // Focus the input
  input.focus();
  
  // Trigger keyboard event
  fireEvent.keyDown(input, { key: 'Enter', code: 'Enter' });
  
  // Check that state was updated
  expect(component.getState().submitted).toBe(true);
  
  // Check that DOM was updated
  expect(container.querySelector('.success-message')).toBeInTheDocument();
});
```

### Testing Custom Events

```javascript
test('handles custom events correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Create custom event
  const customEvent = new CustomEvent('custom', {
    detail: { data: 'test' }
  });
  
  // Dispatch custom event
  container.dispatchEvent(customEvent);
  
  // Check that state was updated
  expect(component.getState().customData).toBe('test');
});
```

## Testing Component State

### Testing Initial State

```javascript
test('initializes with correct state', () => {
  // Create component
  const component = new MyComponent({
    container: container,
    initialValue: 'test'
  }).mount();
  
  // Check initial state
  expect(component.getState().value).toBe('test');
  expect(component.getState().isActive).toBe(false);
});
```

### Testing State Updates

```javascript
test('updates state correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get initial state
  const initialState = component.getState();
  
  // Update state
  component.setState({ value: 'updated' });
  
  // Check updated state
  expect(component.getState().value).toBe('updated');
  expect(component.getState().isActive).toBe(initialState.isActive);
});
```

### Testing State-Dependent Rendering

```javascript
test('renders correctly based on state', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Check initial rendering
  expect(container.querySelector('.value')).toHaveTextContent('default');
  expect(container.querySelector('.status')).toHaveTextContent('inactive');
  
  // Update state
  component.setState({ value: 'updated', isActive: true });
  
  // Check updated rendering
  expect(container.querySelector('.value')).toHaveTextContent('updated');
  expect(container.querySelector('.status')).toHaveTextContent('active');
});
```

## Testing Accessibility

### Testing ARIA Attributes

```javascript
test('sets correct ARIA attributes', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const button = container.querySelector('button');
  const panel = container.querySelector('.panel');
  
  // Check initial ARIA attributes
  expect(button).toHaveAttribute('aria-expanded', 'false');
  expect(button).toHaveAttribute('aria-controls', panel.id);
  expect(panel).toHaveAttribute('aria-hidden', 'true');
  
  // Trigger action
  fireEvent.click(button);
  
  // Check updated ARIA attributes
  expect(button).toHaveAttribute('aria-expanded', 'true');
  expect(panel).toHaveAttribute('aria-hidden', 'false');
});
```

### Testing Focus Management

```javascript
test('manages focus correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const button = container.querySelector('button');
  const dialog = container.querySelector('.dialog');
  const closeButton = dialog.querySelector('.close-button');
  
  // Check initial focus
  expect(document.activeElement).not.toBe(dialog);
  
  // Open dialog
  fireEvent.click(button);
  
  // Check focus moved to dialog
  expect(document.activeElement).toBe(dialog);
  
  // Close dialog
  fireEvent.click(closeButton);
  
  // Check focus returned to button
  expect(document.activeElement).toBe(button);
});
```

### Testing Keyboard Navigation

```javascript
test('supports keyboard navigation', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get elements
  const tabs = container.querySelectorAll('.tab');
  const panels = container.querySelectorAll('.panel');
  
  // Focus first tab
  tabs[0].focus();
  
  // Check initial state
  expect(tabs[0]).toHaveAttribute('aria-selected', 'true');
  expect(panels[0]).not.toHaveAttribute('hidden');
  
  // Press right arrow key
  fireEvent.keyDown(tabs[0], { key: 'ArrowRight' });
  
  // Check focus moved to next tab
  expect(document.activeElement).toBe(tabs[1]);
  
  // Press enter key
  fireEvent.keyDown(tabs[1], { key: 'Enter' });
  
  // Check tab was activated
  expect(tabs[1]).toHaveAttribute('aria-selected', 'true');
  expect(panels[1]).not.toHaveAttribute('hidden');
  expect(tabs[0]).toHaveAttribute('aria-selected', 'false');
  expect(panels[0]).toHaveAttribute('hidden');
});
```

## Testing Performance

### Testing Animation Performance

```javascript
test('optimizes animations for performance', () => {
  // Mock requestAnimationFrame
  jest.spyOn(window, 'requestAnimationFrame').mockImplementation(cb => setTimeout(cb, 0));
  
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Trigger animation
  component.animate();
  
  // Check that requestAnimationFrame was used
  expect(window.requestAnimationFrame).toHaveBeenCalled();
  
  // Restore original implementation
  window.requestAnimationFrame.mockRestore();
});
```

### Testing Throttling and Debouncing

```javascript
test('throttles event handlers for performance', () => {
  // Mock performance.now
  jest.spyOn(performance, 'now')
    .mockReturnValueOnce(0)
    .mockReturnValueOnce(100)
    .mockReturnValueOnce(150);
  
  // Create component
  const component = new MyComponent({
    container: container,
    throttleDelay: 200
  }).mount();
  
  // Spy on handler
  const handleResizeSpy = jest.spyOn(component, '_handleResize');
  
  // Trigger events in quick succession
  component._throttledResize();
  component._throttledResize();
  
  // Check that handler was called only once
  expect(handleResizeSpy).toHaveBeenCalledTimes(1);
  
  // Restore original implementation
  performance.now.mockRestore();
});
```

## Mocking Dependencies

### Mocking EventManager

```javascript
// Mock EventManager
jest.mock('../../../../assets/js/components/event_manager', () => ({
  __esModule: true,
  default: {
    registerComponent: jest.fn().mockReturnValue({
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      addDelegatedEventListener: jest.fn(),
      cleanup: jest.fn()
    }),
    unregisterComponent: jest.fn()
  }
}));

test('registers event listeners correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get EventManager mock
  const eventManager = require('../../../../assets/js/components/event_manager').default;
  const componentAPI = eventManager.registerComponent.mock.results[0].value;
  
  // Check that event listeners were registered
  expect(componentAPI.addEventListener).toHaveBeenCalledWith(
    expect.any(HTMLElement),
    'click',
    expect.any(Function)
  );
});
```

### Mocking DOMCleanup

```javascript
// Mock DOMCleanup
jest.mock('../../../../assets/js/utils/dom_cleanup', () => ({
  __esModule: true,
  default: {
    register: jest.fn().mockReturnValue({
      registerElement: jest.fn(),
      registerTimeout: jest.fn(),
      registerInterval: jest.fn(),
      cleanup: jest.fn()
    }),
    createElement: jest.fn().mockImplementation((tag) => document.createElement(tag)),
    removeAllChildren: jest.fn()
  }
}));

test('registers DOM elements for cleanup', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Get DOMCleanup mock
  const domCleanup = require('../../../../assets/js/utils/dom_cleanup').default;
  const cleanupRegistry = domCleanup.register.mock.results[0].value;
  
  // Check that elements were registered for cleanup
  expect(cleanupRegistry.registerElement).toHaveBeenCalled();
});
```

### Mocking Browser APIs

```javascript
test('handles browser APIs correctly', () => {
  // Mock localStorage
  const localStorageMock = {
    getItem: jest.fn().mockReturnValue('stored value'),
    setItem: jest.fn(),
    removeItem: jest.fn()
  };
  Object.defineProperty(window, 'localStorage', { value: localStorageMock });
  
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Check that localStorage was used
  expect(localStorageMock.getItem).toHaveBeenCalledWith('my-component-key');
  expect(component.getState().storedValue).toBe('stored value');
  
  // Update stored value
  component.updateStoredValue('new value');
  
  // Check that localStorage was updated
  expect(localStorageMock.setItem).toHaveBeenCalledWith('my-component-key', 'new value');
});
```

## Testing Edge Cases

### Testing Empty States

```javascript
test('handles empty data correctly', () => {
  // Create component with empty data
  const component = new MyComponent({
    container: container,
    data: []
  }).mount();
  
  // Check that empty state is shown
  expect(container.querySelector('.empty-state')).toBeInTheDocument();
  expect(container.querySelector('.empty-state')).toHaveTextContent('No data available');
});
```

### Testing Error States

```javascript
test('handles errors correctly', () => {
  // Mock API call to throw error
  jest.spyOn(global, 'fetch').mockRejectedValue(new Error('API error'));
  
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Trigger API call
  return component.fetchData().catch(() => {
    // Check that error state is shown
    expect(container.querySelector('.error-state')).toBeInTheDocument();
    expect(container.querySelector('.error-state')).toHaveTextContent('Failed to fetch data');
    
    // Restore original implementation
    global.fetch.mockRestore();
  });
});
```

### Testing Boundary Conditions

```javascript
test('handles boundary conditions correctly', () => {
  // Test with minimum value
  let component = new MyComponent({
    container: container,
    value: 0
  }).mount();
  
  // Check that minimum value is handled correctly
  expect(container.querySelector('.value')).toHaveTextContent('0');
  expect(container.querySelector('.decrement-button')).toBeDisabled();
  
  // Clean up
  component.destroy();
  container.innerHTML = '';
  
  // Test with maximum value
  component = new MyComponent({
    container: container,
    value: 100
  }).mount();
  
  // Check that maximum value is handled correctly
  expect(container.querySelector('.value')).toHaveTextContent('100');
  expect(container.querySelector('.increment-button')).toBeDisabled();
});
```

## Debugging Tests

### Using Console Logs

```javascript
test('can be debugged with console logs', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Log component state for debugging
  console.log('Component state:', component.getState());
  
  // Log DOM structure for debugging
  console.log('DOM structure:', container.innerHTML);
  
  // Continue with test
  // ...
});
```

### Using Jest Debug Mode

```bash
# Run a specific test in debug mode
node --inspect-brk node_modules/.bin/jest --runInBand "MyComponent"
```

### Using Test Snapshots

```javascript
test('renders correctly', () => {
  // Create component
  const component = new MyComponent({
    container: container
  }).mount();
  
  // Check that component renders correctly
  expect(container.innerHTML).toMatchSnapshot();
});
```

## Test Coverage

### Checking Coverage

```bash
# Generate coverage report
npm test -- --coverage
```

### Coverage Thresholds

```javascript
// jest.config.js
module.exports = {
  // ...
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 85,
      lines: 80
    }
  }
};
```

### Ignoring Code from Coverage

```javascript
// Ignore a line from coverage
const value = condition ? 'a' : 'b'; // istanbul ignore next

// Ignore a function from coverage
/* istanbul ignore next */
function debugOnly() {
  // Debug code
}
```

## Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Use Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Check coverage
        run: npm test -- --coverage
```

## Best Practices

### 1. Test Behavior, Not Implementation

Focus on testing what the component does, not how it does it:

```javascript
// Good: Test behavior
test('shows success message when form is submitted', () => {
  // ...
});

// Bad: Test implementation
test('calls _handleSubmit when form is submitted', () => {
  // ...
});
```

### 2. Keep Tests Independent

Each test should be independent of other tests:

```javascript
// Good: Independent tests
test('initializes with default options', () => {
  // ...
});

test('handles click events', () => {
  // ...
});

// Bad: Dependent tests
test('initializes and handles events', () => {
  // Initialize component
  // ...
  
  // Test event handling
  // ...
});
```

### 3. Use Descriptive Test Names

Use descriptive test names that explain what is being tested:

```javascript
// Good: Descriptive test name
test('shows error message when invalid data is submitted', () => {
  // ...
});

// Bad: Vague test name
test('handles errors', () => {
  // ...
});
```

### 4. Test Edge Cases

Test edge cases and boundary conditions:

```javascript
// Test edge cases
test('handles empty data', () => {
  // ...
});

test('handles maximum value', () => {
  // ...
});

test('handles invalid input', () => {
  // ...
});
```

### 5. Clean Up After Tests

Clean up after each test to prevent test pollution:

```javascript
afterEach(() => {
  // Clean up any components
  if (component) {
    component.destroy();
    component = null;
  }
  
  // Clean up DOM
  if (container && container.parentNode) {
    container.parentNode.removeChild(container);
    container = null;
  }
  
  // Reset mocks
  jest.clearAllMocks();
});
``` 