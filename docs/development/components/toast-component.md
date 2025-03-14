---
title: Toast-Component
description: '## Overview'
topics:
  - development
  - components
  - toast-component
  - overview
  - prerequisites
  - main-content
  - troubleshooting
  - related-documents
  - features
  - usage
  - in-your-liveview-module
  - from-javascript
  - configuration-options
  - accessibility
  - implementation-details
  - examples
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Toast-Component

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Toast-Component.


---
title: Toast Component
description: Implementation guide for the lightweight, temporary notification toast component
category: development
subcategory: components
order: 3
---

# Toast Component

The Toast component provides lightweight, temporary notification toasts that appear briefly and then disappear. It's designed for simple success/error/info messages that don't require user interaction.

## Features

- Multiple toast types: success, error, info, warning
- Configurable position: top-right, top-center, top-left, bottom-right, bottom-center, bottom-left
- Customizable duration
- Maximum toast limit with automatic management
- Automatic cleanup of DOM elements and event listeners
- Dark mode support
- Accessible design with proper ARIA attributes

## Usage

### Basic Usage with LiveView

Add the Toast hook to your LiveView template:

```html
<div id="toast-container" phx-hook="Toast"></div>
```markdown

### Displaying Toasts

#### From LiveView

```elixir
# In your LiveView module
def handle_event("show_success", _params, socket) do
  {:noreply, push_event(socket, "toast", %{type: "success", message: "Operation successful!"})}
end
```markdown

## From JavaScript

```javascript
// Using the built-in event system
window.dispatchEvent(new CustomEvent("hydepwns:toast", {
  detail: {
    type: "success",
    message: "Operation successful!",
    duration: 5000, // optional, in ms
    position: "top-right" // optional
  }
}));
```markdown

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | String | `"info"` | Toast type: `"success"`, `"error"`, `"info"`, `"warning"` |
| `message` | String | (required) | The message to display |
| `duration` | Number | 4000 | Display duration in ms (0 for no auto-close) |
| `position` | String | `"top-right"` | Toast position on screen |
| `showProgress` | Boolean | true | Show countdown progress bar |
| `closable` | Boolean | false | Include close button |

## Accessibility

The Toast component is designed with accessibility in mind:

- Uses appropriate ARIA roles and attributes
- Manages focus correctly
- Ensures color contrast meets WCAG standards
- Provides keyboard interaction for dismissable toasts

## Implementation Details

### Component Structure

The Toast component uses the following structure:

```html
<div class="toast-container toast-container--{position}">
  <div class="toast toast--{type}" role="alert" aria-live="polite">
    <div class="toast__content">
      <div class="toast__icon">{icon}</div>
      <div class="toast__message">{message}</div>
      {closeButton}
    </div>
    {progressBar}
  </div>
</div>
```markdown

### Technical Notes

- The component uses ES modules
- Event listeners are properly cleaned up on component unmount
- The component follows the new component system standards
- Position is managed with CSS custom properties
- Animation is handled with CSS transitions

## Examples

### Success Toast

```javascript
window.dispatchEvent(new CustomEvent("hydepwns:toast", {
  detail: {
    type: "success",
    message: "Profile updated successfully!"
  }
}));
```markdown

### Error Toast with Extended Duration

```javascript
window.dispatchEvent(new CustomEvent("hydepwns:toast", {
  detail: {
    type: "error",
    message: "Failed to save changes. Please try again.",
    duration: 8000
  }
}));
```markdown

### Warning Toast with Custom Position

```javascript
window.dispatchEvent(new CustomEvent("hydepwns:toast", {
  detail: {
    type: "warning",
    message: "Your session will expire in 5 minutes.",
    position: "bottom-center"
  }
}));
```markdown 

## References

- [Project Documentation](../README.md)
