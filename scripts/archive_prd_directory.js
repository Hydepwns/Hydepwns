#!/usr/bin/env node

/**
 * This script archives the PRD directory by:
 * 1. Creating a backup of the PRD directory
 * 2. Adding archive notice to PRD files to indicate they're deprecated
 * 3. Creating a MIGRATION.md file with information about where files have been moved
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DOCS_DIR = path.resolve(__dirname, '../docs');
const PRD_DIR = path.resolve(DOCS_DIR, 'PRD');
const ARCHIVE_DIR = path.resolve(DOCS_DIR, 'archive');
const DRY_RUN = process.argv.includes('--dry-run');
const VERBOSE = process.argv.includes('--verbose');

// Get the migration plan for reference
const MIGRATION_PLAN_PATH = path.resolve(DOCS_DIR, 'project/planning/documentation-implementation-plan.md');

// Function to read the migration plan and extract mappings
function extractMigrationMappings() {
  try {
    const content = fs.readFileSync(MIGRATION_PLAN_PATH, 'utf8');
    const mappings = [];
    
    // Extract migration mappings using regex
    // Look for lines like: `- `docs/PRD/README.md` → `docs/guides/getting-started/overview.md``
    const migrationRegex = /`(docs\/PRD\/[^`]+)` → `([^`]+)`/g;
    let match;
    
    while ((match = migrationRegex.exec(content)) !== null) {
      mappings.push({
        source: match[1],
        destination: match[2]
      });
    }
    
    return mappings;
  } catch (error) {
    console.error('Error reading migration plan:', error.message);
    return [];
  }
}

// Function to add archive notice to a file
function addArchiveNotice(filePath, destinationPath) {
  if (DRY_RUN) {
    if (VERBOSE) {
      console.log(`Would add archive notice to ${filePath}`);
    }
    return;
  }
  
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Create the archive notice
    const archiveNotice = `
> ⚠️ **ARCHIVED DOCUMENT** ⚠️
> 
> This document has been archived and is no longer maintained.
> The current version can be found at: [New Location](/${destinationPath})
> 
> Please update any bookmarks or links to use the new location.

`;
    
    // Add the notice after the title (first heading)
    const updatedContent = content.replace(
      /(# .+?\n)/,
      `$1\n${archiveNotice}`
    );
    
    fs.writeFileSync(filePath, updatedContent, 'utf8');
    console.log(`Added archive notice to ${filePath}`);
  } catch (error) {
    console.error(`Error adding archive notice to ${filePath}:`, error.message);
  }
}

// Function to create a migration guide
function createMigrationGuide(mappings) {
  if (DRY_RUN) {
    if (VERBOSE) {
      console.log('Would create migration guide');
    }
    return;
  }
  
  try {
    const migrationGuidePath = path.resolve(PRD_DIR, 'MIGRATION.md');
    
    const migrationGuide = `# PRD Documentation Migration Guide

## Overview

This document provides information about where PRD documentation has been migrated in the new documentation structure.

## Migration Mappings

The following documents have been migrated to new locations:

| Original Location | New Location |
| --- | --- |
${mappings.map(mapping => `| \`${mapping.source}\` | [\`${mapping.destination}\`](/${mapping.destination}) |`).join('\n')}

## Why Were Documents Migrated?

The documentation has been reorganized to improve:

1. **Discoverability**: Making it easier to find related documentation
2. **Maintainability**: Grouping documentation by topic rather than by project phase
3. **Consistency**: Using a standardized format and structure

## References

- [Documentation Map](${path.relative(path.dirname(migrationGuidePath), path.resolve(DOCS_DIR, 'DOCUMENTATION_MAP.md'))})
- [Table of Contents](${path.relative(path.dirname(migrationGuidePath), path.resolve(DOCS_DIR, 'TABLE_OF_CONTENTS.md'))})
- [Documentation Implementation Plan](${path.relative(path.dirname(migrationGuidePath), MIGRATION_PLAN_PATH)})
`;
    
    fs.writeFileSync(migrationGuidePath, migrationGuide, 'utf8');
    console.log(`Created migration guide at ${migrationGuidePath}`);
  } catch (error) {
    console.error('Error creating migration guide:', error.message);
  }
}

// Function to prepare the archive directory
function prepareArchiveDirectory() {
  if (DRY_RUN) {
    if (VERBOSE) {
      console.log(`Would create archive directory at ${ARCHIVE_DIR}`);
    }
    return;
  }
  
  // Create the archive directory if it doesn't exist
  if (!fs.existsSync(ARCHIVE_DIR)) {
    fs.mkdirSync(ARCHIVE_DIR, { recursive: true });
    console.log(`Created archive directory at ${ARCHIVE_DIR}`);
  }
  
  // Create a README.md for the archive directory
  const archiveReadmePath = path.resolve(ARCHIVE_DIR, 'README.md');
  const archiveReadme = `# Documentation Archive

## Overview

This directory contains archived documentation that has been migrated to new locations in the documentation structure.

## Why These Documents Are Archived

These documents are kept for historical reference but are no longer maintained. They have been moved to more appropriate locations within the documentation structure.

Please refer to the current documentation in the main documentation directories:

- [Guides](../guides/)
- [Development](../development/)
- [Reference](../reference/)
- [Project](../project/)

## Finding Migrated Documents

To find where a document has been migrated, refer to:

- [Documentation Map](../DOCUMENTATION_MAP.md)
- [PRD Migration Guide](../PRD/MIGRATION.md)

## References

- [Documentation Implementation Plan](../project/planning/documentation-implementation-plan.md)
`;
  
  fs.writeFileSync(archiveReadmePath, archiveReadme, 'utf8');
  console.log(`Created archive README at ${archiveReadmePath}`);
}

// Main function
function main() {
  console.log('Starting PRD directory archiving process...');
  
  if (!fs.existsSync(PRD_DIR)) {
    console.error(`PRD directory not found at ${PRD_DIR}`);
    process.exit(1);
  }
  
  // Extract migration mappings
  const mappings = extractMigrationMappings();
  console.log(`Found ${mappings.length} migration mappings`);
  
  if (mappings.length === 0) {
    console.error('No migration mappings found. Check the migration plan document.');
    process.exit(1);
  }
  
  // Prepare the archive directory
  prepareArchiveDirectory();
  
  // Create a mapping by source file for quick lookup
  const mappingsBySource = {};
  mappings.forEach(mapping => {
    mappingsBySource[mapping.source] = mapping.destination;
  });
  
  // Create migration guide
  createMigrationGuide(mappings);
  
  // Add archive notices to PRD files
  let filesUpdated = 0;
  function processDirectory(directory) {
    const files = fs.readdirSync(directory);
    
    for (const file of files) {
      const filePath = path.join(directory, file);
      const stat = fs.statSync(filePath);
      
      if (stat.isDirectory()) {
        processDirectory(filePath);
      } else if (file.endsWith('.md')) {
        // Convert to the format in the mapping (docs/PRD/...)
        const relativePath = path.relative(DOCS_DIR, filePath).replace(/\\/g, '/');
        const destination = mappingsBySource[relativePath];
        
        if (destination) {
          addArchiveNotice(filePath, destination);
          filesUpdated++;
        } else if (VERBOSE) {
          console.log(`No migration mapping found for ${relativePath}`);
        }
      }
    }
  }
  
  processDirectory(PRD_DIR);
  console.log(`Updated ${filesUpdated} files with archive notices`);
  
  console.log('PRD directory archiving process completed successfully!');
  
  // Suggest next steps
  console.log('\nNext steps:');
  console.log('1. Review the archive notices added to PRD files');
  console.log('2. Check the migration guide for completeness');
  console.log('3. Run the documentation validation to ensure no broken links were introduced');
}

// Run the script
if (require.main === module) {
  if (DRY_RUN) {
    console.log('Running in DRY RUN mode. No changes will be made.');
  }
  main();
} 