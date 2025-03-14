---
title: Event-Bus
description: '## Overview'
topics:
  - reference
  - architecture
  - event-bus
  - overview
  - prerequisites
  - main-content
  - troubleshooting
  - related-documents
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
  - related-documentation
  - references
  - code-examples
  - development
last_updated: '2025-03-14'
---
# Event-Bus

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Event-Bus.


---
title: Event Bus System
description: Documentation for the event bus architecture that enables decoupled communication between components
category: reference
subcategory: architecture
order: 4
last_updated: 2024-04-20
contributors:
  - documentation_team
status: active
priority: medium
tags:
  - architecture
  - components
  - communication
  - events
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
    document.body.classList.toggle('dark-theme', event.data.theme === 'dark');
  }
}
```markdown

## Integration with Reactive State System

The Event Bus works seamlessly with the [Reactive State System](reactive-state.md):

```javascript
class ConnectedComponent extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Set up state
    this.stateManager = new StateManager();
    this.state = this.stateManager.defineState({
      data: null,
      isLoading: false,
      error: null
    });
    
    // Subscribe to events
    this.subscribe('data:fetch-requested', this.fetchData.bind(this));
  }
  
  fetchData() {
    this.state.isLoading = true;
    this.state.error = null;
    
    // When data is received
    apiClient.getData()
      .then(result => {
        this.state.data = result;
        this.state.isLoading = false;
        
        // Publish success event
        this.publish('data:updated', { data: result });
      })
      .catch(error => {
        this.state.error = error;
        this.state.isLoading = false;
        
        // Publish error event
        this.publish('data:error', { error });
      });
  }
}
```markdown

## Debugging Tools

The Event Bus includes built-in debugging tools to help troubleshoot event-related issues:

### Event Inspector

Enable the event inspector to visualize event flow:

```javascript
// Enable event inspection
EventBus.setDebug(true);

// Open the event inspector
EventBus.showInspector();
```markdown

The Event Inspector provides:

- Real-time event visualization
- Filtering by event name or component
- Timeline view of events
- Event payload inspection
- Subscription management

### Logging and History

```javascript
// Get recent events (last 100)
const eventHistory = EventBus.getHistory(100);

// Log all events to console
EventBus.setDebug(true, { console: true });

// Advanced logging with filtering
EventBus.setDebug(true, {
  console: true,
  filter: event => event.name.startsWith('user:')
});
```markdown

## Related Documentation

- [Component Guidelines](../../development/components/guidelines.md)
- [Reactive State System](reactive-state.md)
- [Component Inspector](../../development/tools/component-inspector.md)
- [Component Architecture](/docs/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/reference/architecture/component-architecture.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> 

## References

- [Project Documentation](../README.md)
