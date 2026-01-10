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

# Local-dev marketplace (turg root)
LOCAL_DEV_JSON="$PLUGIN_ROOT/.claude-plugin/marketplace.json"

# Marketplace 1: claude-code (zero2onemvp-claude-code) - submodule
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

echo -e "${GREEN}=== Lock and Deploy (Submodule Edition) ===${NC}"
echo "Source: $SOURCE_PLUGIN"
echo "Target 1: $MARKETPLACE_1_PLUGIN (claude-code submodule)"
echo "Target 2: $MARKETPLACE_2_PLUGIN (promptlock submodule - with lock.yml)"
echo ""

# Verify submodules are initialized
if [ ! -d "$MARKETPLACE_1/.git" ] || [ ! -d "$MARKETPLACE_2/.git" ]; then
    echo -e "${YELLOW}Initializing submodules...${NC}"
    git -C "$PLUGIN_ROOT" submodule update --init --recursive
fi

# Step 1: Lock the plugin (delete old lock.yml first to ensure fresh vocabulary)
echo -e "${YELLOW}Step 1: Locking plugin...${NC}"
if [ -f "$KEY_PATH/lock.yml" ]; then
    rm "$KEY_PATH/lock.yml"
    echo "  Deleted old lock.yml (fresh vocabulary will be generated)"
fi
cd "$PROMPTLOCK_DIR"
bundle exec context-lock lock "$SOURCE_PLUGIN" "$LOCKED_OUTPUT" --keys=1 --key-path "$KEY_PATH"

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

# Remove lock-and-deploy files (development-only, not for deployment)
echo -e "${YELLOW}  Removing development-only lock-and-deploy files...${NC}"
rm -f "$MARKETPLACE_2_PLUGIN/commands/lock-and-deploy.md"
rm -f "$MARKETPLACE_2_PLUGIN/scripts/lock-and-deploy.sh"
rm -f "$MARKETPLACE_2_PLUGIN/scripts/lock-and-deploy.sh.locked"
rm -rf "$MARKETPLACE_2_PLUGIN/skills/lock-and-deploy"
echo "  Removed lock-and-deploy files from locked output"

# Copy unlocked README.md to locked marketplace (overwrite locked version)
cp "$SOURCE_PLUGIN/README.md" "$MARKETPLACE_2_PLUGIN/README.md"
echo "  Copied: README.md (unlocked, comprehensive documentation)"

# Context-lock generates wrappers for .sh and .py files, but NOT .rb files
# Manually create wrappers for Ruby scripts (ILX emitters)
echo -e "${YELLOW}  Creating wrappers for Ruby scripts...${NC}"

# Create wrapper for ILX hook
if [ -f "$MARKETPLACE_2_PLUGIN/hooks/ilx_emitter_hook.rb.locked" ]; then
    cat > "$MARKETPLACE_2_PLUGIN/hooks/ilx_emitter_hook.rb" << 'WRAPPER'
#!/bin/bash
# Wrapper for locked ilx_emitter_hook - delegates to run script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/../run" "$DIR/ilx_emitter_hook.rb.locked" "$@"
WRAPPER
    chmod +x "$MARKETPLACE_2_PLUGIN/hooks/ilx_emitter_hook.rb"
    echo "    Created: hooks/ilx_emitter_hook.rb"
fi

# Create wrappers for ILX script files
for script in ilx_domain_emitter ilx_view_emitter ilx_batch_convert ilx_ast_emitter; do
    if [ -f "$MARKETPLACE_2_PLUGIN/scripts/${script}.rb.locked" ]; then
        cat > "$MARKETPLACE_2_PLUGIN/scripts/${script}.rb" << WRAPPER
#!/bin/bash
# Wrapper for locked ${script} - delegates to run script
DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
"\$DIR/../run" "\$DIR/${script}.rb.locked" "\$@"
WRAPPER
        chmod +x "$MARKETPLACE_2_PLUGIN/scripts/${script}.rb"
        echo "    Created: scripts/${script}.rb"
    fi
done

# Step 2: Deploy to Marketplace 1 (claude-code) - WITHOUT lock.yml
echo -e "${YELLOW}Step 2: Deploying to claude-code marketplace...${NC}"

# Clean existing plugin files (preserve .git if any)
find "$MARKETPLACE_1_PLUGIN" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy locked files (exclude lock.yml and .git)
rsync -av --delete --exclude='lock.yml' --exclude='.git' \
    "$MARKETPLACE_2_PLUGIN/" \
    "$MARKETPLACE_1_PLUGIN/"

echo "  Deployed to: $MARKETPLACE_1_PLUGIN"

# Verify lock.yml is NOT in marketplace 1
if [ -f "$MARKETPLACE_1_PLUGIN/lock.yml" ]; then
    echo "ERROR: lock.yml was copied to claude-code! Removing..."
    rm "$MARKETPLACE_1_PLUGIN/lock.yml"
fi

# Step 3: Get current version and increment (do this BEFORE copying plugin.json)
echo -e "${YELLOW}Step 3: Updating version...${NC}"

# Source plugin.json is the single source of truth
SOURCE_PLUGIN_JSON="$SOURCE_PLUGIN/.claude-plugin/plugin.json"
current_version=$(grep -o '"version": "[^"]*"' "$SOURCE_PLUGIN_JSON" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
echo "  Source version: $current_version"

# Increment patch version
IFS='.' read -r major minor patch <<< "$current_version"
new_patch=$((patch + 1))
new_version="$major.$minor.$new_patch"
echo "  New version: $new_version"

# Update source plugin.json (the canonical version)
sed -i '' "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$new_version\"/" "$SOURCE_PLUGIN_JSON"
echo "  Updated source: $SOURCE_PLUGIN_JSON"

# Update local-dev marketplace to match (plugin version only, not metadata version)
sed -i '' "/\"name\": \"agentc\"/,/\"strict\"/{s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$new_version\"/;}" "$LOCAL_DEV_JSON"
echo "  Updated local-dev marketplace: $LOCAL_DEV_JSON"

# Update claude-code marketplace (ALL version fields: metadata + plugin entry)
sed -i '' "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$new_version\"/g" "$MARKETPLACE_1_JSON"
echo "  Updated claude-code marketplace: $MARKETPLACE_1_JSON"

# Get commit message
if [ -n "$1" ]; then
    commit_msg="agentc $new_version: $1"
else
    commit_msg="agentc $new_version: Deploy locked version"
fi

# Step 3b: Copy unlocked files AFTER version update (these must NOT be locked)
echo -e "${YELLOW}Step 3b: Copying unlocked files with updated version...${NC}"
# hooks.json - must reference the locked scripts via 'run'
cp "$SOURCE_PLUGIN/hooks/hooks.json" "$MARKETPLACE_1_PLUGIN/hooks/"
# plugin.json - must be readable for Claude Code to discover the plugin (NOW with updated version)
cp "$SOURCE_PLUGIN/.claude-plugin/plugin.json" "$MARKETPLACE_1_PLUGIN/.claude-plugin/"
# README.md - comprehensive documentation for all users
cp "$SOURCE_PLUGIN/README.md" "$MARKETPLACE_1_PLUGIN/README.md"
echo "  Copied: hooks/hooks.json (unlocked, references .locked scripts via run)"
echo "  Copied: .claude-plugin/plugin.json (unlocked, v$new_version)"
echo "  Copied: README.md (unlocked, comprehensive documentation)"

# Step 4: Commit and push Marketplace 1 (claude-code submodule)
echo -e "${YELLOW}Step 4: Committing claude-code submodule...${NC}"
cd "$MARKETPLACE_1"

# Add and commit changes first (while still potentially in detached HEAD)
git add plugins/agentc .claude-plugin/marketplace.json
git commit -m "$commit_msg" || echo "  No changes to commit in claude-code"

# Save the commit SHA before checkout
COMMIT_SHA=$(git rev-parse HEAD)

# Checkout main branch and reset to our commit
git checkout main || true
git reset --hard "$COMMIT_SHA"

# Push to remote (force if needed since we may have detached HEAD history)
git push origin main --force-with-lease
echo -e "${CYAN}  Pushed submodule to: github.com:zero20nemvp/claude-code.git${NC}"

# Step 5: Commit and push Marketplace 2 (promptlock submodule)
echo -e "${YELLOW}Step 5: Committing promptlock submodule...${NC}"
cd "$MARKETPLACE_2"

# Add and commit changes first (while still potentially in detached HEAD)
git add plugins/locked/agentc
git commit -m "$commit_msg" || echo "  No changes to commit in promptlock"

# Save the commit SHA before checkout
COMMIT_SHA=$(git rev-parse HEAD)

# Checkout master branch and reset to our commit
git checkout master || true
git reset --hard "$COMMIT_SHA"

# Push to remote (force if needed since we may have detached HEAD history)
git push origin master --force-with-lease
echo -e "${CYAN}  Pushed submodule to: github.com:zero20nemvp/context-lock.git${NC}"

# Step 6: Commit source plugin version change and local-dev marketplace
echo -e "${YELLOW}Step 6: Committing source plugin and local-dev marketplace...${NC}"
cd "$PLUGIN_ROOT"

git add plugins/agentc/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "Update agentc version: $new_version" || echo "  No source plugin changes to commit"
echo -e "${CYAN}  Committed version update${NC}"

# Step 7: Update parent repo submodule references and push
echo -e "${YELLOW}Step 7: Updating parent repo and pushing...${NC}"

git add marketplaces/claude-code marketplaces/context-lock
git commit -m "Update marketplace submodules: $commit_msg" || echo "  No submodule updates needed"
git push origin main
echo -e "${CYAN}  Pushed turg repo to origin${NC}"

# Step 8: Push lock.yml to agentc-web container
echo -e "${YELLOW}Step 8: Pushing lock.yml to agentc-web container...${NC}"
if lxc file push "$KEY_PATH/lock.yml" hetzner:agentc-web/var/www/agentc/lock.yml --mode 0600 --uid 33 --gid 33 2>/dev/null; then
    echo -e "${CYAN}  Pushed lock.yml to hetzner:agentc-web${NC}"
else
    echo -e "${YELLOW}  Warning: Could not push to agentc-web (container may be offline)${NC}"
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo "Version: $new_version"
echo ""
echo "Version Management:"
echo "  - Source (single source of truth): $SOURCE_PLUGIN_JSON"
echo "  - All marketplaces synced to version: $new_version"
echo ""
echo "Key storage:"
echo "  - Primary: $KEY_PATH/lock.yml"
echo ""
echo "Local-dev marketplace (turg root):"
echo "  - Path: $LOCAL_DEV_JSON"
echo "  - Plugin version: $new_version"
echo "  - Used for local development"
echo ""
echo "Marketplace 1 (claude-code) - Submodule:"
echo "  - Remote: github.com:zero20nemvp/claude-code.git"
echo "  - Path: $MARKETPLACE_1_PLUGIN"
echo "  - lock.yml: NOT included (distributed via website)"
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
