#!/bin/bash
# Wrapper for locked statusline - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/statusline.sh.locked" "$@"
