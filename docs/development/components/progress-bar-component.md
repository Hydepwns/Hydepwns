---
title: Progress-Bar-Component
description: '## Overview'
topics:
  - development
  - components
  - progress-bar-component
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
# Progress-Bar-Component

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Progress-Bar-Component.


---
title: Progress Bar Component
description: Implementation guide for the customizable progress bar component
category: development
subcategory: components
order: 4
---

# Progress Bar Component

The Progress Bar component provides a customizable, animated progress indicator that can be used to show the status of operations, file uploads, form completions, and other processes requiring visual feedback about completion percentage.

## Features

- Multiple styles: line, circular, stepped
- Customizable colors and themes
- Animated transitions
- Support for determinate and indeterminate states
- Optional text labels and percentage display
- Accessible with proper ARIA attributes
- Integrated with the component system
- Dark mode support

## Usage

### Basic Usage with LiveView

Add the Progress Bar hook to your LiveView template:

```html
<div 
  id="my-progress" 
  class="progress-bar" 
  data-value="25" 
  data-max="100"
  phx-hook="ProgressBar">
</div>
```markdown

### Updating Progress

#### From LiveView

```elixir
# In your LiveView module
def handle_info({:progress_update, percentage}, socket) do
  {:noreply, push_event(socket, "progress_update", %{id: "my-progress", value: percentage})}
end
```markdown

## From JavaScript

```javascript
// Using the built-in event system
window.dispatchEvent(new CustomEvent("hydepwns:progress_update", {
  detail: {
    id: "my-progress",
    value: 50
  }
}));
```markdown

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data-value` | Number | `0` | Current progress value |
| `data-max` | Number | `100` | Maximum progress value |
| `data-type` | String | `"line"` | Progress bar type: `"line"`, `"circular"`, `"stepped"` |
| `data-show-text` | Boolean | `true` | Whether to show percentage text |
| `data-animate` | Boolean | `true` | Whether to animate transitions |
| `data-steps` | Number | `5` | Number of steps (for stepped type) |
| `data-indeterminate` | Boolean | `false` | Whether progress is indeterminate |

## Accessibility

The Progress Bar component follows accessibility best practices:

- Uses `role="progressbar"` attribute
- Includes `aria-valuenow`, `aria-valuemin`, and `aria-valuemax` attributes
- Updates ARIA attributes when progress changes
- Provides text alternatives for screen readers

## Implementation Details

### Component Structure

The Progress Bar component has different structures based on the type:

#### Line Progress Bar

```html
<div class="progress-bar progress-bar--line" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
  <div class="progress-bar__track">
    <div class="progress-bar__fill" style="width: 25%"></div>
  </div>
  <div class="progress-bar__text">25%</div>
</div>
```markdown

#### Circular Progress Bar

```html
<div class="progress-bar progress-bar--circular" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
  <svg class="progress-bar__svg" viewBox="0 0 100 100">
    <circle class="progress-bar__track" cx="50" cy="50" r="45"></circle>
    <circle class="progress-bar__fill" cx="50" cy="50" r="45" style="stroke-dashoffset: 212.5px"></circle>
  </svg>
  <div class="progress-bar__text">25%</div>
</div>
```markdown

### Technical Notes

- Uses CSS custom properties for theming
- Implements smooth animations with CSS transitions
- Follows the component system standards for initialization and cleanup
- Handles window resize events appropriately
- Properly manages state and DOM updates

## Examples

### Basic Line Progress Bar

```html
<div 
  id="upload-progress" 
  class="progress-bar" 
  data-value="0" 
  data-max="100"
  data-type="line"
  phx-hook="ProgressBar">
</div>
```markdown

### Circular Progress with Custom Colors

```html
<div 
  id="download-progress" 
  class="progress-bar progress-bar--custom" 
  data-value="75" 
  data-max="100"
  data-type="circular"
  style="--progress-color: var(--color-success); --track-color: var(--color-neutral-200);"
  phx-hook="ProgressBar">
</div>
```markdown

### Stepped Progress for Multi-step Processes

```html
<div 
  id="onboarding-progress" 
  class="progress-bar" 
  data-value="2" 
  data-max="5"
  data-type="stepped"
  data-steps="5"
  data-show-text="false"
  phx-hook="ProgressBar">
</div>
```markdown 

## References

- [Project Documentation](../README.md)
