---
title: ⚠️ DOCUMENTATION MOVED ⚠️
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - features
  - '-documentation-moved-'
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - new-location
  - automatic-redirect
  - reactive-state-system
  - introduction
  - key-features
  - basic-usage
  - advanced-features
  - integration-with-components
  - performance-optimization
  - integration-with-event-bus
  - debugging-tools
  - best-practices
  - conclusion
  - references
  - code-examples
  - architecture
  - development
last_updated: '2025-03-14'
---
# ⚠️ DOCUMENTATION MOVED ⚠️

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

# ⚠️ DOCUMENTATION MOVED ⚠️


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about REACTIVE STATE SYSTEM.


This document has been migrated to a new location as part of our documentation restructuring.

## New Location

**Please visit the new document location**: [reference/architecture/reactive-state.md](../../reference/architecture/reactive-state.md)

## Automatic Redirect

You will be automatically redirected to the new location in 5 seconds.

<meta http-equiv="refresh" content="5;url=../../reference/architecture/reactive-state.md" />

---

# Reactive State System

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
    email: 'john@example.com'
  },
  items: ['Item 1', 'Item 2']
});

// Connect the state to update a component
stateManager.connect(component);
```markdown

### Updating State

```javascript
// Update simple values
state.count = 1;

// Update nested objects
state.user.name = 'Jane';

// Update arrays
state.items.push('Item 3');
state.items = [...state.items, 'Item 4'];

// Batch updates
stateManager.batch(() => {
  state.count++;
  state.user.name = 'Alice';
  state.items.push('Item 5');
});
```markdown

### Observing State Changes

```javascript
// Watch specific properties
stateManager.watch('count', (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`);
});

// Watch nested properties
stateManager.watch('user.name', (newValue, oldValue) => {
  console.log(`Name changed from ${oldValue} to ${newValue}`);
});

// Watch any property change
stateManager.watchAny((path, newValue, oldValue) => {
  console.log(`Property at '${path}' changed from`, oldValue, 'to', newValue);
});
```markdown

## Advanced Features

### Computed Properties

```javascript
// Define computed properties that depend on state
const computedState = stateManager.defineComputed({
  // Compute total from items array
  totalItems: () => state.items.length,
  
  // Compute full name from first and last name
  fullName: () => `${state.user.firstName} ${state.user.lastName}`,
  
  // Compute status based on multiple values
  status: () => {
    if (state.isLoggedIn && state.hasPermission) {
      return 'Authorized';
    } else if (state.isLoggedIn) {
      return 'Unauthorized';
    } else {
      return 'Unauthenticated';
    }
  }
});

// Computed properties are accessed like normal properties
console.log(computedState.totalItems); // Number of items
```markdown

### State History and Time Travel

```javascript
// Enable history tracking
stateManager.enableHistory({
  maxEntries: 50, // Store up to 50 history entries
  include: ['count', 'user'], // Only track specific properties
  exclude: ['temporaryData'] // Exclude specific properties
});

// Get the history
const history = stateManager.getHistory();

// Travel back in time by restoring a previous state
stateManager.restoreState(history[3]);

// Undo last change
stateManager.undo();

// Redo an undone change
stateManager.redo();
```markdown

### Persistent State

```javascript
// Enable persistence to localStorage
stateManager.enablePersistence({
  key: 'my-app-state',
  storage: localStorage,
  include: ['user', 'settings'], // Only persist specific properties
  exclude: ['temporaryData'], // Exclude specific properties
  debounce: 300 // Debounce persistence (ms)
});

// Manual control over persistence
stateManager.saveState(); // Force an immediate save
stateManager.loadState(); // Force an immediate load
```markdown

## Integration with Components

### Basic Component Integration

```javascript
import { Component } from 'assets/js/components/core';
import { StateManager } from 'assets/js/components/core';

class Counter extends Component {
  constructor(options) {
    super(options);
    
    // Create state manager
    this.stateManager = new StateManager();
    
    // Define state
    this.state = this.stateManager.defineState({
      count: 0
    });
    
    // Connect state to this component
    this.stateManager.connect(this);
    
    // Define computed properties
    this.computed = this.stateManager.defineComputed({
      doubleCount: () => this.state.count * 2,
      isEven: () => this.state.count % 2 === 0
    });
  }
  
  increment() {
    this.state.count++;
  }
  
  decrement() {
    this.state.count--;
  }
  
  render() {
    return `
      <div class="counter">
        <button class="decrement" data-on-click="decrement">-</button>
        <span class="count ${this.computed.isEven ? 'even' : 'odd'}">
          ${this.state.count}
        </span>
        <span class="double-count">
          Double: ${this.computed.doubleCount}
        </span>
        <button class="increment" data-on-click="increment">+</button>
      </div>
    `;
  }
}
```markdown

### Class-based Component with Decorator Syntax

```javascript
import { Component, reactive, computed } from 'assets/js/components/core';

class UserProfile extends Component {
  // Define reactive state
  @reactive state = {
    user: {
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com'
    },
    isEditing: false
  };
  
  // Define computed properties
  @computed get fullName() {
    return `${this.state.user.firstName} ${this.state.user.lastName}`;
  }
  
  @computed get displayMode() {
    return this.state.isEditing ? 'edit' : 'view';
  }
  
  toggleEdit() {
    this.state.isEditing = !this.state.isEditing;
  }
  
  updateUser(formData) {
    // Batch update all user properties
    this.batchUpdate(() => {
      this.state.user.firstName = formData.firstName;
      this.state.user.lastName = formData.lastName;
      this.state.user.email = formData.email;
      this.state.isEditing = false;
    });
  }
  
  render() {
    if (this.state.isEditing) {
      return this.renderEditForm();
    } else {
      return this.renderProfile();
    }
  }
  
  renderProfile() {
    // Render view mode
  }
  
  renderEditForm() {
    // Render edit form
  }
}
```markdown

## Performance Optimization

### Selective Updates

The Reactive State System only updates components when state they depend on changes:

```javascript
// Define multiple components
const header = new HeaderComponent();
const sidebar = new SidebarComponent();
const content = new ContentComponent();

// Connect them all to the same state manager
stateManager.connect(header);
stateManager.connect(sidebar);
stateManager.connect(content);

// Update state
state.currentPage = 'dashboard';
// Only components that use currentPage will update

state.user.profileImage = 'new-image.jpg';
// Only components that use user.profileImage will update
```markdown

### Update Batching

Batch state changes to prevent unnecessary re-renders:

```javascript
// Without batching, this would trigger 3 updates
stateManager.batch(() => {
  state.loading = true;
  state.items = [];
  state.error = null;
  
  // Fetch data...
  
  state.items = fetchedItems;
  state.loading = false;
});
// Only 1 update is triggered at the end of the batch
```markdown

### Optimizing Arrays

Reactive arrays need special handling for optimal performance:

```javascript
// Instead of direct mutation (causes full re-render):
// state.items.push(newItem);

// Better approach (targeted updates):
state.items = [...state.items, newItem];

// For large arrays, use immutable helpers:
import { updateArray } from 'assets/js/utils';

// Update a specific item
state.items = updateArray(state.items, 3, { ...state.items[3], status: 'completed' });

// Filter without re-creating the entire array
state.visibleItems = state.items.filter(item => item.isVisible);
```markdown

## Integration with Event Bus

The Reactive State System integrates seamlessly with the Event Bus:

```javascript
import { EventBus } from 'assets/js/components/core';

// Publish events when state changes
stateManager.watch('user', (newValue, oldValue) => {
  EventBus.publish('user:updated', { 
    user: newValue,
    previousUser: oldValue
  });
});

// Update state based on events
EventBus.subscribe('auth:login', (event) => {
  state.user = event.data.user;
  state.isLoggedIn = true;
});

EventBus.subscribe('auth:logout', () => {
  state.user = null;
  state.isLoggedIn = false;
});
```markdown

## Debugging Tools

The Reactive State System includes tools for debugging state:

```javascript
// Log all state changes
stateManager.watchAny((path, newValue, oldValue) => {
  console.log(`[State] ${path} changed:`, oldValue, '→', newValue);
});

// Get current state snapshot
const snapshot = stateManager.getState();
console.log('Current state:', snapshot);

// Track performance
stateManager.enablePerformanceTracking();
const stats = stateManager.getPerformanceStats();
console.log('Performance stats:', stats);
```markdown

## Best Practices

### 1. Keep State Normalized

Avoid deeply nested state structures:

```javascript
// Instead of:
state.currentUser.posts[0].comments[3].author.name = 'New Name';

// Better structure:
state.users = {
  'user-1': { id: 'user-1', name: 'User 1' },
  'user-2': { id: 'user-2', name: 'New Name' }
};
state.posts = {
  'post-1': { id: 'post-1', userId: 'user-1', title: 'Post 1' }
};
state.comments = {
  'comment-1': { id: 'comment-1', postId: 'post-1', userId: 'user-2', text: 'Comment 1' }
};
```markdown

### 2. Use Computed Properties for Derived Data

Don't store what you can compute:

```javascript
// Instead of:
state.totalPrice = state.items.reduce((sum, item) => sum + item.price, 0);
state.items.push(newItem);
state.totalPrice = state.items.reduce((sum, item) => sum + item.price, 0); // Duplicated logic

// Better approach:
computed.totalPrice = () => state.items.reduce((sum, item) => sum + item.price, 0);
state.items.push(newItem); // totalPrice updates automatically
```markdown

### 3. Use Selectors for Component-Specific Views

```javascript
// Define selectors in your component
const selectors = {
  activeItems: () => state.items.filter(item => item.active),
  itemsByCategory: (category) => state.items.filter(item => item.category === category),
  sortedItems: () => [...state.items].sort((a, b) => a.name.localeCompare(b.name))
};

// Use in rendering
render() {
  const activeItems = selectors.activeItems();
  // ...
}
```markdown

### 4. Optimize Updates for Large Lists

```javascript
// For large lists, consider using keyed items
render() {
  return `
    <ul>
      ${this.state.items.map(item => `
        <li data-key="${item.id}">
          ${item.name}
        </li>
      `).join('')}
    </ul>
  `;
}
```markdown

## Conclusion

The Reactive State System provides a simple yet powerful way to manage component state in Hydepwns applications. By combining automatic reactivity with performance optimizations, it enables developers to create responsive, maintainable user interfaces with minimal boilerplate code. 

## References

- [Project Documentation](../README.md)
