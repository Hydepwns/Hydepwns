---
title: Hydepwns Resource System
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - features
  - hydepwns-resource-system
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - introduction
  - table-of-contents
  - core-concepts
  - creating-resources
  - working-with-events
  - resource-testing
  - integration-with-external-systems
  - admin-interface
  - performance-optimization
  - best-practices
  - conclusion
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Hydepwns Resource System

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

# Hydepwns Resource System


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about RESOURCE SYSTEM.


## Introduction

The Hydepwns Resource System is a comprehensive solution for managing domain entities in your application through an event-sourced approach. This document explains the system's architecture, how to create and use resources, and how to leverage the various features available.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Creating Resources](#creating-resources)
3. [Working with Events](#working-with-events)
4. [Resource Testing](#resource-testing)
5. [Integration with External Systems](#integration-with-external-systems)
6. [Admin Interface](#admin-interface)
7. [Performance Optimization](#performance-optimization)
8. [Best Practices](#best-practices)

## Core Concepts

### What is a Resource?

A resource is a domain entity that represents a business concept in your application. Resources in Hydepwns are event-sourced, meaning their state is derived from a sequence of events rather than being directly stored in a database.

### Event Sourcing

Event sourcing is a pattern where changes to the application state are captured as a sequence of events. Instead of storing the current state directly, we store the events that led to that state. This provides benefits like:

- Complete audit history
- Ability to reconstruct the state at any point in time
- Separation of write and read models

### Command-Query Responsibility Segregation (CQRS)

The Resource System implements CQRS by separating:

- **Commands**: Operations that change state (create, update, delete)
- **Queries**: Operations that retrieve data without changing state

This separation allows for optimizing each path independently and better scalability.

## Creating Resources

### Resource Definition

To create a new resource, define a resource module with event handlers:

```javascript
// resources/user.js
import { Resource } from 'assets/js/resources/core';

// Define the User resource
export default class User extends Resource {
  // Define the initial state
  static initialState() {
    return {
      id: null,
      username: '',
      email: '',
      profile: {
        displayName: '',
        bio: '',
        avatarUrl: ''
      },
      isActive: false,
      createdAt: null,
      updatedAt: null
    };
  }
  
  // Define event handlers
  static eventHandlers = {
    'user:created': (state, event) => ({
      ...state,
      id: event.data.id,
      username: event.data.username,
      email: event.data.email,
      isActive: true,
      createdAt: event.timestamp,
      updatedAt: event.timestamp
    }),
    
    'user:profile-updated': (state, event) => ({
      ...state,
      profile: {
        ...state.profile,
        ...event.data.profile
      },
      updatedAt: event.timestamp
    }),
    
    'user:email-changed': (state, event) => ({
      ...state,
      email: event.data.email,
      updatedAt: event.timestamp
    }),
    
    'user:deactivated': (state, event) => ({
      ...state,
      isActive: false,
      updatedAt: event.timestamp
    }),
    
    'user:activated': (state, event) => ({
      ...state,
      isActive: true,
      updatedAt: event.timestamp
    })
  };
  
  // Command methods that produce events
  static commands = {
    create(data) {
      return this.createEvent('user:created', {
        id: data.id || generateId(),
        username: data.username,
        email: data.email
      });
    },
    
    updateProfile(userId, profileData) {
      return this.createEvent('user:profile-updated', {
        userId,
        profile: profileData
      });
    },
    
    changeEmail(userId, email) {
      return this.createEvent('user:email-changed', {
        userId,
        email
      });
    },
    
    deactivate(userId) {
      return this.createEvent('user:deactivated', {
        userId
      });
    },
    
    activate(userId) {
      return this.createEvent('user:activated', {
        userId
      });
    }
  };
}
```markdown

### Resource Registration

Register your resources with the resource registry:

```javascript
import { ResourceRegistry } from 'assets/js/resources/core';
import User from './resources/user';
import Post from './resources/post';
import Comment from './resources/comment';

// Register resources
ResourceRegistry.register([
  User,
  Post,
  Comment
]);
```markdown

### Resource Factory

Use the resource factory to create new resource instances:

```javascript
import { ResourceFactory } from 'assets/js/resources/core';

// Create a new user
const user = ResourceFactory.create('User', {
  username: 'johndoe',
  email: 'john@example.com'
});

// The factory handles:
// 1. Creating the initial event
// 2. Applying it to the initial state
// 3. Returning the resource instance
```markdown

## Working with Events

### Creating Events

Events are the building blocks of resource state. Create events using the resource's command methods:

```javascript
// Using static command methods
const createEvent = User.commands.create({
  username: 'johndoe',
  email: 'john@example.com'
});

// Or using instance methods on a resource instance
const profileUpdateEvent = user.updateProfile({
  displayName: 'John Doe',
  bio: 'Software Developer',
  avatarUrl: 'https://example.com/avatar.jpg'
});
```markdown

### Dispatching Events

Events must be dispatched to take effect:

```javascript
import { EventDispatcher } from 'assets/js/resources/core';

// Dispatch a single event
EventDispatcher.dispatch(createEvent);

// Or dispatch multiple events
EventDispatcher.dispatchBatch([
  createEvent,
  profileUpdateEvent
]);
```markdown

### Event Validation

Events are validated before being applied to ensure data integrity:

```javascript
// Define validators in your resource
static validators = {
  'user:created': (event) => {
    const errors = {};
    
    if (!event.data.username) {
      errors.username = 'Username is required';
    }
    
    if (!event.data.email) {
      errors.email = 'Email is required';
    } else if (!isValidEmail(event.data.email)) {
      errors.email = 'Invalid email format';
    }
    
    return Object.keys(errors).length ? errors : null;
  }
};
```markdown

### Event Streams

Access the event stream for a resource:

```javascript
// Get all events for a specific user
const userEvents = await EventStore.getEvents('User', userId);

// Filter events by type
const profileUpdates = userEvents.filter(
  event => event.type === 'user:profile-updated'
);

// Get events in a time range
const recentEvents = await EventStore.getEvents('User', userId, {
  from: new Date('2023-01-01'),
  to: new Date()
});
```markdown

## Resource Testing

### Unit Testing Resources

Test resources in isolation using the testing utilities:

```javascript
import { ResourceTester } from 'assets/js/resources/testing';
import User from './resources/user';

describe('User Resource', () => {
  let tester;
  
  beforeEach(() => {
    tester = new ResourceTester(User);
  });
  
  test('should create a user', () => {
    // Given
    const command = {
      username: 'testuser',
      email: 'test@example.com'
    };
    
    // When
    const result = tester.execute('create', command);
    
    // Then
    expect(result.state).toMatchObject({
      username: 'testuser',
      email: 'test@example.com',
      isActive: true
    });
    expect(result.events).toHaveLength(1);
    expect(result.events[0].type).toBe('user:created');
  });
  
  test('should deactivate a user', () => {
    // Given
    tester.given([
      {
        type: 'user:created',
        data: {
          id: '123',
          username: 'testuser',
          email: 'test@example.com'
        }
      }
    ]);
    
    // When
    const result = tester.execute('deactivate', { userId: '123' });
    
    // Then
    expect(result.state.isActive).toBe(false);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].type).toBe('user:deactivated');
  });
});
```markdown

### Integration Testing

Test resources with the actual event store and dispatcher:

```javascript
import { ResourceRegistry, EventStore, EventDispatcher } from 'assets/js/resources/core';
import User from './resources/user';

describe('User Resource Integration', () => {
  beforeAll(() => {
    ResourceRegistry.register([User]);
  });
  
  beforeEach(async () => {
    await EventStore.clear(); // Clear the event store before each test
  });
  
  test('should create and update a user', async () => {
    // Create a user
    const createEvent = User.commands.create({
      username: 'testuser',
      email: 'test@example.com'
    });
    
    await EventDispatcher.dispatch(createEvent);
    
    // Get the user from the store
    const user = await ResourceRegistry.getResource('User', createEvent.data.id);
    
    // Update the user's profile
    const updateEvent = User.commands.updateProfile(user.id, {
      displayName: 'Test User',
      bio: 'A test user'
    });
    
    await EventDispatcher.dispatch(updateEvent);
    
    // Verify the updated user
    const updatedUser = await ResourceRegistry.getResource('User', user.id);
    
    expect(updatedUser.profile.displayName).toBe('Test User');
    expect(updatedUser.profile.bio).toBe('A test user');
  });
});
```markdown

## Integration with External Systems

### Subscriptions and Projections

Create subscriptions to react to resource events:

```javascript
import { Subscription } from 'assets/js/resources/core';

// Create a subscription that updates a search index
const searchIndexSubscription = new Subscription({
  name: 'search-index-updater',
  eventTypes: ['user:created', 'user:profile-updated', 'user:email-changed'],
  
  async handleEvent(event) {
    if (event.type === 'user:created') {
      await SearchIndex.addDocument('users', {
        id: event.data.id,
        username: event.data.username,
        email: event.data.email
      });
    } else if (event.type === 'user:profile-updated') {
      await SearchIndex.updateDocument('users', event.data.userId, {
        displayName: event.data.profile.displayName,
        bio: event.data.profile.bio
      });
    } else if (event.type === 'user:email-changed') {
      await SearchIndex.updateDocument('users', event.data.userId, {
        email: event.data.email
      });
    }
  }
});

// Register the subscription
Subscription.register(searchIndexSubscription);
```markdown

### External Event Sources

Integrate with external event sources:

```javascript
import { ExternalEventAdapter } from 'assets/js/resources/core';

// Create an adapter for a message queue
const mqAdapter = new ExternalEventAdapter({
  source: 'message-queue',
  
  // Map external events to internal events
  mapEvent(externalEvent) {
    if (externalEvent.topic === 'users.created') {
      return {
        type: 'user:created',
        data: {
          id: externalEvent.payload.id,
          username: externalEvent.payload.username,
          email: externalEvent.payload.email
        }
      };
    }
    
    return null; // Return null to ignore events
  }
});

// Register the adapter
ExternalEventAdapter.register(mqAdapter);

// Start processing events
mqAdapter.start();
```markdown

## Admin Interface

### Resource Explorer

The Resource System includes an admin interface for exploring resources:

```javascript
import { ResourceAdmin } from 'assets/js/resources/admin';

// Initialize the admin interface
const admin = new ResourceAdmin({
  container: document.getElementById('resource-admin'),
  resources: ['User', 'Post', 'Comment']
});

// Show the admin interface
admin.show();
```markdown

### Event Inspector

Inspect events for debugging:

```javascript
import { EventInspector } from 'assets/js/resources/admin';

// Initialize the event inspector
const inspector = new EventInspector({
  container: document.getElementById('event-inspector'),
  resourceType: 'User',
  resourceId: '123'
});

// Show the inspector
inspector.show();
```markdown

## Performance Optimization

### Event Snapshots

Use snapshots to improve loading performance for resources with many events:

```javascript
import { SnapshotStrategy } from 'assets/js/resources/core';

// Configure snapshots for users
SnapshotStrategy.configure('User', {
  frequency: 100, // Create a snapshot every 100 events
  includes: ['profile', 'settings'], // Include specific nested objects
  excludes: ['temporaryData'] // Exclude specific properties
});
```markdown

### Batch Processing

Process events in batches for better performance:

```javascript
// Import multiple resources efficiently
async function importUsers(userDataList) {
  const events = userDataList.map(userData => 
    User.commands.create(userData)
  );
  
  // Dispatch in batches of 100
  const batchSize = 100;
  for (let i = 0; i < events.length; i += batchSize) {
    const batch = events.slice(i, i + batchSize);
    await EventDispatcher.dispatchBatch(batch);
  }
}
```markdown

## Best Practices

### 1. Design Events Carefully

- Make events meaningful and descriptive
- Include all necessary data in the event
- Use consistent naming conventions
- Version events to allow for future changes

```javascript
// Good event design
const goodEvent = {
  type: 'user:email-changed:v1', // Versioned event type
  data: {
    userId: '123',
    email: 'new@example.com',
    previousEmail: 'old@example.com', // Include previous state when helpful
    reason: 'user-requested' // Context about why the change happened
  },
  metadata: {
    requestId: '456', // For tracking/correlation
    initiatedBy: 'user', // Or 'system', 'admin', etc.
    clientInfo: { // Additional context
      ip: '127.0.0.1',
      userAgent: '...'
    }
  }
};
```markdown

### 2. Keep Event Handlers Pure

Event handlers should be pure functions that only transform state:

```javascript
// Good event handler
'user:email-changed': (state, event) => ({
  ...state,
  email: event.data.email,
  emailHistory: [
    ...(state.emailHistory || []),
    { email: state.email, changedAt: state.updatedAt }
  ],
  updatedAt: event.timestamp
})

// Bad event handler - has side effects
'user:email-changed': (state, event) => {
  // Don't do this in an event handler!
  notifyUser(state.id, 'Your email has been changed');
  
  return {
    ...state,
    email: event.data.email,
    updatedAt: event.timestamp
  };
}
```markdown

### 3. Use Commands for Business Logic

Keep business logic in command methods, not event handlers:

```javascript
// Good approach
static commands = {
  changeEmail(userId, email, options = {}) {
    // Validate email format
    if (!isValidEmail(email)) {
      throw new Error('Invalid email format');
    }
    
    // Check if email is already taken (might be async in real code)
    if (isEmailTaken(email) && !options.force) {
      throw new Error('Email is already in use');
    }
    
    // Create the event
    return this.createEvent('user:email-changed', {
      userId,
      email,
      previousEmail: this.getResource('User', userId).email
    });
  }
}
```markdown

### 4. Consider Event Ordering

Be careful with event ordering and concurrency:

```javascript
// Use version numbers to detect conflicts
static commands = {
  updateProfile(userId, profileData) {
    const user = this.getResource('User', userId);
    
    return this.createEvent('user:profile-updated', {
      userId,
      profile: profileData,
      version: user.version // Include current version
    });
  }
}

// Check for conflicts in the dispatcher
EventDispatcher.on('beforeDispatch', event => {
  if (event.type === 'user:profile-updated') {
    const currentUser = ResourceRegistry.getResource('User', event.data.userId);
    
    if (currentUser.version !== event.data.version) {
      throw new ConcurrencyError('User has been modified');
    }
  }
});
```markdown

### 5. Plan for Event Schema Evolution

Design events to be extensible and versionable:

```javascript
// Version 1 event handler
'user:created:v1': (state, event) => ({
  ...state,
  id: event.data.id,
  username: event.data.username,
  email: event.data.email,
  createdAt: event.timestamp
})

// Version 2 event handler adds new fields
'user:created:v2': (state, event) => ({
  ...state,
  id: event.data.id,
  username: event.data.username,
  email: event.data.email,
  fullName: event.data.fullName, // New in v2
  locale: event.data.locale,     // New in v2
  createdAt: event.timestamp
})

// Upcasting function to convert v1 to v2
static upcasters = {
  'user:created:v1': (event) => ({
    ...event,
    type: 'user:created:v2',
    data: {
      ...event.data,
      fullName: '', // Default value for new field
      locale: 'en'  // Default value for new field
    }
  })
}
```markdown

## Conclusion

The Hydepwns Resource System provides a powerful, event-sourced approach to managing application state. By separating commands, events, and state, it creates a maintainable and scalable architecture that naturally supports auditing, temporal queries, and integration with external systems. 

## References

- [Project Documentation](../README.md)
