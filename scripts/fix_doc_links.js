#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Configuration
const DOCS_DIR = 'docs';
const MIGRATION_MAP = {
    // PRD migrations
    '../archive/PRD_MIGRATION_GUIDE.md': '../project/documentation/migration-guide.md',
    '../PRD/ARCHITECTURE/COMPONENT_ARCHITECTURE.md': '../development/components/architecture.md',
    '../PRD/DEVELOPMENT/DOCUMENTATION_PROCESS.md': '../project/documentation/process.md',
    '../PRD/FEATURES/TERMINAL_PLUGINS.md': '../development/tools/terminal-plugins.md',
    'PRD/RESOURCE_TRANSFORMATION_PIPELINE.md': 'reference/architecture/transformation-pipeline.md',
    'archive/PRD/RESOURCE_TRANSFORMATION_PIPELINE.md': 'archive/reference/architecture/transformation-pipeline.md',
    'PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md': 'reference/architecture/resource-system.md',
    'archive/PRD/RESOURCE_SYSTEM_IMPLEMENTATION.md': 'archive/reference/architecture/resource-system.md',
    'PRD/PROJECT_MANAGEMENT/ROADMAP.md': 'project/roadmap.md',
    'archive/PRD/PROJECT_MANAGEMENT/ROADMAP.md': 'archive/project/roadmap.md',
    'PRD/DEVELOPMENT/E2E_TESTING_GUIDE.md': 'development/testing/e2e-guide.md',
    'PRD/DEVELOPMENT/ES_MODULE_TESTING.md': 'development/testing/es-module-testing.md',
    'PRD/DEVELOPMENT/IMAGE_OPTIMIZATION.md': 'development/tools/image-optimization.md',
    'PRD/DEVELOPMENT/INCREMENTAL_TEST_COVERAGE.md': 'development/testing/incremental-coverage.md',
    'PRD/DEVELOPMENT/MIGRATION_TESTING_PLAN.md': 'development/testing/migration-plan.md',
    'PRD/DEVELOPMENT/NAMING_CONVENTIONS.md': 'development/guidelines/naming-conventions.md',
    'PRD/DEVELOPMENT/DOCUMENTATION_UPDATES.md': 'project/documentation/updates.md',
    'PRD/DEVELOPMENT/DOM_TESTING_CAPABILITIES.md': 'development/testing/dom-capabilities.md',
    
    // Common paths
    'reference/architecture/reference/architecture': 'reference/architecture',
    '../reference/architecture/reference/architecture': '../reference/architecture'
};

// Function to check if a file exists
function fileExists(filePath) {
    try {
        return fs.statSync(filePath).isFile();
    } catch {
        return false;
    }
}

// Function to find the actual file
function findActualFile(basePath, targetPath) {
    // Try common variations
    const variations = [
        targetPath,
        targetPath.toLowerCase(),
        targetPath.replace(/[-_]/g, '-'),
        targetPath.replace(/[-_]/g, '_'),
        path.join(path.dirname(targetPath), path.basename(targetPath, '.md').toLowerCase() + '.md')
    ];
    
    for (const variant of variations) {
        const fullPath = path.resolve(basePath, variant);
        if (fileExists(fullPath)) {
            return path.relative(basePath, fullPath);
        }
    }
    
    return null;
}

// Function to fix links in a file
function fixLinks(filePath) {
    console.log(`Processing ${filePath}...`);
    
    const content = fs.readFileSync(filePath, 'utf8');
    let updatedContent = content;
    let hasChanges = false;
    
    // Fix links using migration map
    Object.entries(MIGRATION_MAP).forEach(([oldPath, newPath]) => {
        const regex = new RegExp(`\\]\\(${oldPath.replace(/\//g, '\\/')}\\)`, 'g');
        if (regex.test(updatedContent)) {
            updatedContent = updatedContent.replace(regex, `](${newPath})`);
            hasChanges = true;
        }
    });
    
    // Fix broken relative links
    const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
    const basePath = path.dirname(filePath);
    
    updatedContent = updatedContent.replace(linkRegex, (match, text, url) => {
        if (!url.startsWith('http') && !url.startsWith('#')) {
            // Handle relative paths
            if (url.startsWith('./') || url.startsWith('../')) {
                const actualFile = findActualFile(basePath, url);
                if (actualFile) {
                    hasChanges = true;
                    return `[${text}](${actualFile})`;
                }
            }
            
            // If link is broken and we can't find the file, mark it
            if (!findActualFile(basePath, url)) {
                hasChanges = true;
                return `[${text}](${url}) <!-- TODO: Fix broken link -->`;
            }
        }
        return match;
    });
    
    // Fix recursive paths
    const recursiveRegex = /(\.\.\/)+([^)]+)\1/g;
    updatedContent = updatedContent.replace(recursiveRegex, (match, prefix, path) => {
        hasChanges = true;
        return prefix + path;
    });
    
    // Write back if changed
    if (hasChanges) {
        fs.writeFileSync(filePath, updatedContent);
        console.log(`✅ Fixed links in ${filePath}`);
    }
}

// Process all markdown files
function processDirectory(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        
        if (entry.isDirectory()) {
            processDirectory(fullPath);
        } else if (entry.name.endsWith('.md')) {
            fixLinks(fullPath);
        }
    }
}

// Main execution
console.log('Fixing documentation links...');
processDirectory(DOCS_DIR);
console.log('Done fixing documentation links.'); 