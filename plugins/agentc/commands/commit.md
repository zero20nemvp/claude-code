---
name: commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit with auto-generated message based on changes
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.

1. Analyze the changes and recent commit style
2. Stage all relevant files
3. Create commit with descriptive message following repo conventions

You have the capability to call multiple tools in a single response. Stage and create the commit using a single message.

**Commit message format:**
```
<type>: <description>

<body if needed>

Co-Authored-By: Claude <noreply@anthropic.com>
```

Common types: feat, fix, refactor, docs, test, chore
