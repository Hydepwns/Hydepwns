#!/bin/bash

# CSS build script for Hydepwns project
#
# Purpose:
#   Concatenates all CSS files into a single file for the browser
#
# Usage:
#   ./scripts/build/css_builder.sh [output_path]
#
# Arguments:
#   output_path - Optional. Path to output file. Default: priv/static/assets/app.css
#
# Example:
#   ./scripts/build/css_builder.sh 
#   ./scripts/build/css_builder.sh priv/static/assets/custom.css

# Exit on any error
set -e

# Get the project root directory (works regardless of where script is called from)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Default output path
OUTPUT_PATH="priv/static/assets/app.css"

# Use custom output path if provided
if [ "$1" != "" ]; then
  OUTPUT_PATH="$1"
fi

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"

echo "Building CSS..."

# Input CSS files
CSS_FILES=(
  "assets/css/reset.css"
  "assets/css/app.css"
  "assets/css/components.css"
)

# Check that all input files exist
for file in "${CSS_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Input file not found: $file"
    exit 1
  fi
done

# Combine CSS files
cat "${CSS_FILES[@]}" > "$OUTPUT_PATH"

echo "CSS files combined successfully into $OUTPUT_PATH" 