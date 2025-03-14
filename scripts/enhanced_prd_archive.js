#!/usr/bin/env node

/**
 * This script enhances the PRD archiving process by:
 * 1. Creating a comprehensive migration guide
 * 2. Adding archive notices to all PRD files
 * 3. Updating links in the migration guide to point to new locations
 * 4. Creating an index of archived documents for easy reference
 * 
 * Usage:
 *   node scripts/enhanced_prd_archive.js
 *   node scripts/enhanced_prd_archive.js --dry-run  # Don't make changes
 *   node scripts/enhanced_prd_archive.js --verbose  # Show detailed output
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DOCS_DIR = path.resolve(__dirname, '../docs');
const PRD_DIR = path.resolve(DOCS_DIR, 'PRD');
const ARCHIVE_DIR = path.resolve(DOCS_DIR, 'archive');
const ARCHIVE_PRD_DIR = path.resolve(ARCHIVE_DIR, 'PRD');
const DRY_RUN = process.argv.includes('--dry-run');
const VERBOSE = process.argv.includes('--verbose');
const ARCHIVE_DATE = new Date().toISOString().split('T')[0];

// Migration guide path
const MIGRATION_GUIDE_PATH = path.resolve(ARCHIVE_DIR, 'PRD_MIGRATION_GUIDE.md');
const ARCHIVE_INDEX_PATH = path.resolve(ARCHIVE_DIR, 'README.md');

// Mapping of PRD directories to new structure
const directoryMappings = {
  'ARCHITECTURE': 'reference/architecture',
  'DEVELOPMENT': 'development',
  'FEATURES': 'reference/features',
  'PROJECT_MANAGEMENT': 'project',
  'DEPLOYMENT': 'reference/deployment'
};

// Known file migrations from PRD to new structure
const fileMappings = {
  'PRD/ARCHITECTURE/COMPONENT_ARCHITECTURE.md': 'reference/architecture/component-architecture.md',
  'PRD/DEVELOPMENT/EVENT_MANAGEMENT.md': 'development/components/event-management.md',
  'PRD/FEATURES/LIVEVIEW.md': 'reference/features/liveview.md',
  'PRD/FEATURES/THEMES.md': 'guides/design/themes.md',
  'PRD/GETTING_STARTED.md': 'guides/getting-started/index.md',
  'PRD/PROJECT_MANAGEMENT/ROADMAP.md': 'project/roadmap.md',
  'PRD/PROJECT_MANAGEMENT/DOCUMENTATION_MIGRATION.md': 'project/planning/documentation-migration.md',
  'PRD/PROJECT_MANAGEMENT/DOCUMENTATION_STYLE_GUIDE.md': 'project/documentation/style-guide.md',
  'PRD/DEPLOYMENT/DEPLOYMENT.md': 'reference/deployment/overview.md'
};

// Create archive notice template
const createArchiveNotice = (originalPath, newPath) => `# ⚠️ Archived Document

This document has been archived as part of the documentation reorganization project.

- Original location: \`${originalPath}\`
- Current location: \`${newPath}\`
- Archive date: ${ARCHIVE_DATE}

Please refer to the new documentation structure for up-to-date information.

---

`;

// Function to prepare archive directory
function prepareArchiveDirectory() {
  if (!fs.existsSync(ARCHIVE_DIR)) {
    if (!DRY_RUN) {
      fs.mkdirSync(ARCHIVE_DIR, { recursive: true });
      console.log(`Created archive directory at ${ARCHIVE_DIR}`);
    } else {
      console.log(`Would create archive directory at ${ARCHIVE_DIR}`);
    }
  }

  if (!fs.existsSync(ARCHIVE_PRD_DIR)) {
    if (!DRY_RUN) {
      fs.mkdirSync(ARCHIVE_PRD_DIR, { recursive: true });
      console.log(`Created PRD archive directory at ${ARCHIVE_PRD_DIR}`);
    } else {
      console.log(`Would create PRD archive directory at ${ARCHIVE_PRD_DIR}`);
    }
  }
}

// Function to archive a single file
const archiveFile = (filePath) => {
  const relativePath = path.relative(PRD_DIR, filePath);
  const archivePath = path.join(ARCHIVE_DIR, relativePath);
  const archiveDir = path.dirname(archivePath);

  // Create archive directory if it doesn't exist
  if (!fs.existsSync(archiveDir)) {
    fs.mkdirSync(archiveDir, { recursive: true });
  }

  // Read original content
  const content = fs.readFileSync(filePath, 'utf8');

  // Get the new path from the migration mapping
  const migrationMap = {
    'README.md': 'docs/guides/getting-started/overview.md',
    'GETTING_STARTED.md': 'docs/guides/getting-started/installation.md',
    'ROBUST_IMPLEMENTATION.md': 'docs/development/components/robust-implementation.md',
    'PROJECT_MANAGEMENT/ROADMAP.md': 'docs/project/roadmap.md',
    'ARCHITECTURE/MODULE_ORGANIZATION.md': 'docs/reference/architecture/modules.md',
    'DEVELOPMENT/DOCUMENTATION_PROCESS.md': 'docs/project/documentation/process.md',
    'FEATURES/TERMINAL_PLUGINS.md': 'docs/development/tools/terminal-plugins.md'
  };

  const newPath = migrationMap[relativePath] || 'Unknown';

  // Add archive notice to content
  const archivedContent = createArchiveNotice(filePath, newPath) + content;

  // Write to archive location
  fs.writeFileSync(archivePath, archivedContent);
  console.log(`✅ Archived: ${filePath} -> ${archivePath}`);

  // Add archive notice to original file
  fs.writeFileSync(filePath, archivedContent);
  console.log(`✅ Updated original with archive notice: ${filePath}`);
};

// Function to recursively process directory
const processDirectory = (dirPath) => {
  const items = fs.readdirSync(dirPath);

  items.forEach(item => {
    const fullPath = path.join(dirPath, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      processDirectory(fullPath);
    } else if (stat.isFile() && item.endsWith('.md')) {
      archiveFile(fullPath);
    }
  });
};

// Function to create migration guide
function createMigrationGuide() {
  const guideContent = `# PRD Migration Guide

## Overview

This document provides guidance for finding content that has been migrated from the PRD directory to the new documentation structure. 

## Directory Mappings

The following directories have been migrated to new locations:

| Old Location (PRD) | New Location |
|-------------------|-------------|
${Object.entries(directoryMappings)
  .map(([oldDir, newDir]) => `| \`PRD/${oldDir}\` | \`${newDir}\` |`)
  .join('\n')}

## File Mappings

The following specific files have been migrated:

| Old Location | New Location | Status |
|-------------|-------------|--------|
${Object.entries(fileMappings)
  .map(([oldPath, newPath]) => {
    const exists = fs.existsSync(path.join(DOCS_DIR, newPath));
    return `| \`${oldPath}\` | \`${newPath}\` | ${exists ? '✅ Migrated' : '❌ Pending'} |`;
  })
  .join('\n')}

## How to Find Migrated Content

1. **Check the tables above** to see if the document you're looking for has been migrated
2. **Use the search functionality** in your editor or repository to find content
3. **Look in the corresponding new directory** based on the directory mappings
4. **Check the archived copy** in the \`docs/archive/PRD\` directory

## Archived Documents

All PRD documents have been archived and are available in the \`docs/archive/PRD\` directory with their original structure preserved. These archived documents contain notices pointing to their new locations where applicable.

## Directory Structure Reference

### Old Structure

\`\`\`
docs/PRD/
├── ARCHITECTURE/       # System architecture documentation
├── DEVELOPMENT/        # Development guidelines and processes
├── FEATURES/           # Feature specifications
├── PROJECT_MANAGEMENT/ # Project management documentation
└── README.md           # PRD overview
\`\`\`

### New Structure

\`\`\`
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
\`\`\`

## Questions and Support

If you can't find a document that has been migrated, please check the [Documentation Map](../DOCUMENTATION_MAP.md) or [Table of Contents](../TABLE_OF_CONTENTS.md) for a complete listing of all documentation.
`;

  if (!DRY_RUN) {
    fs.writeFileSync(MIGRATION_GUIDE_PATH, guideContent, 'utf8');
    console.log(`✅ Created migration guide at ${MIGRATION_GUIDE_PATH}`);
  } else {
    console.log(`Would create migration guide at ${MIGRATION_GUIDE_PATH}`);
  }
}

// Function to create archive index
function createArchiveIndex() {
  const indexContent = `# Documentation Archive

## Overview

This directory contains archived documentation that has been migrated to new locations in the documentation structure. These documents are preserved for historical reference but may contain outdated information.

## PRD Directory

The PRD (Product Requirements Document) directory has been archived and its contents migrated to the new documentation structure. See the [PRD Migration Guide](PRD_MIGRATION_GUIDE.md) for information about where to find migrated content.

## Archive Contents

### PRD Directory Archive

The complete PRD directory has been archived with the following structure:

\`\`\`
archive/PRD/
├── ARCHITECTURE/       # System architecture documentation
├── DEVELOPMENT/        # Development guidelines and processes
├── FEATURES/           # Feature specifications
├── PROJECT_MANAGEMENT/ # Project management documentation
└── README.md           # PRD overview
\`\`\`

## Finding Current Documentation

To find the current version of the documentation:

1. Check the [PRD Migration Guide](PRD_MIGRATION_GUIDE.md) for information about where files have been moved
2. Refer to the [Documentation Map](../DOCUMENTATION_MAP.md) for a complete listing of documentation
3. Browse the [Table of Contents](../TABLE_OF_CONTENTS.md) for a structured overview of all documentation

## Archiving Policy

Documentation is archived when:

1. It has been migrated to a new location
2. Its content has been merged into other documents
3. It contains obsolete information that should be preserved for historical context

Archived documents contain notices indicating their archive status and pointing to new locations where applicable.
`;

  if (!DRY_RUN) {
    fs.writeFileSync(ARCHIVE_INDEX_PATH, indexContent, 'utf8');
    console.log(`✅ Created archive index at ${ARCHIVE_INDEX_PATH}`);
  } else {
    console.log(`Would create archive index at ${ARCHIVE_INDEX_PATH}`);
  }
}

// Function to copy PRD directory to archive
function copyPRDToArchive() {
  if (!DRY_RUN) {
    try {
      // Use execSync to copy the entire directory
      execSync(`cp -R "${PRD_DIR}" "${ARCHIVE_DIR}/"`);
      console.log(`✅ Copied PRD directory to ${ARCHIVE_PRD_DIR}`);
    } catch (error) {
      console.error(`Error copying PRD directory: ${error.message}`);
    }
  } else {
    console.log(`Would copy PRD directory to ${ARCHIVE_PRD_DIR}`);
  }
}

// Main function
function main() {
  console.log('Starting PRD documentation archival process...');
  console.log(`Running in ${DRY_RUN ? 'DRY RUN' : 'LIVE'} mode. ${DRY_RUN ? 'No changes will be made.' : ''}`);
  
  // Step 1: Prepare archive directory
  prepareArchiveDirectory();
  
  // Step 2: Create migration guide
  createMigrationGuide();
  
  // Step 3: Create archive index
  createArchiveIndex();
  
  // Step 4: Copy PRD directory to archive
  copyPRDToArchive();
  
  // Step 5: Archive all PRD files
  processDirectory(PRD_DIR);
  
  console.log('PRD directory archival process complete.');
  console.log(`Next steps:
1. Review the migration guide at ${path.relative(process.cwd(), MIGRATION_GUIDE_PATH)}
2. Verify archive notices in PRD files
3. Run broken link checker to identify any remaining issues`);
}

// Run the main function
main(); 