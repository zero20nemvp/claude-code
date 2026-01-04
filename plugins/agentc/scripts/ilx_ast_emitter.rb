#!/bin/bash
# Wrapper for locked ilx_ast_emitter - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_ast_emitter.rb.locked" "$@"
