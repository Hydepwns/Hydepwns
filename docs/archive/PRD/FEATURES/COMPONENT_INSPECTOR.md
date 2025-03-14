---
title: ⚠️ DOCUMENTATION MOVED ⚠️
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - features
  - '-documentation-moved-'
  - prerequisites
  - main-content
  - examples
  - related-documents
  - overview
  - new-location
  - automatic-redirect
  - component-inspector
  - introduction
  - key-features
  - getting-started
  - usage
  - advanced-features
  - integration-with-event-bus
  - best-practices
  - troubleshooting
  - conclusion
  - references
  - code-examples
  - testing
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


## Related Documents

* No references yet

# ⚠️ DOCUMENTATION MOVED ⚠️


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about COMPONENT INSPECTOR.


This document has been migrated to a new location as part of our documentation restructuring.

## New Location

**Please visit the new document location**: [development/tools/component-inspector.md](../../development/tools/component-inspector.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->

## Automatic Redirect

You will be automatically redirected to the new location in 5 seconds.

<meta http-equiv="refresh" content="5;url=../../development/tools/component-inspector.md" />

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

The Component Inspector integrates with the Event Bus to provide comprehensive debugging capabilities:

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

Performance monitoring adds overhead. Enable it selectively for components you're actively debugging:

```javascript
// Enable only for specific components
inspector.enablePerformanceMonitoring(['UserProfile', 'Dashboard']);

// Or for specific component instances
inspector.enablePerformanceMonitoring([component1, component2]);
```markdown

### 3. Clean Up After Testing

After debugging, properly dispose of the inspector to avoid memory leaks:

```javascript
// Remove the inspector when done
inspector.detach();

// Or just hide it temporarily
inspector.hide();
```markdown

## Troubleshooting

### Common Issues

1. **Inspector Not Showing**: Check that you're in development mode and the inspector is properly attached to the DOM.

2. **Component Not in Tree**: Ensure the component is properly mounted and is a proper HydeComponent instance.

3. **Cannot Modify State**: Some components may implement state protection. Check if the component uses immutable state patterns.

4. **Performance Impact**: The inspector itself affects performance. For accurate measurements, use lighter monitoring or disable the inspector when not needed.

## Conclusion

The Component Inspector is an essential tool for developing and debugging Hydepwns applications. By providing visibility into component structure, state, and interactions, it helps you identify and fix issues more efficiently. 

## References

- [Project Documentation](../README.md)
