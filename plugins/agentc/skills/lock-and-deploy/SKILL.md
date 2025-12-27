---
name: lock-and-deploy
description: Lock the agentc plugin IP and deploy to BOTH marketplaces (claude-code and promptlock). Preserves skill/agent/command metadata for discoverability while protecting methodology content.
---

# Lock and Deploy Skill

Use this skill to publish a protected version of the agentc plugin to both marketplaces.

## Full Deployment Steps

When deploying the plugin, follow these steps in order:

```bash
# 1. Git add, commit, and tag your changes
git -C /Users/db/Desktop/turg add .
git -C /Users/db/Desktop/turg commit -m "Your commit message"
git -C /Users/db/Desktop/turg tag -a vX.Y.Z -m "Version description"

# 2. Build and install context-lock gem (from submodule)
pushd /Users/db/Desktop/turg/marketplaces/context-lock && gem build context_lock.gemspec && popd
gem install /Users/db/Desktop/turg/marketplaces/context-lock/context_lock-*.gem

# 3. Run lock-and-deploy (pushes claude-code and context-lock submodules)
/Users/db/Desktop/turg/plugins/agentc/scripts/lock-and-deploy.sh "Description of changes"

# 4. Push turg repo (parent with submodule references)
git -C /Users/db/Desktop/turg push origin main --tags

# 5. Update the plugin in other projects
claude /plugins update agentc
```

## What This Does

1. **Locks** the plugin using context-lock (preserves YAML frontmatter, encodes content)
2. **Deploys to claude-code submodule** - WITHOUT lock.yml
3. **Deploys to context-lock submodule** - WITH lock.yml
4. **Updates** marketplace.json with new version
5. **Commits and pushes** both submodules
6. **Updates** parent repo submodule references
7. **Updates plugin in other projects** - run `claude /plugins update agentc` to pull latest

## Architecture (Submodules)

Both marketplaces are git submodules within the turg repo:

```
/Users/db/Desktop/turg/
├── .gitmodules
├── marketplaces/
│   ├── claude-code/      ← submodule (github.com:zero20nemvp/claude-code.git)
│   └── context-lock/     ← submodule (github.com:zero20nemvp/context-lock.git)
└── plugins/
    └── agentc/           ← source plugin
```

| Marketplace | Submodule Path | Branch | lock.yml | Purpose |
|-------------|----------------|--------|----------|---------|
| claude-code | `marketplaces/claude-code` | main | NO | Public distribution |
| context-lock | `marketplaces/context-lock` | master | YES | Master copy with key |

## Workflow

```
turg/plugins/agentc (SOURCE)
        │
        ▼ context-lock lock
        │
marketplaces/context-lock/plugins/locked/agentc (LOCKED + lock.yml)
        │
        ├──► marketplaces/claude-code/plugins/agentc (PUBLIC - no lock.yml)
        │         └── git push origin main
        │
        └──► marketplaces/context-lock/plugins/locked/agentc (MASTER - with lock.yml)
        │         └── git push origin master
        │
        └──► turg repo: update submodule references
```

## Quick Execution

If context-lock gem is already installed:

```bash
/lock-and-deploy "Description of changes"
```

## After Execution

Both submodules are updated and pushed:

1. **claude-code** (public marketplace)
   - Users can install the plugin
   - Skills are discoverable (frontmatter visible)
   - Content is locked (encoded numbers)
   - No lock.yml = cannot unlock

2. **context-lock** (master copy)
   - Contains lock.yml key
   - Can be used to unlock if needed
   - Serves as backup/master

## Important Notes

- **Version auto-increments** - patch version bumps automatically (1.0.1 → 1.0.2)
- **Both submodules pushed** - single command updates both marketplaces
- **lock.yml protected** - only exists in context-lock repo, not in public claude-code
- **Parent repo updated** - submodule references committed after deploy

## Verification

After deployment, verify:

```bash
# Check claude-code has locked content (no lock.yml)
ls /Users/db/Desktop/turg/marketplaces/claude-code/plugins/agentc/lock.yml  # Should fail

# Check context-lock has lock.yml
ls /Users/db/Desktop/turg/marketplaces/context-lock/plugins/locked/agentc/lock.yml  # Should exist

# Check frontmatter is visible
head -5 /Users/db/Desktop/turg/marketplaces/claude-code/plugins/agentc/skills/test-driven-development/SKILL.md
```
