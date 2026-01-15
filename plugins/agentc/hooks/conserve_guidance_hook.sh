#!/bin/bash
# Wrapper for locked conserve_guidance_hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/conserve_guidance_hook.sh.locked" "$@"
