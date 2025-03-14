---
title: PRD Migration Guide
description: '## Overview'
topics:
  - archive
  - prd-migration-guide
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - references
  - related-documents
  - directory-mappings
  - file-mappings
  - how-to-find-migrated-content
  - archived-documents
  - directory-structure-reference
  - questions-and-support
  - code-examples
  - testing
  - deployment
  - architecture
  - development
last_updated: '2025-03-14'
---
# PRD Migration Guide

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## References

* No references yet


## Related Documents

* No references yet

This document provides guidance for finding content that has been migrated from the PRD directory to the new documentation structure. 

## Directory Mappings

The following directories have been migrated to new locations:

| Old Location (PRD) | New Location |
|-------------------|-------------|
| `PRD/ARCHITECTURE` | `reference/architecture` |
| `PRD/DEVELOPMENT` | `development` |
| `PRD/FEATURES` | `reference/features` |
| `PRD/PROJECT_MANAGEMENT` | `project` |
| `PRD/DEPLOYMENT` | `reference/deployment` |

## File Mappings

The following specific files have been migrated:

| Old Location | New Location | Status |
|-------------|-------------|--------|
| `PRD/ARCHITECTURE/COMPONENT_ARCHITECTURE.md` | `reference/architecture/component-architecture.md` | ✅ Migrated |
| `PRD/DEVELOPMENT/EVENT_MANAGEMENT.md` | `development/components/event-management.md` | ❌ Pending |
| `PRD/FEATURES/LIVEVIEW.md` | `reference/features/liveview.md` | ❌ Pending |
| `PRD/FEATURES/THEMES.md` | `guides/design/themes.md` | ❌ Pending |
| `PRD/GETTING_STARTED.md` | `guides/getting-started/index.md` | ✅ Migrated |
| `PRD/PROJECT_MANAGEMENT/ROADMAP.md` | `project/roadmap.md` | ✅ Migrated |
| `PRD/PROJECT_MANAGEMENT/DOCUMENTATION_MIGRATION.md` | `project/planning/documentation-migration.md` | ❌ Pending |
| `PRD/PROJECT_MANAGEMENT/DOCUMENTATION_STYLE_GUIDE.md` | `project/documentation/style-guide.md` | ❌ Pending |
| `PRD/DEPLOYMENT/DEPLOYMENT.md` | `reference/deployment/overview.md` | ❌ Pending |

## How to Find Migrated Content

1. **Check the tables above** to see if the document you're looking for has been migrated
2. **Use the search functionality** in your editor or repository to find content
3. **Look in the corresponding new directory** based on the directory mappings
4. **Check the archived copy** in the `docs/archive/PRD` directory

## Archived Documents

All PRD documents have been archived and are available in the `docs/archive/PRD` directory with their original structure preserved. These archived documents contain notices pointing to their new locations where applicable.

## Directory Structure Reference

### Old Structure

```
docs/PRD/
├── ARCHITECTURE/       # System architecture documentation
├── DEVELOPMENT/        # Development guidelines and processes
├── FEATURES/           # Feature specifications
├── PROJECT_MANAGEMENT/ # Project management documentation
└── README.md           # PRD overview
```

### New Structure

```
docs/
├── guides/             # User and developer guides
│   ├── getting-started/ # Getting started guides
│   └── design/         # Design guidelines
├── development/        # Development documentation
│   ├── components/     # Component documentation
│   ├── testing/        # Testing guides
│   └── tools/          # Development tools
├── reference/          # Reference documentation
│   ├── architecture/   # Architecture documentation
│   ├── features/       # Feature documentation
│   └── deployment/     # Deployment documentation
├── project/            # Project management docs
└── archive/            # Archived documentation
    └── PRD/            # Archived PRD directory
```

## Questions and Support

If you can't find a document that has been migrated, please check the [Documentation Map](../DOCUMENTATION_MAP.md) or [Table of Contents](../TABLE_OF_CONTENTS.md) for a complete listing of all documentation.
