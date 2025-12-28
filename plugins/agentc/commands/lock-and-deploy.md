---
name: lock-and-deploy
description: "Lock the agentc plugin and deploy to the zero2one-turg marketplace"
arguments:
  - name: message
    description: "Optional commit message describing the changes"
    required: false
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Lock and Deploy Command

Lock the agentc plugin IP and deploy to the marketplace.

## What This Does

1. Runs `context-lock lock` on the source plugin
2. Copies locked files to marketplace (excluding lock.yml)
3. Increments version in marketplace.json
4. Commits and pushes to origin/main

## Execution

Run the lock-and-deploy script:

```bash
/Users/db/Desktop/turg/plugins/agentc/scripts/lock-and-deploy.sh "{{message}}"
```

If no message is provided, use: "Deploy locked version"

## After Execution

Report:
- New version number
- Location of lock.yml (stays local)
- Verification command to check locked content

## Important

- The lock.yml key stays at `/Users/db/Desktop/promptlock/plugins/locked/agentc/lock.yml`
- This key is required to unlock the content
- The marketplace only contains the locked (encoded) files
