#!/bin/bash
# Detect project language based on manifest files
# Returns: "ruby", "javascript", or "unknown"

if [ -f "Gemfile" ]; then
    echo "ruby"
elif [ -f "package.json" ]; then
    echo "javascript"
else
    echo "unknown"
fi
