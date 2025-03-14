# Hydepwns Project Documentation

Welcome to the Hydepwns Project Documentation. This guide serves as your comprehensive introduction to the project and navigation hub for all related documentation.

## Why This Documentation Exists

This Product Requirements Document (PRD) collection exists to:

1. **Provide Clear Direction**: Define the vision, goals, and technical requirements of Hydepwns
2. **Ensure Consistency**: Maintain a coherent approach across different aspects of the project
3. **Facilitate Onboarding**: Help new contributors understand the project quickly and effectively
4. **Document Decisions**: Record architectural and design choices for future reference
5. **Support Sustainable Development**: Enable long-term maintenance through well-documented systems

Whether you're a new contributor, curious about the project's architecture, or looking for specific implementation details, this documentation aims to make your journey smoother.

## What is Hydepwns?

Hydepwns is a Phoenix LiveView application that implements a personal website with a focus on monospace typography and clean grid-based layouts. The project embraces the philosophy of [The Monospace Web](https://github.com/owickstrom/the-monospace-web), creating a distinctive digital experience through precise character-grid alignment and thoughtful design.

### Key Features

- **Monospace Typography**: Pixel-perfect character grid alignment for a unique visual experience
- **Theme System**: Light, Dark, and Dim modes with persistent user preferences
- **Phoenix LiveView**: Real-time user experiences with minimal JavaScript
- **Responsive Design**: Mobile-friendly layouts that maintain grid precision
- **Resource Management**: Comprehensive system for managing, validating, and tracking changes to resources
  - Relationship Management System
  - Change Tracking Implementation
  - Nested Resource Validation with dependency resolution and hierarchical error reporting
  - Resource Transformation Pipeline with composable operations
  - Resource Event System for event-driven architecture

## ⚠️ Urgent Priority: Robust Long-term Component System ⚠️

We are currently implementing a robust long-term solution for our component architecture to prevent technical debt and ensure system stability. This is our top priority and includes the following key improvements:

### 1. Component Isolation

We've redesigned our components (starting with the debug grid) as isolated, self-contained units that don't interfere with each other. This includes unique runtime IDs, scoped state management, and self-contained initialization.

### 2. Event Management System

A centralized event management system has been implemented to prevent event handler conflicts and ensure proper cleanup. This system includes registration/deregistration protocols, delegated events for performance, and component lifecycle integration.

### 3. CSS Refactoring

Our CSS has been refactored to use consistent variable-based theming that works well in both light and dark modes, with standardized spacing, sizing units, and grid-based layout variables.

### 4. DOM Cleanup Protocol

We've established a clear protocol for DOM cleanup when components are dismounted, including cleanup registries, automatic element removal, timer clearing, and event listener cleanup.

### 5. Explicit Z-index System

A standardized z-index system with clearly defined layers and priorities has been created, with semantic variable names and helper classes for consistent application.

### 7. Component Migration Initiative

We are actively migrating all existing components to utilize the robust component system. This high-priority initiative includes:
- A comprehensive migration guide for developers ✅
- Example implementations of migrated components (theme_toggle.js, animations.js) ✅
- Systematic approach to update all components ✅ 
- Testing and validation procedures for migrated components ⚠️ IN PROGRESS

Current Progress:
- 11 out of 11 targeted components have been migrated to the robust component system ✅
- 3 out of 8 components have corresponding unit tests ⚠️ IN PROGRESS
- Accessibility validation of all components is scheduled for Q3 2024 ⏳

See the [Component Migration Guide](../assets/js/components/COMPONENT_MIGRATION_GUIDE.md) for implementation details and the [Project Roadmap](PROJECT_MANAGEMENT/ROADMAP.md) for progress tracking.

For details, see our [Robust Implementation Documentation](ROBUST_IMPLEMENTATION.md) and the [Project Roadmap](PROJECT_MANAGEMENT/ROADMAP.md).

## Getting Started

New to the project? Here's a recommended path through the documentation:

1. Start with the [Getting Started Guide](GETTING_STARTED.md) for setup instructions
2. Explore the [Design Principles](DESIGN/DESIGN_PRINCIPLES.md) to understand the project's philosophy
3. Review the [Architecture Overview](ARCHITECTURE/ARCHITECTURE.md) for technical foundation
4. Check out the [Contributing Guide](DEVELOPMENT/CONTRIBUTING.md) if you'd like to participate

## Documentation Structure

The documentation is organized into the following sections:

### Project Management

- [Changelog](PROJECT_MANAGEMENT/CHANGELOG.md)
- [Documentation Style Guide](PROJECT_MANAGEMENT/DOCUMENTATION_STYLE_GUIDE.md)
- [Known Issues and Limitations](PROJECT_MANAGEMENT/KNOWN_ISSUES.md)
- [Project Roadmap](PROJECT_MANAGEMENT/ROADMAP.md)
- [Code Consistency Guide](PROJECT_MANAGEMENT/CODE_CONSISTENCY.md)

### Architecture

- [Architecture Overview](ARCHITECTURE/ARCHITECTURE.md)
- [Resource Event System](ARCHITECTURE/RESOURCE_EVENT_SYSTEM.md)
- [Component Architecture](ARCHITECTURE/COMPONENT_ARCHITECTURE.md)
- [Enhanced Error Reporting](ARCHITECTURE/ENHANCED_ERROR_REPORTING.md)
- [Error Handling Best Practices](ARCHITECTURE/ERROR_HANDLING.md)
- [Module Organization](ARCHITECTURE/MODULE_ORGANIZATION.md)
- [Resource Architecture](ARCHITECTURE/RESOURCE_ARCHITECTURE.md)
- [Socket Validation System](ARCHITECTURE/SOCKET_VALIDATION.md)
- [BaseLive and Flint Integration](ARCHITECTURE/BASELIVE_FLINT_INTEGRATION.md)
- [API Documentation](ARCHITECTURE/API_DOCUMENTATION.md)

### Development

- [Contributing Guide](DEVELOPMENT/CONTRIBUTING.md)
- [Development Environment Setup](DEVELOPMENT/DEVELOPMENT_SETUP.md)
- [Docker Development Environment](DEVELOPMENT/DOCKER_SETUP.md)
- [Image Optimization Guide](DEVELOPMENT/IMAGE_OPTIMIZATION.md)
- [PathHelper Module](DEVELOPMENT/PATH_HELPER.md)
- [Testing Guide](DEVELOPMENT/TESTING_GUIDE.md)
- [Testing Strategy](DEVELOPMENT/TESTING_STRATEGY.md)
- [Documentation Process](DEVELOPMENT/DOCUMENTATION_PROCESS.md)

### Features

- [Animation Guide](FEATURES/ANIMATIONS.md)
- [ASCII Art Components](FEATURES/ASCII_ART_COMPONENTS.md)
- [Change Tracking Architecture](FEATURES/CHANGE_TRACKING.md)
- [LiveView Integration](FEATURES/LIVEVIEW.md)
- [Nested Resource Validation](FEATURES/NESTED_RESOURCE_VALIDATION.md)
- [Relationship Management System](FEATURES/RELATIONSHIP_MANAGEMENT.md)
- [Resource Management System](FEATURES/RESOURCE_MANAGEMENT.md)
- [Resource Transformation Pipeline](FEATURES/RESOURCE_TRANSFORMATION.md)
- [Terminal Plugin System](FEATURES/TERMINAL_PLUGINS.md)
- [Theme System](FEATURES/THEMES.md)

### Deployment

- [Deployment Guide](DEPLOYMENT/DEPLOYMENT.md)

### Design

- [Design Principles](DESIGN/DESIGN_PRINCIPLES.md)
- [Mobile Performance Optimizations](DESIGN/MOBILE_OPTIMIZATIONS.md)
- [Screen Reader Testing Guide](DESIGN/SCREEN_READER_TESTING.md)

### Implementation Examples

- [Resource Transformation Pipeline Examples](RESOURCE_TRANSFORMATION_PIPELINE.md)
- [Resource System Implementation](RESOURCE_SYSTEM_IMPLEMENTATION.md)
- [Robust Implementation Documentation](ROBUST_IMPLEMENTATION.md)
