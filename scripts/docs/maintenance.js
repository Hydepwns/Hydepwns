#!/usr/bin/env node

/**
 * Documentation Maintenance Script
 * 
 * A comprehensive tool for maintaining documentation in the Hydepwns project.
 * This script serves as an entry point for various documentation maintenance tasks:
 * 
 * - Validating documentation formatting and structure
 * - Generating and updating documentation indexes
 * - Tracking documentation migration status
 * - Checking for broken links
 * - Generating reports on documentation health
 * 
 * Usage:
 *   node scripts/docs/maintenance.js [command] [options]
 * 
 * Commands:
 *   validate   - Check documentation for issues
 *   index      - Update documentation indexes
 *   migration  - Show documentation migration status
 *   links      - Check for broken internal links
 *   stats      - Generate documentation statistics
 *   health     - Comprehensive documentation health check
 *   fix        - Attempt to fix common issues automatically
 *   all        - Run all checks (default)
 * 
 * Options:
 *   --fix      - Attempt to fix issues automatically
 *   --report   - Generate HTML report
 *   --verbose  - Show detailed output
 *   --quiet    - Show only errors
 * 
 * Examples:
 *   node scripts/docs/maintenance.js validate
 *   node scripts/docs/maintenance.js health --report
 *   node scripts/docs/maintenance.js all --fix
 * 
 * Author: Hydepwns Team
 * Created: 2024-03-13
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

// Try to load chalk for colored output
let chalk;
try {
  chalk = require('chalk');
} catch (e) {
  // If chalk is not available, create a simple replacement
  chalk = {
    bold: text => text,
    red: text => text,
    green: text => text,
    yellow: text => text,
    blue: text => text,
    cyan: text => text,
    gray: text => text
  };
}

// Configuration
const SCRIPTS_DIR = __dirname;
const ROOT_DIR = path.join(__dirname, '../..');
const DOCS_DIR = path.join(ROOT_DIR, 'docs');
const PRD_DIR = path.join(DOCS_DIR, 'PRD');
const REPORTS_DIR = path.join(ROOT_DIR, 'tmp/doc_reports');

// Script paths
const SCRIPTS = {
  validate: path.join(SCRIPTS_DIR, 'validate_documentation.js'),
  index: path.join(SCRIPTS_DIR, 'generate_index.js'),
  migration: path.join(SCRIPTS_DIR, 'doc_migration_status.js')
};

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0] || 'all';
const options = {
  fix: args.includes('--fix'),
  report: args.includes('--report'),
  verbose: args.includes('--verbose'),
  quiet: args.includes('--quiet')
};

/**
 * Main function
 */
async function main() {
  printHeader('Documentation Maintenance');
  
  try {
    switch (command) {
      case 'validate':
        await validateDocumentation();
        break;
      case 'index':
        await updateIndexes();
        break;
      case 'migration':
        await checkMigrationStatus();
        break;
      case 'links':
        await checkLinks();
        break;
      case 'stats':
        await generateStats();
        break;
      case 'health':
        await healthCheck();
        break;
      case 'fix':
        await fixIssues();
        break;
      case 'all':
        await runAllChecks();
        break;
      default:
        console.log(chalk.red(`Unknown command: ${command}`));
        printUsage();
        process.exit(1);
    }
  } catch (error) {
    console.error(chalk.red('Error running maintenance script:'));
    console.error(error);
    process.exit(1);
  }
}

/**
 * Run documentation validation
 */
async function validateDocumentation() {
  printSection('Documentation Validation');
  
  try {
    const { stdout, stderr } = await execAsync(`node ${SCRIPTS.validate}`);
    if (!options.quiet) {
      console.log(stdout);
    }
    if (stderr) {
      console.error(chalk.red(stderr));
    }
    console.log(chalk.green('✓ Documentation validation complete'));
  } catch (error) {
    console.error(chalk.red('✗ Documentation validation failed:'));
    console.error(error.stdout || error.message);
    return false;
  }
  return true;
}

/**
 * Update documentation indexes
 */
async function updateIndexes() {
  printSection('Updating Documentation Indexes');
  
  try {
    const { stdout, stderr } = await execAsync(`node ${SCRIPTS.index}`);
    if (!options.quiet) {
      console.log(stdout);
    }
    if (stderr) {
      console.error(chalk.red(stderr));
    }
    console.log(chalk.green('✓ Documentation indexes updated'));
  } catch (error) {
    console.error(chalk.red('✗ Failed to update documentation indexes:'));
    console.error(error.stdout || error.message);
    return false;
  }
  return true;
}

/**
 * Check documentation migration status
 */
async function checkMigrationStatus() {
  printSection('Documentation Migration Status');
  
  try {
    const { stdout, stderr } = await execAsync(`node ${SCRIPTS.migration}`);
    console.log(stdout);
    if (stderr) {
      console.error(chalk.red(stderr));
    }
  } catch (error) {
    console.error(chalk.red('✗ Failed to check migration status:'));
    console.error(error.stdout || error.message);
    return false;
  }
  return true;
}

/**
 * Check for broken links in documentation
 */
async function checkLinks() {
  printSection('Checking Internal Links');
  
  // This is partially duplicating functionality in validate_documentation.js
  // but focusing specifically on links
  let brokenLinks = 0;
  const mdFiles = findMarkdownFiles(DOCS_DIR);
  
  for (const file of mdFiles) {
    const content = fs.readFileSync(file, 'utf8');
    const links = extractLinks(content);
    
    for (const link of links) {
      if (link.startsWith('http')) continue; // Skip external links
      
      const fullPath = resolveInternalLink(file, link);
      if (!fs.existsSync(fullPath)) {
        console.error(chalk.red(`✗ Broken link in ${file}: ${link} -> ${fullPath}`));
        brokenLinks++;
      }
    }
  }
  
  if (brokenLinks === 0) {
    console.log(chalk.green('✓ No broken internal links found'));
    return true;
  } else {
    console.error(chalk.red(`✗ Found ${brokenLinks} broken internal links`));
    return false;
  }
}

/**
 * Extract links from markdown content
 */
function extractLinks(content) {
  const links = [];
  const linkRegex = /\[.*?\]\((.*?)\)/g;
  let match;
  
  while ((match = linkRegex.exec(content)) !== null) {
    links.push(match[1]);
  }
  
  return links;
}

/**
 * Resolve an internal link to a full file path
 */
function resolveInternalLink(sourceFile, link) {
  if (link.startsWith('http')) return link;
  
  const sourceDir = path.dirname(sourceFile);
  const linkPath = link.split('#')[0]; // Remove hash fragment
  
  return path.resolve(sourceDir, linkPath);
}

/**
 * Generate documentation statistics
 */
async function generateStats() {
  printSection('Documentation Statistics');
  
  // Find all markdown files
  const mdFiles = findMarkdownFiles(DOCS_DIR);
  
  // Collect statistics
  const stats = {
    totalFiles: mdFiles.length,
    totalLines: 0,
    byDirectory: {},
    byMonth: {}
  };
  
  for (const file of mdFiles) {
    const content = fs.readFileSync(file, 'utf8');
    const lines = content.split('\n').length;
    stats.totalLines += lines;
    
    // Group by directory
    const relPath = path.relative(DOCS_DIR, file);
    const dir = path.dirname(relPath);
    stats.byDirectory[dir] = stats.byDirectory[dir] || { files: 0, lines: 0 };
    stats.byDirectory[dir].files++;
    stats.byDirectory[dir].lines += lines;
    
    // Group by modification month
    const stat = fs.statSync(file);
    const month = new Date(stat.mtime).toISOString().substring(0, 7); // YYYY-MM
    stats.byMonth[month] = stats.byMonth[month] || { files: 0, lines: 0 };
    stats.byMonth[month].files++;
    stats.byMonth[month].lines += lines;
  }
  
  // Print statistics
  console.log(chalk.bold(`Total documentation files: ${stats.totalFiles}`));
  console.log(chalk.bold(`Total documentation lines: ${stats.totalLines}`));
  
  console.log('\nDocumentation by directory:');
  for (const [dir, dirStats] of Object.entries(stats.byDirectory)) {
    console.log(`  ${dir}: ${dirStats.files} files, ${dirStats.lines} lines`);
  }
  
  console.log('\nDocumentation by modification month:');
  const sortedMonths = Object.keys(stats.byMonth).sort().reverse();
  for (const month of sortedMonths) {
    console.log(`  ${month}: ${stats.byMonth[month].files} files modified`);
  }
  
  if (options.report) {
    generateStatsReport(stats);
  }
  
  return true;
}

/**
 * Find all markdown files in a directory
 */
function findMarkdownFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      // Skip node_modules and hidden directories
      if (file !== 'node_modules' && !file.startsWith('.')) {
        findMarkdownFiles(filePath, fileList);
      }
    } else if (file.endsWith('.md')) {
      fileList.push(filePath);
    }
  }
  
  return fileList;
}

/**
 * Generate an HTML report for documentation statistics
 */
function generateStatsReport(stats) {
  if (!fs.existsSync(REPORTS_DIR)) {
    fs.mkdirSync(REPORTS_DIR, { recursive: true });
  }
  
  const reportPath = path.join(REPORTS_DIR, 'doc_stats.html');
  
  let html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Hydepwns Documentation Statistics</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 20px; }
    h1 { color: #333; }
    .stat-panel { background: #f5f5f5; border-radius: 4px; padding: 15px; margin: 15px 0; }
    table { width: 100%; border-collapse: collapse; }
    th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
    th { background-color: #f1f1f1; }
    .chart { height: 200px; margin: 20px 0; }
  </style>
</head>
<body>
  <h1>Hydepwns Documentation Statistics</h1>
  
  <div class="stat-panel">
    <h2>Overview</h2>
    <p>Total files: ${stats.totalFiles}</p>
    <p>Total lines: ${stats.totalLines}</p>
    <p>Generated: ${new Date().toISOString()}</p>
  </div>
  
  <div class="stat-panel">
    <h2>Documentation by Directory</h2>
    <table>
      <tr>
        <th>Directory</th>
        <th>Files</th>
        <th>Lines</th>
      </tr>
  `;
  
  for (const [dir, dirStats] of Object.entries(stats.byDirectory)) {
    html += `
      <tr>
        <td>${dir}</td>
        <td>${dirStats.files}</td>
        <td>${dirStats.lines}</td>
      </tr>
    `;
  }
  
  html += `
    </table>
  </div>
  
  <div class="stat-panel">
    <h2>Documentation by Modification Month</h2>
    <table>
      <tr>
        <th>Month</th>
        <th>Files Modified</th>
      </tr>
  `;
  
  const sortedMonths = Object.keys(stats.byMonth).sort().reverse();
  for (const month of sortedMonths) {
    html += `
      <tr>
        <td>${month}</td>
        <td>${stats.byMonth[month].files}</td>
      </tr>
    `;
  }
  
  html += `
    </table>
  </div>
  
</body>
</html>
  `;
  
  fs.writeFileSync(reportPath, html);
  console.log(chalk.green(`✓ Statistics report generated: ${reportPath}`));
}

/**
 * Run a comprehensive health check on documentation
 */
async function healthCheck() {
  printSection('Documentation Health Check');
  
  let success = true;
  
  success = await validateDocumentation() && success;
  success = await checkLinks() && success;
  success = await checkMigrationStatus() && success;
  await generateStats();
  
  if (success) {
    console.log(chalk.green('\n✓ Documentation health check passed'));
  } else {
    console.error(chalk.red('\n✗ Documentation health check found issues'));
    if (options.fix) {
      await fixIssues();
    } else {
      console.log(chalk.yellow('\nRun with --fix option to attempt automatic fixes:'));
      console.log('  node scripts/docs/maintenance.js health --fix');
    }
  }
  
  return success;
}

/**
 * Attempt to fix common documentation issues
 */
async function fixIssues() {
  printSection('Fixing Documentation Issues');
  
  // Update indexes first
  await updateIndexes();
  
  // Find all markdown files
  const mdFiles = findMarkdownFiles(DOCS_DIR);
  let fixedIssues = 0;
  
  for (const file of mdFiles) {
    let content = fs.readFileSync(file, 'utf8');
    let originalContent = content;
    
    // Fix common issues
    content = fixMarkdownHeadings(content);
    content = fixBrokenLinks(file, content);
    content = fixCodeBlocks(content);
    content = fixTableFormatting(content);
    
    if (content !== originalContent) {
      fs.writeFileSync(file, content);
      console.log(chalk.green(`✓ Fixed issues in ${path.relative(ROOT_DIR, file)}`));
      fixedIssues++;
    }
  }
  
  if (fixedIssues > 0) {
    console.log(chalk.green(`\n✓ Fixed issues in ${fixedIssues} files`));
  } else {
    console.log(chalk.green('\n✓ No fixable issues found'));
  }
  
  return true;
}

/**
 * Fix markdown headings
 */
function fixMarkdownHeadings(content) {
  // Ensure there's a single h1 at the top
  const lines = content.split('\n');
  let hasH1 = false;
  let result = [];
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    if (line.startsWith('# ')) {
      if (!hasH1) {
        hasH1 = true;
        result.push(line);
      } else {
        // Convert subsequent h1s to h2s
        result.push('#' + line);
      }
    } else {
      result.push(line);
    }
  }
  
  return result.join('\n');
}

/**
 * Fix broken internal links
 */
function fixBrokenLinks(file, content) {
  const links = extractLinks(content);
  let newContent = content;
  
  for (const link of links) {
    if (link.startsWith('http')) continue; // Skip external links
    
    const fullPath = resolveInternalLink(file, link);
    if (!fs.existsSync(fullPath)) {
      // Try to find alternative link
      const alternativeLink = findAlternativeLink(link);
      if (alternativeLink) {
        newContent = newContent.replace(`](${link})`, `](${alternativeLink})`);
      }
    }
  }
  
  return newContent;
}

/**
 * Find an alternative link for a broken link
 */
function findAlternativeLink(brokenLink) {
  // Implementation would depend on your specific documentation structure
  // This is a placeholder for a more sophisticated link correction algorithm
  const filename = path.basename(brokenLink);
  
  // Look for files with the same name in PRD structure
  const mdFiles = findMarkdownFiles(PRD_DIR);
  for (const file of mdFiles) {
    if (path.basename(file) === filename) {
      return path.relative(path.dirname(brokenLink), file);
    }
  }
  
  return null;
}

/**
 * Fix code blocks
 */
function fixCodeBlocks(content) {
  // Ensure code blocks have language specification
  let newContent = content.replace(/```\n/g, '```text\n');
  
  // Ensure proper spacing around code blocks
  newContent = newContent.replace(/([^\n])```/g, '$1\n```');
  newContent = newContent.replace(/```([^\n])/g, '```\n$1');
  
  return newContent;
}

/**
 * Fix table formatting
 */
function fixTableFormatting(content) {
  const lines = content.split('\n');
  let inTable = false;
  let tableStartIndex = -1;
  let result = [];
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    
    if (line.startsWith('|') && line.endsWith('|')) {
      if (!inTable) {
        inTable = true;
        tableStartIndex = result.length;
      }
      
      // Ensure equal spacing in table cells
      const cells = line.split('|').slice(1, -1);
      const formattedCells = cells.map(cell => ` ${cell.trim()} `);
      result.push(`|${formattedCells.join('|')}|`);
    } else if (inTable && line.startsWith('|-') && line.endsWith('-|')) {
      // Standardize separator row
      const cells = line.split('|').slice(1, -1);
      const formattedSeparators = cells.map(() => ' --- ');
      result.push(`|${formattedSeparators.join('|')}|`);
    } else {
      if (inTable) {
        inTable = false;
        // Ensure table has a proper separator row
        const hasHeader = tableStartIndex >= 0 && result.length > tableStartIndex + 1;
        if (hasHeader) {
          const headerRow = result[tableStartIndex];
          const cellCount = headerRow.split('|').length - 2;
          if (!result[tableStartIndex + 1].includes('---')) {
            const separators = Array(cellCount).fill(' --- ');
            result.splice(tableStartIndex + 1, 0, `|${separators.join('|')}|`);
          }
        }
      }
      result.push(lines[i]);
    }
  }
  
  return result.join('\n');
}

/**
 * Run all documentation maintenance checks
 */
async function runAllChecks() {
  console.log(chalk.blue('Running all documentation maintenance checks...\n'));
  
  const validationSuccess = await validateDocumentation();
  await updateIndexes();
  await checkMigrationStatus();
  const linksSuccess = await checkLinks();
  await generateStats();
  
  console.log(chalk.bold('\nDocumentation Maintenance Summary:'));
  
  if (validationSuccess && linksSuccess) {
    console.log(chalk.green('✓ All checks passed'));
  } else {
    console.error(chalk.red('✗ Some checks failed'));
    
    if (options.fix) {
      await fixIssues();
    } else {
      console.log(chalk.yellow('\nRun with --fix option to attempt automatic fixes:'));
      console.log('  node scripts/docs/maintenance.js all --fix');
    }
  }
}

/**
 * Print a header section
 */
function printHeader(text) {
  const border = '='.repeat(text.length + 4);
  console.log(chalk.cyan(border));
  console.log(chalk.cyan(`= ${chalk.bold(text)} =`));
  console.log(chalk.cyan(border));
  console.log('');
}

/**
 * Print a section title
 */
function printSection(text) {
  console.log(chalk.blue(`\n${text}`));
  console.log(chalk.blue('-'.repeat(text.length)));
}

/**
 * Print usage information
 */
function printUsage() {
  console.log(`
Usage:
  node scripts/docs/maintenance.js [command] [options]

Commands:
  validate   - Check documentation for issues
  index      - Update documentation indexes
  migration  - Show documentation migration status
  links      - Check for broken internal links
  stats      - Generate documentation statistics
  health     - Comprehensive documentation health check
  fix        - Attempt to fix common issues automatically
  all        - Run all checks (default)

Options:
  --fix      - Attempt to fix issues automatically
  --report   - Generate HTML report
  --verbose  - Show detailed output
  --quiet    - Show only errors
`);
}

// Run the main function
main().catch(error => {
  console.error(chalk.red('Unhandled error:'));
  console.error(error);
  process.exit(1);
}); 