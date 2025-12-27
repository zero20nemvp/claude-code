#!/bin/bash
# Wrapper for locked timer - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/timer.sh.locked" "$@"
