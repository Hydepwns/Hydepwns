---
title: Component-Inspector
description: '## Overview'
topics:
  - development
  - tools
  - component-inspector
  - overview
  - prerequisites
  - main-content
  - examples
  - related-documents
  - introduction
  - key-features
  - getting-started
  - usage
  - advanced-features
  - integration-with-event-bus
  - best-practices
  - compatibility
  - troubleshooting
  - related-documentation
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Component-Inspector

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Related Documents

* No references yet

This document provides information about Component-Inspector.


---
title: Component Inspector
description: Debugging and visualization tool for component-based applications
category: development
subcategory: tools
order: 3
last_updated: 2024-04-20
contributors:
  - documentation_team
status: active
priority: medium
tags:
  - debugging
  - components
  - development
  - tools
---

# Component Inspector

## Introduction

The Component Inspector is a powerful debugging tool that helps you visualize, monitor, and troubleshoot your component-based application. It provides real-time insights into component hierarchies, state changes, event flows, and performance metrics.

## Key Features

- **Component Tree Visualization**: See your component hierarchy in a tree view
- **State Inspection**: Examine component state and props in real-time
- **Performance Monitoring**: Track render times and identify slow components
- **Event Flow Tracking**: Monitor events passing between components
- **Interactive Debugging**: Modify state and trigger updates for testing

## Getting Started

### Enabling the Inspector

The Component Inspector is available in development mode only and can be enabled through several methods:

```javascript
import { Inspector } from 'assets/js/components/core';

// Method 1: Create and configure the inspector directly
const inspector = new Inspector.UI({
  position: 'bottom-right', // 'top-left', 'top-right', 'bottom-left', 'bottom-right'
  theme: 'dark',           // 'light' or 'dark'
  width: '400px',
  height: '500px'
});

// Method 2: Enable via global configuration
import { HydeConfig } from 'assets/js/components/core';

HydeConfig.set('inspector', {
  enabled: true,
  position: 'bottom-right',
  theme: 'dark'
});

// Method 3: Enable in development through URL parameter
// Add '?inspector=true' to your application URL
```markdown

### Restricting to Development Mode

To ensure the inspector is only available in development environments:

```javascript
import { Environment } from 'assets/js/utils';

if (Environment.isDevelopment()) {
  const inspector = new Inspector.UI();
  inspector.attach();
}
```markdown

## Usage

### Component Tree Navigation

The Component Inspector displays your component hierarchy as a navigable tree. Each component is displayed with:

- Component name and type
- Component ID
- Instance state (mounted, unmounted, errored)
- Child components count

Clicking on a component in the tree selects it and shows its details in the inspection panel.

### State and Props Inspection

The inspection panel shows the selected component's:

- State: All state variables with their current values
- Props: All props passed to the component
- DOM: Element properties and attributes
- Events: Event listeners attached to the component

```javascript
// The inspector automatically detects and displays:
class UserProfile extends HydeComponent {
  constructor(options) {
    super(options);
    
    // This state will be visible in the Inspector
    this.state = {
      user: {
        name: 'John Doe',
        email: 'john@example.com'
      },
      isEditing: false
    };
  }
}
```markdown

### Modifying State

You can modify component state directly through the Inspector:

1. Select the component in the tree view
2. Find the state variable in the State tab
3. Click the Edit button next to the value
4. Enter the new value and press Enter

This triggers the standard component update cycle, allowing you to test state changes without modifying code.

### Performance Monitoring

The Performance tab shows performance metrics for the selected component:

- Render time (average, min, max)
- Update frequency
- DOM operations count
- Memory usage

You can also record a performance trace to identify bottlenecks in your component's lifecycle:

1. Select the component in the tree view
2. Click "Start Recording" in the Performance tab
3. Perform the actions you want to analyze
4. Click "Stop Recording"
5. Review the performance timeline

### Event Flow Monitoring

The Events tab shows all events passing through the selected component:

- Events published by the component
- Events the component has subscribed to
- Events received from other components

This helps debug communication issues between components.

## Advanced Features

### Component Filtering

You can filter the component tree to focus on specific components:

```javascript
// Show only components that match certain criteria
inspector.filter({
  type: 'Button',                // Filter by component type
  hasState: true,                // Only show components with state
  hasProps: ['onClick', 'label'] // Components with specific props
});

// Clear filters
inspector.clearFilters();
```markdown

### Remote Inspection

For testing on mobile devices or remote browsers, you can enable remote inspection:

```javascript
// On the device/browser to inspect
import { RemoteInspector } from 'assets/js/components/core';

RemoteInspector.connect({
  server: 'https://inspector.example.com',
  sessionId: 'unique-session-id',
  componentSelector: '#app-root'
});

// On the inspector interface
import { RemoteInspector } from 'assets/js/components/core';

RemoteInspector.listen({
  server: 'https://inspector.example.com',
  sessionId: 'unique-session-id'
});
```markdown

### Snapshot and Restore

You can capture the state of your component tree and restore it later:

```javascript
// Capture current state
const snapshot = inspector.captureSnapshot();

// Save snapshot (e.g., to localStorage)
localStorage.setItem('debug-snapshot', JSON.stringify(snapshot));

// Later, restore the snapshot
const savedSnapshot = JSON.parse(localStorage.getItem('debug-snapshot'));
inspector.restoreSnapshot(savedSnapshot);
```markdown

### Console Integration

The Inspector integrates with the browser console for advanced debugging:

```javascript
// Access the selected component in the console
console.inspect(selectedComponent);

// Log all component events
console.logEvents(selectedComponent);

// Profile component performance
console.profileComponent(selectedComponent);
```markdown

## Integration with Event Bus

The Component Inspector integrates with the [Event Bus](../../reference/architecture/event-bus.md) to provide comprehensive debugging capabilities:

```javascript
// Enable event tracking in the inspector
inspector.setEventTracking({
  enabled: true,
  filter: {
    include: ['user:*', 'data:*'],  // Use glob patterns
    exclude: ['heartbeat:*']
  }
});

// View event flow between components
inspector.showEventFlow('componentA', 'componentB');
```markdown

## Best Practices

### 1. Use Inspector-friendly Component Design

Design your components to be inspector-friendly:

- Use descriptive component names
- Structure state clearly
- Add debug information when appropriate

```javascript
class UserProfile extends HydeComponent {
  static debugInfo = {
    description: 'Displays and manages user profile information',
    stateDescription: {
      user: 'User data object with profile information',
      isEditing: 'Whether the profile is in edit mode'
    }
  };
  
  // Component implementation...
}
```markdown

### 2. Enable Performance Monitoring Selectively

Performance monitoring adds some overhead. Enable it selectively:

```javascript
// Only monitor specific components
inspector.enablePerformanceMonitoring({
  components: ['UserProfile', 'Dashboard'],
  includeChildren: false
});
```markdown

### 3. Use Component Annotations

Add annotations to your components to improve inspector visibility:

```javascript
@inspectable({
  name: 'UserProfile',
  description: 'User profile management component',
  category: 'User Components'
})
class UserProfile extends HydeComponent {
  // Component implementation...
}
```markdown

## Compatibility

The Component Inspector is compatible with all modern browsers:

- Chrome 50+
- Firefox
- Safari 10+
- Edge

## Troubleshooting

### Inspector Not Showing

- Ensure you're in development mode
- Check the console for errors
- Verify that the inspector is properly initialized
- Confirm that your components inherit from HydeComponent

### Performance Issues

- Reduce the number of monitored components
- Disable event tracking for high-frequency events
- Limit the history size for events and state changes

## Related Documentation

- [Event Bus](../../reference/architecture/event-bus.md)
- [Reactive State System](../../reference/architecture/reactive-state.md)
- [Component Architecture](/docs/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/component-architecture.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->
- [Performance Optimization](performance-optimization.md) 

## References

- [Project Documentation](../README.md)
