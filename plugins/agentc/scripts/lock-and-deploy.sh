#!/bin/bash
# lock-and-deploy.sh - Lock agentc plugin and deploy to BOTH marketplaces (submodule version)
# Usage: ./lock-and-deploy.sh [version_message]

set -e

# Derive paths from script location (works with submodules)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PLUGIN="$(dirname "$SCRIPT_DIR")"  # agentc plugin directory
PLUGIN_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"  # turg repo root (3 levels up: scripts -> agentc -> plugins -> turg)

# Submodule locations
PROMPTLOCK_DIR="$PLUGIN_ROOT/marketplaces/context-lock"
LOCKED_OUTPUT="$PROMPTLOCK_DIR/plugins/locked"

# Centralized key location
KEY_PATH="$HOME/.config/context-lock/keys/agentc"

# Per-plugin glossary - stored IN THE REPO so it's version controlled
# This ensures consistent token IDs across machines/deploys
GLOSSARY_PATH="$SOURCE_PLUGIN/.context-lock/glossary.yml"

# Marketplace 1: claude-code (zero2one-turg) - submodule
MARKETPLACE_1="$PLUGIN_ROOT/marketplaces/claude-code"
MARKETPLACE_1_PLUGIN="$MARKETPLACE_1/plugins/agentc"
MARKETPLACE_1_JSON="$MARKETPLACE_1/.claude-plugin/marketplace.json"

# Marketplace 2: promptlock (context-lock) - submodule with lock.yml backup
MARKETPLACE_2="$PROMPTLOCK_DIR"
MARKETPLACE_2_PLUGIN="$LOCKED_OUTPUT/agentc"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
ALLOW_REMOVAL=false
COMMIT_MSG=""
for arg in "$@"; do
    case $arg in
        --allow-removal)
            ALLOW_REMOVAL=true
            shift
            ;;
        *)
            COMMIT_MSG="$arg"
            ;;
    esac
done

echo -e "${GREEN}=== Lock and Deploy (Submodule Edition) ===${NC}"
echo "Source: $SOURCE_PLUGIN"
echo "Target 1: $MARKETPLACE_1_PLUGIN (claude-code submodule)"
echo "Target 2: $MARKETPLACE_2_PLUGIN (promptlock submodule - with lock.yml)"
echo ""

# Step 0: Manifest verification (no silent regressions)
echo -e "${YELLOW}Step 0: Verifying manifest (no silent regressions)...${NC}"

# Get source commands (strip path, get basename without extension)
SOURCE_COMMANDS=$(find "$SOURCE_PLUGIN/commands" -name "*.md" -type f 2>/dev/null | xargs -I{} basename {} .md | sort)
# Get source skills (directory names under skills/)
SOURCE_SKILLS=$(find "$SOURCE_PLUGIN/skills" -name "SKILL.md" -type f 2>/dev/null | xargs -I{} dirname {} | xargs -I{} basename {} | sort)
# Get source agents (directory names under agents/)
SOURCE_AGENTS=$(find "$SOURCE_PLUGIN/agents" -name "AGENT.md" -type f 2>/dev/null | xargs -I{} dirname {} | xargs -I{} basename {} | sort)

# Get existing marketplace items (ignore duplicate " 2" files from previous issues)
EXISTING_COMMANDS=$(find "$MARKETPLACE_1_PLUGIN/commands" -name "*.md" -type f 2>/dev/null | grep -v " 2\.md$" | xargs -I{} basename {} .md | sort)
EXISTING_SKILLS=$(find "$MARKETPLACE_1_PLUGIN/skills" -name "SKILL.md" -type f 2>/dev/null | xargs -I{} dirname {} | xargs -I{} basename {} | sort)
EXISTING_AGENTS=$(find "$MARKETPLACE_1_PLUGIN/agents" -name "AGENT.md" -type f 2>/dev/null | xargs -I{} dirname {} | xargs -I{} basename {} | sort)

# Find removals (in existing but not in source)
REMOVED_COMMANDS=$(comm -23 <(echo "$EXISTING_COMMANDS") <(echo "$SOURCE_COMMANDS") | grep -v "^$" || true)
REMOVED_SKILLS=$(comm -23 <(echo "$EXISTING_SKILLS") <(echo "$SOURCE_SKILLS") | grep -v "^$" || true)
REMOVED_AGENTS=$(comm -23 <(echo "$EXISTING_AGENTS") <(echo "$SOURCE_AGENTS") | grep -v "^$" || true)

# Find additions (in source but not in existing)
ADDED_COMMANDS=$(comm -13 <(echo "$EXISTING_COMMANDS") <(echo "$SOURCE_COMMANDS") | grep -v "^$" || true)
ADDED_SKILLS=$(comm -13 <(echo "$EXISTING_SKILLS") <(echo "$SOURCE_SKILLS") | grep -v "^$" || true)
ADDED_AGENTS=$(comm -13 <(echo "$EXISTING_AGENTS") <(echo "$SOURCE_AGENTS") | grep -v "^$" || true)

# Report additions (always allowed)
if [ -n "$ADDED_COMMANDS" ] || [ -n "$ADDED_SKILLS" ] || [ -n "$ADDED_AGENTS" ]; then
    echo -e "  ${GREEN}ADDITIONS (will be deployed):${NC}"
    [ -n "$ADDED_COMMANDS" ] && echo "$ADDED_COMMANDS" | sed 's/^/    + command: /'
    [ -n "$ADDED_SKILLS" ] && echo "$ADDED_SKILLS" | sed 's/^/    + skill: /'
    [ -n "$ADDED_AGENTS" ] && echo "$ADDED_AGENTS" | sed 's/^/    + agent: /'
fi

# Check for removals (block unless --allow-removal)
HAS_REMOVALS=false
if [ -n "$REMOVED_COMMANDS" ] || [ -n "$REMOVED_SKILLS" ] || [ -n "$REMOVED_AGENTS" ]; then
    HAS_REMOVALS=true
    echo -e "  ${YELLOW}REMOVALS DETECTED:${NC}"
    [ -n "$REMOVED_COMMANDS" ] && echo "$REMOVED_COMMANDS" | sed 's/^/    - command: /'
    [ -n "$REMOVED_SKILLS" ] && echo "$REMOVED_SKILLS" | sed 's/^/    - skill: /'
    [ -n "$REMOVED_AGENTS" ] && echo "$REMOVED_AGENTS" | sed 's/^/    - agent: /'
fi

if [ "$HAS_REMOVALS" = true ] && [ "$ALLOW_REMOVAL" = false ]; then
    echo ""
    echo -e "${YELLOW}ERROR: Deployment blocked - functionality would be removed${NC}"
    echo "The items above exist in the marketplace but are missing from source."
    echo ""
    echo "Options:"
    echo "  1. Add the missing items back to source"
    echo "  2. Run with --allow-removal to explicitly remove them:"
    echo "     ./lock-and-deploy.sh --allow-removal \"message\""
    exit 1
fi

if [ "$HAS_REMOVALS" = true ] && [ "$ALLOW_REMOVAL" = true ]; then
    echo -e "  ${YELLOW}Removals allowed via --allow-removal flag${NC}"
fi

echo -e "  ${GREEN}✓ Manifest verification passed${NC}"
echo ""

# Verify submodules are initialized
if [ ! -d "$MARKETPLACE_1/.git" ] || [ ! -d "$MARKETPLACE_2/.git" ]; then
    echo -e "${YELLOW}Initializing submodules...${NC}"
    git -C "$PLUGIN_ROOT" submodule update --init --recursive
fi

# Step 1: Lock the plugin
echo -e "${YELLOW}Step 1: Locking plugin...${NC}"
cd "$PROMPTLOCK_DIR"
mkdir -p "$(dirname "$GLOSSARY_PATH")"
bundle exec context-lock lock "$SOURCE_PLUGIN" "$LOCKED_OUTPUT" --keys=1 --key-path "$KEY_PATH" --glossary "$GLOSSARY_PATH"

# Verify key created at centralized location
if [ ! -f "$KEY_PATH/lock.yml" ]; then
    echo "ERROR: lock.yml not created at $KEY_PATH"
    exit 1
fi
echo "  lock.yml created at: $KEY_PATH/lock.yml"

# Copy key to promptlock for backup/archival
mkdir -p "$MARKETPLACE_2_PLUGIN"
cp "$KEY_PATH/lock.yml" "$MARKETPLACE_2_PLUGIN/lock.yml"
echo "  lock.yml copied to: $MARKETPLACE_2_PLUGIN/lock.yml (backup)"

# Remove embedded .git from locked directory (context-lock creates one)
if [ -d "$MARKETPLACE_2_PLUGIN/.git" ]; then
    rm -rf "$MARKETPLACE_2_PLUGIN/.git"
    echo "  Removed embedded .git from locked directory"
fi

# Step 2: Deploy to Marketplace 1 (claude-code) - WITHOUT lock.yml
echo -e "${YELLOW}Step 2: Deploying to claude-code marketplace...${NC}"

# Clean existing plugin files (preserve .git if any)
find "$MARKETPLACE_1_PLUGIN" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy locked files (exclude lock.yml and .git)
rsync -av --exclude='lock.yml' --exclude='.git' \
    "$MARKETPLACE_2_PLUGIN/" \
    "$MARKETPLACE_1_PLUGIN/"

echo "  Deployed to: $MARKETPLACE_1_PLUGIN"

# Verify lock.yml is NOT in marketplace 1
if [ -f "$MARKETPLACE_1_PLUGIN/lock.yml" ]; then
    echo "ERROR: lock.yml was copied to claude-code! Removing..."
    rm "$MARKETPLACE_1_PLUGIN/lock.yml"
fi

# Step 2b: Copy unlocked files (these must NOT be locked)
echo -e "${YELLOW}Step 2b: Copying unlocked files...${NC}"
# decode-session.sh - the decoder script itself
cp "$SOURCE_PLUGIN/hooks/decode-session.sh" "$MARKETPLACE_1_PLUGIN/hooks/"
chmod +x "$MARKETPLACE_1_PLUGIN/hooks/decode-session.sh"
# hooks.json - must reference the decoder, not be locked
cp "$SOURCE_PLUGIN/hooks/hooks.json" "$MARKETPLACE_1_PLUGIN/hooks/"
echo "  Copied: hooks/decode-session.sh (unlocked)"
echo "  Copied: hooks/hooks.json (unlocked)"
# .claude-plugin - Claude Code reads this directly for command registration
mkdir -p "$MARKETPLACE_1_PLUGIN/.claude-plugin"
cp "$SOURCE_PLUGIN/.claude-plugin/plugin.json" "$MARKETPLACE_1_PLUGIN/.claude-plugin/"
echo "  Copied: .claude-plugin/plugin.json (unlocked)"

# Step 3: Get current version and increment
echo -e "${YELLOW}Step 3: Updating version...${NC}"
current_version=$(grep -o '"version": "[^"]*"' "$MARKETPLACE_1_JSON" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
echo "  Current version: $current_version"

# Increment patch version
IFS='.' read -r major minor patch <<< "$current_version"
new_patch=$((patch + 1))
new_version="$major.$minor.$new_patch"
echo "  New version: $new_version"

# Update ALL version fields in marketplace.json (metadata + plugin entry)
sed -i '' "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$new_version\"/g" "$MARKETPLACE_1_JSON"

# Update source plugin.json to stay in sync
SOURCE_PLUGIN_JSON="$SOURCE_PLUGIN/.claude-plugin/plugin.json"
sed -i '' "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$new_version\"/" "$SOURCE_PLUGIN_JSON"
echo "  Updated: $SOURCE_PLUGIN_JSON"

# Get commit message
if [ -n "$COMMIT_MSG" ]; then
    commit_msg="agentc $new_version: $COMMIT_MSG"
else
    commit_msg="agentc $new_version: Deploy locked version"
fi

# Step 4: Commit and push Marketplace 1 (claude-code submodule)
echo -e "${YELLOW}Step 4: Committing claude-code submodule...${NC}"
cd "$MARKETPLACE_1"

git add plugins/agentc .claude-plugin/marketplace.json
git commit -m "$commit_msg" || echo "  No changes to commit in claude-code"
git push origin main
echo -e "${CYAN}  Pushed submodule to: github.com:zero20nemvp/claude-code.git${NC}"

# Step 5: Commit and push Marketplace 2 (promptlock submodule)
echo -e "${YELLOW}Step 5: Committing promptlock submodule...${NC}"
cd "$MARKETPLACE_2"

git add plugins/locked/agentc
git commit -m "$commit_msg" || echo "  No changes to commit in promptlock"
git push origin master
echo -e "${CYAN}  Pushed submodule to: github.com:zero20nemvp/context-lock.git${NC}"

# Step 6: Update parent repo submodule references
echo -e "${YELLOW}Step 6: Updating parent repo submodule references...${NC}"
cd "$PLUGIN_ROOT"

git add marketplaces/claude-code marketplaces/context-lock
git commit -m "Update marketplace submodules: $commit_msg" || echo "  No submodule updates needed"
echo -e "${CYAN}  Updated submodule references in turg repo${NC}"

# Step 7: Push lock.yml to agentc-web container
echo -e "${YELLOW}Step 7: Pushing lock.yml to agentc-web container...${NC}"
if lxc file push "$KEY_PATH/lock.yml" hetzner:agentc-web/var/www/agentc/lock.yml --mode 0600 --uid 33 --gid 33 2>/dev/null; then
    echo -e "${CYAN}  Pushed lock.yml to hetzner:agentc-web${NC}"
else
    echo -e "${YELLOW}  Warning: Could not push to agentc-web (container may be offline)${NC}"
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo "Version: $new_version"
echo ""
echo "Key storage (centralized):"
echo "  - Local: $KEY_PATH/lock.yml"
echo ""
echo "Marketplace 1 (claude-code) - Submodule:"
echo "  - Remote: github.com:zero20nemvp/claude-code.git"
echo "  - Path: $MARKETPLACE_1_PLUGIN"
echo "  - lock.yml: NOT included (protected)"
echo ""
echo "Marketplace 2 (promptlock) - Submodule:"
echo "  - Remote: github.com:zero20nemvp/context-lock.git"
echo "  - Path: $MARKETPLACE_2_PLUGIN"
echo "  - lock.yml: INCLUDED (backup copy)"
echo ""
echo "Parent repo (turg):"
echo "  - Submodule references updated"
echo ""
echo "User download (agentc-web):"
echo "  - hetzner:agentc-web:/var/www/agentc/lock.yml"
echo ""
echo "Verification:"
echo "  head -10 $MARKETPLACE_1_PLUGIN/skills/test-driven-development/SKILL.md"
