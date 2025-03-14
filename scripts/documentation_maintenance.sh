#!/bin/bash

# Documentation Maintenance Script
# This script performs regular maintenance tasks on the documentation

# Configuration
DOCS_DIR="docs"
REPORT_DIR="reports/documentation"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/maintenance-report-$DATE.md"

# Create reports directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOL
# Documentation Maintenance Report
Date: $DATE

## Overview
This report contains the results of the automated documentation maintenance checks.

EOL

# Function to run and log a check
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    echo "Running $check_name..."
    echo -e "\n## $check_name" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    eval "$check_command" >> "$REPORT_FILE" 2>&1
    local status=$?
    echo '```' >> "$REPORT_FILE"
    
    if [ $status -eq 0 ]; then
        echo "✅ $check_name passed" >> "$REPORT_FILE"
    else
        echo "❌ $check_name failed" >> "$REPORT_FILE"
    fi
    
    return $status
}

# Run documentation validation
run_check "Documentation Validation" "./scripts/ci_documentation_validation.sh"

# Check for broken links
run_check "Broken Links Check" "node scripts/automate_broken_link_fixes.js --check-only"

# Check for outdated content (files not modified in last 90 days)
echo -e "\n## Outdated Content Check" >> "$REPORT_FILE"
echo "Files not modified in the last 90 days:" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
find "$DOCS_DIR" -type f -name "*.md" -mtime +90 -exec ls -l {} \; >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"

# Check for missing metadata
echo -e "\n## Metadata Check" >> "$REPORT_FILE"
echo "Files missing required metadata:" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
for file in $(find "$DOCS_DIR" -type f -name "*.md"); do
    if ! grep -q "^---$" "$file"; then
        echo "$file is missing frontmatter metadata"
    fi
done >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"

# Check for consistency in document structure
echo -e "\n## Document Structure Check" >> "$REPORT_FILE"
echo "Files missing standard sections:" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
for file in $(find "$DOCS_DIR" -type f -name "*.md"); do
    echo "Checking $file..."
    if ! grep -q "^# " "$file"; then
        echo "$file is missing a main title (H1)"
    fi
    if ! grep -q "^## " "$file"; then
        echo "$file is missing section headers (H2)"
    fi
done >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"

# Generate summary
echo -e "\n## Summary" >> "$REPORT_FILE"
echo "Total files checked: $(find "$DOCS_DIR" -type f -name "*.md" | wc -l)" >> "$REPORT_FILE"
echo "Report generated on: $(date)" >> "$REPORT_FILE"

# Print report location
echo "Documentation maintenance report generated at: $REPORT_FILE"

# Exit with status from validation check
exit $? 