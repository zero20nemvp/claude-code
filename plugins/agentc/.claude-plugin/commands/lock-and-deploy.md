---
name: lock-and-deploy
description: "Lock the agentc plugin and deploy to public marketplaces (claude-code and promptlock)"
arguments:
  - name: message
    description: "Optional commit message describing the changes"
    required: false
allowed-tools:
  - Bash
  - Read
  - Glob
  - Task
---

# Lock and Deploy Command

Lock the agentc plugin IP and deploy to the marketplace.

## What This Does

1. **Validates** the plugin using plugin-dev:plugin-validator
2. Runs `context-lock lock` on the source plugin
3. Copies locked files to marketplace (excluding lock.yml)
4. Increments version in marketplace.json
5. Commits and pushes to origin/main

## Step 1: Pre-Deployment Validation (REQUIRED)

Before deploying, validate the development version of the plugin:

Use the Task tool to spawn the `plugin-dev:plugin-validator` agent:
- Plugin path: `/Users/db/Desktop/turg/plugins/agentc`
- Check for critical issues

**If validation finds critical issues:**
- STOP deployment
- Report the issues to the user
- Do NOT run the deploy script

**If validation passes (no critical issues):**
- Report validation summary
- Proceed to Step 2

## Step 2: Execution

Run the lock-and-deploy script:

```bash
/Users/db/Desktop/turg/plugins/agentc/scripts/lock-and-deploy.sh "{{message}}"
```

If no message is provided, use: "Deploy locked version"

## After Execution

Report:
- Validation status (passed/warnings)
- New version number
- Location of lock.yml (stays local)
- Verification command to check locked content

## Important

- The lock.yml key stays at `/Users/db/.config/context-lock/keys/agentc/lock.yml`
- This key is required to unlock the content
- The marketplace only contains the locked (encoded) files
