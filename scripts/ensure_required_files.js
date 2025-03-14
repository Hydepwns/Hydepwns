#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');

// Configuration
const DOCS_DIR = 'docs';
const TEMPLATE_FILE = 'docs/DOCUMENT_SECTIONS_TEMPLATE.md';

// Required files with their templates
const REQUIRED_FILES = {
    'project/documentation/migration-guide.md': {
        title: 'Documentation Migration Guide',
        description: 'Guide for the documentation migration process and new structure',
        topics: ['documentation', 'migration', 'guide'],
        content: `# Documentation Migration Guide

This guide provides information about the documentation migration process and how to find content in the new structure.

## Overview

The documentation has been reorganized to improve maintainability and discoverability. This guide helps you understand the changes and find migrated content.

## Migration Status

All documentation has been migrated from the PRD directory to the new structure:

- \`docs/guides/*\` - Getting started and how-to guides
- \`docs/development/*\` - Development documentation
- \`docs/reference/*\` - Technical reference
- \`docs/project/*\` - Project management documentation

## Finding Migrated Content

Here's where to find commonly accessed documentation:

| Old Location | New Location |
|-------------|--------------|
| \`PRD/README.md\` | \`guides/getting-started/overview.md\` |
| \`PRD/GETTING_STARTED.md\` | \`guides/getting-started/installation.md\` |
| \`PRD/ARCHITECTURE/*\` | \`reference/architecture/*\` |
| \`PRD/DEVELOPMENT/*\` | \`development/*\` |
| \`PRD/FEATURES/*\` | \`development/features/*\` |
| \`PRD/PROJECT_MANAGEMENT/*\` | \`project/*\` |

## Document Structure

All documentation now follows a standardized structure:

1. Frontmatter metadata
2. Title and description
3. Standard sections (Overview, Prerequisites, etc.)
4. References and related documents

## References

* [Documentation Map](../DOCUMENTATION_MAP.md)
* [Documentation Process](process.md)
* [Documentation Updates](updates.md)`
    },
    'development/testing/e2e-guide.md': {
        title: 'End-to-End Testing Guide',
        description: 'Guide for implementing and running end-to-end tests',
        topics: ['testing', 'e2e', 'development'],
        content: `# End-to-End Testing Guide

Comprehensive guide for implementing and running end-to-end tests.

## Overview

This guide covers the end-to-end testing strategy and implementation details.

## Prerequisites

* Node.js 18 or later
* npm 8 or later
* Basic understanding of testing concepts

## Test Implementation

Details about implementing end-to-end tests...

## Running Tests

Instructions for running the tests...

## References

* [Testing Framework Guide](framework-guide.md)
* [DOM Testing Capabilities](dom-capabilities.md)`
    }
    // Add more required files as needed
};

// Function to ensure a file exists with proper content
function ensureFileExists(filePath, template) {
    const fullPath = path.join(DOCS_DIR, filePath);
    const dirPath = path.dirname(fullPath);
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
        console.log(`✅ Created directory: ${dirPath}`);
    }
    
    // Create or update file
    if (!fs.existsSync(fullPath)) {
        const { title, description, topics, content } = template;
        const frontmatter = {
            title,
            description,
            topics,
            last_updated: new Date().toISOString().split('T')[0]
        };
        
        const fileContent = matter.stringify(content, frontmatter);
        fs.writeFileSync(fullPath, fileContent);
        console.log(`✅ Created file: ${fullPath}`);
    }
}

// Main execution
console.log('Ensuring required files exist...');

Object.entries(REQUIRED_FILES).forEach(([filePath, template]) => {
    ensureFileExists(filePath, template);
});

console.log('Done ensuring required files exist.'); 