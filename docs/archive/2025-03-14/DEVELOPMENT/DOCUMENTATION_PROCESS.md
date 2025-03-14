---
title: ⚠️ DOCUMENTATION MOVED ⚠️
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - '-documentation-moved-'
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - new-location
  - automatic-redirect
  - documentation-update-process
  - documentation-structure
  - documentation-update-workflow
  - documentation-standards
  - pr-checklist-for-documentation-changes
  - automated-documentation-maintenance
  - generate-and-update-documentation-indexes
  - validate-documentation-formatting-and-structure
  - check-documentation-migration-status
  - documentation-review-process
  - documentation-update-schedule
  - legacy-documentation-migration
  - references
  - documentation-development-workflow
  - pull-request-process
  - review-criteria
  - validation-requirements
  - continuous-improvement
  - roles-and-responsibilities
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# ⚠️ DOCUMENTATION MOVED ⚠️

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

# ⚠️ DOCUMENTATION MOVED ⚠️


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about DOCUMENTATION PROCESS.


This document has been migrated to a new location as part of our documentation restructuring.

## New Location

**Please visit the new document location**: [project/documentation/process.md](../../project/documentation/process.md)

## Automatic Redirect

You will be automatically redirected to the new location in 5 seconds.

<meta http-equiv="refresh" content="5;url=../../project/documentation/process.md" />

---

# Documentation Update Process

This document outlines the process for updating, maintaining, and reviewing documentation in the Hydepwns project.

## Documentation Structure

The Hydepwns documentation is organized in a PRD (Product Requirements Document) structure:

```markdown
docs/
├── PRD/                    # Main documentation directory
│   ├── ARCHITECTURE/       # System architecture documentation
│   ├── DESIGN/             # Design principles and guidelines
│   ├── DEVELOPMENT/        # Development guides and processes
│   ├── DEPLOYMENT/         # Deployment and operations documentation
│   ├── FEATURES/           # Feature-specific documentation
│   └── PROJECT_MANAGEMENT/ # Project management documents (roadmap, etc.)
├── DOCUMENTATION_MAP.md    # Map of documentation locations
└── README.md               # Documentation overview
```markdown

## Documentation Update Workflow

Follow these steps when updating or adding documentation:

1. **Identify the Appropriate Location**
   - Use the `DOCUMENTATION_MAP.md` to find where existing documentation lives
   - For new documentation, choose the appropriate subdirectory in the PRD structure
   - Related documentation should be grouped together

2. **Create or Update Documentation**
   - Use markdown format with consistent styling
   - Follow the templates provided in `docs/DOCUMENTATION_META_TEMPLATE.md`
   - Include all required sections (Purpose, Audience, Content)
   - Use header hierarchy consistently (# for title, ## for major sections)

3. **Include Required Elements**
   - Title and description at the top
   - Table of contents for longer documents
   - Appropriate cross-references to related documentation
   - Code examples where relevant
   - Diagrams or images for complex concepts

4. **Validate Documentation**
   - Run `node scripts/docs/validate_documentation.js` to check for issues
   - Run `node scripts/docs/generate_index.js` to update indexes and check links
   - Fix any issues reported by the validation scripts

5. **Update Documentation Indexes**
   - Ensure new documentation is referenced in `DOCUMENTATION_MAP.md`
   - Add entry to relevant index files in subdirectories
   - Update the main `docs/PRD/README.md` if adding a major document

6. **Submit for Review**
   - Create a PR with your documentation changes
   - Complete the documentation section in the PR template
   - Request review from team members with domain expertise

## Documentation Standards

All documentation should follow these standards:

### Formatting

- Use consistent markdown formatting throughout
- Break lines at 100 characters for better readability in raw form
- Use code blocks with language specification (```elixir)
- Use tables for structured data
- Use bulleted or numbered lists for sequences and options

### Structure

- Start with a clear title and brief description
- Include a table of contents for documents longer than 200 lines
- Group related information under clear headings
- Use a consistent header hierarchy
- End with relevant references or "see also" sections

### Content

- Write in clear, concise language
- Target the appropriate technical level for the intended audience
- Include examples where helpful
- Document both "how" and "why"
- Update date stamps when making significant changes

## PR Checklist for Documentation Changes

Before submitting a PR that includes documentation changes, ensure:

- [ ] Documentation follows the project's structure and templates
- [ ] All internal links are valid
- [ ] Code examples are correct and tested
- [ ] No spelling or grammar errors
- [ ] Documentation indexes are updated
- [ ] `node scripts/docs/generate_index.js` has been run
- [ ] `node scripts/docs/validate_documentation.js` passes
- [ ] Documentation accurately reflects the current state of the code
- [ ] Added appropriate tags/categories to the documentation

## Automated Documentation Maintenance

The project uses several scripts to maintain documentation quality:

- **generate_index.js**: Updates documentation indexes and validates internal links
- **validate_documentation.js**: Checks documentation for formatting and structural issues
- **doc_migration_status.js**: Tracks progress of legacy documentation migration

Run these regularly and before submitting PRs with documentation changes:

```bash
# Generate and update documentation indexes
node scripts/docs/generate_index.js

# Validate documentation formatting and structure
node scripts/docs/validate_documentation.js

# Check documentation migration status
node scripts/docs/doc_migration_status.js
```markdown

## Documentation Review Process

Documentation changes follow this review process:

1. **Initial Review**: Technical accuracy and completeness
2. **Structural Review**: Organization, cross-references, and adherence to templates
3. **Language Review**: Clarity, conciseness, and correctness
4. **Final Verification**: Ensuring all validation scripts pass

At least one reviewer with domain expertise must approve documentation changes before merging.

## Documentation Update Schedule

- **Feature Documentation**: Updated with feature implementation
- **Architecture Documentation**: Updated when architectural changes occur
- **Process Documentation**: Reviewed quarterly and updated as needed
- **General Guide**: Refreshed monthly with recent changes and improvements

## Legacy Documentation Migration

The project is in the process of migrating legacy documentation to the PRD structure:

1. Identify legacy documentation to migrate
2. Create new file in appropriate PRD subdirectory
3. Update content to match current templates and standards
4. Add to documentation map and indexes
5. Create PR to add new file and deprecate old location
6. Update references to point to new location

Track migration progress using `node scripts/docs/doc_migration_status.js`. 

## References

- [Project Documentation](../README.md)

# Documentation Review Process

## Overview

This document outlines the process for creating, updating, and reviewing documentation in our project. Following this process ensures that all documentation meets our quality standards and remains consistent across the project.

## Documentation Development Workflow

### Creating New Documentation

1. **Plan**: Determine the purpose, audience, and scope of the documentation.
2. **Structure**: Plan the document structure according to the [Style Guide](../../STYLE_GUIDE.md).
3. **Draft**: Write the initial draft following style guidelines.
4. **Validate**: Run `npm run validate:docs` to check for issues.
5. **Review**: Submit for peer review before creating a PR.

### Updating Existing Documentation

1. **Identify**: Determine which documents need updates and why.
2. **Review Current**: Read and understand the existing documentation.
3. **Update**: Make necessary changes while maintaining consistency.
4. **Validate**: Run `npm run validate:docs` to check for issues.
5. **Review**: Submit for peer review before creating a PR.

## Pull Request Process

When submitting documentation changes:

1. **PR Description**: Clearly describe the purpose and scope of documentation changes.
2. **Validation**: Ensure all documentation passes validation (`npm run validate:docs`).
3. **Checklist**: Complete the documentation checklist in the PR template.
4. **Review**: Request review from at least one documentation maintainer.

## Review Criteria

Reviewers should evaluate documentation based on:

1. **Technical Accuracy**: Information must be correct and up-to-date.
2. **Completeness**: Documentation should cover all necessary aspects.
3. **Clarity**: Content should be clear and understandable for the target audience.
4. **Structure**: Document should follow the project's documentation structure.
5. **Style**: Writing should adhere to the [Style Guide](../../STYLE_GUIDE.md).
6. **Validation**: Documentation must pass automated validation.

## Validation Requirements

All documentation must pass the following validation checks:

1. **Heading Structure**: Proper hierarchy without skipping levels.
2. **Required Sections**: Each document must have title, overview, and content.
3. **Link Validation**: All links must be functional.
4. **Code Blocks**: All code blocks must specify a language.

## Continuous Improvement

The documentation process includes:

1. **Regular Audits**: Scheduled weekly validation checks.
2. **Feedback Collection**: Gathering user feedback on documentation.
3. **Updates**: Continuous improvement based on feedback and project changes.

## Roles and Responsibilities

### Documentation Contributors
- Follow the documentation style guide
- Run validation before submitting changes
- Address review feedback

### Documentation Reviewers
- Provide timely, constructive feedback
- Verify validation results
- Ensure documentation meets quality standards

### Documentation Maintainers
- Update style guides and templates as needed
- Monitor validation results
- Address systematic documentation issues

## References

- [Documentation Style Guide](../../STYLE_GUIDE.md)
- [GitHub Markdown Guide](https://guides.github.com/features/mastering-markdown/)
