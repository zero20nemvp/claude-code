#!/bin/bash
# Wrapper for locked find-polluter - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../../run" "$DIR/find-polluter.sh.locked" "$@"
