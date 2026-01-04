#!/bin/bash
# Wrapper for locked ilx_batch_convert - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_batch_convert.rb.locked" "$@"
