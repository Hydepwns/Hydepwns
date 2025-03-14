---
title: ASCII Art Components
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - features
  - ascii-art-components
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - key-features
  - component-types
  - styling-and-customization
  - accessibility-considerations
  - creating-custom-ascii-art
  - integration-with-grid-system
  - handle-selection-in-your-liveview
  - future-enhancements
  - conclusion
  - references
  - code-examples
last_updated: '2025-03-14'
---
# ASCII Art Components

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

# ASCII Art Components


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

The Hydepwns monospace design system includes a suite of ASCII art components that leverage the precise character alignment of monospace fonts to create visually appealing and functional diagrams, charts, and decorative elements using only text characters.

This documentation covers how to use the various ASCII art components included in the style guide, customization options, and best practices for creating your own ASCII art elements.

## Key Features

- Character-perfect alignment in monospace grids
- Synthwave-inspired color palette integration
- Responsive design that maintains proportions
- Accessibility considerations for screen readers
- Component-based implementation for easy reuse

## Component Types

### Simple Boxes

Box components use box-drawing Unicode characters to create containers for content. These are useful for highlighting important information, creating panels, or visually separating content.

#### Rounded Box Example

```elixir
def render_box_title(assigns) do
  ~H"""
  <pre class="ascii-box" style="color: #9D53F2;">
╭─────────────────────────╮
│ HYDEPWNS MONOSPACE GRID │
╰─────────────────────────╯
  </pre>
  """
end
```markdown

#### Structured Box Example

```elixir
def render_documentation_box(assigns) do
  ~H"""
  <pre class="ascii-box" style="color: #FF2E97;">
┌───────────────────────────────┐
│ SYNTHWAVE STYLE DOCUMENTATION │
├───────────────────────────────┤
│ • Clean monospace typography  │
│ • Neon color accents          │
│ • Grid-based layouts          │
│ • ASCII art visualizations    │
└───────────────────────────────┘
  </pre>
  """
end
```markdown

### Flow Diagrams

Flow diagrams are perfect for visualizing processes, data flows, and relationships between components. The fixed-width nature of monospace fonts ensures that connections align perfectly.

#### Simple Flow Example

```elixir
def render_flow_diagram(assigns) do
  ~H"""
  <pre class="ascii-diagram" style="color: #19DCFF;">
┌───────┐     ┌───────┐     ┌───────┐
│ Input  │     │Process │     │ Output │
│ Data   │ ──► │ Logic  │ ──► │ Display│
└───────┘     └───────┘     └───────┘
  </pre>
  """
end
```markdown

#### Sequence Diagram Example

```elixir
def render_sequence_diagram(assigns) do
  ~H"""
  <pre class="ascii-diagram" style="color: #36F9F6;">
┌───────┐ ┌───────┐ ┌───────┐
│User    │ │Server  │ │Database│
└───┬───┘ └───┬───┘ └───┬───┘
    │         │         │    
    │ Request │         │    
    │────────►│         │    
    │         │  Query  │    
    │         │────────►│    
    │         │ Results │    
    │         │◄────────│    
    │Response │         │    
    │◄────────│         │    
┌───┴───┐ ┌───┴───┐ ┌───┴───┐
│User    │ │Server  │ │Database│
└───────┘ └───────┘ └───────┘
  </pre>
  """
end
```markdown

### Charts and Graphs

ASCII charts are useful for displaying data in a visually appealing way while maintaining the monospace aesthetic. They're particularly useful for terminal-like interfaces or when you want to maintain a consistent text-based theme.

#### Bar Chart Example

```elixir
def render_bar_chart(assigns) do
  ~H"""
  <pre class="ascii-chart" style="color: #FFD319;">
                  Performance Metrics                
                                              
    │                                              
100 │    █                                    
    │    █                                    
    │    █         █                          
 80 │    █         █                          
    │    █         █                          
    │    █         █         █               
 60 │    █         █         █                
    │    █         █         █         █      
    │    █         █         █         █      
 40 │    █         █         █         █      
    │    █         █         █         █      
    │    █         █         █         █      
 20 │    █         █         █         █      
    │    █         █         █         █      
    │    █         █         █         █      
  0 └────▀─────────▀─────────▀─────────▀──────
       Alpha      Beta     Gamma     Delta   
  </pre>
  """
end
```markdown

### Decorative Headers

ASCII art headers provide visual impact while maintaining the text-based nature of monospace interfaces. We offer several styles with synthwave-inspired effects.

#### Neon Glow Header

```elixir
def render_synthwave_header(assigns) do
  ~H"""
  <pre class="ascii-header" style="color: #FF2E97; text-shadow: 0 0 5px #FF2E97, 0 0 10px #FF2E97;">
 _   _           _                             
| | | |_  _  __| |___ _ ____      ___ _  ___ 
| |_| | || |/ _` / -_) '_ \ \ /\ / / ' \/ -_)
 \___/ \_,_|\__,_\___|  __/\ V  V /|_||_\___|
                      |_|    \_/\_/           
  </pre>
  """
end
```markdown

#### Gradient Text Header

```elixir
def render_gradient_header(assigns) do
  ~H"""
  <pre class="ascii-header" style="background: linear-gradient(to right, #9D53F2, #FF2E97, #19DCFF, #FFD319); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-weight: bold;">
███╗   ███╗ ██████╗ ███╗   ██╗ ██████╗ ███████╗██████╗  █████╗  ██████╗███████╗
████╗ ████║██╔═══██╗████╗  ██║██╔═══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║███████╗██████╔╝███████║██║     █████╗  
██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝  
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║╚██████╔╝███████║██║     ██║  ██║╚██████╗███████╗
  </pre>
  """
end
```markdown

## Styling and Customization

### Color Palette Integration

Our ASCII art components use the Hydepwns synthwave color palette to create visual hierarchy and aesthetic appeal:

- **Primary Purple (#9D53F2)**: Used for primary elements and focus states
- **Neon Pink (#FF2E97)**: For highlighting and attention-grabbing elements
- **Electric Cyan (#19DCFF)**: For information and process flows
- **Neon Yellow (#FFD319)**: For warnings and charts
- **Synthwave Teal (#36F9F6)**: For secondary elements and multi-selections

### CSS Effects

Several CSS effects can enhance ASCII art:

1. **Text Shadow**: Creates a neon glow effect

   ```css
   text-shadow: 0 0 5px #FF2E97, 0 0 10px #FF2E97;
   ```markdown

2. **Gradient Text**: Creates a synthwave gradient across text

   ```css
   background: linear-gradient(to right, #9D53F2, #FF2E97, #19DCFF, #FFD319);
   -webkit-background-clip: text;
   -webkit-text-fill-color: transparent;
   ```markdown

3. **Animation**: Subtle pulsing or color shifts

   ```css
   @keyframes neon-pulse {
     0%, 100% { text-shadow: 0 0 5px #FF2E97, 0 0 10px #FF2E97; }
     50% { text-shadow: 0 0 10px #FF2E97, 0 0 20px #FF2E97; }
   }
   ```markdown

## Accessibility Considerations

ASCII art can present challenges for screen readers and users with visual impairments. Here are best practices:

1. **Always include alt text**:

   ```elixir
   <pre class="ascii-box" aria-label="Decorative box containing documentation highlights">
   ```markdown

2. **Consider hidden descriptive text**:

   ```elixir
   <span class="visually-hidden">Flowchart showing data flow from input to processing to output</span>
   ```markdown

3. **Progressive enhancement**:

   ```elixir
   # Provide alternative representations when possible
   if @accessible_mode do
     render_accessible_chart(assigns)
   else
     render_ascii_chart(assigns)
   end
   ```markdown

## Creating Custom ASCII Art

### Useful Tools

- [Asciiflow](https://asciiflow.com/): Interactive ASCII diagram editor
- [Text to ASCII Art Generator](https://patorjk.com/software/taag/): For creating text headers
- [Figlet](http://www.figlet.org/): Command-line ASCII art generation

### Best Practices

1. **Maintain alignment**: Ensure all characters align to the monospace grid
2. **Keep it simple**: Less complex designs translate better to ASCII
3. **Test responsiveness**: Ensure diagrams don't break at different viewport sizes
4. **Document character sets**: Note which Unicode box-drawing characters you're using
5. **Consider fallbacks**: Have alternatives for environments that don't support certain characters

## Integration with Grid System

The ASCII art components pair perfectly with our grid selection system. You can create interactive ASCII diagrams where users can select and interact with specific parts of the diagram.

```elixir
def render_interactive_diagram(assigns) do
  ~H"""
  <div class="ascii-interactive">
    <pre class="ascii-diagram" phx-click="select_diagram_element">
      <!-- ASCII diagram here -->
    </pre>
  </div>
  """
end

# Handle selection in your LiveView
def handle_event("select_diagram_element", %{"x" => x, "y" => y}, socket) do
  # Process the coordinates and update the diagram
  {:noreply, assign(socket, selected_element: {x, y})}
end
```markdown

## Future Enhancements

The following enhancements are planned for ASCII art components:

1. **Animation framework**: For creating dynamic ASCII animations
2. **Interactive components**: Clickable ASCII diagrams with state
3. **Theme adaptation**: Automatic color adjustments based on light/dark mode
4. **Template library**: Common diagram patterns for quick implementation

## Conclusion

ASCII art components provide a unique and visually consistent way to represent information while maintaining the monospace aesthetic of the Hydepwns design system. By leveraging the pixel-perfect alignment of monospace fonts and the vibrant synthwave color palette, these components offer both functional and aesthetic value to your applications.

For further assistance or to contribute new ASCII art components, please see our [CONTRIBUTING.md](../DEVELOPMENT/CONTRIBUTING.md) guide.


## References

- [Project Documentation](../README.md)
