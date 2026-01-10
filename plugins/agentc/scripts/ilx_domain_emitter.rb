#!/bin/bash
# Wrapper for locked ilx_domain_emitter - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_domain_emitter.rb.locked" "$@"
