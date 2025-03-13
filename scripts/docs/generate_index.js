#!/usr/bin/env node

/**
 * Documentation Index Generator
 * 
 * This script scans the documentation directories and generates:
 * 1. An updated README.md in the docs/PRD directory with correct links
 * 2. An updated DOCUMENTATION_MAP.md with migration status
 * 3. Validates internal links between documentation files
 *
 * Usage:
 *   node scripts/docs/generate_index.js
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// Configuration
const docRoot = path.join(__dirname, '../../docs');
const prdRoot = path.join(docRoot, 'PRD');

// Categories for organizing documentation
const categories = {
  'PROJECT_MANAGEMENT': 'Project Management',
  'ARCHITECTURE': 'Architecture',
  'DEVELOPMENT': 'Development',
  'FEATURES': 'Features',
  'DEPLOYMENT': 'Deployment',
  'DESIGN': 'Design'
};

// Function to get all markdown files recursively
async function getMarkdownFiles(dir, fileList = []) {
  const files = await readdirAsync(dir);
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = await statAsync(filePath);
    
    if (stat.isDirectory()) {
      fileList = await getMarkdownFiles(filePath, fileList);
    } else if (file.endsWith('.md')) {
      fileList.push(filePath);
    }
  }
  
  return fileList;
}

// Function to extract title from markdown file
async function extractTitle(filePath) {
  try {
    const content = await readFileAsync(filePath, 'utf8');
    const titleMatch = content.match(/^# (.*)/m);
    return titleMatch ? titleMatch[1] : path.basename(filePath, '.md');
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error);
    return path.basename(filePath, '.md');
  }
}

// Function to check if a file in docs has been migrated to PRD
function isMigrated(file, prdFiles) {
  const baseName = path.basename(file);
  return prdFiles.some(prdFile => path.basename(prdFile) === baseName);
}

// Function to generate documentation map
async function generateDocumentationMap(docsFiles, prdFiles) {
  const prdCategories = {};
  
  // Group PRD files by category
  for (const file of prdFiles) {
    const relativePath = path.relative(prdRoot, file);
    const category = relativePath.split(path.sep)[0];
    
    if (!prdCategories[category]) {
      prdCategories[category] = [];
    }
    
    prdCategories[category].push(file);
  }
  
  // Generate documentation map content
  let mapContent = `# Documentation Map

This file helps you find documentation that has been moved to the new PRD structure.

## Documentation Structure Changes

We have reorganized our documentation to improve navigation and discoverability. The main documentation is now organized in the \`docs/PRD/\` directory.

## Where to Find Documentation

| Looking for... | New Location |
|----------------|--------------|
| Main Documentation Index | [PRD/README.md](PRD/README.md) |
| Getting Started | [PRD/GETTING_STARTED.md](PRD/GETTING_STARTED.md) |
`;

  // Add entries for each category
  for (const [category, files] of Object.entries(prdCategories)) {
    if (categories[category]) {
      for (const file of files) {
        const title = await extractTitle(file);
        const relativePath = path.relative(docRoot, file).replace(/\\/g, '/');
        mapContent += `| ${title} | [${relativePath}](${relativePath}) |\n`;
      }
    }
  }
  
  // Add entries for non-migrated files
  const nonMigratedFiles = docsFiles.filter(file => 
    path.relative(docRoot, file).split(path.sep)[0] !== 'PRD' && 
    !isMigrated(file, prdFiles)
  );
  
  if (nonMigratedFiles.length > 0) {
    mapContent += `\n## Feature-Specific Documentation\n\nSome feature-specific documentation remains in the main docs directory:\n\n`;
    
    for (const file of nonMigratedFiles) {
      const relativePath = path.relative(docRoot, file).replace(/\\/g, '/');
      const title = await extractTitle(file);
      mapContent += `- [${title}](${relativePath})\n`;
    }
  }
  
  // Add development process section
  mapContent += `\n## Development Process\n\n`;
  mapContent += `- [Component Documentation Template](COMPONENT_DOCUMENTATION_TEMPLATE.md)\n`;
  mapContent += `- [Testing Strategy](TESTING_STRATEGY.md)\n`;
  
  return mapContent;
}

// Function to generate PRD README
async function generatePrdReadme(prdFiles) {
  let readmeContent = `# Hydepwns Project Documentation

Welcome to the Hydepwns Project Documentation. This document serves as the main index for all project documentation.

## Overview

Hydepwns is a Phoenix LiveView application that implements a personal website with a focus on monospace typography and clean grid-based layouts.

### Key Features

- **Monospace Typography**: Pixel-perfect character grid alignment
- **Theme System**: Light, Dark, and Dim modes with persistent preferences
- **Phoenix LiveView**: Real-time user experiences without JavaScript
- **Responsive Design**: Mobile-friendly layouts that maintain grid precision
- **Resource Management**: Comprehensive system for managing, validating, and tracking changes to resources
  - Relationship Management System
  - Change Tracking Implementation
  - Nested Resource Validation with dependency resolution and hierarchical error reporting

## Documentation Structure

`;

  // Add entries for each category
  for (const [categoryKey, categoryName] of Object.entries(categories)) {
    const categoryFiles = prdFiles.filter(file => {
      const relativePath = path.relative(prdRoot, file);
      return relativePath.split(path.sep)[0] === categoryKey;
    });
    
    if (categoryFiles.length > 0) {
      readmeContent += `### ${categoryName}\n\n`;
      
      for (const file of categoryFiles) {
        const title = await extractTitle(file);
        const relativePath = path.relative(prdRoot, file).replace(/\\/g, '/');
        readmeContent += `- [${title}](${relativePath})\n`;
      }
      
      readmeContent += '\n';
    }
  }
  
  // Add quick start section
  readmeContent += `## Quick Start

\`\`\`bash
# Install dependencies
mix deps.get

# Setup database
mix ecto.setup

# Install and compile assets
mix assets.setup
mix assets.build

# Start Phoenix server
mix phx.server
\`\`\`

Visit [\`localhost:4000\`](http://localhost:4000) to see the application.

For detailed setup instructions, see the [Development Setup](DEVELOPMENT/DEVELOPMENT_SETUP.md) guide.
`;

  return readmeContent;
}

// Function to validate internal links
async function validateInternalLinks(files) {
  const brokenLinks = [];
  
  for (const file of files) {
    try {
      const content = await readFileAsync(file, 'utf8');
      const linkMatches = content.matchAll(/\[.*?\]\((.*?)\)/g);
      
      for (const match of linkMatches) {
        const link = match[1];
        
        // Skip external links, anchors, and absolute paths
        if (link.startsWith('http') || link.startsWith('#') || link.startsWith('/')) {
          continue;
        }
        
        const linkPath = path.resolve(path.dirname(file), link.split('#')[0]);
        
        try {
          await statAsync(linkPath);
        } catch (error) {
          brokenLinks.push({
            file: path.relative(process.cwd(), file),
            link: link,
            resolvedPath: path.relative(process.cwd(), linkPath)
          });
        }
      }
    } catch (error) {
      console.error(`Error processing ${file}:`, error);
    }
  }
  
  return brokenLinks;
}

// Main function
async function main() {
  try {
    console.log('Scanning documentation directories...');
    
    // Get all markdown files
    const docsFiles = await getMarkdownFiles(docRoot);
    const prdFiles = docsFiles.filter(file => file.includes(path.join('docs', 'PRD')));
    
    // Generate documentation map
    console.log('Generating documentation map...');
    const mapContent = await generateDocumentationMap(docsFiles, prdFiles);
    await writeFileAsync(path.join(docRoot, 'DOCUMENTATION_MAP.md'), mapContent);
    
    // Generate PRD README
    console.log('Generating PRD README...');
    const readmeContent = await generatePrdReadme(prdFiles);
    await writeFileAsync(path.join(prdRoot, 'README.md'), readmeContent);
    
    // Validate internal links
    console.log('Validating internal links...');
    const brokenLinks = await validateInternalLinks(docsFiles);
    
    if (brokenLinks.length > 0) {
      console.log('\nWarning: Found broken internal links:');
      for (const { file, link, resolvedPath } of brokenLinks) {
        console.log(`  - In ${file}: Link to "${link}" (resolved to "${resolvedPath}") is broken`);
      }
    } else {
      console.log('All internal links are valid!');
    }
    
    console.log('\nDocumentation index generation completed successfully!');
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

// Run the script
main(); 