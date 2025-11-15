#!/bin/bash

# AgentH Directory Detection Helper
# Sources this file to get the correct directory path

if [ -d "agenth" ]; then
  export AGENTH_DIR="agenth"
elif [ -d "agentme" ]; then
  export AGENTH_DIR="agentme"
else
  echo "Error: Neither agenth/ nor agentme/ directory found" >&2
  echo "AgentH is not initialized in this project." >&2
  exit 1
fi
