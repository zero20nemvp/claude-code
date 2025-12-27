#!/bin/bash
# Wrapper for locked detect-language - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/detect-language.sh.locked" "$@"
