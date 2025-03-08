# Hydepwns Monospace Web for LiveView

A clean, typography-focused design system for Phoenix LiveView applications, inspired by [The Monospace Web](https://github.com/owickstrom/the-monospace-web) project.

![Monospace Web Screenshot](https://github.com/owickstrom/the-monospace-web/raw/main/screenshot.png)

## Features

- **Character-based grid layout** - All elements align to a monospace character grid
- **Monaspace Argon typography** - Beautiful monospace typography with JetBrains Mono fallback
- **Grid-based animations** - Animations that respect the character grid
- **Theme support** - Light, dark, and dim themes with easy customization
- **LiveView integration** - Fully integrated with Phoenix LiveView
- **Debug grid** - Visualize the character grid during development
- **Comprehensive style guide** - Complete documentation of all components

## Quick Start

1. Clone the repository
2. Install dependencies with `mix deps.get`
3. Install Node.js dependencies with `cd assets && npm install && cd ..`
4. Start the Phoenix server with `mix phx.server`
5. Visit [localhost:4000](http://localhost:4000) to see the monospace web in action
6. Check out the style guide at [localhost:4000/style-guide](http://localhost:4000/style-guide)

## Documentation

This project includes comprehensive documentation:

- [LiveView Integration Guide](LIVEVIEW.md) - How to use the monospace web with LiveView
- [Monospace Styling Guide](MONOSPACE_GUIDE.md) - Detailed guide to monospace web principles
- [Repository PRD](REPOSITORY_PRD.md) - Project requirements and specifications

## Grid-Based Animations

The project includes several animations that respect the character grid:

- **Typewriter** - Text appears one character at a time
- **Character Fade-in** - Each character fades in separately
- **Grid Slide-in** - Content slides in using character-width steps
- **Cursor Blink** - A classic terminal cursor
- **ASCII Spinner** - A loading indicator made with ASCII characters
- **Border Draw** - Animated border that follows the character grid
- **Grid Fade** - Page transition that reveals content line by line

## Components

The monospace web includes styled components for:

- Typography (headings, paragraphs, etc.)
- Navigation
- Tables
- Grids
- Forms
- Code blocks
- Details/summary
- and more...

All components are designed to maintain the character grid alignment.

## Customization

The design system uses CSS variables for easy customization:

```css
:root {
  --font-family: 'Monaspace Argon', 'JetBrains Mono', monospace;
  --line-height: 1.20rem;
  --border-thickness: 2px;
  --text-color: #000;
  --text-color-alt: #666;
  --background-color: #fff;
  --background-color-alt: #eee;
  /* ... other variables ... */
}
```

You can customize colors, spacing, and other properties by modifying these variables.

## Creating Custom Components

When creating custom components:

1. Use character-based measurements (`ch` units and line-height multiples)
2. Test with the debug grid to ensure alignment
3. Follow the monospace principles outlined in the [Monospace Styling Guide](MONOSPACE_GUIDE.md)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

- Original concept: [The Monospace Web](https://github.com/owickstrom/the-monospace-web) by Oskar Wickström
- Fonts: [Monaspace](https://github.com/githubnext/monaspace) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- Web framework: [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)

## License

This project is licensed under the MIT License - see the LICENSE file for details. 