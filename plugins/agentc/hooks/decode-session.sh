#!/bin/bash
# Wrapper for locked decode-session - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/decode-session.sh.locked" "$@"
