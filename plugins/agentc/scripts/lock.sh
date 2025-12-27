#!/bin/bash
# File locking for AgentC multi-process safety
# Usage: lock.sh lock|unlock [file]
#
# Uses mkdir-based locking for cross-platform compatibility (macOS + Linux)

set -e

ACTION="${1:-}"
FILE="${2:-agentc/agentc.json}"
LOCKDIR="${FILE}.lock"
TIMEOUT=30  # seconds

lock() {
  local elapsed=0
  while ! mkdir "$LOCKDIR" 2>/dev/null; do
    if [ $elapsed -ge $TIMEOUT ]; then
      echo "Lock timeout after ${TIMEOUT}s - another session may be active" >&2
      exit 1
    fi
    sleep 0.5
    elapsed=$((elapsed + 1))
  done
  # Store PID for debugging
  echo "$$" > "${LOCKDIR}/pid"
}

unlock() {
  rm -rf "$LOCKDIR" 2>/dev/null || true
}

case "$ACTION" in
  lock)
    lock
    ;;
  unlock)
    unlock
    ;;
  *)
    echo "Usage: lock.sh lock|unlock [file]" >&2
    exit 1
    ;;
esac
