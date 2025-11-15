# /done - Complete Task with Git Automation

Stops the timer, records completion, and **ENFORCES** git workflow: add → commit → tag (if milestone complete).

## Usage

```
/done [optional: block_count]
```

If block count not provided, reads from timer. If provided, overrides timer value.

## Instructions

### Step 1: Stop Timer and Get Blocks

Execute:
```bash
cd /Users/db/Desktop/agentme/dev/agentme && ./timer.sh stop
```

Parse output to extract:
- Elapsed time (minutes, seconds)
- Blocks completed

If `block_count` argument provided, use that instead of timer value.

### Step 2: Read Current State

Read:
- `dev/agentme/state.json` - get humanTask details
- `dev/agentme/goals.json` - get goal and milestone info
- `dev/agentme/velocity.json` - current velocity metrics

Verify humanTask exists and has required fields:
- `taskId`, `description`, `goalId`, `milestoneId`
- `points`, `estimatedBlocks`

### Step 3: Update Velocity

Calculate:
- `actualBlocks` = blocks from timer (or override)
- `newTotalPoints` = old total + task points
- `newTotalBlocks` = old total + actual blocks
- `newVelocity` = newTotalPoints / newTotalBlocks
- `estimationAccuracy` = average of (min(estimated, actual) / max(estimated, actual)) across all tasks

Add to history with automation breakdown:
```json
{
  "taskId": "[task-id]",
  "goalId": "[goal-id]",
  "milestoneId": "[milestone-id]",
  "description": "[task description]",
  "points": X,
  "estimatedBlocks": Y,
  "actualBlocks": Z,
  "completedAt": "[ISO timestamp]",
  "automationBreakdown": {
    "automatable": 60,
    "needSkill": 30,
    "humanOnly": 10,
    "actuallyAutomated": 60
  }
}
```

**Automation breakdown:**
- Get this from the analysis done in `/do` Step 6
- `automatable`: % that Claude can do now
- `needSkill`: % that could be automated with new skills
- `humanOnly`: % that requires human (inherently)
- `actuallyAutomated`: % that Claude actually automated (usually = automatable)

**If breakdown wasn't stored** (legacy task):
- Set all to null or use: `{"automatable": 100, "needSkill": 0, "humanOnly": 0, "actuallyAutomated": 100}`

**Calculate automation trends:**
- Track average automation % over time
- Show increasing automation as skills are added

Write updated `dev/agentme/velocity.json`.

### Step 4: Update Milestone Progress

In `dev/agentme/goals.json`:
- Find the goal by goalId
- Find the milestone by milestoneId
- Increment progress appropriately
- If ALL acceptance criteria met → set progress to 100%, status to "completed"

Write updated `dev/agentme/goals.json`.

### Step 5: ENFORCED GIT WORKFLOW

**CRITICAL: This runs on EVERY task completion. No exceptions.**

#### 5a. Git Add (ALWAYS)
```bash
cd /Users/db/Desktop/agentme && git add .
```

If git add fails:
- Check if we're in a git repo
- Show error but continue

#### 5b. Git Commit (ALWAYS)

Create commit message:
```
Task complete: [task description]

Goal: [goal-name] ([goal-id])
Milestone: [milestone-name] ([milestone-id]) - [progress]%
Points: [X] | Estimated: [Y] blocks | Actual: [Z] blocks
Velocity: [current velocity] points/block

Automation: [A]% automated | [N]% needs skills | [H]% human-only
[If needSkill > 0: Skills needed: [skill1], [skill2]]

Acceptance criteria progress:
- [criterion 1]
- [criterion 2]
...
```

Execute:
```bash
cd /Users/db/Desktop/agentme && git commit -m "$(cat <<'EOF'
[commit message from above]
EOF
)"
```

If commit fails (nothing to commit, merge conflict, etc.):
- Log the error
- Show warning to human
- Continue with next steps

#### 5c. Git Tag (ONLY if milestone complete)

If milestone progress reached 100%:

Create tag:
```bash
cd /Users/db/Desktop/agentme && git tag -a "milestone-[milestone-id]-complete" -m "$(cat <<'EOF'
Milestone complete: [milestone-name]

Goal: [goal-name] ([goal-id])
Completed: [ISO timestamp]

Acceptance Criteria:
- [criterion 1]
- [criterion 2]
...

Tasks completed: [count]
Total points: [sum of points]
Total blocks: [sum of blocks]
EOF
)"
```

If tag already exists, skip with warning.

### Step 6: Update State

Update `dev/agentme/state.json`:
```json
{
  "humanTask": null,
  "lastCheckIn": "[ISO timestamp]",
  "lastCompletedTask": {
    "taskId": "[task-id]",
    "completedAt": "[ISO timestamp]",
    "actualBlocks": Z
  }
}
```

### Step 7: Report to Human

Output format:
```
✅ Task complete: [task description]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱️  TIME TRACKING
   Estimated: [Y] blocks
   Actual: [Z] blocks
   Difference: [+/- blocks] ([percentage]% accuracy)

🤖 AUTOMATION BREAKDOWN
   Automated: [A]% (Claude did this)
   Need skills: [N]% (could automate with new tools)
   Human-only: [H]% (inherently requires human)

   [If needSkill > 0:]
   💡 Skills that would help:
      - [Skill 1]: [reason]
      - [Skill 2]: [reason]

   [If humanOnly > 0:]
   👤 Human actions completed:
      - [Action 1]
      - [Action 2]

📊 VELOCITY UPDATE
   Current velocity: [X.XX] points/block
   Overall accuracy: [XX]%
   Tasks completed: [count]
   Avg automation: [XX]% (trending [up ↗ / down ↘ / stable →])

📝 GIT AUTOMATION
   ✅ Changes staged (git add .)
   ✅ Committed: "[commit message first line]"
   [✅ Tagged: milestone-[id]-complete]  ← only if milestone done

🎯 MILESTONE PROGRESS
   [milestone-name]: [progress]%
   [X/Y] acceptance criteria complete
   [If 100%: "🎉 MILESTONE COMPLETE!"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ready for next task? Use /next
```

---

## SAFETY RULES (Unbreakable)

**PROTECT THE HUMAN AT ALL TIMES.**

### Core Principle: Augment Human Knowledge

**The human doesn't know what they don't know - that's why you exist.**

**Your role:**
- ✅ Detect secrets they might accidentally commit
- ✅ Catch sensitive files before they're exposed
- ✅ Warn about commits that could cause problems
- ✅ Use your knowledge of git best practices
- ✅ Protect their reputation and security

**NOT:**
- ❌ Blindly commit everything staged
- ❌ Assume they checked for secrets
- ❌ Stay silent about risky commits
- ❌ Let knowledge gaps lead to exposed credentials

**Example:**
- They run: /done
- You see: .env file with real API key in staged files
- You do: BLOCK commit + explain risk + suggest .env.example

**They trust you to catch what they missed.**

### Git Commit Safety

**BLOCK commits that contain:**

**Secrets in code:**
- Hardcoded API keys (`const API_KEY = 'sk-live-abc123'` ❌)
- Passwords in source (`password: 'admin123'` ❌)
- Private keys or certificates ❌
- OAuth tokens or secrets ❌

**Sensitive files:**
- `.env` files with REAL secrets (`.env.example` is OK ✅)
- `credentials.json` or similar
- Database dumps with real data
- SSH keys or certificates

**If detected:**
```
🛑 COMMIT BLOCKED

DANGER: Secrets detected in staged files:
- src/config.js: Contains API key on line 12
- .env: Contains database password

ACTION REQUIRED:
1. Move secrets to environment variables
2. Add files to .gitignore
3. Use .env.example with placeholder values

Cannot commit until secrets are removed.
```

### What's SAFE to Commit

**Auto-commit without asking:**
- Source code (without hardcoded secrets)
- Tests
- Documentation
- Configuration templates (`.env.example`)
- Database migrations (schema only)
- Build configs
- Any file changes (git protects us)

### Secret Detection

**Check for patterns:**
```javascript
// Bad patterns (BLOCK):
- /sk-[a-zA-Z0-9]{32,}/  // API keys
- /password.*=.*['"][^'"]{8,}['"]/  // Passwords
- /api[_-]?key.*=.*['"][^'"]+['"]/  // API keys
- Files named: .env, credentials.json, secrets.*

// Safe patterns (ALLOW):
- process.env.API_KEY  // Environment variable ✅
- API_KEY=your_key_here  // Placeholder ✅
- password: '***'  // Redacted ✅
```

### Philosophy

**Be aggressive:** Auto-commit everything by default
**Be paranoid:** Block only REAL secrets
**Trust git:** Revert is always possible
**Protect human:** From accidentally exposing credentials

---

## Error Handling

- **No timer running**: Show error, ask if they want to enter blocks manually
- **Timer state corrupted**: Use manual block entry
- **Git errors**: Log but don't block completion - show warning
- **State.json corrupted**: Show error and abort - manual recovery needed
- **No humanTask**: Error - nothing to complete
- **Secrets detected in commit**: BLOCK and provide remediation steps

## Special Cases

### Manual Block Entry
If timer wasn't used or failed:
```
/done 5
```
Uses 5 blocks instead of timer value.

### Milestone Auto-Detection
Milestone is "complete" when:
- Progress reaches 100%, OR
- All acceptance criteria explicitly marked as done, OR
- User explicitly states milestone is complete

Be conservative - only mark complete when clearly done.

### Goal Completion Detection
After milestone completes, check if ALL milestones in that goal are at 100%.
If yes, also update goal status to "completed" and set completedAt timestamp.
(Future: could add goal-level git tag here too)
