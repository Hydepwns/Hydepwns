#!/bin/sh
# Summarize test errors and warnings from a test run.
# Usage: ./scripts/summarize_test_errors.sh

TMP_DIR=tmp
INPUT_FILE=$TMP_DIR/test_output.txt
OUTPUT_FILE=$TMP_DIR/test_error_summary.txt
ERROR_FILE=$TMP_DIR/test_errors.txt

# Ensure tmp directory exists
mkdir -p "$TMP_DIR"

# Remove old output files to ensure fresh results
echo "Removing old test output files..."
rm -f "$INPUT_FILE" "$ERROR_FILE"

# Run the test suite and capture all output directly for inspection
echo "Running mix test..."
if mix test > "$INPUT_FILE" 2>&1; then
  echo "mix test completed successfully."
else
  echo "mix test failed. Full output in $INPUT_FILE"
fi

# Extract errors and warnings from the full output
# The original grep might be too broad or too narrow for this specific Mox issue.
# Let's be more targeted for now or just look at INPUT_FILE manually.
echo "Filtering $INPUT_FILE for errors and warnings..."
grep -E -i "(compilation error|undefinedfunctionerror|mox.__using__|error|warning|failed|== Compilation error)" "$INPUT_FILE" > "$ERROR_FILE"

cat "$ERROR_FILE"
echo "Full summary in $ERROR_FILE" 