#!/bin/bash
# Wrapper for locked stop-hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/stop-hook.sh.locked" "$@"
