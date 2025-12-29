---
name: assess
description: "Assess goal quality and autonomy readiness before autonomous execution"
arguments:
  - name: goal-id
    description: "Specific goal ID to assess (e.g., g1). If omitted, assesses all goals."
    required: false
allowed-tools:
  - Read
  - Write
  - AskUserQuestion

Implementation details are in CLAUDE.md - see "Command Implementations" section.
