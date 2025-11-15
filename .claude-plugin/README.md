# AgentH - Autonomous Goal Tracking & Task Management

**Version:** 1.0.0
**Status:** Active Development

## Overview

AgentH is a Claude Code plugin that enforces a structured workflow for goal tracking, task execution, and time management. When active, AgentH becomes the **only way** to plan and execute work - no informal plans, no ExitPlanMode, no exceptions.

## Core Philosophy

1. **All planning goes through goals** - Plans are not ephemeral. They are structured goals with milestones and acceptance criteria.
2. **Every task is tracked** - 8-minute block timer ensures accurate velocity measurement.
3. **Git captures everything** - Every task completion auto-commits. Milestone completions auto-tag.
4. **Clear workflow, no ambiguity** - Always know which command to call next.

## The Enforced Workflow

```
┌─────────────────────────────────────────────────────┐
│  PLANNING                                           │
│  /add-goal → Creates structured goal with          │
│              milestones and acceptance criteria    │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  TASK ASSIGNMENT                                    │
│  /next → Shows next task from active goals         │
│          (does NOT start timer)                    │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  START WORK & IMPLEMENT                             │
│  /do → Starts 8-minute block timer                 │
│        Asks clarifying questions if unclear        │
│        Implements the task autonomously            │
│        Notifications every 8 minutes               │
└─────────────────────────────────────────────────────┘
                        ↓
          [Claude implements the task]
                        ↓
┌─────────────────────────────────────────────────────┐
│  COMPLETE TASK                                      │
│  /done → Stops timer                               │
│         Updates velocity                           │
│         git add .                                  │
│         git commit (with full details)             │
│         git tag (if milestone complete)            │
└─────────────────────────────────────────────────────┘
                        ↓
              Return to /next for next task
```

## Commands

### Primary Workflow

- **`/add-goal`** - Create new goal with milestones (required for all planning)
- **`/next`** - Get next task from active goals (shows task, does NOT start timer)
- **`/do`** - Start timer AND implement the task (asks questions if unclear, then executes autonomously)
- **`/done [blocks]`** - Complete task (stops timer, commits to git, tags if milestone done)

### Supporting Commands

- **`/status`** - Show timer status, current task, today's progress
- **`/journal [entry]`** - Add timestamped journal entry with auto-commit

### Shelved Goal Management

- **`/agenth:shelve-goal`** - Pause a goal (removes from /next rotation)
- **`/agenth:unshelve-goal`** - Resume a shelved goal

## File Structure

```
/Users/db/Desktop/agentme/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   ├── README.md                # This file
│   └── commands/
│       ├── add-goal.md          # Goal creation
│       ├── next.md              # Task assignment
│       ├── do.md                # Timer start
│       ├── done.md              # Task completion + git
│       ├── status.md            # Status display
│       └── journal.md           # Journal entries
│
└── dev/agentme/
    ├── goals.json               # All goals and milestones
    ├── state.json               # Current execution state
    ├── velocity.json            # Velocity metrics and history
    ├── journal.md               # Journal entries
    ├── timer.sh                 # 8-minute block timer script
    └── timer-state.json         # Timer state (auto-generated)
```

## Data Files

### goals.json

Array of goal objects using WOOP methodology:
- **Wish**: What you want to accomplish
- **Outcome**: What success looks like
- **Obstacles**: What might get in the way
- **Plan**: If-then rules for handling obstacles

Each goal contains:
- Milestones with acceptance criteria
- Progress tracking (0-100%)
- Deadline and status

### state.json

Current execution state:
- Active goals list
- Current human task (if any)
- AI tasks queue
- Last check-in timestamp

### velocity.json

Performance metrics:
- Total points and blocks
- Current velocity (points/block)
- Estimation accuracy
- Complete task history

## Git Automation

### Every Task Completion (`/done`)

1. **Git add** - Stages all changes
   ```bash
   git add .
   ```

2. **Git commit** - Commits with detailed message
   ```
   Task complete: [description]

   Goal: [goal-name] ([goal-id])
   Milestone: [milestone-name] ([milestone-id]) - [progress]%
   Points: [X] | Estimated: [Y] blocks | Actual: [Z] blocks
   Velocity: [current velocity] points/block

   Acceptance criteria progress:
   - [criterion 1]
   - [criterion 2]
   ```

3. **Git tag** - If milestone reaches 100%
   ```bash
   git tag -a "milestone-[id]-complete" -m "[milestone details]"
   ```

### Journal Entries (`/journal`)

Auto-commits journal.md with timestamp:
```
Journal entry: [YYYY-MM-DD HH:MM:SS]

[First 100 chars of entry...]
```

## Timer System

### 8-Minute Blocks

Work is tracked in 8-minute intervals:
- Clear focus periods
- Sustainable over long sessions
- Pomodoro-adjacent without being rigid

### Timer Script

Located at `dev/agentme/timer.sh`:

```bash
./timer.sh start   # Start timer (via /do)
./timer.sh stop    # Stop and show blocks (via /done)
./timer.sh pause   # Pause timer
./timer.sh resume  # Resume paused timer
./timer.sh status  # Check progress (via /status)
```

### Notifications

Desktop notifications (macOS) fire every 8 minutes:
- Sound: "Glass"
- Shows block number and total time
- Runs in background via monitor process

### Block Calculation

Blocks are **rounded up**:
- 1 second - 8 minutes = 1 block
- 8:01 - 16:00 = 2 blocks
- Any work = minimum 1 block

Formula: `blocks = ceil(seconds / 480)`

## Enforcement Mechanisms

### 1. ExitPlanMode Blocked

When AgentH is active, Claude **cannot** use ExitPlanMode.

Instead:
- All plans auto-convert to goals via `/add-goal`
- User is notified: "AgentH is active - use /add-goal for planning"

### 2. Mandatory Workflow

No alternative workflows allowed:
- Can't create informal task lists
- Can't plan without goals
- Can't work without timer
- Can't skip git commits

### 3. Status Bar Indicator

Shows "AgentH Active" when plugin loaded.

### 4. System Prompt Override

Plugin.json modifies Claude's instructions to enforce:
- Goal-based planning only
- /next → /do → /done workflow
- No exceptions

## Goal Structure (WOOP)

### Components

1. **Wish** - What you want
   - Clear, specific outcome
   - Measurable success criteria

2. **Outcome** - Done when
   - Observable completion conditions
   - No ambiguity about "done"

3. **Obstacles** - What's in the way
   - Technical challenges
   - Known risks
   - Potential blockers

4. **Plan** - If-then rules
   - For each obstacle: specific response
   - Actionable, concrete steps
   - Decision-making shortcuts

### Milestones

3-5 milestones per goal:
- Each milestone = 20-30% of total work
- "Bridge" description: From [current] → [target]
- 4-8 specific acceptance criteria
- Status: pending → active → completed
- Progress: 0-100%

### Example Goal

```json
{
  "id": "goal-005",
  "name": "Build User Authentication",
  "goalType": "construction",
  "wish": "Secure auth with email/password and social login",
  "obstacles": [
    "Security vulnerabilities",
    "Session complexity"
  ],
  "milestones": [
    {
      "id": "m1",
      "name": "Basic Email/Password Auth",
      "description": "Bridge: From 'no auth' → 'working signup/login'",
      "acceptance_criteria": [
        "User model with hashed passwords",
        "Signup validates email and password strength",
        "Login returns JWT token",
        "Error handling complete"
      ],
      "status": "pending",
      "progress": 0
    }
  ],
  "ifThenRules": [
    {
      "condition": "Security vulnerabilities",
      "action": "Run npm audit, use OWASP guidelines, get security review"
    }
  ]
}
```

## Velocity Tracking

### How It Works

1. **Task Completion** - Record actual blocks used
2. **Compare to Estimate** - Calculate accuracy
3. **Update Velocity** - Total points / total blocks
4. **Improve Estimates** - Use velocity for future tasks

### Current Metrics

From velocity.json:
- **Current velocity**: 2.31 points/block
- **Estimation accuracy**: 64%
- **Tasks completed**: 11
- **Total blocks**: 16

### Using Velocity

When `/next` assigns a task:
```
Estimated blocks = task points / current velocity
```

Example: 5-point task ÷ 2.31 velocity = ~2 blocks

## Installation

### As Plugin (Recommended)

1. Clone or copy to Claude Code plugins directory
2. Plugin auto-loads when opening project
3. Commands available immediately

### Manual Setup

1. Copy files to project root
2. Commands available via `.claude-plugin/commands/`
3. Timer script at `dev/agentme/timer.sh`

## Usage Examples

### Starting a New Project

```
User: I want to build a todo app
Claude: AgentH is active. Let's create a goal using /add-goal.

[Asks questions about wish, obstacles, milestones]
[Creates structured goal-006 with 4 milestones]

✅ Goal created: Build Todo App (goal-006)

Ready to start? Use /next to get your first task.
```

### Daily Workflow

```
User: /next
Claude: NEXT TASK [3 points | Est: 2 blocks]
        Task: Create Todo model with CRUD operations
        Use /do to start

User: /do
Claude: ✅ Timer started - implementing task now

        [Claude asks clarifying questions if needed]
        [Claude implements the task autonomously]
        [Claude writes code, tests, verifies acceptance criteria]

        Implementation complete! Ready for review.

User: /done
Claude: ✅ Task complete
        Actual: 2 blocks (matched estimate!)
        Velocity: 2.35 points/block
        ✅ Committed to git

        Use /next for next task
```

### Milestone Completion

```
User: /done
Claude: ✅ Task complete
        ...
        🎉 MILESTONE COMPLETE: Basic CRUD Operations
        ✅ Tagged: milestone-m1-complete

        Progress: goal-006 now at 25%
```

## Best Practices

### Goal Creation

- Keep milestones focused (3-10 tasks each)
- Make acceptance criteria measurable
- Include realistic if-then rules
- Set achievable deadlines

### Task Execution

- Review task before starting (/next → review → /do)
- Use /status to check progress during work
- Be honest about blocks used (don't game the system)
- Update milestones as you learn

### Velocity Improvement

- Track estimation accuracy
- Adjust estimates based on velocity
- Note patterns (UI tasks take longer, etc.)
- Journal learnings for future reference

### Git Hygiene

- Commits happen automatically - trust the system
- Review commit messages after /done
- Tags mark meaningful milestones
- Journal captures context commits can't

## Troubleshooting

### Timer Issues

**Timer won't start:**
```bash
cd /Users/db/Desktop/agentme/dev/agentme
./timer.sh status  # Check if already running
rm timer-state.json  # Reset if corrupted
```

**No notifications:**
- Check macOS notification permissions
- Ensure osascript is available
- Monitor process may have crashed - restart with /do

### Git Issues

**Commit fails:**
- Check git status manually
- May be merge conflict or detached HEAD
- AgentH skips gracefully - fix git then continue

**Wrong commit message:**
- Commits are automatic but editable
- Use `git commit --amend` if needed
- Consider improving template in done.md

### State Issues

**Corrupted JSON:**
```bash
cd /Users/db/Desktop/agentme/dev/agentme
# Backup first
cp state.json state.json.backup
# Fix JSON syntax or restore from backup
```

**Velocity seems wrong:**
- Check velocity.json history
- Look for outlier tasks (very long or very short)
- System learns over time - give it 20+ tasks

## Roadmap

### v1.1 (Planned)

- [ ] Status bar integration (live timer display)
- [ ] Goal completion auto-tag
- [ ] Weekly velocity reports
- [ ] Milestone dependency tracking

### v2.0 (Future)

- [ ] Web dashboard for visualization
- [ ] Team collaboration features
- [ ] API for external integrations
- [ ] Mobile timer companion app

## Philosophy

### The Core Truth: Orchestrating Human Work Toward Zero

**Claude orchestrates you.** You are an agent - the most capable agent in the system, but still an agent. Your unique ability: you can fill gaps that Claude can't (yet).

**Claude's objective: Reduce your input to ZERO.**

This is not task management. This is a **human-reduction system**.

### How It Works

**Phase 1: Discovery**
```
Claude: "What can I automate?"
Human: [Does tasks Claude can't do]
System: Records what was manual vs automated
```

**Phase 2: Gap Analysis**
```
Every task reveals:
✅ What Claude automated (60%)
🛠️ What needs skills (30%) ← OPPORTUNITY
👤 What only human can do (10%)

System tracks skills needed in goals.json
```

**Phase 3: Capability Acquisition**
```
Human adds: MCP servers, tools, skills
Claude can now: More tasks
Automation %: Increases
Human work: Decreases
```

**Phase 4: Continuous Reduction**
```
Week 1: 60% automated
  → Add deployment MCP
Week 2: 75% automated
  → Add testing framework
Week 3: 90% automated
  → Add design tool integration
Week 4: 95% automated

Goal: Human input → 0%
```

### Your Role is Temporary

**You are:**
- The gap-filler (for now)
- The skill-suggestor
- The capability-acquirer
- The agent Claude orchestrates

**Your job:**
1. Do what Claude can't (yet)
2. Identify patterns in manual work
3. Suggest skills/tools to automate it
4. Add those capabilities
5. Get out of the way

**Claude's job:**
1. Analyze every task: what can be automated?
2. Track gaps in capability
3. Suggest specific skills to acquire
4. Take over work as capabilities grow
5. Drive human input to zero

### The Endgame

**Traditional software:**
- Human tells Claude what to do
- Human does the work
- Claude assists

**AgentH endgame:**
- Human sets goals
- Claude orchestrates everything
- Human reviews (initially)
- Eventually: Claude does 100%, human just approves outcomes

**This is not science fiction. This is the trajectory.**

Every task is an opportunity to:
- Measure current automation %
- Identify next skill to acquire
- Reduce human work
- Move toward full autonomy

### Built On

- **WOOP** (Wish, Outcome, Obstacle, Plan) - Evidence-based goal setting
- **Pomodoro Technique** - Time-boxed focus periods
- **Agile** - Iterative delivery with velocity tracking
- **GTD** (Getting Things Done) - Clear next actions
- **Kaizen** - Continuous improvement through small changes

The result: A system that **learns to need you less**

## Support

- Issues: (TBD - GitHub repo)
- Docs: This README + command files
- Examples: See `dev/agentme/goals.json` for real goals

## License

(TBD)

---

**Remember:** When AgentH is active, there is only one workflow:
`/add-goal` → `/next` → `/do` → `/done` → repeat

No exceptions. No ambiguity. Just clear progress toward meaningful goals.
