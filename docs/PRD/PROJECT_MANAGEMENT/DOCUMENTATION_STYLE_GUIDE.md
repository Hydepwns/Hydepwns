# Documentation Style Guide

This guide establishes standards for creating and maintaining documentation across the Hydepwns project. Following these guidelines ensures our documentation is consistent, accessible, and easy to navigate.

## Table of Contents

- [Document Structure](#document-structure)
- [Formatting](#formatting)
- [Code Examples](#code-examples)
- [Links and References](#links-and-references)
- [Images and Diagrams](#images-and-diagrams)
- [Accessibility Considerations](#accessibility-considerations)
- [Version Control](#version-control)
- [Documentation Review Process](#documentation-review-process)

## Document Structure

### Basic Structure

All documentation files should follow this basic structure:

1. **Title**: The document title as a level-1 heading (`# Title`)
2. **Overview/Introduction**: A brief introduction to the content
3. **Table of Contents**: For longer documents (>500 lines)
4. **Main Content**: Organized in logical sections with hierarchical headings
5. **References**: Links to related documentation (when applicable)
6. **Changelog/Version History**: For documents that undergo significant changes

### Heading Hierarchy

Use proper heading hierarchy to organize content:

```markdown
# Document Title (H1)

## Major Section (H2)

### Subsection (H3)

#### Minor subsection (H4)
```

Limit heading nesting to 4 levels and ensure the hierarchy is not skipped (e.g., don't jump from H2 to H4).

## Formatting

### Text Formatting

- Use **bold** (`**text**`) for emphasis
- Use *italics* (`*text*`) for terminology or secondary emphasis
- Use `code formatting` (`` `code` ``) for:
  - Code snippets
  - File names
  - Command-line input/output
  - Function or variable names

### Lists

Use ordered lists for sequential steps:

```markdown
1. First step
2. Second step
3. Third step
```

Use unordered lists for non-sequential items:

```markdown
- Item one
- Item two
- Item three
```

### Tables

Format tables with proper column headers:

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |
```

## Code Examples

### Code Blocks

Use fenced code blocks with language specification:

````markdown
```elixir
def example_function(arg) do
  String.upcase(arg)
end
```
````

### Inline Code

For inline code references, use backticks:

```markdown
The `example_function/1` takes a string argument.
```

### Code Comments

Include comments in code examples to explain complex parts:

```markdown
```elixir
# This function transforms input to uppercase
def example_function(arg) do
  String.upcase(arg)  # Convert to uppercase
end
```
```

## Links and References

### Internal Links

For links to other documentation files, use relative paths:

```markdown
See the [Contributing Guide](../DEVELOPMENT/CONTRIBUTING.md) for more information.
```

- Use relative paths starting from the current file's location
- Ensure links are working by testing them after changes

### External Links

For external references, include the full URL and a descriptive link text:

```markdown
For more information, see the [Elixir Documentation](https://elixir-lang.org/docs.html).
```

### Section References

For linking to sections within the same document, use anchor links:

```markdown
See the [Code Examples](#code-examples) section above.
```

## Images and Diagrams

### Image Inclusion

When including images:

```markdown
![Alt text for the image](https://example.com/images/example.png)
```

- Always provide descriptive alt text
- Keep images in a consistent location (e.g., `docs/assets/images/`)
- Use relative paths

### Image Formatting

- Use PNG format for screenshots and diagrams
- Optimize images for web viewing (compressed, appropriate dimensions)
- Consider providing both light and dark mode versions for diagrams

## Accessibility Considerations

- Write descriptive link text (avoid "click here" or "more info")
- Use proper heading hierarchy
- Provide alt text for all images
- Use sufficient color contrast in diagrams
- Avoid relying solely on color to convey information
- Use tables for tabular data, not for layout

## Version Control

### Documentation Versioning

- Update the "Last Updated" date when making significant changes
- Consider adding a simple changelog at the bottom of important documents
- Use semantic versioning for API documentation

### Commit Messages

When committing documentation changes:

- Use clear, descriptive commit messages
- Prefix documentation commits with "docs:" 
- Explain what was changed and why

Example:
```
docs: Update socket validation guide with new error examples
```

## Documentation Review Process

All documentation should go through a review process:

1. **Self-review**: Check formatting, links, and content
2. **Peer review**: Have at least one other person review the document
3. **Technical accuracy review**: For technical documentation, ensure technical accuracy
4. **Readability review**: Ensure the document is clear and understandable

## Documentation Validation

We use automated tools to validate documentation:

- Link checkers to detect broken links
- Markdown linters for consistent formatting
- Spelling and grammar checkers

## Examples of Good Documentation

Here's an example of well-formatted documentation:

```markdown
# Feature Name

## Overview

Brief description of the feature and its purpose.

## Usage

### Basic Usage

```elixir
Feature.example("input")
```

### Advanced Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `:mode` | atom | `:normal` | Operation mode |
| `:timeout` | integer | 5000 | Timeout in milliseconds |

## Best Practices

- Always validate input
- Handle errors appropriately
- Consider performance implications
``` 