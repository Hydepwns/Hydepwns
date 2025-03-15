---
title: Documentation Map
description: Complete map of the documentation structure and organization
last_updated: 2024-04-20
---

# Documentation Map

This document provides a complete map of the documentation structure and organization.

## Directory Structure

```
docs/
├── development/           # Development documentation
│   ├── components/       # Component system documentation
│   ├── contributing/     # Contribution guidelines
│   ├── testing/         # Testing documentation
│   └── tools/           # Development tools
│       └── documentation-validation.md  # Documentation validation config
├── design/               # Design system documentation
│   ├── principles.md    # Design principles
│   ├── style-guide.md   # Visual style guide
│   ├── ui-components/   # UI component design docs
│   └── accessibility/   # Accessibility guidelines
├── guides/               # User and developer guides
│   ├── getting-started/ # Getting started guides
│   └── user-guides/     # End-user documentation
├── reference/            # Reference documentation
│   ├── api/             # API documentation
│   ├── architecture/    # Architecture documentation
│   ├── data-models/     # Data model documentation
│   ├── navigation/      # Documentation navigation
│   │   ├── documentation-map.md    # This file
│   │   └── table-of-contents.md    # Table of contents
│   └── search/          # Search functionality
│       ├── search_index.json       # Search index
│       ├── topics.json            # Topics metadata
│       └── topics.md              # Topics documentation
├── project/             # Project management
│   ├── documentation/   # Documentation about docs
│   ├── planning/        # Project planning docs
│   ├── roadmap.md      # Project roadmap
│   └── migration-notice.md  # Documentation migration notice
├── security/            # Security documentation
├── archive/             # Archived documentation
└── test/                # Documentation tests
```

## Key Documents

### Root Level
- [README.md](../../README.md) - Project overview
- [LICENSE.md](../../LICENSE.md) - License information

### Design
- [Style Guide](../../design/style-guide.md) - Documentation style guide
- [Design Principles](../../design/principles.md) - Design system principles

### Development
- [Documentation Validation](../../development/tools/documentation-validation.md) - Documentation validation configuration
- [Component Migration Guide](../../development/components/migration-guide.md)
- [Contributing Guide](../../development/contributing/contributing-guide.md)
- [Testing Guide](../../development/testing/testing-guide.md)

### Reference
- [Table of Contents](../../reference/navigation/table-of-contents.md) - Complete documentation index
- [API Overview](../../reference/api/overview.md)
- [Architecture Overview](../../reference/architecture/overview.md)
- [Data Models](../../reference/data-models/index.md)

### Project Management
- [Project Roadmap](../../project/roadmap.md)
- [Migration Notice](../../project/migration-notice.md)
- [Migration Plan](../../project/planning/migration-plan.md)

## Recent Changes

The documentation has undergone significant reorganization (April 2024):
1. Moved style guide to design/style-guide.md
2. Created dedicated search directory under reference/
3. Consolidated navigation files under reference/navigation/
4. Moved documentation validation to development/tools/
5. Updated all cross-references to use relative paths

## Navigation Tips

1. Use the directory structure above to locate documentation
2. Check migration-notice.md in the project directory for recently moved content
3. Use the search functionality in reference/search/
4. Check the table of contents for a complete index

## Contributing

See the [Contributing Guide](../../development/contributing/contributing-guide.md) for:
- Documentation standards
- Writing guidelines
- Review process
- Templates

## Questions and Support

If you can't find what you're looking for:
1. Use the search functionality in reference/search/
2. Check the table of contents
3. Review the migration notice
4. Check the archive
5. Raise an issue in the documentation repository
