#!/usr/bin/env node

/**
 * Documentation Cross-Reference Update Script
 * 
 * This script updates cross-references in documentation files to point to
 * the new locations after the documentation migration.
 * 
 * Usage:
 *   node scripts/docs/update_cross_references.js [--dry-run] [--verbose]
 * 
 * Options:
 *   --dry-run  - Show what changes would be made without actually making them
 *   --verbose  - Show detailed output for each file processed
 *   --path=DIR - Process only files in the specified directory
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

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
  fileExtensions: ['.md'],
  ignoreDirs: ['node_modules', '.git'],
  dryRun: process.argv.includes('--dry-run'),
  verbose: process.argv.includes('--verbose')
};

// Process path argument if provided
const pathArg = process.argv.find(arg => arg.startsWith('--path='));
if (pathArg) {
  const customPath = pathArg.split('=')[1];
  config.docsRoot = path.join(__dirname, '../../', customPath);
}

// Stats for reporting
const stats = {
  filesChecked: 0,
  filesModified: 0,
  referencesUpdated: 0
};

// Migration mapping from old paths to new paths
const migrationMap = [
  { old: 'docs/PRD/README.md', new: 'docs/guides/getting-started/overview.md' },
  { old: 'PRD/README.md', new: 'guides/getting-started/overview.md' },
  
  { old: 'docs/PRD/GETTING_STARTED.md', new: 'docs/guides/getting-started/installation.md' },
  { old: 'PRD/GETTING_STARTED.md', new: 'guides/getting-started/installation.md' },
  
  { old: 'docs/GUIDE.md', new: 'docs/guides/getting-started/quickstart.md' },
  { old: 'GUIDE.md', new: 'guides/getting-started/quickstart.md' },
  
  { old: 'docs/PRD/ROBUST_IMPLEMENTATION.md', new: 'docs/development/components/guidelines.md' },
  { old: 'PRD/ROBUST_IMPLEMENTATION.md', new: 'development/components/guidelines.md' },
  
  { old: 'docs/ROBUST_IMPLEMENTATION.md', new: 'docs/development/components/robust-implementation.md' },
  { old: 'ROBUST_IMPLEMENTATION.md', new: 'development/components/robust-implementation.md' },
  
  { old: 'docs/COMPONENT_IMPLEMENTATION_PATTERNS.md', new: 'docs/development/components/patterns.md' },
  { old: 'COMPONENT_IMPLEMENTATION_PATTERNS.md', new: 'development/components/patterns.md' },
  
  { old: 'docs/PRD/PROJECT_MANAGEMENT/ROADMAP.md', new: 'docs/project/roadmap.md' },
  { old: 'PRD/PROJECT_MANAGEMENT/ROADMAP.md', new: 'project/roadmap.md' },
  
  { old: 'docs/TRANSFORMATION_COOKBOOK.md', new: 'docs/development/components/transformation-cookbook.md' },
  { old: 'TRANSFORMATION_COOKBOOK.md', new: 'development/components/transformation-cookbook.md' },
  
  { old: 'docs/reactive_state_system.md', new: 'docs/reference/architecture/reactive-state.md' },
  { old: 'reactive_state_system.md', new: 'reference/architecture/reactive-state.md' },
  
  { old: 'docs/event_bus.md', new: 'docs/reference/architecture/event-bus.md' },
  { old: 'event_bus.md', new: 'reference/architecture/event-bus.md' },
  
  { old: 'docs/component_inspector.md', new: 'docs/development/tools/component-inspector.md' },
  { old: 'component_inspector.md', new: 'development/tools/component-inspector.md' },
  
  { old: 'docs/PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md', new: 'docs/reference/architecture/resource-system.md' },
  { old: 'PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md', new: 'reference/architecture/resource-system.md' },
  
  { old: 'docs/PRD/RESOURCE_TRANSFORMATION_PIPELINE.md', new: 'docs/reference/architecture/transformation-pipeline.md' },
  { old: 'PRD/RESOURCE_TRANSFORMATION_PIPELINE.md', new: 'reference/architecture/transformation-pipeline.md' },
  
  { old: 'docs/TEST_FRAMEWORK_GUIDE.md', new: 'docs/development/testing/framework-guide.md' },
  { old: 'TEST_FRAMEWORK_GUIDE.md', new: 'development/testing/framework-guide.md' },
  
  { old: 'docs/performance_optimization.md', new: 'docs/development/tools/performance-optimization.md' },
  { old: 'performance_optimization.md', new: 'development/tools/performance-optimization.md' },
  
  { old: 'docs/PRD/ARCHITECTURE/MODULE_ORGANIZATION.md', new: 'docs/reference/architecture/modules.md' },
  { old: 'PRD/ARCHITECTURE/MODULE_ORGANIZATION.md', new: 'reference/architecture/modules.md' },
  
  { old: 'docs/PRD/DEVELOPMENT/DOCUMENTATION_PROCESS.md', new: 'docs/project/documentation/process.md' },
  { old: 'PRD/DEVELOPMENT/DOCUMENTATION_PROCESS.md', new: 'project/documentation/process.md' },
  
  { old: 'docs/PRD/FEATURES/TERMINAL_PLUGINS.md', new: 'docs/development/tools/terminal-plugins.md' },
  { old: 'PRD/FEATURES/TERMINAL_PLUGINS.md', new: 'development/tools/terminal-plugins.md' },
  
  { old: 'docs/PRD/FEATURES/EVENT_BUS.md', new: 'docs/reference/architecture/event-bus.md' },
  { old: 'PRD/FEATURES/EVENT_BUS.md', new: 'reference/architecture/event-bus.md' },
  
  { old: 'docs/PRD/FEATURES/COMPONENT_INSPECTOR.md', new: 'docs/development/tools/component-inspector.md' },
  { old: 'PRD/FEATURES/COMPONENT_INSPECTOR.md', new: 'development/tools/component-inspector.md' },
  
  { old: 'docs/PRD/FEATURES/REACTIVE_STATE_SYSTEM.md', new: 'docs/reference/architecture/reactive-state.md' },
  { old: 'PRD/FEATURES/REACTIVE_STATE_SYSTEM.md', new: 'reference/architecture/reactive-state.md' },
  
  // New entries for recent migrations
  { old: 'docs/PRD/FEATURES/LIVEVIEW_COMPONENT_INTEGRATION.md', new: 'docs/development/integration/liveview-component-integration.md' },
  { old: 'PRD/FEATURES/LIVEVIEW_COMPONENT_INTEGRATION.md', new: 'development/integration/liveview-component-integration.md' },
  { old: 'LIVEVIEW_COMPONENT_INTEGRATION.md', new: 'development/integration/liveview-component-integration.md' },
  
  { old: 'docs/developer_experience_enhancements.md', new: 'docs/development/tools/developer-experience-enhancements.md' },
  { old: 'developer_experience_enhancements.md', new: 'development/tools/developer-experience-enhancements.md' },
  { old: 'docs/PRD/FEATURES/DEVELOPER_EXPERIENCE_ENHANCEMENTS.md', new: 'docs/development/tools/developer-experience-enhancements.md' },
  { old: 'PRD/FEATURES/DEVELOPER_EXPERIENCE_ENHANCEMENTS.md', new: 'development/tools/developer-experience-enhancements.md' },
  
  { old: 'docs/DOCUMENTATION_META_TEMPLATE.md', new: 'docs/project/documentation/templates/documentation-meta-template.md' },
  { old: 'DOCUMENTATION_META_TEMPLATE.md', new: 'project/documentation/templates/documentation-meta-template.md' },
  
  { old: 'docs/DOCUMENT_SECTIONS_TEMPLATE.md', new: 'docs/project/documentation/templates/document-sections-template.md' },
  { old: 'DOCUMENT_SECTIONS_TEMPLATE.md', new: 'project/documentation/templates/document-sections-template.md' }
];

// Create a lookup map for faster reference checking
const linkLookup = {};
migrationMap.forEach(mapping => {
  linkLookup[mapping.old] = mapping.new;
});

/**
 * Update all relative links in the content that match the migration map
 */
function updateLinks(content, filePath) {
  let updatedContent = content;
  let updateCount = 0;
  
  // Track for reporting only
  const updatedLinks = [];
  
  // Regular expression to find markdown links
  // This handles both [text](link) and [text][reference] formats
  const linkRegex = /\[([^\]]+)\]\(([^)]+)\)|\[([^\]]+)\]\[([^\]]+)\]/g;
  
  updatedContent = updatedContent.replace(linkRegex, (match, text1, link, text2, reference) => {
    // Handle [text](link) format
    if (text1 && link) {
      // Check if the link matches any in our migration map
      for (const [oldPath, newPath] of Object.entries(linkLookup)) {
        // Strip leading ./ from the link for comparison
        const cleanLink = link.replace(/^\.\//, '');
        
        // Check for various link formats (with or without docs/ prefix)
        if (cleanLink === oldPath || 
            cleanLink === oldPath.replace('docs/', '') ||
            cleanLink === path.basename(oldPath)) {
          
          // Get the correct relative path
          const relativePath = newPath.replace('docs/', '');
          
          // Record for reporting
          updatedLinks.push({ old: link, new: relativePath });
          updateCount++;
          
          return `[${text1}](${relativePath})`;
        }
      }
    }
    
    // Handle [text][reference] format (reference links)
    // We don't update these directly, but note them for manual review
    if (text2 && reference) {
      if (config.verbose) {
        console.log(chalk.yellow(`Reference link found in ${filePath}: [${text2}][${reference}] - manual review required`));
      }
    }
    
    return match;
  });
  
  // Report link updates if verbose
  if (config.verbose && updatedLinks.length > 0) {
    console.log(chalk.green(`Updated ${updatedLinks.length} links in ${chalk.blue(filePath)}:`));
    updatedLinks.forEach(link => {
      console.log(`  ${chalk.red(link.old)} → ${chalk.green(link.new)}`);
    });
  }
  
  return { 
    content: updatedContent, 
    updateCount 
  };
}

/**
 * Process a single documentation file
 */
async function processFile(filePath) {
  try {
    // Read the file content
    const content = await readFileAsync(filePath, 'utf8');
    
    // Update cross-references
    const { content: updatedContent, updateCount } = updateLinks(content, filePath);
    
    // Update stats
    stats.filesChecked++;
    stats.referencesUpdated += updateCount;
    
    // If changes were made and not in dry-run mode, write the file
    if (updatedContent !== content) {
      stats.filesModified++;
      
      if (!config.dryRun) {
        await writeFileAsync(filePath, updatedContent, 'utf8');
        if (config.verbose) {
          console.log(chalk.green(`✓ Updated file: ${filePath}`));
        }
      } else {
        if (config.verbose) {
          console.log(chalk.yellow(`Would update file: ${filePath} (dry run)`));
        }
      }
    } else {
      if (config.verbose) {
        console.log(chalk.gray(`No changes needed in: ${filePath}`));
      }
    }
  } catch (error) {
    console.error(chalk.red(`Error processing file ${filePath}:`), error);
  }
}

/**
 * Recursively process all files in a directory
 */
async function processDirectory(dirPath) {
  try {
    const entries = await readdirAsync(dirPath);
    
    for (const entry of entries) {
      const entryPath = path.join(dirPath, entry);
      const stat = await statAsync(entryPath);
      
      if (stat.isDirectory()) {
        // Skip ignored directories
        if (config.ignoreDirs.includes(entry)) {
          continue;
        }
        // Process subdirectory
        await processDirectory(entryPath);
      } else if (stat.isFile() && config.fileExtensions.includes(path.extname(entry))) {
        // Process file if it has the right extension
        await processFile(entryPath);
      }
    }
  } catch (error) {
    console.error(chalk.red(`Error processing directory ${dirPath}:`), error);
  }
}

/**
 * Main function
 */
async function main() {
  console.log(chalk.bold('\nHydepwns Documentation Cross-Reference Updater'));
  console.log(chalk.bold('=============================================\n'));
  
  console.log(`Processing documentation files in: ${config.docsRoot}`);
  if (config.dryRun) {
    console.log(chalk.yellow('Running in dry-run mode - no files will be modified'));
  }
  
  // Process all documentation
  await processDirectory(config.docsRoot);
  
  // Print summary
  console.log(chalk.bold('\nUpdate Summary'));
  console.log(chalk.bold('-------------'));
  console.log(`Files checked: ${stats.filesChecked}`);
  console.log(`Files modified: ${config.dryRun ? chalk.yellow('Would modify: ' + stats.filesModified) : stats.filesModified}`);
  console.log(`References updated: ${config.dryRun ? chalk.yellow('Would update: ' + stats.referencesUpdated) : stats.referencesUpdated}`);
  
  if (config.dryRun) {
    console.log(chalk.yellow('\nThis was a dry run. Run without --dry-run to apply changes.'));
  } else if (stats.referencesUpdated > 0) {
    console.log(chalk.green('\nCross-references updated successfully!'));
  } else {
    console.log(chalk.blue('\nNo cross-references needed updating.'));
  }
}

// Run the script
main().catch(error => {
  console.error(chalk.red('Error:'), error);
  process.exit(1);
}); 