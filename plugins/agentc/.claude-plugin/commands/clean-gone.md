---
name: clean-gone
description: Clean up stale local branches marked as [gone] (deleted on remote but still exist locally)
---

## Your Task

Clean up local branches that have been deleted from the remote repository.

## Commands to Execute

1. **List branches to identify any with [gone] status**
   ```bash
   git branch -v
   ```

   Note: Branches with a '+' prefix have associated worktrees.

2. **Identify worktrees that need removal for [gone] branches**
   ```bash
   git worktree list
   ```

3. **Remove worktrees and delete [gone] branches**
   ```bash
   git branch -v | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' | while read branch; do
     echo "Processing branch: $branch"
     # Find and remove worktree if it exists
     worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
     if [ ! -z "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
       echo "  Removing worktree: $worktree"
       git worktree remove --force "$worktree"
     fi
     # Delete the branch
     echo "  Deleting branch: $branch"
     git branch -D "$branch"
   done
   ```

## Expected Output

- List of all local branches with status
- Removal of worktrees for [gone] branches
- Deletion of all [gone] branches
- Summary of what was cleaned up

If no branches are marked as [gone], report that no cleanup was needed.
