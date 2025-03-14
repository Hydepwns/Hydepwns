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
  - troubleshooting
  - related-documents
  - overview
  - new-location
  - automatic-redirect
  - event-bus-system
  - table-of-contents
  - introduction
  - basic-concepts
  - usage-patterns
  - api-reference
  - best-practices
  - examples
  - integration-with-reactive-state-system
  - debugging-tools
  - references
  - code-examples
  - architecture
last_updated: '2025-03-14'
---
# ⚠️ DOCUMENTATION MOVED ⚠️

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# ⚠️ DOCUMENTATION MOVED ⚠️


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about EVENT BUS.


This document has been migrated to a new location as part of our documentation restructuring.

## New Location

**Please visit the new document location**: [reference/architecture/event-bus.md](../../reference/architecture/event-bus.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->

## Automatic Redirect

You will be automatically redirected to the new location in 5 seconds.

<meta http-equiv="refresh" content="5;url=../../reference/architecture/event-bus.md" />

---

# Event Bus System

The Event Bus is a central part of the Hydepwns Component System that enables communication between components without creating tight coupling. This document explains how to use the Event Bus effectively in your applications.

## Table of Contents

1. [Introduction](#introduction)
2. [Basic Concepts](#basic-concepts)
3. [Usage Patterns](#usage-patterns)
4. [API Reference](#api-reference)
5. [Best Practices](#best-practices)
6. [Examples](#examples)
7. [Integration with Reactive State System](#integration-with-reactive-state-system)
8. [Debugging Tools](#debugging-tools)

## Introduction

The Event Bus provides a publish/subscribe (pub/sub) pattern implementation that allows components to communicate with each other in a decoupled way. Components can publish events to the Event Bus, and other components can subscribe to those events to be notified when they occur.

Key features of the Event Bus include:

- **Global Events**: Broadcast events to all interested subscribers
- **Scoped Events**: Publish events within a specific context or scope
- **Direct Messaging**: Send messages directly to specific components
- **Automatic Cleanup**: Subscription management tied to component lifecycle
- **Debugging Support**: Event history and statistics for troubleshooting

## Basic Concepts

### Events

An event in the Event Bus system is a named message with associated data. Events have the following characteristics:

- **Name**: A string identifier for the event (e.g., `'user:login'`, `'data:updated'`)
- **Data**: Any JavaScript value that should be passed with the event
- **Source**: (Optional) The ID of the component that published the event

### Subscribers

Subscribers are components that register interest in specific events. When an event is published, all subscribers for that event are notified and receive the event data.

### Scopes

Scopes are named contexts that allow events to be published only to subscribers who are interested in events within that specific scope. This prevents event naming collisions and provides a way to organize event communication.

## Usage Patterns

The Event Bus supports several communication patterns:

### 1. Broadcast (One-to-Many)

A component publishes an event globally, and multiple components can receive it.

```javascript
// Publisher
component.publish('notification:new', { message: 'Hello World' });

// Subscribers
component1.subscribe('notification:new', handleNotification);
component2.subscribe('notification:new', handleNotification);
```markdown

### 2. Scoped Communication

Components communicate within a specific scope, isolated from other components.

```javascript
// Components in the 'sidebar' scope
sidebarToggle.publishInScope('sidebar', 'toggle', { isOpen: true });
sidebarPanel.subscribeInScope('sidebar', 'toggle', handleToggle);
```markdown

### 3. Direct Messaging (One-to-One)

A component sends a message directly to another specific component.

```javascript
// Sender
component.sendTo('receiver-component-id', 'private:message', { data: 'Secret' });

// Receiver
class ReceiverComponent extends HydeComponent {
  onMessage(message) {
    if (message.name === 'private:message') {
      // Handle message
    }
  }
}
```markdown

## API Reference

### Event Bus API

The Event Bus provides the following methods:

#### Global Events

- `subscribe(eventName, handler, options)`: Subscribe to a global event
- `publish(eventName, data, options)`: Publish a global event

#### Scoped Events

- `subscribeScoped(scope, eventName, handler, options)`: Subscribe to an event in a scope
- `publishScoped(scope, eventName, data, options)`: Publish an event in a scope

#### Direct Messaging

- `sendToComponent(targetComponentId, eventName, data, options)`: Send a message to a specific component

#### Subscription Management

- `unsubscribe(subscriptionId)`: Unsubscribe from an event
- `unsubscribeComponent(componentId)`: Unsubscribe all events for a component

#### Debugging

- `getStats()`: Get statistics about event bus usage
- `getHistory(limit)`: Get recent event history
- `setDebug(enable)`: Enable or disable debug mode
- `setHistoryLimit(limit)`: Set history limit for event tracking

### HydeComponent Integration

The `HydeComponent` base class provides wrapper methods to interact with the Event Bus:

```javascript
// Global events
component.publish(eventName, data);
component.subscribe(eventName, handler);

// Scoped events
component.publishInScope(scope, eventName, data);
component.subscribeInScope(scope, eventName, handler);

// Direct messaging
component.sendTo(componentId, eventName, data);

// Message reception
component.onMessage(message); // Override to handle direct messages
```markdown

## Best Practices

### 1. Event Naming Conventions

Use namespaced event names to prevent collisions:

- `component:event` - Component-specific events (e.g., `modal:open`, `dropdown:select`)
- `domain:event` - Domain-specific events (e.g., `user:login`, `cart:updated`)
- `ui:event` - UI-related events (e.g., `ui:theme-changed`, `ui:resize`)

### 2. Component Cleanup

Always clean up subscriptions when components are unmounted to prevent memory leaks:

```javascript
unmount() {
  // The HydeComponent base class handles this automatically
  super.unmount();
}
```markdown

### 3. Use Scoped Events

Prefer scoped events over global ones when communication only needs to happen within a specific context:

```javascript
// Better than using global events for sidebar components
this.subscribeInScope('sidebar', 'toggle', this.handleToggle.bind(this));
```markdown

### 4. Handle Event Errors

Always implement error handling in your event subscribers to prevent one failing subscriber from affecting others:

```javascript
subscribe('data:updated', event => {
  try {
    // Handle event
  } catch (error) {
    console.error('Error handling data:updated event', error);
  }
});
```markdown

### 5. Use Direct Messaging Sparingly

Direct messaging creates tighter coupling between components. Use it only when necessary, such as for private communications between closely related components.

## Examples

### Example 1: Notification System

```javascript
// Notification Publisher
class NotificationPublisher extends HydeComponent {
  sendNotification(message, type = 'info') {
    this.publish('notification:new', {
      message,
      type,
      timestamp: Date.now()
    });
  }
}

// Notification Display
class NotificationDisplay extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Subscribe to notification events
    this.subscribe('notification:new', this.handleNotification.bind(this));
  }
  
  handleNotification(event) {
    const { data } = event;
    this.displayNotification(data.message, data.type);
  }
  
  displayNotification(message, type) {
    // Display logic here
  }
}
```markdown

### Example 2: Theme Change System

```javascript
// Theme Toggle with context
@withContext('theme')
class ThemeToggle extends HydeComponent {
  toggleTheme() {
    const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
    this.currentTheme = newTheme;
    
    // Publish to theme scope
    this.publishInScope('theme', 'theme:changed', { theme: newTheme });
  }
}

// Theme Consumer with same context
@withContext('theme')
class ThemeConsumer extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Subscribe to theme changes in scope
    this.subscribeInScope('theme', 'theme:changed', this.applyTheme.bind(this));
  }
  
  applyTheme(event) {
    const { theme } = event.data;
    this.element.classList.toggle('dark-theme', theme === 'dark');
    this.element.classList.toggle('light-theme', theme === 'light');
  }
}
```markdown

## Integration with Reactive State System

The Event Bus works seamlessly with the Reactive State System to provide a complete state management solution:

### Publishing State Changes as Events

```javascript
class UserProfileComponent extends HydeComponent {
  constructor(options) {
    super(options);
    this.state = createReactiveState({
      user: { name: '', email: '' }
    });
    
    // Add event publishing to reactive state
    this.state.on('change:user', (newValue, oldValue) => {
      this.publish('user:updated', { 
        newValue,
        oldValue,
        changes: getChanges(newValue, oldValue)
      });
    });
  }
}
```markdown

### Subscribing to Events to Update State

```javascript
class UserDashboard extends HydeComponent {
  constructor(options) {
    super(options);
    this.state = createReactiveState({
      activeUser: null,
      notifications: []
    });
    
    // Update state based on events
    this.subscribe('user:updated', event => {
      this.state.activeUser = event.data.newValue;
    });
    
    this.subscribe('notification:new', event => {
      this.state.notifications = [
        ...this.state.notifications,
        event.data
      ];
    });
  }
}
```markdown

## Debugging Tools

The Event Bus comes with built-in debugging tools to help troubleshoot event-related issues:

### Event Monitor

The Event Monitor is a UI tool that displays all events flowing through the system in real-time:

```javascript
import { EventMonitor } from 'assets/js/components/debug';

// Create and attach the event monitor to the DOM
const monitor = new EventMonitor({
  position: 'bottom-right',
  filters: {
    eventTypes: ['user:*', 'notification:*'], // Use glob patterns
    exclude: ['heartbeat:*']
  }
});

monitor.attach(document.body);
```markdown

### Event Logging

Enable event logging to the console for debugging:

```javascript
import { EventBus } from 'assets/js/components/core';

// Enable debug mode
EventBus.setDebug(true);

// Configure logging options
EventBus.configureLogging({
  logLevel: 'info', // 'debug', 'info', 'warn', 'error'
  includeStack: true, // Include stack trace for event origins
  prettyPrint: true, // Format event data for readability
});
```markdown

### Event History

Access event history programmatically for debugging:

```javascript
// Get the last 100 events
const recentEvents = EventBus.getHistory(100);

// Filter events by name
const userEvents = recentEvents.filter(event => 
  event.name.startsWith('user:')
);

// Analyze event frequency
const eventCounts = recentEvents.reduce((counts, event) => {
  counts[event.name] = (counts[event.name] || 0) + 1;
  return counts;
}, {});
```markdown 

## References

- [Project Documentation](../README.md)
