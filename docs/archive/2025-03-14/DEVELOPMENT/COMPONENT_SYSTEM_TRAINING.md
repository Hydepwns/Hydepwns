---
title: Component System Training Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - component-system-training-guide
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - introduction
  - prerequisites
  - module-1-component-architecture-overview
  - module-2-creating-components
  - module-3-advanced-component-features
  - module-4-testing-components
  - module-5-component-integration-with-liveview
  - module-6-best-practices
  - practical-exercises
  - additional-resources
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Component System Training Guide

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Component System Training Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about COMPONENT SYSTEM TRAINING.


## Introduction

This training guide provides a comprehensive introduction to Hydepwns' component system. It covers component architecture, implementation patterns, resource management, event handling, and best practices.

## Prerequisites

Before starting this training, you should have:

- Basic knowledge of JavaScript
- Familiarity with DOM manipulation
- Understanding of event handling in browsers
- Basic knowledge of Phoenix LiveView

## Module 1: Component Architecture Overview

### 1.1 Component System Philosophy

The Hydepwns component system is built on these principles:

- **Modularity**: Components are self-contained units
- **Resource Management**: Components clean up their own resources
- **Event Isolation**: Components manage their own event listeners
- **Lifecycle Management**: Components have well-defined lifecycles
- **Consistent APIs**: Components follow standard interface patterns

### 1.2 Component Structure

Every component follows this standard structure:

```javascript
class ExampleComponent {
  constructor(options = {}) {
    // Component ID generation
    // Options merging
    // State initialization
    // Element references setup
  }
  
  mount() {
    // Event manager registration
    // Cleanup registry initialization
    // DOM construction
    // Event listener setup
    // Lifecycle hook triggering
  }
  
  destroy() {
    // Pre-destruction lifecycle hook
    // Resource cleanup
    // Event manager unregistration
    // Reference clearing
  }
  
  // Public API methods
  
  // Private implementation methods
}
```markdown

### 1.3 Key Utilities

The component system utilizes these key utilities:

- **EventManager**: Centralizes event listener management
- **DOMCleanup**: Manages DOM element creation and cleanup
- **ComponentRegistry**: Tracks component instances (future)

## Module 2: Creating Components

### 2.1 Creating a Basic Component

Follow these steps to create a new component:

1. **Define the Component Class**

```javascript
// import core utilities
import EventManager from '../components/event_manager';
import DOMCleanup from 'utils/dom_cleanup';

/**
 * Notification Component
 * 
 * Displays notification messages to the user
 */
class NotificationComponent {
  /**
   * Create a new Notification component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `notification-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      duration: 3000,
      type: 'info',
      message: '',
      ...options
    };
    
    // Component state
    this._state = {
      isVisible: false
    };
    
    // Element references
    this.elements = {
      container: null,
      root: null
    };
  }
  
  /**
   * Initialize and mount the component
   * @returns {this} Component instance
   */
  mount() {
    // Register with event manager
    this.events = EventManager.registerComponent(this.componentId);
    
    // Register with cleanup utility
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Create root element
    this.elements.root = DOMCleanup.createElement('div', {
      className: `notification notification--${this.options.type}`,
      id: this.componentId,
      'data-component': 'notification'
    }, '', this.cleanup);
    
    // Set container reference
    this.elements.container = this.options.container;
    
    // Build DOM structure
    this._buildDOM();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Add to DOM if message is provided
    if (this.options.message) {
      this.elements.container.appendChild(this.elements.root);
      this._setState({ isVisible: true });
      
      // Auto-hide after duration
      if (this.options.duration > 0) {
        const timeout = setTimeout(() => this.hide(), this.options.duration);
        this.cleanup.registerTimeout(timeout);
      }
    }
    
    return this;
  }
  
  /**
   * Remove the component and clean up resources
   */
  destroy() {
    // Remove from DOM if still attached
    if (this.elements.root && this.elements.root.parentNode) {
      this.elements.root.parentNode.removeChild(this.elements.root);
    }
    
    // Clean up registered resources
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Show a notification message
   * @param {string} message - The message to display
   * @param {string} type - The notification type (info, success, warning, error)
   * @returns {this} Component instance
   */
  show(message = this.options.message, type = this.options.type) {
    // Update message and type
    this.options.message = message;
    this.options.type = type;
    
    // Update class to match type
    if (this.elements.root) {
      this.elements.root.className = `notification notification--${type}`;
      this.elements.content.textContent = message;
      
      // Add to DOM if not already there
      if (!this.elements.root.parentNode) {
        this.elements.container.appendChild(this.elements.root);
      }
      
      this._setState({ isVisible: true });
      
      // Set up auto-hide
      if (this.options.duration > 0) {
        const timeout = setTimeout(() => this.hide(), this.options.duration);
        this.cleanup.registerTimeout(timeout);
      }
    }
    
    return this;
  }
  
  /**
   * Hide the notification
   * @returns {this} Component instance
   */
  hide() {
    if (this.elements.root && this.elements.root.parentNode) {
      this.elements.root.parentNode.removeChild(this.elements.root);
      this._setState({ isVisible: false });
    }
    
    return this;
  }
  
  /**
   * Update component state and trigger re-render
   * @param {Object} newState - State changes to apply
   * @private
   */
  _setState(newState) {
    const prevState = { ...this._state };
    this._state = { ...this._state, ...newState };
    
    // Only re-render if something changed
    if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
      this._render();
    }
  }
  
  /**
   * Build the component DOM structure
   * @private
   */
  _buildDOM() {
    // Create content element
    this.elements.content = DOMCleanup.createElement('div', {
      className: 'notification__content'
    }, this.options.message, this.cleanup);
    
    // Create close button
    this.elements.closeButton = DOMCleanup.createElement('button', {
      className: 'notification__close',
      type: 'button',
      'aria-label': 'Close notification'
    }, '×', this.cleanup);
    
    // Assemble component
    this.elements.root.appendChild(this.elements.content);
    this.elements.root.appendChild(this.elements.closeButton);
  }
  
  /**
   * Set up component event listeners
   * @private
   */
  _setupEventListeners() {
    // Add click handler for close button
    this.events.addEventListener(
      this.elements.closeButton,
      'click',
      this._handleCloseClick.bind(this)
    );
  }
  
  /**
   * Render component based on current state
   * @private
   */
  _render() {
    // Nothing to do in this simple component
    // In more complex components, we would update the DOM based on state
  }
  
  /**
   * Handle close button clicks
   * @param {Event} event - Click event
   * @private
   */
  _handleCloseClick(event) {
    event.preventDefault();
    this.hide();
  }
}

export default NotificationComponent;
```markdown

2. **Export the Component Class**

Ensure your component is properly exported for import by other modules.

3. **Use the Component in the Application**

```javascript
import NotificationComponent from './components/notification_component';

// Create a notification component
const notification = new NotificationComponent({
  container: document.querySelector('#notifications'),
  duration: 5000,
  type: 'success'
});

// Mount the component to make it ready for use
notification.mount();

// Show a notification message
notification.show('Operation completed successfully!');

// When the component is no longer needed
notification.destroy();
```markdown

### 2.2 Component Lifecycle

Components follow this lifecycle:

1. **Construction**: Initial object creation and option processing
2. **Mounting**: DOM creation, event setup, and initialization
3. **Active Life**: Responding to events and API calls
4. **Destruction**: Cleanup of resources and event listeners

### 2.3 Event Management

All event listeners should be managed through EventManager:

```javascript
// Register with event manager
this.events = EventManager.registerComponent(this.componentId);

// Add direct event listener
this.events.addEventListener(
  element,
  'click',
  this._handleClick.bind(this)
);

// Add delegated event listener
this.events.addDelegatedEventListener(
  this.elements.root,
  'click',
  '.button',
  this._handleButtonClick.bind(this)
);

// Unregister component (automatically removes all listeners)
EventManager.unregisterComponent(this.componentId);
```markdown

### 2.4 DOM Management

All DOM elements should be created and tracked through DOMCleanup:

```javascript
// Register with cleanup utility
this.cleanup = DOMCleanup.register(this.componentId);

// Create element with cleanup tracking
const element = DOMCleanup.createElement('div', {
  className: 'example',
  id: 'example-id'
}, 'Content text', this.cleanup);

// Register timeouts for cleanup
const timeoutId = setTimeout(() => {}, 1000);
this.cleanup.registerTimeout(timeoutId);

// Register intervals for cleanup
const intervalId = setInterval(() => {}, 1000);
this.cleanup.registerInterval(intervalId);

// Clean up all registered resources
this.cleanup.cleanup();
```markdown

## Module 3: Advanced Component Features

### 3.1 Component State Management

Components should manage their state using a predictable pattern:

```javascript
// Initialize state in constructor
this._state = {
  isVisible: false,
  isExpanded: false,
  selectedItems: []
};

// Update state and trigger render if needed
_setState(newState) {
  const prevState = { ...this._state };
  this._state = { ...this._state, ...newState };
  
  // Only re-render if something changed
  if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
    this._render();
  }
}

// Example usage
this._setState({ isExpanded: true, selectedItems: [1, 2, 3] });
```markdown

### 3.2 Component Communication

Components can communicate through:

1. **Direct Method Calls**: When a component has a reference to another component
2. **Custom Events**: For decoupled communication between components
3. **Shared State**: Through a common parent or state manager

Example of custom event communication:

```javascript
// Component A: Dispatch a custom event
const event = new CustomEvent('item-selected', {
  bubbles: true,
  detail: { itemId: 123 }
});
this.elements.root.dispatchEvent(event);

// Component B: Listen for custom events
this.events.addEventListener(
  document,
  'item-selected',
  this._handleItemSelected.bind(this)
);

_handleItemSelected(event) {
  const { itemId } = event.detail;
  console.log(`Item ${itemId} was selected`);
}
```markdown

### 3.3 Component Performance Optimization

Optimize component performance using these techniques:

1. **Throttle and Debounce**: Limit frequent events like resize or scroll
2. **Efficient DOM Updates**: Batch DOM manipulations
3. **Render Optimization**: Only render when state actually changes
4. **Event Delegation**: Use delegation for multiple similar elements

Example of debounced handler:

```javascript
_setupEventListeners() {
  // Resize handler with debounce
  const handleResize = this._debounce(this._handleResize.bind(this), 250);
  this.events.addEventListener(window, 'resize', handleResize);
}

// Debounce utility
_debounce(func, wait) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
    this.cleanup.registerTimeout(timeout);
  };
}
```markdown

## Module 4: Testing Components

### 4.1 Unit Testing

Test individual component functionality:

```javascript
describe('NotificationComponent', () => {
  let component;
  let container;

  beforeEach(() => {
    container = document.createElement('div');
    document.body.appendChild(container);
    component = new NotificationComponent({ container });
    component.mount();
  });

  afterEach(() => {
    component.destroy();
    document.body.removeChild(container);
  });

  test('should show notification with message', () => {
    const message = 'Test message';
    component.show(message);
    
    expect(container.querySelector('.notification')).not.toBeNull();
    expect(container.querySelector('.notification__content').textContent).toBe(message);
  });

  test('should hide notification when close button is clicked', () => {
    component.show('Test message');
    
    // Find and click close button
    container.querySelector('.notification__close').click();
    
    // Notification should be removed
    expect(container.querySelector('.notification')).toBeNull();
  });
});
```markdown

### 4.2 Memory Leak Testing

Test for memory leaks in components:

```javascript
test('should not leak memory on destroy', () => {
  // Create and track elements before creation
  let elementCount = document.querySelectorAll('*').length;
  
  // Create component
  const container = document.createElement('div');
  document.body.appendChild(container);
  const component = new NotificationComponent({ container });
  component.mount();
  component.show('Test message');
  
  // Destroy component
  component.destroy();
  document.body.removeChild(container);
  
  // Check that no elements remain
  const newElementCount = document.querySelectorAll('*').length;
  expect(newElementCount).toBe(elementCount);
});
```markdown

### 4.3 Performance Testing

Test component performance using performance measurement:

```javascript
test('should render efficiently', () => {
  const container = document.createElement('div');
  document.body.appendChild(container);
  
  // Measure instantiation time
  performance.mark('start-init');
  const component = new NotificationComponent({ container });
  performance.mark('end-init');
  
  // Measure mount time
  performance.mark('start-mount');
  component.mount();
  performance.mark('end-mount');
  
  // Measure show time
  performance.mark('start-show');
  component.show('Performance test message');
  performance.mark('end-show');
  
  // Calculate measurements
  const initMeasure = performance.measure('init', 'start-init', 'end-init');
  const mountMeasure = performance.measure('mount', 'start-mount', 'end-mount');
  const showMeasure = performance.measure('show', 'start-show', 'end-show');
  
  // Cleanup
  component.destroy();
  document.body.removeChild(container);
  
  // Assert performance expectations
  expect(initMeasure.duration).toBeLessThan(50);
  expect(mountMeasure.duration).toBeLessThan(100);
  expect(showMeasure.duration).toBeLessThan(50);
});
```markdown

## Module 5: Component Integration with LiveView

### 5.1 LiveView Hook Integration

To integrate components with Phoenix LiveView:

```javascript
// In your app.js or hooks.js file
import NotificationComponent from './components/notification_component';

// Define LiveView hooks
const Hooks = {
  Notification: {
    mounted() {
      // Create and store the component instance
      this.component = new NotificationComponent({
        container: this.el
      });
      this.component.mount();
      
      // Handle push events from the server
      this.handleEvent('show-notification', ({ message, type }) => {
        this.component.show(message, type);
      });
    },
    destroyed() {
      // Clean up the component when the element is removed
      if (this.component) {
        this.component.destroy();
        this.component = null;
      }
    }
  }
};

// Register hooks with LiveView
const liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
});
```markdown

### 5.2 LiveView DOM Updates

Components must be designed to handle LiveView DOM updates:

1. Use delegated events for dynamic content
2. Re-query elements after potential DOM updates
3. Consider using LiveView's phx-update attributes
4. Use morphdom-aware component design

### 5.3 Client-Server Communication

Components can communicate with the server through LiveView pushEvents:

```javascript
_handleButtonClick(event) {
  // Get data from the component
  const data = { id: this.options.id, value: this._state.value };
  
  // Push event to the server
  this.pushEvent('component-action', data);
}
```markdown

## Module 6: Best Practices

### 6.1 Resource Management

- Always use DOMCleanup to create and track DOM elements
- Register all timeouts and intervals with cleanup utility
- Clean up all resources in the destroy method
- Nullify references to DOM elements after destruction

### 6.2 Event Handling

- Always use EventManager for event listeners
- Use delegate events for dynamic elements
- Bind event handlers to preserve context
- Consider throttling or debouncing frequent events

### 6.3 Naming Conventions

- Component filenames: `snake_case.js`
- Component class names: `PascalCase`
- Private methods: `_camelCase` (with underscore prefix)
- Public methods: `camelCase`
- Event handler methods: `_handleEventName`

### 6.4 Code Organization

- Group related methods together
- Private methods after public methods
- Event handlers at the end of the file
- Consistent code formatting

## Practical Exercises

### Exercise 1: Create a Basic Component

Create a simple Toggle component that:

- Displays a toggle button
- Maintains an on/off state
- Changes appearance based on state
- Dispatches events when toggled

### Exercise 2: Refactor an Existing Component

Take an existing non-standard component and refactor it to:

- Use the standard component pattern
- Implement proper resource management
- Add event handling through EventManager
- Use state management correctly

### Exercise 3: Create a Complex Component

Create a complex component (like a tabbed interface or accordion) that:

- Manages multiple child elements
- Handles dynamic content
- Uses delegated events
- Implements a rich API

### Exercise 4: Component Integration

Integrate a component with LiveView:

- Create a LiveView hook
- Handle server-push events
- Push events to the server
- Maintain component state during LiveView updates

## Additional Resources

- [Component Implementation Patterns](../../development/components/patterns.md)
- [Event Management Guide](../DEVELOPMENT/development/components/event-management.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->
- [Resource Cleanup Documentation](../DEVELOPMENT/development/components/resource-cleanup.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->
- [Testing Guide](TESTING_GUIDE.md)
- [Performance Optimization Techniques](../DEVELOPMENT/reference/optimization/performance.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->


## References

- [Project Documentation](../README.md)
