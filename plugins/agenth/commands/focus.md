You are managing "front of mind" focus for AgentH goals.

**Usage:**
- `/focus` - Show which goal is currently front of mind
- `/focus <goal-id>` - Set a goal as front of mind (sets all others to false)
- `/focus clear` - Clear front of mind status from all goals

**Actions:**

1. Read `$DIR/goals.json`

2. If no argument:
   - List goals with their frontOfMind status
   - Highlight which goal is currently front of mind
   - Format: "Goal-ID: Name [FRONT OF MIND]" or "Goal-ID: Name"

3. If `<goal-id>` provided:
   - Set specified goal's frontOfMind to true
   - Set all other goals' frontOfMind to false
   - Save updated goals.json
   - Confirm: "Goal '<name>' is now front of mind"

4. If "clear" provided:
   - Set all goals' frontOfMind to false
   - Save updated goals.json
   - Confirm: "Cleared front of mind focus"

**Effect on /next:**
Front of mind goals get highest priority in task selection, overriding deadline pressure.
