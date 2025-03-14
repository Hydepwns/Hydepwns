#!/usr/bin/env node

/**
 * This script fixes heading structure issues in Markdown files
 * It finds cases where H1 is followed by H3 or H4 without an intermediate H2
 * and adds appropriate H2 headings where needed.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DOCS_DIR = path.resolve(__dirname, '../docs');
const DRY_RUN = process.argv.includes('--dry-run');
const VERBOSE = process.argv.includes('--verbose');

// Files to process - from the validation output
const filesWithHeadingIssues = [
  'docs/PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md',
  'docs/PRD/GETTING_STARTED.md',
  'docs/reference/data-models/nested-resource-validation.md',
  'docs/reference/architecture/transformation-pipeline.md',
  'docs/reference/architecture/resource-system.md',
  'docs/reference/architecture/component-architecture.md',
  'docs/reference/architecture/change-tracking.md',
  'docs/guides/getting-started/installation.md',
  'docs/guides/getting-started/index.md',
  'docs/development/tools/docker-setup.md',
  'docs/development/tools/developer-experience-enhancements.md',
  'docs/development/testing/framework-guide.md',
  'docs/development/contributing/development-setup.md',
  'docs/development/components/toast-component.md',
  'docs/development/components/progress-bar-component.md',
  'docs/PRD/FEATURES/RESOURCE_TRANSFORMATION.md',
  'docs/PRD/FEATURES/RESOURCE_MANAGEMENT.md',
  'docs/PRD/FEATURES/RELATIONSHIP_MANAGEMENT.md',
  'docs/PRD/FEATURES/NESTED_RESOURCE_VALIDATION.md',
  'docs/PRD/FEATURES/LIVEVIEW.md',
  'docs/PRD/FEATURES/DEVELOPER_EXPERIENCE_ENHANCEMENTS.md',
  'docs/PRD/FEATURES/CHANGE_TRACKING.md',
  'docs/PRD/DEVELOPMENT/TESTING_GUIDE.md',
  'docs/PRD/DEVELOPMENT/PERFORMANCE_TESTING_GUIDE.md',
  'docs/PRD/DEVELOPMENT/INCREMENTAL_TEST_COVERAGE.md',
  'docs/PRD/DEVELOPMENT/IMAGE_OPTIMIZATION.md',
  'docs/PRD/DEVELOPMENT/E2E_TESTING_GUIDE.md',
  'docs/PRD/DEVELOPMENT/DOCKER_SETUP.md',
  'docs/PRD/DEVELOPMENT/DEVELOPMENT_SETUP.md',
  'docs/PRD/DEVELOPMENT/COMPONENT_TESTING_GUIDE.md',
  'docs/PRD/ARCHITECTURE/SOCKET_VALIDATION.md',
  'docs/PRD/ARCHITECTURE/RESOURCE_ARCHITECTURE.md',
  'docs/PRD/ARCHITECTURE/ERROR_HANDLING.md',
  'docs/PRD/ARCHITECTURE/ENHANCED_ERROR_REPORTING.md',
  'docs/PRD/ARCHITECTURE/COMPONENT_ARCHITECTURE.md',
  'docs/PRD/ARCHITECTURE/BASELIVE_FLINT_INTEGRATION.md',
  'docs/project/documentation/templates/document-sections-template.md'
];

// Regular expression to match headings
const H1_REGEX = /^# (.+)$/;
const H2_REGEX = /^## (.+)$/;
const H3_REGEX = /^### (.+)$/;
const H4_REGEX = /^#### (.+)$/;

function fixHeadingStructure(filePath) {
  try {
    if (!fs.existsSync(filePath)) {
      console.error(`File not found: ${filePath}`);
      return;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    const newLines = [];
    
    let lastHeadingLevel = 0;
    let lastH1Content = '';
    let sectionName = '';
    let inCodeBlock = false;
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Skip processing inside code blocks
      if (line.trim().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        newLines.push(line);
        continue;
      }
      
      if (inCodeBlock) {
        newLines.push(line);
        continue;
      }
      
      // Track heading levels
      if (H1_REGEX.test(line)) {
        lastHeadingLevel = 1;
        lastH1Content = line.match(H1_REGEX)[1].trim();
        newLines.push(line);
      } else if (H2_REGEX.test(line)) {
        lastHeadingLevel = 2;
        newLines.push(line);
      } else if (H3_REGEX.test(line)) {
        const h3Content = line.match(H3_REGEX)[1].trim();
        
        // If we're jumping from H1 to H3, add an H2
        if (lastHeadingLevel === 1) {
          // Generate a section name based on the H3 content
          if (h3Content.startsWith('1.') || h3Content.startsWith('2.') || h3Content.startsWith('3.') || 
              h3Content.startsWith('4.') || h3Content.startsWith('5.')) {
            sectionName = 'Configuration Steps';
          } else if (h3Content.includes('Setup')) {
            sectionName = 'Setup Instructions';
          } else if (h3Content.includes('Commands')) {
            sectionName = 'Command Reference';
          } else if (h3Content.includes('Test')) {
            sectionName = 'Testing';
          } else if (h3Content.includes('Load')) {
            sectionName = 'Loading and Performance';
          } else if (h3Content.includes('Visual')) {
            sectionName = 'Visual Components';
          } else if (h3Content.includes('Tools')) {
            sectionName = 'Tools and Utilities';
          } else if (h3Content.includes('Tracking')) {
            sectionName = 'Tracking and Monitoring';
          } else if (h3Content.includes('Resource')) {
            sectionName = 'Resource Management';
          } else if (h3Content.includes('Integration')) {
            sectionName = 'Integration';
          } else if (h3Content.includes('Relationship')) {
            sectionName = 'Relationship Management';
          } else if (h3Content.includes('Validation')) {
            sectionName = 'Validation';
          } else if (h3Content.includes('Error')) {
            sectionName = 'Error Handling';
          } else {
            sectionName = 'Implementation Details';
          }
          
          newLines.push(`\n## ${sectionName}\n`);
          lastHeadingLevel = 2;
        }
        
        newLines.push(line);
        lastHeadingLevel = 3;
      } else if (H4_REGEX.test(line)) {
        const h4Content = line.match(H4_REGEX)[1].trim();
        
        // If we're jumping from H1 to H4, add an H2 and H3
        if (lastHeadingLevel === 1) {
          newLines.push(`\n## Implementation Details\n`);
          newLines.push(`\n### Component Details\n`);
          lastHeadingLevel = 3;
        } else if (lastHeadingLevel === 2) {
          // Add an H3 if going from H2 to H4
          newLines.push(`\n### Implementation Specifics\n`);
          lastHeadingLevel = 3;
        }
        
        newLines.push(line);
        lastHeadingLevel = 4;
      } else {
        newLines.push(line);
      }
    }
    
    const newContent = newLines.join('\n');
    
    // Only write if changes were made
    if (content !== newContent) {
      if (DRY_RUN) {
        console.log(`[DRY RUN] Would fix headings in: ${filePath}`);
        if (VERBOSE) {
          console.log('=== Before ===');
          console.log(content.substring(0, 500) + '...');
          console.log('=== After ===');
          console.log(newContent.substring(0, 500) + '...');
        }
      } else {
        fs.writeFileSync(filePath, newContent, 'utf8');
        console.log(`Fixed headings in: ${filePath}`);
      }
      return true;
    } else {
      if (VERBOSE) {
        console.log(`No heading issues found in: ${filePath}`);
      }
      return false;
    }
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
    return false;
  }
}

// Main function
function main() {
  console.log(`Fixing heading structure in ${filesWithHeadingIssues.length} Markdown files...`);
  
  let fixedCount = 0;
  
  filesWithHeadingIssues.forEach(relativePath => {
    const fullPath = path.resolve(__dirname, '..', relativePath);
    if (fixHeadingStructure(fullPath)) {
      fixedCount++;
    }
  });
  
  console.log(`\nHeading structure fix complete.`);
  console.log(`Fixed ${fixedCount} files with heading issues.`);
  
  if (DRY_RUN) {
    console.log('This was a dry run. No files were actually modified.');
    console.log('Run without --dry-run to apply changes.');
  }
}

main(); 