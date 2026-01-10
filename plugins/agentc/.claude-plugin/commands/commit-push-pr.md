---
name: commit-push-pr
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*)
description: Full workflow - commit changes, push branch, and create pull request
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Remote tracking: !`git remote -v`

## Your task

Based on the above changes, execute the full commit-to-PR workflow:

1. **Create branch** (if on main/master):
   - Generate descriptive branch name from changes
   - `git checkout -b <branch-name>`

2. **Create commit**:
   - Stage all relevant changes
   - Write descriptive commit message

3. **Push to remote**:
   - `git push -u origin <branch-name>`

4. **Create pull request**:
   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   ## Summary
   <description of changes>

   ## Test plan
   - [ ] <test steps>

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

You have the capability to call multiple tools in a single response. Execute all steps in a single message.

**Output the PR URL when complete.**
