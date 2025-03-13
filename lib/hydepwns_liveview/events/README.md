# Event System Architecture

## Overview

The HydepwnsLiveview event system implements an event-sourcing architecture with projections and handlers. The system consists of several components:

- **Event Store**: Responsible for persisting and retrieving events
- **Event Bus**: Distributes events to handlers and projections
- **Handlers**: Process events and trigger side effects
- **Projections**: Build read models from event streams
- **Event Sourced Resources**: Domain objects rebuilt from event streams

## Architecture

The event system uses a bridge pattern to maintain backward compatibility while allowing for refactoring and improvements:

```
User Code
    │
    ▼
Bridge Modules (in /events/*.ex)
    │
    ▼
Core Implementations (in /events/core/, /events/handlers/, etc.)
    │
    ▼
Database/Storage
```

### Bridge Modules

Bridge modules live directly in the `/events/` directory and provide a stable public API. They delegate to the actual implementations in subdirectories.

For example:
- `HydepwnsLiveview.Events.EventStore` ➔ `HydepwnsLiveview.Events.Core.EventStore`
- `HydepwnsLiveview.Events.HandlerSupervisor` ➔ `HydepwnsLiveview.Events.Handlers.HandlerSupervisor`

### Core Implementations

The actual implementations are organized by responsibility:

- `/events/core/`: Core event system (event store, event bus, etc.)
- `/events/handlers/`: Event handler implementations
- `/events/projections/`: Projection implementations
- `/events/resource_integration/`: Integration with domain resources

## Development Guidelines

When working with the event system, follow these guidelines:

1. **Adding new functionality**:
   - Implement in the appropriate core module
   - Add a delegation in the corresponding bridge module

2. **Fixing bugs**:
   - Fix in the core implementation
   - Update the bridge module if needed

3. **Modifying interfaces**:
   - Keep the bridge module interface stable if possible
   - If changes are necessary, update both core and bridge

4. **Adding new modules**:
   - Place implementation in the appropriate subdirectory
   - Create a bridge module if it needs to be part of the public API

## Function Naming Conventions

Maintain consistent naming across bridge and core modules:

- Core modules should use descriptive, explicit names (e.g., `store_event`)
- Bridge modules should delegate to the correct core function
- For backward compatibility, bridge modules can provide aliases (e.g., both `store` and `store_event`)

## Testing

All functionality should be tested at the core implementation level. Bridge modules should have minimal tests focused on ensuring proper delegation. 