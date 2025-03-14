---
title: Hydepwns Animation Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - features
  - hydepwns-animation-guide
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - available-animations
  - how-to-use-the-animations
  - animation-controls
  - implementation-in-liveview-templates
  - animation-speed-controls
  - css-requirements
  - accessibility-considerations
  - example-implementation
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Hydepwns Animation Guide

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

# Hydepwns Animation Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about ANIMATIONS.


This guide explains how to use the animation components that are already implemented in the codebase but need to be reintegrated.

## Available Animations

The codebase currently has two main animation types:

1. **Character Animations** - Text-based animations like typewriter effect and character fade-in
2. **Grid Animations** - Grid-based animations like grid fade-in

## How to Use the Animations

### Character Animations

#### Typewriter Effect

The typewriter effect types characters one by one with a cursor blink.

```html
<p phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="50">
  This text will be typed out character by character.
</p>
```markdown

Options:
- `data-typing-speed`: Controls typing speed (in milliseconds per character)
- `data-delay`: Initial delay before typing starts (in milliseconds)

#### Character Fade-In Effect

The character fade-in effect fades in each character with a slight delay between characters.

```html
<p phx-hook="CharacterAnimation" class="char-fade">
  Each character in this text will fade in one by one.
</p>
```markdown

Options:
- `data-fade-delay`: Controls the delay between characters (in milliseconds)

### Grid Animations

#### Grid Fade-In Effect

The grid fade-in effect reveals content line by line, creating a grid animation.

```html
<div phx-hook="GridFadeIn" class="grid-fade-in">
  <p>This entire grid section will fade in line by line.</p>
  <p>Multiple paragraphs can be included.</p>
</div>
```markdown

Options:
- `data-line-delay`: Controls the delay between lines (in milliseconds)

## Animation Controls

All animations support keyboard controls:
- `Alt+R`: Replay the animation

## Implementation in LiveView Templates

### Example in a LiveView Template

```elixir
def render(assigns) do
  ~H"""
  <div class="container">
    <h1 phx-hook="CharacterAnimation" class="typewriter">
      Welcome to Hydepwns
    </h1>
    
    <div phx-hook="GridFadeIn" class="grid-fade-in">
      <p>This is a monospace-styled website with neat animations.</p>
      <p phx-hook="CharacterAnimation" class="char-fade">
        Each character in this text will fade in one by one.
      </p>
    </div>
  </div>
  """
end
```markdown

## Animation Speed Controls

To implement animation speed controls, add the following to your LiveView:

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, :animation_speed_class, "normal-speed")}
end

def handle_event("set_animation_speed", %{"speed" => speed}, socket) do
  speed_class =
    case speed do
      "slow" -> "slow-speed"
      "normal" -> "normal-speed"
      "fast" -> "fast-speed"
      _ -> "normal-speed"
    end

  {:noreply, assign(socket, :animation_speed_class, speed_class)}
end
```markdown

Then in your HTML, add both the speed class and animation classes:

```html
<div class={@animation_speed_class}>
  <p phx-hook="CharacterAnimation" class="typewriter">
    This animation speed will be controlled by the buttons.
  </p>
</div>

<div class="animation-controls">
  <button phx-click="set_animation_speed" phx-value-speed="slow">Slow</button>
  <button phx-click="set_animation_speed" phx-value-speed="normal">Normal</button>
  <button phx-click="set_animation_speed" phx-value-speed="fast">Fast</button>
</div>
```markdown

## CSS Requirements

Make sure your CSS file includes the necessary animation definitions:

```css
/* Animation speed controls */
.slow-speed .typewriter {
  animation-duration: 5s;
}

.normal-speed .typewriter {
  animation-duration: 3.5s;
}

.fast-speed .typewriter {
  animation-duration: 2s;
}

/* Similar for other animation types */
```markdown

## Accessibility Considerations

1. All animations respect the user's `prefers-reduced-motion` setting
2. Animation controls are keyboard accessible
3. Animation states are announced to screen readers

## Example Implementation

Let's update the home page to showcase these animations properly:

1. Edit the home_live.ex file
2. Add examples of each animation type
3. Include animation controls
4. Ensure accessibility features are enabled 

## References

- [Project Documentation](../README.md)
