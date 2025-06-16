#!/bin/bash
# Summarize real test failures from a test run.
# Usage: ./scripts/summarize_test_errors.sh

# Usage instructions
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: $0"
  echo "Runs mix test and summarizes warnings and errors in tmp/test_error_summary.txt"
  exit 0
fi

# Directory for storing test output
TMP_DIR="tmp"
# File to store raw test output
INPUT_FILE="$TMP_DIR/test_output.txt"
# File to store the summarized errors
OUTPUT_FILE="$TMP_DIR/test_error_summary.txt"

# Ensure tmp directory exists
mkdir -p "$TMP_DIR"

# Function to categorize warnings
categorize_warnings() {
  local input_file="$1"
  local output_file="$2"
  
  # Clear the output file
  echo "=== Test Results Summary ===" > "$output_file"
  echo "" >> "$output_file"
  
  # Unused Variables
  echo "=== Unused Variables ===" >> "$output_file"
  grep -E "variable \".*\" is unused" "$input_file" | sort -u >> "$output_file"
  echo "" >> "$output_file"
  
  # Unused Functions
  echo "=== Unused Functions ===" >> "$output_file"
  grep -E "function .* is unused" "$input_file" | sort -u >> "$output_file"
  echo "" >> "$output_file"
  
  # Unused Aliases/Imports
  echo "=== Unused Aliases/Imports ===" >> "$output_file"
  grep -E "unused (alias|import)" "$input_file" | sort -u >> "$output_file"
  echo "" >> "$output_file"
  
  # Pattern Matching Warnings
  echo "=== Pattern Matching Warnings ===" >> "$output_file"
  grep -E "this clause .* cannot match|the underscored variable .* is used after being set" "$input_file" | sort -u >> "$output_file"
  echo "" >> "$output_file"
  
  # Undefined Functions/Modules
  echo "=== Undefined Functions/Modules ===" >> "$output_file"
  grep -E "is undefined|is undefined or private" "$input_file" | sort -u >> "$output_file"
  echo "" >> "$output_file"
  
  # Other Warnings
  echo "=== Other Warnings ===" >> "$output_file"
  grep -E "warning:" "$input_file" | grep -v -E "variable .* is unused|function .* is unused|unused (alias|import)|this clause .* cannot match|the underscored variable .* is used after being set|is undefined|is undefined or private" | sort -u >> "$output_file"
  echo "" >> "$output_file"
}

# Main execution
echo "Running mix test..."
if mix test > "$INPUT_FILE" 2>&1; then
  echo "All tests passed!" > "$OUTPUT_FILE"
  echo "Full summary in $OUTPUT_FILE"
  exit 0
fi

# If mix test failed
echo "mix test failed. Full output in $INPUT_FILE" > "$OUTPUT_FILE"

# Process the output
categorize_warnings "$INPUT_FILE" "$OUTPUT_FILE"

echo "Full summary in $OUTPUT_FILE"
