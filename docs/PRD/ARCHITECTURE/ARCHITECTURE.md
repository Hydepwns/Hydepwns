# Hydepwns Architecture & Requirements

This document provides an overview of the Hydepwns application architecture and requirements, explaining what the system does, how it's built, and why certain design decisions were made.

## Project Overview

Hydepwns is a web application that embraces the principles of The Monospace Web, focusing on pixel-perfect monospace typography, character-based grid layouts, and minimalist design. The application serves as both a personal website and a demonstration of monospace web principles.

The application is built on Phoenix LiveView, providing real-time interactivity with server-rendered HTML and minimal JavaScript.

## User Requirements

### Target Users

- Web developers interested in monospace typography and grid-based layouts
- Users who appreciate minimalist, typography-focused web design
- Visitors seeking information about the website owner

### User Stories

1. As a visitor, I want to view information about the website owner so that I can learn about their background and experiences.
2. As a user, I want to toggle between different themes (light, dark, dim) so that I can customize my viewing experience.
3. As a web developer, I want to understand how the monospace grid system works so that I can apply similar principles to my projects.
4. As a user, I want my theme preference to persist between visits so that I don't have to reset it each time.

## Functional Requirements

### Core Features

1. **Content Display**
   - Display information about the website owner
   - Organize content in a clean, grid-based layout
   - Ensure all text aligns to the character grid

2. **Theme System**
   - Provide three theme options: light, dark, and dim
   - Allow users to toggle between themes via UI controls
   - Persist theme selection in user's browser storage
   - Apply theme changes without page reloads

3. **Typography System**
   - Implement pixel-perfect monospace typography
   - Ensure consistent character spacing and alignment
   - Support appropriate font fallbacks

## Non-Functional Requirements

### Performance

- Initial page load under 2 seconds on average connections
- Theme changes should occur in under 100ms
- Smooth scrolling and animations (60fps)

### Accessibility

- Meet WCAG 2.1 AA standards
- Ensure proper color contrast in all themes
- Keyboard navigable interface

### Compatibility

- Support latest versions of major browsers (Chrome, Firefox, Safari, Edge)
- Responsive design for devices from 320px width and up
- Graceful degradation for older browsers

### Documentation

- All documentation organized in a structured PRD (Product Requirements Document) format
- Documentation categorized into logical sections:
  - ARCHITECTURE: System design, components, and technical decisions
  - DEVELOPMENT: Setup guides, contribution guidelines, and testing information
  - FEATURES: Detailed documentation of specific features and components
  - PROJECT_MANAGEMENT: Roadmap, changelog, and project planning documents
  - DESIGN: Design principles, accessibility guidelines, and UI/UX standards
  - DEPLOYMENT: Deployment procedures and environment configurations
- Documentation follows a consistent style guide with standardized formatting
- Cross-references between documents maintained for easy navigation
- Documentation validation scripts ensure consistency and quality

## System Architecture

Hydepwns follows the standard Phoenix architecture with custom additions for theme management and monospace layout components.

### Core Layers

1. **Phoenix Framework** - The foundation of the application
   - LiveView for real-time, server-rendered UI
   - Plug for composable web modules
   - Routing for URL management

2. **Templates & Components** - UI layer
   - HEEX templates for page structure
   - LiveComponents for reusable UI elements
   - Formatting and layout helpers

3. **State Management** - Session and user preferences
   - Theme state management
   - User preferences storage
   - Session persistence

4. **Monospace Grid System** - Typography and layout
   - Character grid calculations
   - CSS utilities for monospace alignment
   - Debug visualization tools

### Resource-Oriented Architecture

The application now incorporates a resource-oriented architecture for socket validation and data management:

1. **LiveViewResource** - Core resource definition system
   - Declarative attribute definitions
   - Relationship specifications with support for various relationship types
   - Validation rules
   - Nested attribute support

2. **Resource Adapters** - Data source integration
   - Ecto schema adapter
   - Ash resource adapter
   - Custom data source adapters
   - Bidirectional data synchronization

3. **Relationship Management System** - Resource relationship handling
   - Declarative relationship DSL for defining connections between resources
   - Support for belongs_to, has_many, has_one, through, and polymorphic relationships
   - Lazy and eager loading strategies for optimized data access
   - Relationship caching mechanism for performance
   - RelationshipResolver for loading related resources
   - RelationshipValidator for ensuring referential integrity
   - Cascading operations with validation for updates and deletes

4. **LiveViewAPI** - Standardized access patterns
   - Resource query methods
   - Resource manipulation functions
   - Resource transformation pipeline
   - Lifecycle hooks for resource changes

5. **Resource Events** - Change detection and propagation
   - Resource change notifications
   - Resource validation events
   - Resource synchronization events
   - Telemetry integration for resource metrics

### Enhanced Error Reporting

The application includes an advanced error reporting system for socket validation:

1. **Context-Aware Errors** - Smart error detection
   - Type conversion suggestions
   - Schema validation help
   - Code examples for fixes
   - Value history analysis
   - Pattern recognition for errors

2. **Error Visualization** - Visual error feedback
   - Debug grid integration
   - Error highlighting
   - Real-time error tracking
   - Error rate visualization

3. **Telemetry Integration** - Error metrics
   - Error frequency tracking
   - Resource-specific error rates
   - Error pattern analysis
   - Performance impact tracking

### Terminal Component

The terminal component provides a rich interactive experience:

1. **Terminal UI** - Advanced terminal interface
   - Command parsing and execution
   - Visual effects for commands
   - Fullscreen mode
   - Custom keyboard shortcuts
   - Theming API integration

2. **Terminal Sharing** - Collaborative features
   - Shareable terminal sessions
   - Session state persistence
   - Session history and playback
   - Unique URL generation for sessions

## Key Components

### Phoenix Framework

The application is built on the Phoenix Framework, which provides:

- Routing
- Controller layer
- View templates
- Telemetry and metrics
- Endpoint configuration

### Phoenix LiveView

LiveView enables real-time UI updates without writing custom JavaScript:

- Live page updates without full page refreshes
- Real-time user experiences with server-rendered HTML
- Minimal JavaScript for client interactions

### BaseLive Architecture

The BaseLive architecture provides an enhanced foundation for LiveView modules:

- Declarative socket assign specifications using DSL
- Resource-oriented socket assigns
- Enhanced error reporting and validation
- Type validation for socket assigns
- Data source abstraction through adapter pattern

### Resource Adapter System

The Resource Adapter system enables flexible data validation sources:

- Adapter behavior pattern for multiple data source types
- Ecto schema support through EctoAdapter
- In-memory testing support through MemoryAdapter
- Planned support for Ash resources

### Theme System

The theme system manages light, dark, and dim themes:

- CSS variables for consistent styling across themes
- Theme toggle component with JavaScript hooks
- LocalStorage for theme persistence
- System preference detection
- High contrast mode for accessibility

### Asset Pipeline

The asset pipeline manages JavaScript and CSS compilation:

- esbuild for JavaScript compilation
- dart-sass for SCSS compilation
- Custom hooks for LiveView components

## Directory Structure

```bash
lib/
├── hydepwns_liveview/           # Business logic and context modules
├── hydepwns_liveview_web/       # Web-related modules
│   ├── components/              # Reusable UI components
│   ├── controllers/             # Traditional Phoenix controllers
│   ├── live/                    # LiveView modules
│   ├── router.ex                # Application routes
│   └── endpoint.ex              # Application endpoint
assets/
├── css/                         # Sass/CSS files
│   ├── app.scss                 # Main application styles
│   └── themes/                  # Theme-specific styles
├── js/                          # JavaScript files
│   ├── app.js                   # Main JavaScript entry point
│   └── hooks/                   # LiveView hooks
config/                          # Application configuration
docs/                            # Documentation
priv/                            # Private application files
test/                            # Tests
```

## Technology Stack

- **Elixir** (1.14+): The programming language
- **Phoenix** (1.7.20+): Web framework
- **PostgreSQL**: Database (for potential future features)
- **Phoenix LiveView**: Server-side rendering with real-time updates
- **esbuild**: JavaScript bundling
- **dart-sass**: CSS processing
- **Credo**: Code quality tool

## Component Specifications

### Theme Toggle Component

- Includes three theme buttons (light, dark, dim)
- Each button has appropriate ARIA labels
- Component has both `phx-hook` and `id` attributes
- Dispatches appropriate theme-change events
- Visually indicates current theme selection

### Layout Component

- Applies the selected theme to the entire page
- Maintains the character grid alignment
- Includes proper meta tags for SEO and social sharing

## Data Flow

### Request Handling

1. HTTP requests enter through the Endpoint
2. The Router directs requests to the appropriate Controller or LiveView
3. Controllers render traditional views or redirect to LiveViews
4. LiveViews maintain stateful connections and update the UI in real-time

### Theme Management

1. The theme toggle component dispatches theme changes via LiveView hooks
2. The theme selection is stored in localStorage
3. CSS variables are updated based on the selected theme
4. The UI reflects the theme changes immediately

### Socket Validation Flow

1. LiveView declares assign specifications using the resource-oriented DSL
2. When assigns are updated, the validation system checks against specifications
3. Resource adapters connect to appropriate data sources for validation
4. Validation errors are processed through the enhanced error reporting system
5. Error information is presented to developers in development environment
6. Telemetry events are emitted for error tracking

## Development Patterns

### Components

Reusable UI components follow these patterns:

- Functional components with HEEx templates
- Grid-based layouts using monospace-friendly units (ch)
- Component composition for complex interfaces

### State Management

State is managed through:

- LiveView assigns for server-rendered state
- JavaScript hooks for client-side interactions
- Browser localStorage for persistent preferences

## Implementation Timeline

### Phase 1: Core Implementation

- Set up Phoenix LiveView project structure
- Implement basic monospace layout and typography
- Create theme system and theme toggle component

### Phase 2: Content and Refinement

- Add personal content and information
- Refine typography and grid alignment
- Implement theme persistence

### Phase 3: Polish and Optimization

- Add grid-based animations and transitions
- Optimize performance
- Ensure cross-browser compatibility
- Conduct accessibility review

## Deployment Architecture

The application can be deployed using:

- Fly.io or Heroku for simple deployment
- Kubernetes for more complex setups
- Docker containers for consistent environments

## Future Architectural Considerations

- Database integration for dynamic content
- Authentication system for admin features
- Complete Ash resource integration for socket validation
- Shareable terminal sessions with collaborative features
- Enhanced CI/CD pipeline with visual regression testing

## Planned Improvements for Code Organization

The project has identified several inconsistencies and opportunities for improved code organization:

1. **Theme System Consolidation**: Currently, theme-related code is spread across multiple directories (`lib/hydepwns_liveview/themes/`, `lib/hydepwns_liveview/theme_system/`). We plan to consolidate these into a single, consistent structure.

2. **Documentation Standardization**: We'll be standardizing documentation naming conventions and merging duplicate documentation, particularly for the Resource Event System.

3. **Events Directory Reorganization**: The events directory will be reorganized into logical subdirectories for core functionality, handlers, projections, and resource integration.

4. **Resource Directory Structure**: We'll improve the organization of the resources directory by separating resource models from utilities and test framework components.

See the [Project Roadmap](../PROJECT_MANAGEMENT/ROADMAP.md) for more details on these planned improvements in the "Codebase Improvement and Consolidation" section.

## Metrics and Success Criteria

### Performance Metrics

- Lighthouse performance score of 90+
- First Contentful Paint under 1.5 seconds

### User Metrics

- Bounce rate below 40%
- Average session duration above 2 minutes
