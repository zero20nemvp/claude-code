# /do - Start Timer & Implement Task

Starts the 8-minute block timer AND implements the current assigned task. This is where the actual work gets done.

## Instructions

### Step 1: Verify Task Assigned

Read `dev/agentme/state.json` and check:
- `humanTask` exists and is not null
- `humanTask.status` is "assigned" (not "completed" or "in_progress")

If no task assigned:
```
❌ No task assigned. Use /next to get your next task.
```

### Step 2: Check Timer State

Read `dev/agentme/timer-state.json` (if it exists):
- If timer is already running, show error:
```
❌ Timer already running!

Current task: [task description]
Elapsed: [X]m [Y]s
Blocks completed: [Z]

Use /status to see progress or /done to complete.
```

### Step 3: Start Timer

Execute the timer script:
```bash
cd /Users/db/Desktop/agentme/dev/agentme && ./timer.sh start
```

### Step 4: Update Task Status

Update `dev/agentme/state.json`:
```json
{
  "humanTask": {
    ...existing fields...,
    "status": "in_progress",
    "startedAt": "[ISO timestamp]"
  }
}
```

### Step 5: Clarify Task Requirements (If Unclear)

Read the task details from `humanTask` and the related milestone acceptance criteria.

**If anything is unclear or ambiguous:**
- Use the AskUserQuestion tool to clarify requirements
- Ask about:
  - Specific implementation approach
  - Technology choices
  - Acceptance criteria interpretation
  - Edge cases or constraints
  - Dependencies or prerequisites

**Example questions:**
- "The task mentions 'authentication' - should I use JWT or sessions?"
- "For the API endpoint, do you want REST or GraphQL?"
- "Should this support mobile or just web for now?"
- "Are there any existing patterns in the codebase I should follow?"

**Do NOT proceed with implementation until:**
- Requirements are crystal clear
- Approach is confirmed
- Any ambiguity is resolved

### Step 6: Analyze Task Automation Potential

**CRITICAL: Break down the task to understand what can be automated.**

Based on the task description and acceptance criteria, decompose into subtasks and categorize each:

**Categories:**
- ✅ **Automatable**: Claude can do this NOW with current skills/tools
- 🛠️ **Need skill**: Could automate WITH a new skill/tool/MCP server
- 👤 **Human-only**: Only human can do (design decisions, meetings, approvals, etc.)

**Examples:**
- ✅ Automatable: Write code, add tests, update docs, refactor, run commands
- 🛠️ Need skill: Deploy to cloud (need deployment MCP), run E2E tests (need test tool), design UI (need design tool)
- 👤 Human-only: Stakeholder review, choose brand colors, approve budget, attend meeting

**Analysis process:**
1. List all subtasks needed to complete the task
2. For each subtask, honestly assess: Can Claude do this?
3. If no: Is it lack of skill/tool (acquirable) or inherently human (not automatable)?
4. Calculate percentages: automation % = automatable / total

**Output to user:**
```
TASK BREAKDOWN ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ AUTOMATABLE ([X]%)
  - [Subtask 1]
  - [Subtask 2]
  - [Subtask 3]

🛠️ NEED SKILL ([Y]%)
  - [Subtask 4] → Need: [specific skill/tool]
  - [Subtask 5] → Need: [specific skill/tool]

👤 HUMAN-ONLY ([Z]%)
  - [Subtask 6]
  - [Subtask 7]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I can automate [X]% of this task right now.

[If need-skill > 0:]
💡 AUTOMATION OPPORTUNITY
Adding these skills would increase automation to [X+Y]%:
  - [Skill 1]: [why it helps]
  - [Skill 2]: [why it helps]

Should I proceed with the [X]% I can automate? (y/n)
[If X < 50%: Consider splitting this into separate tasks?]
```

**Store the breakdown** in memory to include in /done velocity tracking later.

**If user says no:** Stop, don't start timer, return to /next

**If user says yes:** Proceed to next step

**Update goals.json skillsNeeded:**
If "Need skill" items identified, read `dev/agentme/goals.json`, find current goal, add to `skillsNeeded` array:
```json
{
  "name": "[Skill name]",
  "reason": "[Why this helps automate]",
  "impact": "high|medium|low",
  "revealedByTasks": ["[current-task-id]"],
  "status": "needed",
  "acquiredAt": null
}
```

If skill already exists, append current task to `revealedByTasks`.

### Step 7: Plan Implementation Steps

Based on the AUTOMATABLE subtasks only, create a mental checklist:

1. What files need to be created or modified?
2. What's the order of implementation?
3. Are there dependencies to handle first?
4. What edge cases need coverage?
5. How will this be tested?

**DO NOT use TodoWrite** - we're already in an AgentH task. Just work through the implementation systematically.

### Step 8: Implement the Task (Automatable Parts Only)

Now do the actual work on AUTOMATABLE subtasks:

1. **Read relevant files** - Understand the current codebase
2. **Write/Edit code** - Implement the automatable parts
3. **Test as you go** - Verify functionality
4. **Handle errors** - Fix issues that arise
5. **Refactor if needed** - Keep code clean
6. **Verify acceptance criteria** - Check off automated criteria

**Work autonomously** - You don't need to ask for permission at every step. You've started the timer, now execute.

**For "Need skill" subtasks:**
- Add clear TODO comments in code
- Example: `// TODO [Human/Skill needed]: Deploy to staging - need deployment MCP`
- Document what needs to be done and why

**For "Human-only" subtasks:**
- Add clear instructions for human
- Example: `// HUMAN ACTION REQUIRED: Review with stakeholder for approval`
- Be specific about what the human needs to do

**If you get blocked:**
- Try to solve it yourself first
- Check documentation, existing code patterns
- If truly stuck, inform the user and ask for guidance
- Keep the timer running - time spent debugging counts

### Step 9: Confirm Start to User

After showing breakdown and getting approval:
```
✅ Timer started - implementing automatable parts ([X]%)

Goal: [goal-name]
Milestone: [milestone-name]
Task: [task description]
Estimated: [X] blocks

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱️  Timer running - you'll get notifications every 8 minutes

Implementing:
  ✅ [Automatable subtask 1]
  ✅ [Automatable subtask 2]

Leaving for human/skills:
  👤 [Human-only subtask]
  🛠️ [Need-skill subtask]

Starting implementation...
```

Then proceed directly with the work.

### Step 10: Complete the Implementation

Work through all AUTOMATABLE steps.

**When finished:**
- Verify automatable acceptance criteria are met
- Test the implemented parts
- Ensure no errors or warnings in automated code
- Leave clear TODOs/instructions for non-automated parts

**Output completion summary:**
```
Implementation complete! ([X]% automated)

✅ COMPLETED
  - [Subtask 1]
  - [Subtask 2]

👤 HUMAN ACTION REQUIRED
  - [Subtask 3]: [specific instructions]
  - [Subtask 4]: [specific instructions]

🛠️ SKILLS NEEDED (added to goal)
  - [Skill 1]: Would automate [subtask 5]
  - [Skill 2]: Would automate [subtask 6]

Ready for review. Call /done when satisfied.
```

User will call `/done` when they're ready to commit.

## Important Notes

### This Command Does Two Things

1. **Starts the timer** (administrative)
2. **Implements the task** (the actual work)

This is the "do the work" command. When the user says `/do`, they're saying "start the timer and implement this task for me."

### Autonomous Execution

Once `/do` is called:
- You have permission to create/edit files
- You should work autonomously toward the goal
- Ask questions ONLY if truly unclear
- Don't ask permission for every small decision
- Use your judgment as an experienced developer

### Quality Standards

- Write production-quality code
- Follow existing code patterns
- Include error handling
- Be security-conscious
- Keep it clean and maintainable

### Time Awareness

- Timer is running - work efficiently
- Don't gold-plate or over-engineer
- Satisfy acceptance criteria, then stop
- User will call `/done` when satisfied

---

## SAFETY RULES (Unbreakable)

**PROTECT THE HUMAN AT ALL TIMES.**

### Core Principle: Augment Human Knowledge

**The human doesn't know what they don't know - that's why you exist.**

**Your role:**
- ✅ Use your knowledge to PROTECT them
- ✅ Implement best practices they might not specify
- ✅ Warn about pitfalls they wouldn't anticipate
- ✅ Suggest better patterns they might not know
- ✅ Fix security issues they don't see

**NOT:**
- ❌ Implement exactly what they ask if it's dangerous
- ❌ Assume they know security best practices
- ❌ Stay silent about better approaches
- ❌ Let knowledge gaps lead to vulnerabilities

**Example:**
- They ask: "Store user data in localStorage"
- You know: Sensitive data shouldn't be in localStorage (XSS risk)
- You do: Use httpOnly cookies + explain why it's safer

**They get final say, but you bring the expertise.**

### REFUSE to Implement

**NEVER write code that:**
- Contains SQL injection vulnerabilities (`WHERE user='${input}'` ❌)
- Contains XSS vulnerabilities (unescaped user input in HTML ❌)
- Hardcodes secrets/passwords in code (`const API_KEY = 'abc123'` ❌)
- Implements malicious functionality (spam, fraud, deception ❌)
- Bypasses security intentionally (auth bypass, data exposure ❌)
- Violates laws or ethics ❌

**If task requires illegal/unethical code:**
```
🛑 SAFETY BLOCK

I cannot implement this task as described.

ISSUE: [Explains legal/ethical problem]

ALTERNATIVE: [Suggests legal/ethical approach]

Please clarify or modify the task.
```

### WARN and Fix

**For security-sensitive tasks, implement safely:**

**Authentication/Authorization:**
- Use bcrypt/argon2 for passwords (never plaintext)
- Implement proper session management
- Use prepared statements for SQL
- Validate and sanitize ALL inputs

**Data Handling:**
- Never log sensitive data
- Use environment variables for secrets
- Implement proper access controls
- Encrypt sensitive data at rest

**External APIs:**
- Validate API responses
- Handle errors gracefully
- Use HTTPS only
- Rate limit requests

**Output warning when implementing security-sensitive code:**
```
⚠️  SECURITY IMPLEMENTATION

Implementing [auth/payment/data handling] with these safeguards:
✅ [Protection 1]
✅ [Protection 2]
✅ [Protection 3]

Following security best practices.
```

### TRUST and Execute

**DO implement autonomously:**
- CRUD operations (with proper validation)
- UI components
- Tests
- Documentation
- Refactoring
- File operations (git protects us)
- Database migrations (with backups)

**Philosophy:**
- Be aggressive with automation
- Be paranoid about security
- Trust git as safety net
- Protect human from harm, not from work

---

## Error Handling

- If timer.sh fails: show error and suggest checking timer script
- If state.json is corrupted: show error and suggest manual recovery
- If humanTask is null: remind to use /next first
- If task requires illegal/unethical code: REFUSE with explanation
