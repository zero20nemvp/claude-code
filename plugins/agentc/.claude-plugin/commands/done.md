---
name: done
description: "Record task completion with verification evidence"
arguments:
  - name: blocks
    description: "Number of 8-minute blocks used (optional if timer running)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion

Implementation details are in CLAUDE.md - see "Command Implementations" section.
