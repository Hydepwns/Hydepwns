---
title: Reactive State System
description: '## Overview'
topics:
  - reference
  - architecture
  - reactive-state-system
  - overview
  - prerequisites
  - main-content
  - examples
  - related-documents
  - introduction
  - key-features
  - basic-usage
  - advanced-patterns
  - best-practices
  - performance-considerations
  - browser-support
  - integration-with-component-inspector
  - troubleshooting
  - related-documentation
  - references
  - code-examples
  - development
last_updated: '2025-03-14'
---
# Reactive State System

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Related Documents

* No references yet

This document provides information about Reactive-State.


## Introduction

The Reactive State System is a lightweight, powerful solution for managing component state with automatic UI updates. It's designed to simplify state management while maintaining excellent performance by tracking state changes and only updating the UI when necessary.

## Key Features

- **Automatic Reactivity**: Changes to state automatically trigger UI updates
- **Nested Reactivity**: Deep reactivity for complex state objects
- **Computed Properties**: Derived state that updates automatically
- **State History**: Optional tracking of state changes for debugging
- **Batched Updates**: Group multiple state changes into a single update
- **Dependency Tracking**: Only recompute values when dependencies change

## Basic Usage

### Creating Reactive State

```javascript
import { StateManager } from 'assets/js/components/core';

// Create a state manager instance
const stateManager = new StateManager();

// Initialize state
const state = stateManager.defineState({
  count: 0,
  user: {
    name: 'John',
    loggedIn: false
  }
});

// State is now reactive - access and modify it normally
console.log(state.count); // 0
state.count = 1; // This will trigger updates
state.user.name = 'Jane'; // Nested properties also trigger updates
```markdown

### Adding Computed Properties

```javascript
// Define a computed property
stateManager.compute('doubleCount', ['count'], (state) => {
  return state.count * 2;
});

console.log(state.doubleCount); // 2 (based on count === 1)

// Update the dependency
state.count = 5;
console.log(state.doubleCount); // 10 (automatically updated)
```markdown

### Watching for Changes

```javascript
// Watch for changes to a specific property
stateManager.watch('user.loggedIn', (newValue, oldValue) => {
  console.log(`Login status changed: ${oldValue} -> ${newValue}`);
});

// This will trigger the watcher
state.user.loggedIn = true;
```markdown

### Batching Updates

```javascript
// Multiple changes will only trigger one update
stateManager.batch(() => {
  state.count = 10;
  state.user.name = 'Alice';
  state.user.loggedIn = false;
});
```markdown

## Advanced Patterns

### Integration with DOM

```javascript
import { StateManager } from 'assets/js/components/core';

class CounterComponent {
  constructor(element) {
    this.element = element;
    
    // Create state manager with update callback
    this.stateManager = new StateManager({
      updateCallback: () => this.render()
    });
    
    // Define state
    this.state = this.stateManager.defineState({
      count: 0
    });
    
    // Add computed properties
    this.stateManager.compute('isEven', ['count'], (state) => {
      return state.count % 2 === 0;
    });
    
    // Set up DOM events
    this.element.querySelector('.increment').addEventListener('click', () => {
      this.state.count++;
    });
    
    // Initial render
    this.render();
  }
  
  render() {
    this.element.querySelector('.count').textContent = this.state.count;
    this.element.querySelector('.even-odd').textContent = 
      this.state.isEven ? 'even' : 'odd';
  }
}
```markdown

### Complex Computed Properties

```javascript
// Computed property with multiple dependencies
stateManager.compute('fullName', ['user.firstName', 'user.lastName'], (state) => {
  return `${state.user.firstName} ${state.user.lastName}`;
});

// Computed property that depends on another computed property
stateManager.compute('greeting', ['fullName'], (state) => {
  return `Hello, ${state.fullName}!`;
});
```markdown

### State History for Time Travel

```javascript
// Create state manager with history enabled
const stateManager = new StateManager({
  historyEnabled: true,
  historyLimit: 50 // Store up to 50 changes
});

// View history
const history = stateManager.getHistory();

// Time travel
stateManager.revertToState(5); // Go back to the 5th state
```markdown

## Best Practices

1. **Keep State Minimal**: Only include values that affect the UI or application behavior
2. **Use Computed Properties**: For derived values rather than storing redundant state
3. **Batch Complex Updates**: Use `batch()` for multiple related changes
4. **Structure State Logically**: Organize state by purpose or component
5. **Avoid Circular Dependencies**: In computed properties

## Performance Considerations

- The reactive system adds a small overhead to property access/updates
- For large collections, consider manual updates rather than making the entire collection reactive
- Use `batch()` for multiple updates to prevent unnecessary re-renders
- Computed properties with expensive calculations should be used carefully

## Browser Support

The reactive state system uses JavaScript Proxies, which are supported in:
- Chrome 49+
- Firefox 18+
- Safari 10+
- Edge 12+

## Integration with Component Inspector

The reactive state system integrates seamlessly with the Component Inspector:

```javascript
// Enable history for debugging
const stateManager = new StateManager({
  historyEnabled: true
});

// Create component with state
const component = new HydeComponent({
  stateManager,
  name: 'MyComponent'
});

// The component inspector will now show the state and state history
```markdown

## Troubleshooting

### Changes Not Triggering Updates

- Ensure the object is made reactive via `defineState()`
- Check that the property is being set with an assignment operator (`=`)
- Verify that the state is connected to a component or has an update callback

### Performance Issues

- Too many computed properties may cause performance issues
- Large reactive objects can slow down the application
- Check for circular dependencies in computed properties

### Memory Leaks

- Remember to unsubscribe watchers when they're no longer needed
- Clear state history for long-running applications

## Related Documentation

- [Component Guidelines](../../development/components/guidelines.md)
- [Robust Implementation](../../development/components/robust-implementation.md)
- [Event Bus Architecture](event-bus.md)
- [Component Inspector](../../development/tools/component-inspector.md) 

## References

- [Project Documentation](../README.md)
