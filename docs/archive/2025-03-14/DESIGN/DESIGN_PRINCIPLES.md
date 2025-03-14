---
title: Design Principles
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - design
  - design-principles
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - development-principles
  - monospace-web-design
  - learning-resources
  - credits
  - references
  - code-examples
  - development
last_updated: '2025-03-14'
---
# Design Principles

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

# Design Principles


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about DESIGN PRINCIPLES.


This document outlines the core design principles, personal philosophies, and monospace design guidelines that inform the Hydepwns project.

## Development Principles

### Code Quality

1. **Simplicity Over Complexity**
   - Prefer simple, readable solutions over clever, complex ones
   - When faced with a complex problem, break it down into smaller parts
   - "Make it work, make it right, make it fast" - in that order

2. **Consistency Is Key**
   - Follow established patterns in the codebase
   - Use consistent naming conventions
   - Document exceptions and unusual patterns

3. **Documentation Matters**
   - Code should be self-documenting where possible
   - Document the "why" more than the "what"
   - Keep documentation close to the code it describes

### User Experience

1. **Respect User Preferences**
   - Remember user choices (like theme selection)
   - Design for accessibility from the start
   - Support keyboard navigation and assistive technologies

2. **Performance Is a Feature**
   - Optimize for perceived performance
   - Avoid unnecessary work on the client
   - Use server-side rendering for faster initial loads

3. **Feedback Is Essential**
   - Provide clear feedback for user actions
   - Use meaningful error messages
   - Design for progressive disclosure of complexity

### Technical Approach

1. **Embrace the Elixir Way**
   - Prefer pattern matching over conditionals
   - Use processes for state management
   - Let it crash (and handle errors at the appropriate level)

2. **The Monospace Aesthetic**
   - Embrace character grid alignment
   - Use monospace typography as a design constraint
   - Create layouts that respect character boundaries

3. **LiveView Philosophy**
   - Server-rendered HTML is the default approach
   - Use hooks judiciously when client-side behavior is needed
   - Build components that can be composed for complex UIs

## Monospace Web Design

### Core Principles

Hydepwns is inspired by [The Monospace Web](https://github.com/owickstrom/the-monospace-web) project and implements these core principles:

#### Character-Based Grid

The foundation of monospace web design is the character grid:

- Each character occupies the same width (`1ch` unit in CSS)
- Line heights are fixed multiples of the base unit (`var(--line-height)`)
- All elements align to this invisible grid
- Spacing is measured in character units rather than arbitrary pixels

#### Typography Focus

Monospace typography emphasizes:

- Clean, consistent spacing
- Readability through proper line height and width
- Character alignment across lines
- Clear hierarchy through font weight rather than size variation

#### Minimalist Design

The monospace aesthetic embraces minimalism:

- Limited color palette defined by CSS variables
- Simple borders and structural elements
- Typography as the primary design element
- Elimination of decorative elements that don't serve a purpose

### Implementation

#### CSS Variables System

Our implementation uses a flexible CSS variable system for consistent styling:

```css
:root {
  /* Core Variables */
  --font-family: 'Monaspace Argon', 'JetBrains Mono', monospace;
  --line-height: 1.20rem;
  --border-thickness: 2px;
  
  /* Colors */
  --text-color: #000;
  --text-color-alt: #666;
  --background-color: #fff;
  --background-color-alt: #eee;
  
  /* Spacing */
  --spacing-unit: 1ch;
  --spacing-small: calc(var(--spacing-unit) * 1);
  --spacing-medium: calc(var(--spacing-unit) * 2);
  --spacing-large: calc(var(--spacing-unit) * 4);
}
```markdown

#### Grid-Based Animations

The project includes animations that respect the character grid:

- **Typewriter** - Text appears one character at a time
- **Character Fade-in** - Each character fades in separately
- **Grid Slide-in** - Content slides in using character-width steps
- **Cursor Blink** - A classic terminal cursor
- **ASCII Spinner** - A loading indicator made with ASCII characters

#### Component Design Guidelines

When building components for the monospace web:

1. **Use character-based measurements**
   - Width: Use `ch` units for horizontal measurements
   - Height: Use multiples of `var(--line-height)` for vertical spacing
   - Padding/margins: Use character-based units

2. **Maintain the grid**
   - Ensure text aligns across components
   - Use the debug grid for visual verification
   - Avoid elements that break the character grid

3. **Typography-first approach**
   - Let typography define the visual hierarchy
   - Use font weight for emphasis
   - Maintain consistent font sizing

### Practical Application

#### Debug Grid

During development, you can enable the debug grid to visualize the character grid:

```css
body.debug-grid {
  background-image: 
    linear-gradient(to right, rgba(0,0,0,0.1) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(0,0,0,0.1) 1px, transparent 1px);
  background-size: 
    1ch var(--line-height),
    1ch var(--line-height);
}
```markdown

Add the `debug-grid` class to the body element to enable this visualization.

#### Responsive Design

Even with monospace constraints, responsive design is achieved through:

- Using percentage-based container widths
- Setting max-widths in character units
- Using media queries to adjust layouts at breakpoints
- Maintaining the character grid at all viewport sizes

## Learning Resources

### Books

- "Thinking, Fast and Slow" by Daniel Kahneman
- "Atomic Habits" by James Clear
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "Programming Elixir" by Dave Thomas

### Films and Documentaries

- "The Social Dilemma" - On the impact of social media
- "AlphaGo" - On machine learning and human creativity
- [This Is What Winning Looks Like](https://youtu.be/Ja5Q75hf6QI?si=XuwgSsvxtF_9jSz4&t=3694)

## Credits

- Original monospace web concept: [The Monospace Web](https://github.com/owickstrom/the-monospace-web) by Oskar Wickström
- Fonts: [Monaspace](https://github.com/githubnext/monaspace) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/)


## References

- [Project Documentation](../README.md)
