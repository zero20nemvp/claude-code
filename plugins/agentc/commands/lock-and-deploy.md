---
description: "Lock the agentc plugin and deploy to the zero2one-turg marketplace"
arguments:
  - name: message
    description: "Optional commit message describing the changes"
    required: false
  - name: allow-removal
    description: "Flag to explicitly allow removing commands/skills/agents"
    required: false
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Lock and Deploy Command

Lock the agentc plugin IP and deploy to the marketplace.

## What This Does

0. **Manifest verification** - Compares source vs deployed, blocks if items would be removed
1. Runs `context-lock lock` on the source plugin
2. Copies locked files to marketplace (excluding lock.yml)
3. Increments version in marketplace.json
4. Commits and pushes to origin/main

## Manifest Verification (Step 0)

Before deployment, the script verifies no functionality is silently removed:

- **Additions**: Always allowed (reported with `+`)
- **Removals**: Blocked unless `--allow-removal` flag is passed

If removals are detected without the flag, deployment fails with:
```
ERROR: Deployment blocked - functionality would be removed
```

## Execution

Standard deployment:
```bash
/Users/db/Desktop/turg/plugins/agentc/scripts/lock-and-deploy.sh "{{message}}"
```

Allow explicit removal of items:
```bash
/Users/db/Desktop/turg/plugins/agentc/scripts/lock-and-deploy.sh --allow-removal "Removed deprecated X"
```

If no message is provided, use: "Deploy locked version"

## After Execution

Report:
- New version number
- Location of lock.yml (stays local)
- Verification command to check locked content

## Important

- The lock.yml key stays at `~/.config/context-lock/keys/agentc/lock.yml`
- This key is required to unlock the content
- The marketplace only contains the locked (encoded) files
