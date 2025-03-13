#!/usr/bin/env node

/**
 * Documentation Validation Script
 * 
 * This script checks documentation files for:
 * - Broken internal links
 * - Consistent formatting (heading structure, code blocks)
 * - Adherence to the style guide
 * - Spelling issues (common typos)
 * - Missing required sections
 */

const fs = require('fs');
const path = require('path');

// Try to load chalk from the script's directory, but fall back to the assets directory
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
      green: (text) => text
    };
    console.warn('Warning: chalk module not found. Console output will not be colored.');
  }
}

// Configuration
const config = {
  docsRoot: path.join(__dirname, '../../docs'),
  styleGuide: path.join(__dirname, '../../docs/PRD/PROJECT_MANAGEMENT/DOCUMENTATION_STYLE_GUIDE.md'),
  ignoreDirs: ['node_modules', '.git'],
  fileExtensions: ['.md'],
  requiredSections: ['Overview', 'References'], // Sections that should be in every document
  maxHeadingLevel: 4, // Maximum heading level (####)
  checkSpelling: true,
  verboseOutput: false
};

// Common spelling errors
const spellingErrors = {
  'accesibility': 'accessibility',
  'occuring': 'occurring',
  'seperate': 'separate',
  'accomodate': 'accommodate',
  'dependancy': 'dependency',
  'recieve': 'receive',
  'similiar': 'similar',
  'transfered': 'transferred',
  'untill': 'until'
};

// Statistics
const stats = {
  filesChecked: 0,
  errors: 0,
  warnings: 0,
  brokenLinks: 0
};

// Validation checks
const checks = {
  // Check heading structure (H1 > H2 > H3, not skipping levels)
  headingStructure: function(content, filePath) {
    const headingLevels = [];
    const lines = content.split('\n');
    const issues = [];
    
    lines.forEach((line, index) => {
      if (line.startsWith('#')) {
        const level = line.match(/^#+/)[0].length;
        headingLevels.push({ level, line, index: index + 1 });
      }
    });
    
    // Check for title (H1)
    if (headingLevels.length === 0 || headingLevels[0].level !== 1) {
      issues.push({
        type: 'error',
        message: 'Document should start with a level 1 heading (# Title)',
        line: 1
      });
    }
    
    // Check for proper hierarchy
    for (let i = 1; i < headingLevels.length; i++) {
      const current = headingLevels[i];
      const previous = headingLevels[i - 1];
      
      // Can't skip levels (e.g., H2 -> H4)
      if (current.level > previous.level && current.level - previous.level > 1) {
        issues.push({
          type: 'error',
          message: `Heading level skipped from H${previous.level} to H${current.level}`,
          line: current.index
        });
      }
      
      // Heading level too deep
      if (current.level > config.maxHeadingLevel) {
        issues.push({
          type: 'warning',
          message: `Heading level ${current.level} exceeds maximum recommended level (${config.maxHeadingLevel})`,
          line: current.index
        });
      }
    }
    
    return issues;
  },
  
  // Check for broken internal links
  brokenLinks: function(content, filePath) {
    const issues = [];
    const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
    const baseDir = path.dirname(filePath);
    let match;
    
    while ((match = linkRegex.exec(content)) !== null) {
      const [fullMatch, linkText, linkPath] = match;
      
      // Skip external links or anchor links
      if (linkPath.startsWith('http') || linkPath.startsWith('#')) {
        continue;
      }
      
      // Resolve the target file path
      const targetPath = path.resolve(baseDir, linkPath.split('#')[0]);
      
      // Check if the file exists
      if (!fs.existsSync(targetPath)) {
        issues.push({
          type: 'error',
          message: `Broken link: ${linkPath} (file does not exist)`,
          line: getLineNumber(content, fullMatch)
        });
        stats.brokenLinks++;
      }
    }
    
    return issues;
  },
  
  // Check for required sections
  requiredSections: function(content, filePath) {
    const issues = [];
    
    config.requiredSections.forEach(section => {
      // Look for section heading (## Section)
      const sectionRegex = new RegExp(`^\\s*##\\s+${section}\\b`, 'm');
      if (!sectionRegex.test(content)) {
        issues.push({
          type: 'warning',
          message: `Missing required section: ${section}`,
          line: 1
        });
      }
    });
    
    return issues;
  },
  
  // Check for code blocks with language specification
  codeBlocks: function(content, filePath) {
    const issues = [];
    const codeBlockRegex = /```([a-zA-Z]*)\n/g;
    let match;
    
    while ((match = codeBlockRegex.exec(content)) !== null) {
      const [fullMatch, language] = match;
      
      // If there's no language specified
      if (!language.trim()) {
        issues.push({
          type: 'warning',
          message: 'Code block without language specification',
          line: getLineNumber(content, fullMatch)
        });
      }
    }
    
    return issues;
  },
  
  // Check for common spelling errors
  spelling: function(content, filePath) {
    if (!config.checkSpelling) return [];
    
    const issues = [];
    
    Object.keys(spellingErrors).forEach(misspelled => {
      const regex = new RegExp(`\\b${misspelled}\\b`, 'gi');
      let match;
      
      while ((match = regex.exec(content)) !== null) {
        issues.push({
          type: 'warning',
          message: `Possible spelling error: "${misspelled}" -> "${spellingErrors[misspelled]}"`,
          line: getLineNumber(content, match[0], match.index)
        });
      }
    });
    
    return issues;
  }
};

// Helper function to get line number from content and text match
function getLineNumber(content, text, index = undefined) {
  const beforeMatch = index !== undefined 
    ? content.substring(0, index) 
    : content.substring(0, content.indexOf(text));
  
  return beforeMatch.split('\n').length;
}

// Process a file
function processFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Combined issues from all checks
  let issues = [];
  
  // Run all checks
  Object.values(checks).forEach(check => {
    const checkIssues = check(content, filePath);
    issues = [...issues, ...checkIssues];
  });
  
  // Report issues
  if (issues.length > 0) {
    console.log(chalk.blue(`\nFile: ${path.relative(config.docsRoot, filePath)}`));
    
    issues.forEach(issue => {
      const prefix = issue.type === 'error' 
        ? chalk.red('ERROR') 
        : chalk.yellow('WARNING');
      
      console.log(`  ${prefix} Line ${issue.line}: ${issue.message}`);
      
      if (issue.type === 'error') {
        stats.errors++;
      } else {
        stats.warnings++;
      }
    });
  } else if (config.verboseOutput) {
    console.log(chalk.green(`✓ ${path.relative(config.docsRoot, filePath)}`));
  }
  
  stats.filesChecked++;
}

// Process a directory recursively
function processDirectory(dirPath) {
  const items = fs.readdirSync(dirPath);
  
  items.forEach(item => {
    const itemPath = path.join(dirPath, item);
    const stat = fs.statSync(itemPath);
    
    if (stat.isDirectory() && !config.ignoreDirs.includes(item)) {
      processDirectory(itemPath);
    } else if (stat.isFile() && config.fileExtensions.includes(path.extname(item))) {
      processFile(itemPath);
    }
  });
}

// Main function
function main() {
  console.log(chalk.bold('\nHydepwns Documentation Validator'));
  console.log(chalk.bold('================================\n'));
  console.log(`Checking documentation files in: ${config.docsRoot}`);
  
  // Process all documentation
  processDirectory(config.docsRoot);
  
  // Print summary
  console.log(chalk.bold('\nValidation Summary'));
  console.log(chalk.bold('------------------'));
  console.log(`Files checked: ${stats.filesChecked}`);
  console.log(`Errors: ${stats.errors > 0 ? chalk.red(stats.errors) : chalk.green(stats.errors)}`);
  console.log(`Warnings: ${stats.warnings > 0 ? chalk.yellow(stats.warnings) : chalk.green(stats.warnings)}`);
  console.log(`Broken links: ${stats.brokenLinks > 0 ? chalk.red(stats.brokenLinks) : chalk.green(stats.brokenLinks)}`);
  
  // Exit with appropriate code
  if (stats.errors > 0) {
    console.log(chalk.red('\nValidation failed with errors. Please fix them before proceeding.'));
    process.exit(1);
  } else if (stats.warnings > 0) {
    console.log(chalk.yellow('\nValidation completed with warnings. Review them when possible.'));
    process.exit(0);
  } else {
    console.log(chalk.green('\nValidation completed successfully!'));
    process.exit(0);
  }
}

// Run the script
main(); 