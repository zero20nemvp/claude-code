#!/bin/bash
# cleanup-stale-cache.sh - Automatically remove stale cached versions of agentc
# Runs on SessionStart to ensure users always have a clean cache

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Get current version from our plugin.json
CURRENT_VERSION=$(grep -o '"version": "[^"]*"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | cut -d'"' -f4)

if [[ -z "$CURRENT_VERSION" ]]; then
  exit 0  # Can't determine version, skip cleanup
fi

CACHE_BASE="$HOME/.claude/plugins/cache"

if [[ ! -d "$CACHE_BASE" ]]; then
  exit 0  # No cache directory
fi

# Find all cached agentc versions and remove ones that don't match current version
for marketplace_dir in "$CACHE_BASE"/*/; do
  agentc_cache="$marketplace_dir/agentc"

  if [[ -d "$agentc_cache" ]]; then
    for version_dir in "$agentc_cache"/*/; do
      if [[ -d "$version_dir" ]]; then
        cached_version=$(basename "$version_dir")

        # Remove if version doesn't match current
        if [[ "$cached_version" != "$CURRENT_VERSION" ]]; then
          rm -rf "$version_dir" 2>/dev/null
        fi
      fi
    done

    # Remove empty agentc directories
    rmdir "$agentc_cache" 2>/dev/null || true
  fi
done

# Also clean up orphaned markers
find "$CACHE_BASE" -name ".orphaned_at" -delete 2>/dev/null || true

exit 0
