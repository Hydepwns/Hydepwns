#!/bin/bash
# Summarize real test failures from a test run.
# Usage: ./scripts/summarize_test_errors.sh

# Directory for storing test output
TMP_DIR="tmp"
# File to store raw test output
INPUT_FILE="$TMP_DIR/test_output.txt"
# File to store the summarized errors
OUTPUT_FILE="$TMP_DIR/test_error_summary.txt"

# Ensure tmp directory exists
mkdir -p "$TMP_DIR"

# Run the test suite and capture all output directly for inspection
echo "Running mix test..."
if mix test > "$INPUT_FILE" 2>&1; then
  echo "All tests passed!" > "$OUTPUT_FILE"
else
  echo "mix test failed. Full output in $INPUT_FILE" > "$OUTPUT_FILE"
  echo "--- Real Test Failure Summary ---" >> "$OUTPUT_FILE"

  # Extract real test failures
  # 1) test ... (Module)
  grep -nE '^\s*[0-9]+\) test ' "$INPUT_FILE" | while read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    test_header=$(echo "$line" | cut -d: -f2-)
    # Get the next 10 lines after the failure header for context (failure message, assertion, stacktrace)
    context=$(sed -n "$((line_num+1)),$((line_num+10))p" "$INPUT_FILE")
    echo "$test_header" >> "$OUTPUT_FILE"
    echo "$context" | grep -E 'Assertion with|stacktrace:|\(test/' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  done

  # If no real failures found, say so
  if ! grep -qE '^\s*[0-9]+\) test ' "$INPUT_FILE"; then
    echo "No real test failures found. (Possible non-assertion error or script bug)" >> "$OUTPUT_FILE"
  fi
fi

echo "Full summary in $OUTPUT_FILE"
