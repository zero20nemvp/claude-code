#!/bin/bash
# Wrapper for locked ilx_emitter_hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_emitter_hook.rb.locked" "$@"
