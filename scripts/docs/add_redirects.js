#!/usr/bin/env node

/**
 * Add Redirect Notices Script
 * 
 * This script adds redirect notices to files that have been migrated to new locations.
 * It helps users who might still be looking at old documentation find the new content.
 * 
 * Usage:
 *   node scripts/docs/add_redirects.js [--dry-run]
 * 
 * Options:
 *   --dry-run - Show what changes would be made without actually making them
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const existsAsync = promisify(fs.exists);

// Try to load chalk for colored output
let chalk;
try {
  chalk = require('chalk');
} catch (e) {
  // If chalk is not found, try to load it from assets/node_modules
  const assetsChalkPath = path.join(__dirname, '../../assets/node_modules/chalk');
  try {
    chalk = require(assetsChalkPath);
  } catch (e2) {
    // If still not found, use a simple fallback
    chalk = {
      bold: (text) => text,
      blue: (text) => text,
      red: (text) => text,
      yellow: (text) => text,
      green: (text) => text,
      gray: (text) => text
    };
    console.warn('Warning: chalk module not found. Console output will not be colored.');
  }
}

// Configuration
const config = {
  docsRoot: path.join(__dirname, '../../docs'),
  dryRun: process.argv.includes('--dry-run')
};

// Stats for reporting
const stats = {
  filesChecked: 0,
  redirectsAdded: 0,
  errors: 0
};

// Files with migration mapping (from old to new)
const migrations = [
  { old: 'PRD/README.md', new: 'guides/getting-started/overview.md' },
  { old: 'PRD/GETTING_STARTED.md', new: 'guides/getting-started/installation.md' },
  { old: 'PRD/ROBUST_IMPLEMENTATION.md', new: 'development/components/guidelines.md' },
  { old: 'PRD/PROJECT_MANAGEMENT/ROADMAP.md', new: 'project/roadmap.md' },
  { old: 'PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md', new: 'reference/architecture/resource-system.md' },
  { old: 'PRD/RESOURCE_TRANSFORMATION_PIPELINE.md', new: 'reference/architecture/transformation-pipeline.md' },
  { old: 'PRD/ARCHITECTURE/MODULE_ORGANIZATION.md', new: 'reference/architecture/modules.md' },
  { old: 'PRD/DEVELOPMENT/DOCUMENTATION_PROCESS.md', new: 'project/documentation/process.md' },
  { old: 'PRD/FEATURES/TERMINAL_PLUGINS.md', new: 'development/tools/terminal-plugins.md' },
  { old: 'PRD/FEATURES/ENHANCED_COMPONENT_SYSTEM.md', new: 'reference/architecture/enhanced-component-system.md' },
  { old: 'PRD/FEATURES/THEMES.md', new: 'guides/user-guides/theme-system.md' },
  { old: 'PRD/FEATURES/LIVEVIEW_COMPONENT_INTEGRATION.md', new: 'development/integration/liveview-component-integration.md' },
  { old: 'PRD/FEATURES/EVENT_BUS.md', new: 'reference/architecture/event-bus.md' },
  { old: 'PRD/FEATURES/COMPONENT_INSPECTOR.md', new: 'development/tools/component-inspector.md' },
  { old: 'PRD/FEATURES/REACTIVE_STATE_SYSTEM.md', new: 'reference/architecture/reactive-state.md' },
  { old: 'PRD/FEATURES/DEVELOPER_EXPERIENCE_ENHANCEMENTS.md', new: 'development/tools/developer-experience-enhancements.md' }
];

/**
 * Creates a redirect notice for a file
 */
function createRedirectNotice(oldPath, newPath) {
  return `# ⚠️ DOCUMENTATION MOVED ⚠️

This document has been migrated to a new location as part of our documentation restructuring.

## New Location

**Please visit the new document location**: [${newPath}](../../${newPath})

## Automatic Redirect

You will be automatically redirected to the new location in 5 seconds.

<meta http-equiv="refresh" content="5;url=../../${newPath}" />

---

`;
}

/**
 * Add a redirect notice to a file
 */
async function addRedirectNotice(filePath, newLocation) {
  try {
    // Check if file exists
    const exists = await existsAsync(filePath);
    if (!exists) {
      console.warn(chalk.yellow(`Warning: File not found: ${filePath}`));
      return false;
    }

    // Read the file
    const content = await readFileAsync(filePath, 'utf8');
    
    // Check if redirect notice already exists
    if (content.includes('# ⚠️ DOCUMENTATION MOVED ⚠️')) {
      console.log(chalk.gray(`Redirect already exists in: ${filePath}`));
      return false;
    }
    
    // Create the new content with redirect notice
    const redirectNotice = createRedirectNotice(filePath, newLocation);
    const newContent = redirectNotice + content;
    
    // Update the file if not in dry-run mode
    if (!config.dryRun) {
      await writeFileAsync(filePath, newContent, 'utf8');
      console.log(chalk.green(`Added redirect notice to: ${filePath}`));
    } else {
      console.log(chalk.yellow(`Would add redirect notice to: ${filePath} (dry run)`));
    }
    
    return true;
  } catch (error) {
    console.error(chalk.red(`Error adding redirect to ${filePath}:`), error);
    stats.errors++;
    return false;
  }
}

/**
 * Main function
 */
async function main() {
  console.log(chalk.bold('\nHydepwns Documentation Redirect Notice Adder'));
  console.log(chalk.bold('=============================================\n'));
  
  if (config.dryRun) {
    console.log(chalk.yellow('Running in dry-run mode - no files will be modified'));
  }
  
  // Process all migrations
  for (const migration of migrations) {
    const oldPath = path.join(config.docsRoot, migration.old);
    stats.filesChecked++;
    
    const redirectAdded = await addRedirectNotice(oldPath, migration.new);
    if (redirectAdded) {
      stats.redirectsAdded++;
    }
  }
  
  // Print summary
  console.log(chalk.bold('\nRedirect Summary'));
  console.log(chalk.bold('----------------'));
  console.log(`Files checked: ${stats.filesChecked}`);
  console.log(`Redirects added: ${config.dryRun ? chalk.yellow('Would add: ' + stats.redirectsAdded) : stats.redirectsAdded}`);
  console.log(`Errors: ${stats.errors}`);
  
  if (config.dryRun) {
    console.log(chalk.yellow('\nThis was a dry run. Run without --dry-run to apply changes.'));
  } else if (stats.redirectsAdded > 0) {
    console.log(chalk.green('\nRedirect notices added successfully!'));
  } else {
    console.log(chalk.blue('\nNo redirect notices needed to be added.'));
  }
}

// Run the script
main().catch(error => {
  console.error(chalk.red('Error:'), error);
  process.exit(1);
}); 