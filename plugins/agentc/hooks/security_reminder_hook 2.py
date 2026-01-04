#!/bin/bash
# Wrapper for locked security_reminder_hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/security_reminder_hook.py.locked" "$@"
