---
name: lock-and-deploy
description: "Lock the agentc plugin and deploy to BOTH marketplaces (claude-code and promptlock)"
arguments:
  - name: message
    description: "Optional commit message describing the changes"
    required: false
allowed-tools:
  - Bash
  - Read
  - Glob

Implementation details are in CLAUDE.md - see "Command Implementations" section.
