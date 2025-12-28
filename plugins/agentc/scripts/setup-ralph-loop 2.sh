#!/bin/bash
# Wrapper for locked setup-ralph-loop - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/setup-ralph-loop.sh.locked" "$@"
