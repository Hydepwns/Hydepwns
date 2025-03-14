#!/usr/bin/env node

/**
 * This script automates fixing common patterns of broken links in documentation
 * based on the output from find_broken_links.js and the documentation implementation plan.
 * 
 * Usage:
 *   node scripts/automate_broken_link_fixes.js
 *   node scripts/automate_broken_link_fixes.js --dry-run  # Don't make changes
 *   node scripts/automate_broken_link_fixes.js --verbose  # Show detailed output
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DOCS_DIR = path.resolve(__dirname, '../docs');
const DRY_RUN = process.argv.includes('--dry-run');
const VERBOSE = process.argv.includes('--verbose');

// Documentation implementation plan path
const IMPLEMENTATION_PLAN_PATH = path.resolve(DOCS_DIR, 'project/planning/documentation-implementation-plan.md');

// Regular expression to match Markdown links
const LINK_REGEX = /\[([^\]]+)\]\(([^)]+)\)/g;

// Known paths that have been migrated
const knownMigrations = {
  "COMPONENT_IMPLEMENTATION_PATTERNS.md": "development/components/patterns.md",
  "THEMES.md": "guides/design/themes.md",
  "EVENT_MANAGEMENT.md": "development/components/event-management.md",
  "RESOURCE_CLEANUP.md": "development/components/resource-cleanup.md",
  "PERFORMANCE_OPTIMIZATION.md": "reference/optimization/performance.md",
  "ENHANCED_COMPONENT_SYSTEM.md": "reference/architecture/enhanced-component-system.md",
  "component-architecture.md": "reference/architecture/component-architecture.md"
};

// Function to extract migration mappings from the implementation plan
function extractMigrationMappings() {
  try {
    const content = fs.readFileSync(IMPLEMENTATION_PLAN_PATH, 'utf8');
    // Extract mappings using regex or other parsing logic
    // For now, we'll use the hardcoded knownMigrations
    return knownMigrations;
  } catch (error) {
    console.error(`Error reading implementation plan: ${error.message}`);
    return knownMigrations;
  }
}

// Function to fix broken links in a file
function fixBrokenLinksInFile(filePath, migrationMappings) {
  try {
    if (VERBOSE) {
      console.log(`Processing file: ${filePath}`);
    }

    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;
    let changedLinks = [];

    // Process Markdown links
    let newContent = content.replace(LINK_REGEX, (match, linkText, linkPath) => {
      // Skip URLs and anchors
      if (linkPath.startsWith('http') || linkPath.startsWith('#')) {
        return match;
      }

      // Check if link path contains a known migration pattern
      for (const [oldPath, newPath] of Object.entries(migrationMappings)) {
        if (linkPath.includes(oldPath)) {
          const updatedLink = linkPath.replace(oldPath, newPath);
          changedLinks.push({ from: linkPath, to: updatedLink });
          modified = true;
          return `[${linkText}](${updatedLink})`;
        }
      }

      // Handle PRD to new structure mappings
      if (linkPath.includes('PRD/') || linkPath.includes('/PRD/')) {
        // Convert PRD paths to new directory structure
        // This is a simplified approach and may need refinement
        const updatedLink = linkPath
          .replace('PRD/DEVELOPMENT/', 'development/')
          .replace('PRD/FEATURES/', 'reference/features/')
          .replace('PRD/ARCHITECTURE/', 'reference/architecture/')
          .replace('PRD/PROJECT_MANAGEMENT/', 'project/');
        
        changedLinks.push({ from: linkPath, to: updatedLink });
        modified = true;
        return `[${linkText}](${updatedLink})`;
      }

      // Fix common relative path issues
      if (linkPath.startsWith('/docs/')) {
        const updatedLink = linkPath.replace('/docs/', '../../');
        changedLinks.push({ from: linkPath, to: updatedLink });
        modified = true;
        return `[${linkText}](${updatedLink})`;
      }

      return match;
    });

    // Write changes if any links were modified
    if (modified && !DRY_RUN) {
      fs.writeFileSync(filePath, newContent, 'utf8');
      console.log(`✅ Updated links in ${filePath}`);
      changedLinks.forEach(({ from, to }) => {
        console.log(`  - Changed: [${from}] -> [${to}]`);
      });
    } else if (modified && DRY_RUN) {
      console.log(`Would update links in ${filePath} (dry run)`);
      changedLinks.forEach(({ from, to }) => {
        console.log(`  - Would change: [${from}] -> [${to}]`);
      });
    }

    return modified;
  } catch (error) {
    console.error(`Error processing file ${filePath}: ${error.message}`);
    return false;
  }
}

// Function to get all Markdown files
function getMarkdownFiles(dir) {
  const files = [];
  
  function scanDirectory(directory) {
    const entries = fs.readdirSync(directory, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(directory, entry.name);
      
      if (entry.isDirectory()) {
        scanDirectory(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  
  scanDirectory(dir);
  return files;
}

// Main function
function main() {
  console.log('Starting automatic broken link fixing process...');
  console.log(`Running in ${DRY_RUN ? 'DRY RUN' : 'LIVE'} mode. ${DRY_RUN ? 'No changes will be made.' : ''}`);
  
  const migrationMappings = extractMigrationMappings();
  const markdownFiles = getMarkdownFiles(DOCS_DIR);
  
  console.log(`Found ${markdownFiles.length} Markdown files to process.`);
  
  let totalFilesModified = 0;
  
  for (const filePath of markdownFiles) {
    const modified = fixBrokenLinksInFile(filePath, migrationMappings);
    if (modified) {
      totalFilesModified++;
    }
  }
  
  console.log(`Process complete. ${DRY_RUN ? 'Would have modified' : 'Modified'} ${totalFilesModified} files.`);
  console.log('To verify remaining broken links, run: node scripts/find_broken_links.js');
}

// Run the main function
main(); 