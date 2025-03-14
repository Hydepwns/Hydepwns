---
title: Documentation Style Guide
description: '## Overview'
topics:
  - documentation-style-guide
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - general-principles
  - document-structure
  - formatting-guidelines
  - content-guidelines
  - validation
  - review-process
  - additional-resources
  - references
  - code-examples
  - testing
  - development
last_updated: '2025-03-14'
---
# Documentation Style Guide

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document outlines the standards and best practices for creating and maintaining documentation in the Hydepwns project. Following these guidelines ensures consistency and quality across all documentation.

This style guide provides rules and best practices for creating and maintaining documentation in this project. Following these guidelines ensures consistency across all documentation and makes it easier for developers and users to understand our content.

## General Principles

- **Clarity First**: Write for clarity above all. Use simple, direct language.
- **Consistency**: Maintain consistent terminology, formatting, and structure.
- **Completeness**: Cover all necessary aspects of the topic without unnecessary details.
- **Accuracy**: Ensure all information is correct and up-to-date.

## Document Structure

### Required Sections

Every documentation file should include:

1. **Title**: Each document must start with a level 1 heading (`# Title`).
2. **Overview**: A brief introduction explaining the document's purpose.
3. **Body Content**: The main content organized into logical sections.
4. **References**: Links to related documentation or external resources (if applicable).

### Heading Structure

- Start with a single `# Heading` as the document title
- Use proper heading hierarchy: H1 → H2 → H3 → H4
- Never skip heading levels (e.g., H1 → H3)
- Keep headings concise and descriptive
- Use sentence case for headings (capitalize first word and proper nouns only)

## Formatting Guidelines

### Code Blocks

- Always specify the language for syntax highlighting
```javascript
// JavaScript example
function example() {
  return true;
}
```text
- For console output, use `console` or `shell`
```shell
$ npm run build
```

### Links

- Use descriptive link text that makes sense out of context
- For internal links, use relative paths
- All links must be valid and working
- Verify links with `npm run validate:docs`

### Lists

- Use unordered lists (`-`) for items without sequence
- Use ordered lists (`1.`) for sequential steps
- Maintain consistent capitalization and punctuation within lists
- Use parallel structure for list items

## Content Guidelines

### Language

- Use present tense ("This command installs the package" not "This command will install")
- Use active voice when possible
- Be concise but complete
- Define abbreviations and acronyms on first use

### Code Examples

- Keep examples simple and focused
- Include comments for complex parts
- Ensure all examples are tested and working
- For longer examples, explain what each part does

## Validation

All documentation should pass validation using:

```shell
npm run validate:docs
```

This validation checks for:
- Missing sections (title, overview, references)
- Heading structure issues
- Broken links
- Code blocks without language specification

## Review Process

Documentation changes require:
1. Self-review against this style guide
2. Passing automated validation checks in CI
3. At least one review from the documentation team

## Additional Resources

- [GitHub Markdown Guide](https://guides.github.com/features/mastering-markdown/)
- [Documentation Process](./development/DOCUMENTATION_PROCESS.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->

## References

- [Project Documentation](../README.md)
- [Documentation Map](DOCUMENTATION_MAP.md)
- [Documentation Process](project/documentation/process.md)
