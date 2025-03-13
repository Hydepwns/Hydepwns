#!/usr/bin/env node

/**
 * doc_migration_status.js
 * 
 * This script analyzes the documentation files in the Hydepwns project
 * to identify which files have been migrated to the PRD structure
 * and which ones still need to be migrated.
 */

const fs = require('fs');
const path = require('path');

// Configuration
const ROOT_DOCS_DIR = path.join(__dirname, '../../docs');
const PRD_DOCS_DIR = path.join(ROOT_DOCS_DIR, 'PRD');
const IGNORE_FILES = [
  'README.md', // Root README is different from PRD README
  'DOCUMENTATION_MAP.md',
  'DOCUMENTATION_META_TEMPLATE.md',
  'COMPONENT_DOCUMENTATION_TEMPLATE.md',
  'LICENSE.md',
  'GUIDE.md'
];

// Map file categories to PRD subdirectories
const CATEGORY_MAP = {
  'ARCHITECTURE': [
    'ARCHITECTURE', 'COMPONENT_ARCHITECTURE', 'MODULE_ORGANIZATION',
    'ERROR_HANDLING', 'ENHANCED_ERROR_REPORTING', 'SOCKET_VALIDATION',
    'resource_architecture', 'RESOURCE_ARCHITECTURE'
  ],
  'DEVELOPMENT': [
    'DEVELOPMENT_SETUP', 'CONTRIBUTING', 'TESTING_GUIDE', 'TESTING_STRATEGY',
    'DOCKER_SETUP', 'PATH_HELPER'
  ],
  'FEATURES': [
    'THEMES', 'LIVEVIEW', 'TERMINAL_PLUGINS', 'ANIMATIONS', 'ASCII_ART_COMPONENTS',
    'RESOURCE_MANAGEMENT', 'RELATIONSHIP_MANAGEMENT', 'CHANGE_TRACKING',
    'NESTED_RESOURCE_VALIDATION', 'BASELIVE_FLINT_INTEGRATION',
    'MOBILE_OPTIMIZATIONS', 'IMAGE_OPTIMIZATION'
  ],
  'PROJECT_MANAGEMENT': [
    'CHANGELOG', 'KNOWN_ISSUES'
  ],
  'DEPLOYMENT': [
    'DEPLOYMENT'
  ],
  'DESIGN': [
    'DESIGN_PRINCIPLES', 'screen_reader_testing', 'SCREEN_READER_TESTING'
  ]
};

// Function to get all .md files in a directory
function getMdFiles(dir) {
  const files = fs.readdirSync(dir);
  return files
    .filter(file => file.endsWith('.md') && !IGNORE_FILES.includes(file))
    .map(file => ({
      name: file,
      path: path.join(dir, file)
    }));
}

// Function to check if a file exists in the PRD structure (case-insensitive)
function findInPrd(filename) {
  const filenameWithoutExt = path.basename(filename, '.md').toLowerCase();
  
  for (const category in CATEGORY_MAP) {
    const categoryDir = path.join(PRD_DOCS_DIR, category);
    if (fs.existsSync(categoryDir)) {
      const categoryFiles = fs.readdirSync(categoryDir);
      
      // Case-insensitive check
      const found = categoryFiles.find(file => 
        path.basename(file, '.md').toLowerCase() === filenameWithoutExt
      );
      
      if (found) {
        return category;
      }
    }
  }
  return null;
}

// Function to guess which category a file should be in
function guessCategory(filename) {
  const filenameWithoutExt = path.basename(filename, '.md');
  const filenameLower = filenameWithoutExt.toLowerCase();
  
  for (const category in CATEGORY_MAP) {
    // Case-insensitive check for category mapping
    if (CATEGORY_MAP[category].some(item => item.toLowerCase() === filenameLower)) {
      return category;
    }
  }
  
  return 'UNKNOWN';
}

// Main function
function analyzeDocMigration() {
  const rootMdFiles = getMdFiles(ROOT_DOCS_DIR);
  
  const migrated = [];
  const notMigrated = [];
  
  // Check each file
  rootMdFiles.forEach(file => {
    const filename = path.basename(file.path);
    const migratedTo = findInPrd(filename);
    
    if (migratedTo) {
      migrated.push({
        name: filename,
        category: migratedTo
      });
    } else {
      notMigrated.push({
        name: filename,
        suggestedCategory: guessCategory(filename)
      });
    }
  });
  
  // Print results
  console.log('===== Documentation Migration Status =====\n');
  
  console.log(`Total MD files in docs: ${rootMdFiles.length}`);
  console.log(`Files migrated to PRD: ${migrated.length}`);
  console.log(`Files not yet migrated: ${notMigrated.length}\n`);
  
  console.log('===== Migrated Files =====\n');
  migrated.forEach(file => {
    console.log(`✅ ${file.name} -> PRD/${file.category}/`);
  });
  
  console.log('\n===== Files To Be Migrated =====\n');
  notMigrated.forEach(file => {
    console.log(`❌ ${file.name} -> Suggested: PRD/${file.suggestedCategory}/`);
  });
  
  console.log('\n===== Migration Progress =====\n');
  console.log(`Progress: ${Math.round((migrated.length / rootMdFiles.length) * 100)}%`);
}

// Run the analysis
analyzeDocMigration(); 