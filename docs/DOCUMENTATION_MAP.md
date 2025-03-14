---
title: Documentation Map
description: Complete map of the documentation structure and organization
last_updated: 2025-03-14
---

# Documentation Map

This document provides a complete map of the documentation structure and organization.

## Directory Structure

```
docs/
├── development/           # Development documentation
│   ├── components/       # Component system documentation
│   ├── contributing/     # Contribution guidelines
│   ├── design/          # Design system documentation
│   ├── integration/     # Integration guides
│   ├── performance/     # Performance optimization
│   ├── testing/         # Testing documentation
│   └── tools/           # Development tools
├── guides/               # User and developer guides
│   ├── getting-started/ # Getting started guides
│   └── user-guides/     # End-user documentation
├── reference/            # Reference documentation
│   ├── api/             # API documentation
│   ├── architecture/    # Architecture documentation
│   └── data-models/     # Data model documentation
├── project/             # Project management
│   ├── documentation/   # Documentation about docs
│   └── planning/        # Project planning docs
├── archive/             # Archived documentation
│   └── 2025-03-14/     # March 2025 archive
└── test/                # Documentation tests
```

## Key Documents

### Root Level
- [README.md](./README.md) - Project overview
- [STYLE_GUIDE.md](./STYLE_GUIDE.md) - Documentation style guide
- [MIGRATION_NOTICE.md](./MIGRATION_NOTICE.md) - Recent documentation moves

### Development
- [Component Migration Guide](development/components/migration-guide.md)
- [Contributing Guide](development/contributing/contributing-guide.md)
- [Testing Guide](development/testing/testing-guide.md)

### Guides
- [Getting Started](guides/getting-started/index.md)
- [Installation Guide](guides/getting-started/installation.md)
- [User Guides](guides/user-guides/index.md)

### Reference
- [API Overview](reference/api/overview.md)
- [Architecture Overview](reference/architecture/overview.md)
- [Data Models](reference/data-models/index.md)

### Project Management
- [Documentation Process](project/documentation/process.md)
- [Project Roadmap](project/roadmap.md)
- [Migration Plan](project/planning/migration-plan.md)

### Archive
- [Archive Notice](archive/README.md)
- [March 2025 Archive](archive/2025-03-14/ARCHIVE_NOTICE.md)

## Recent Changes

The documentation has undergone significant reorganization:
1. Consolidated PRD structure into a more intuitive organization
2. Moved planning and process documentation to project/
3. Consolidated component documentation under development/
4. Created an archive for deprecated content

## Navigation Tips

1. Use the directory structure above to locate documentation
2. Check MIGRATION_NOTICE.md for recently moved content
3. Search functionality is available in the documentation portal
4. Archived content is in the archive/ directory

## Contributing

See the [Contributing Guide](development/contributing/contributing-guide.md) for:
- Documentation standards
- Writing guidelines
- Review process
- Templates

## Questions and Support

If you can't find what you're looking for:
1. Check the search functionality
2. Review the MIGRATION_NOTICE.md
3. Check the archive
4. Raise an issue in the documentation repository
