#!/bin/bash
# Wrapper for locked ilx_view_emitter - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_view_emitter.rb.locked" "$@"
