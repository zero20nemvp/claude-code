---
name: commit
description: "Git commit with auto-generated message. Use --push to push, --pr to create PR"
arguments:
  - name: flags
    description: "--push to push after commit, --pr to push and create PR"
    required: false
allowed-tools:
  - Bash
---

You are creating a git commit with optional push and PR.

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Route by Flags

**No flags:** Commit only
**--push:** Commit and push
**--pr:** Commit, push, and create PR (creates branch if on main)

---

## COMMIT (always)

1. Analyze changes and recent commit style
2. Stage relevant files
3. Create commit with descriptive message

**Message format:**
```
<type>: <description>

<body if needed>

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: feat, fix, refactor, docs, test, chore

---

## --push: Push to Remote

After commit:
```bash
git push -u origin [current-branch]
```

---

## --pr: Full PR Workflow

1. **If on main/master:** Create branch first
   ```bash
   git checkout -b [descriptive-branch-name]
   ```

2. **Commit** (as above)

3. **Push**
   ```bash
   git push -u origin [branch]
   ```

4. **Create PR**
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

5. **Output PR URL**

---

## Output

**Commit only:**
```
Committed: [hash] [message]
```

**With --push:**
```
Committed: [hash] [message]
Pushed to: origin/[branch]
```

**With --pr:**
```
Committed: [hash] [message]
Pushed to: origin/[branch]
PR created: [url]
```
