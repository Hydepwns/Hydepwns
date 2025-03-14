#!/bin/bash

# CI Documentation Validation Script
# This script performs comprehensive validation of documentation

echo "Starting documentation validation..."

# Check if documentation validation script exists
if [ ! -f "scripts/documentation_validation.js" ]; then
    echo "Error: documentation_validation.js not found"
    exit 1
fi

# Run documentation validation
echo "Running documentation validation..."
node scripts/documentation_validation.js

# Check for broken links
echo "Checking for broken links..."
node scripts/automate_broken_link_fixes.js --check-only

# Validate documentation structure
echo "Validating documentation structure..."
required_files=(
    "docs/README.md"
    "docs/TABLE_OF_CONTENTS.md"
    "docs/DOCUMENTATION_MAP.md"
    "docs/DOCUMENT_SECTIONS_TEMPLATE.md"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file $file is missing"
        exit 1
    fi
done

# Check for consistent formatting
echo "Checking documentation formatting..."
find docs -name "*.md" -exec grep -L "^# " {} \; > /tmp/missing_titles.txt
if [ -s /tmp/missing_titles.txt ]; then
    echo "Error: The following files are missing main titles:"
    cat /tmp/missing_titles.txt
    exit 1
fi

# Success message
echo "Documentation validation completed successfully!"
exit 0 