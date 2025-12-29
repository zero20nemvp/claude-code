---
name: next
description: "Get your next optimal task - dynamically generated across all north stars/goals"
arguments:
  - name: energy
    description: "Energy level: 'in' for focused/complex, 'out' for mechanical/simple"
    required: false
  - name: skip-discovery
    description: "Skip discovery stages (jtbd, stories, features, slices) - go straight to implementation"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task

Implementation details are in CLAUDE.md - see "Command Implementations" section.
