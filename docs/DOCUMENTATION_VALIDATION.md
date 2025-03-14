---
title: Documentation Validation Guide
description: '## Overview'
topics:
  - documentation-validation-guide
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - documentation-standards
  - how-to-validate-documentation
  - recommended-workflow
  - adding-documentation-validation-to-ci
  - example-github-actions-workflow-step
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Documentation Validation Guide

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

This document provides information about the documentation validation system and how to ensure your Markdown files meet our quality standards.

## Documentation Standards

All Markdown files in the `docs/` directory must meet these requirements:

1. **Required Sections**:
   - All documentation files must have an `# Title` (H1 heading)
   - All documentation files must have an `## Overview` section
   - All documentation files must have a `## References` section

2. **Code Blocks**:
   - All code blocks must specify a language (e.g., ```javascript instead of just ```markdown)
   - Supported languages: markdown, javascript, typescript, elixir, json, css, html, shell, bash

3. **Heading Structure**:
   - Headings must follow a hierarchical structure
   - Never skip heading levels (e.g., don't go from H1 to H3 without an H2 in between)

4. **Links**:
   - All internal links must point to existing files
   - Avoid broken links

## How to Validate Documentation

We provide tools to validate and fix documentation issues:

### Checking for Issues

Run the validation script to check for issues without making changes:

```bash
npm run validate:docs
```markdown

This will report issues such as:
- Missing sections
- Code blocks without language specification
- Heading structure issues
- Broken links

### Fixing Common Issues Automatically

To automatically fix common issues (missing sections, code block language):

```bash
npm run lint:md:fix
```markdown

This will:
1. Add missing Overview and References sections
2. Add document titles where missing
3. Add language specification to code blocks

### Fixing Issues Manually

Some issues require manual fixes:

1. **Heading Level Issues**: 
   - Identify where heading levels are skipped (H1 to H3 without H2)
   - Add intermediate headings or restructure the document

2. **Broken Links**:
   - Update links to point to existing files
   - Create missing files if needed
   - Remove or replace links that can't be fixed

## Recommended Workflow

1. Run validation to see issues: `npm run validate:docs`
2. Run auto-fix to handle common issues: `npm run lint:md:fix`
3. Manually fix remaining issues (heading structure, broken links)
4. Run validation again to confirm all issues are fixed

## Adding Documentation Validation to CI

You can add documentation validation to CI pipelines to ensure all PRs maintain documentation quality:

```yaml
# Example GitHub Actions workflow step
- name: Validate Documentation
  run: npm run validate:docs
```markdown

## References

- [Project Documentation](README.md)
- [Markdown Guide](https://www.markdownguide.org/)
- [Remark Lint](https://github.com/remarkjs/remark-lint)
