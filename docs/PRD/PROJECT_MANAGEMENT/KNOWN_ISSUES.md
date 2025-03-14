# Known Issues and Limitations

This document lists known issues, limitations, and planned improvements for various components of the Hydepwns application.

## Relationship Management System

### Current Limitations

1. **Query Performance**
   - The current implementation does not optimize queries for loading many-to-many relationships, which may lead to N+1 query issues in some scenarios.
   - For large datasets, eager loading all relationships can be memory-intensive.

2. **Polymorphic Relationships**
   - Polymorphic relationships require both ID and type fields to be maintained separately, which can lead to integrity issues if not carefully managed.
   - The type string to module resolution is somewhat simplistic and may need enhancement for more complex module naming conventions.

3. **Relationship Validation**
   - Deep validation can be computationally expensive for complex relationship graphs.
   - Circular relationships are not specifically detected or handled, which could lead to infinite recursion in some validation scenarios.

4. **Caching**
   - The current caching mechanism is simple and does not handle invalidation strategies beyond the request lifecycle.
   - Cache coherence between multiple concurrent updates is not managed automatically.

### Planned Improvements

1. **Query Optimization**
   - Add batch loading for collections of resources to reduce database roundtrips
   - Implement dataloader-style query batching for more efficient data access
   - Add query planning for complex relationship graphs

2. **Enhanced Polymorphic Support**
   - Add built-in type registration for more robust polymorphic lookups
   - Implement interface-like behavior for polymorphic resources
   - Improve documentation and validation for polymorphic relationships

3. **Validation Enhancements**
   - Add circular dependency detection and resolution
   - Implement validation checkpointing for more efficient re-validation
   - Add more granular validation options for specific use cases

4. **Caching Improvements**
   - Implement a more sophisticated caching system with TTL and invalidation strategies
   - Add option for distributed caching for multi-node deployments
   - Improve cache hit reporting and metrics

5. **Integration with Change Tracking**
   - Once the Change Tracking system is implemented, integrate it with relationship resolution for automatic cache invalidation
   - Add relationship-aware diffing for change detection
   - Implement optimistic concurrency control for relationship updates

## Future Considerations

As we move forward with implementing the Change Tracking System (Phase 2 of the Advanced Resource Integration plan), we will need to ensure that it integrates well with the Relationship Management System. Particularly, we need to ensure that:

1. Changes to relationships are properly tracked in the change history
2. Relationship caches are invalidated when related entities change
3. Relationship validation takes into account the change history when appropriate

These considerations will be addressed in the implementation of the Change Tracking System.

## Code Compilation

### Recent Fixes

As of the latest updates, we have addressed all critical compilation errors in the codebase:

- Fixed undefined function errors, particularly in `mobile_optimizer.ex` and related modules
- Corrected module references and aliases that were causing compilation errors
- Fixed cyclic module dependencies in the Event System
- Addressed syntax errors in conditional statements
- Updated function heads to eliminate duplicate default parameters
- Added missing function implementations, including `handle_command/3` in `order_resource.ex`

### Remaining Warnings

While the code now compiles without errors, there are still some warnings that could be addressed in future updates:

1. **Unused Variables and Functions**
   - Multiple modules contain unused variables and functions that trigger compiler warnings
   - These should be addressed to improve code quality and readability

2. **Undefined Functions and Modules**
   - Some references to functions like `EventBus.publish/1` and `Event.create/2` still appear in warning messages
   - These warnings don't prevent compilation but should be addressed to ensure proper functionality

### Planned Improvements

1. **Systematic Warning Resolution**
   - Address unused variable warnings by either using the variables or marking them with underscore prefix
   - Implement missing functions that are referenced but not defined
   - Review and clean up unused functions to reduce code bloat

2. **Testing and Verification**
   - Implement comprehensive tests to ensure fixed code works as expected
   - Verify proper behavior of the Event System after the recent fixes
   - Create automated test suite to prevent regression of fixed issues

## Component Testing Framework

### Current Limitations

1. **ES Modules Compatibility Issues**
   - Jest has compatibility issues with ES module imports, requiring careful Babel configuration.
   - Some external libraries use ES modules in ways that are difficult to mock in the Jest environment.
   - The setup.js file must carefully use CommonJS require() syntax rather than ES module imports.

2. **DOM Manipulation Testing**
   - Testing components that manipulate the DOM extensively (like Toast) causes HierarchyRequestError when trying to modify the mocked DOM.
   - Jest's jsdom environment has limitations for complex DOM manipulations and animations.
   - Direct DOM manipulation within the jest.mock() factory function is not allowed, requiring more complex mocking strategies.

3. **Test Coverage Challenges**
   - Current component test coverage is significantly below the target threshold (approximately 3.6% vs. target of 80%).
   - Some components interact with browser APIs in ways that are difficult to test without more sophisticated mocking.
   - Event handling, particularly for delegated events, is challenging to test comprehensively.

4. **Component Dependencies**
   - Components often depend on shared utilities like DOMCleanup and EventManager, requiring careful mocking.
   - Components that rely on browser-specific APIs (like scrollHeight) need special handling in the test environment.

### Planned Improvements

1. **Enhanced Test Environment Setup**
   - Create standardized mocking patterns for DOM manipulation and browser APIs.
   - Develop custom test helpers for common testing scenarios (event simulation, DOM inspection).
   - Improve documentation for testing complex components with extensive DOM manipulation.

2. **Testing Utility Enhancements**
   - Extend the component_test_utility.js to provide more robust testing capabilities.
   - Add utilities for simulating user interactions with proper event bubbling.
   - Create specialized test fixtures for components with complex DOM structures.

3. **Test Coverage Strategy**
   - Prioritize component tests based on complexity and usage frequency.
   - Establish incremental coverage goals to progress toward the 80% threshold.
   - Create component-specific testing guidelines for components with unique challenges.

4. **CI Integration**
   - Improve CI pipeline to run component tests efficiently.
   - Add coverage reports to CI build process.
   - Implement test failure notifications with actionable feedback.
