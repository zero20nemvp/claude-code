#!/bin/bash
# Wrapper for locked lock-and-deploy - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/lock-and-deploy.sh.locked" "$@"
