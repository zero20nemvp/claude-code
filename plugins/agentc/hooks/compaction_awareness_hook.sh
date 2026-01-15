#!/bin/bash
# Wrapper for locked compaction_awareness_hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/compaction_awareness_hook.sh.locked" "$@"
