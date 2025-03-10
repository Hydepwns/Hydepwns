#!/bin/bash

# CSS build script for Hydepwns project
# This script concatenates all CSS files into a single file for the browser

# Create output directory if it doesn't exist
mkdir -p ../priv/static/assets

# Combine CSS files
cat assets/css/reset.css assets/css/app.css assets/css/components.css > priv/static/assets/app.css

echo "CSS files combined successfully into priv/static/assets/app.css" 