# /journal - Add Journal Entry with Auto-Commit

Creates a timestamped journal entry and automatically commits it to git.

## Usage

```
/journal [optional: entry text]
```

If no text provided, prompts user to write entry.

## Instructions

### Step 1: Get Journal Entry

If entry text provided as argument:
- Use that as the journal entry

If no text provided:
- Prompt user: "What would you like to journal about?"
- Wait for user response
- Use their response as the entry

### Step 2: Create Timestamp

Generate current timestamp in format:
```
[YYYY-MM-DD HH:MM:SS]
```

Example: `[2025-11-15 14:30:45]`

### Step 3: Append to Journal File

Read `dev/agentme/journal.md` (create if doesn't exist).

Append entry in this format:
```markdown
### [YYYY-MM-DD HH:MM:SS]

[journal entry text]

---
```

Write updated file back.

### Step 4: ENFORCED GIT WORKFLOW

**Auto-commit the journal entry:**

#### 4a. Git Add
```bash
cd /Users/db/Desktop/agentme && git add dev/agentme/journal.md
```

#### 4b. Git Commit
```bash
cd /Users/db/Desktop/agentme && git commit -m "$(cat <<'EOF'
Journal entry: [YYYY-MM-DD HH:MM:SS]

[First 100 chars of entry...]
EOF
)"
```

If commit fails:
- Log error
- Show warning: "Journal saved locally but not committed to git"
- Continue

### Step 5: Confirm to User

Output:
```
✅ Journal entry recorded

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 [YYYY-MM-DD HH:MM:SS]

[journal entry text]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Saved to: dev/agentme/journal.md
✅ Committed to git
```

## Example Journal Entry Format

In journal.md:
```markdown
# AgentMe Journal

Reflections, learnings, and progress notes.

---

### [2025-11-15 14:30:45]

Completed the timer integration milestone. The 8-minute blocks are working really well for focus. I noticed that I tend to underestimate UI tasks by about 2 blocks. Should adjust my estimates going forward.

---

### [2025-11-14 09:15:22]

Started work on the authentication system. Decided to use Passport.js instead of rolling my own. The if-then rules in the goal helped me make this decision quickly when I hit the OAuth complexity.

---
```

## Use Cases

### Quick Reflection
```
/journal Just finished debugging the login flow. Found the issue was in the JWT verification middleware.
```

### Longer Entry
```
/journal
[Claude prompts]
[User writes multi-paragraph reflection]
```

### Learnings
```
/journal Learned that jq needs -r flag to output raw strings. This caused the timer state bug.
```

### Decisions
```
/journal Decided to shelve goal-001 (QJump) to focus on AgentH. The plugin will have more immediate impact.
```

## Integration with Goals

Journal entries can reference goals, milestones, and tasks:
- Use goal IDs: "Completed goal-002-m3"
- Reference milestones: "The timer integration (m2) went smoothly"
- Track obstacles: "Hit the scope creep obstacle - used the if-then rule to stay focused"

## Error Handling

- Journal file missing: Create new file with header
- Git commit fails: Save locally, warn user
- Empty entry: Prompt for content, don't save blank entries
- Timestamp formatting error: Use fallback ISO format
