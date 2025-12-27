# AgentC

**Zero cognitive load. Trust the process. Just execute.**

## The Only Interface

    /next -> /do -> /done -> /next -> /do -> /done ...

Plus /now to check "where am I?" at any point.

**Every command output ends with exactly one of:**

    DO: /next   or   DO: /do   or   DO: /done

You never think "what should I call?" - the system always tells you.

## Philosophy

The human is an **orchestrated agent** - like any other agent in the system, but with unique capabilities. The system:

1. **Pulls toward outcomes** - Works backwards from goals to find the essential path
2. **Optimizes across all goals** - Considers deadlines, velocity, cross-goal leverage
3. **Does everything it can** - AI executes all subtasks within its capability
4. **Surfaces only atomic human actions** - You only do what ONLY you can do

Think of it like an Amazon warehouse: you put items on the tray, the system knows where everything goes. You don't think about organization - you trust the process and execute.

### Human as Agent

The human is an **agent with specific capabilities** that Claude currently lacks:

| Human Capabilities | Why Claude Can't |
|-------------------|------------------|
| External system access | No production credentials |
| Physical device testing | No physical presence |
| Real browser sessions | No persistent auth |
| Strategic authority | Decisions require human sign-off |
| External communication | Can't send emails, Slack, etc. |
| Subjective UX judgment | "Does this feel right?" |
| Domain expertise | Knowledge not in codebase |

**Tasks are assigned by CAPABILITY requirement, not importance.**

If Claude can do it → Claude does it.
Human only does what ONLY human can do.

### Continuous Efficiency Improvement

Claude continuously identifies ways to expand its capabilities:
- MCP servers for external access
- Skills to codify human knowledge
- Automations for repetitive tasks

**Aim:** Reduce human load to true capability gaps only.

## The Only Interface

**Manual mode:**
```
/next → /do → /done (repeat)
```

**Autonomous mode:**
```
/start → Claude drives everything
/next → /do → /done for your tasks
```

That's it. The system handles everything else.

## Autonomous Mode

**Claude becomes the orchestrator. You become an agent.**

```
┌─────────────────────────────────────────────┐
│            Claude (Orchestrator)            │
│                                             │
│   ┌──────────┐    ┌──────────┐             │
│   │ AI Agent │    │ AI Agent │  ...        │
│   │ (bg task)│    │ (bg task)│             │
│   └──────────┘    └──────────┘             │
│                                             │
│   ┌──────────────────────────────────────┐ │
│   │         Human Agent (You)            │ │
│   │  Queue: [task1, task2, task3]        │ │
│   │  Interface: /next → /do → /done      │ │
│   └──────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Retry 3x** | Claude tries 3 different approaches before escalating |
| **Ruthless decomposition** | Extract every Claude-doable piece, human gets minimal action |
| **Parallel by default** | All independent tasks run simultaneously |
| **Execution-ready** | Human tasks = exact commands, zero thinking |
| **Skill creation** | Track patterns, create automations, path to 100% |

### Commands

| Command | Purpose |
|---------|---------|
| `/start [goal]` | Kick off autonomous mode |
| `/assess [goal-id]` | Check goal quality before autonomous execution |
| `/skill` | Create skill/MCP from recurring patterns |
| `/status` | See Claude's work + your queue + metrics |

### Goal Quality Assessment

Before autonomous execution, goals are assessed for readiness:

| Score | Quality |
|-------|---------|
| ✅ Testable | Can be verified programmatically |
| ✅ Specific | Unambiguous language |
| ✅ Measurable | Clear pass/fail condition |
| ✅ Independent | No human judgment to verify |

- Goals < 50% ready: Block autonomous execution
- Goals 50-75%: Warn, allow with confirmation
- Goals > 75%: Proceed automatically

### Metrics Dashboard

Track progress toward 100% automation:

```
=== AUTOMATION PROGRESS ===
Current: 94% autonomous (target: 100%)
Trend: 85% → 88% → 91% → 94% ↑

TOP CAPABILITY GAPS:
  1. external_system_access (15 tasks)
  2. physical_device_testing (8 tasks)

SKILL OPPORTUNITIES:
  🔥 "SSH to production" (12 occurrences)
```

## Core Workflow

### North Star Creation (with Socratic Questioning)
```
/add-north-star
```
- Context-aware questioning flow
- Problem-first, future-first, or constraint-first
- Unearths guiding direction
- Creates ongoing direction (never completes)

### Goal Creation (with WOOP)
```
/add-goal [north-star-id]
```
- WOOP methodology (Wish, Outcome, Obstacles, Plan)
- Generates milestones (state transitions)
- TDD-based task structure
- Deadline and acceptance criteria

### Task Execution
```
/next [in|out]    # Get next optimal task
/do               # Execute with TDD discipline
/done [blocks]    # Record with verification
```

## The Discipline (Automatic)

### TDD (Test-Driven Development)
Every code task follows RED-GREEN-REFACTOR:
1. Write failing test → See RED
2. Write minimal code → See GREEN
3. Refactor → Stay GREEN

### Code Review
Automatic after every `/do` completion:
- Critical issues block completion
- Important issues fixed before `/done`
- Minor issues noted for future

### Verification
Required before `/done`:
- Must see actual test output
- "Should work" is not acceptable
- Evidence before completion claims

### Milk Quality (Testing Tiers)

Code quality is calibrated via three tiers:

| Tier | Tests Required | Code Philosophy |
|------|----------------|-----------------|
| **Skimmed** | Happy case only | Bare minimum to pass |
| **Semi-skimmed** | Happy + essential sad cases | Minimal but extensible, no overengineering |
| **Full phat** | Happy + all sad + essential mad + logging/monitoring | Production-ready, "bet our future" |

**Configuration:**
- **Default**: Semi-skimmed
- **Override**: `/do --tier skimmed|semi|full`
- **Enforcement**: Strict - `/done` blocked if tier requirements unmet

**Tier Checklists:**

Skimmed:
- [ ] Happy case test written FIRST
- [ ] Happy case test passes
- [ ] Minimal code only

Semi-skimmed:
- [ ] Happy case test written FIRST
- [ ] Essential sad case tests written
- [ ] All tests pass
- [ ] Code extensible but not overengineered

Full phat:
- [ ] Happy case test written FIRST
- [ ] Essential sad case tests written
- [ ] Non-essential sad case tests written
- [ ] Essential mad case tests written
- [ ] Logging implemented
- [ ] Monitoring hooks added
- [ ] All tests pass
- [ ] Production-ready quality

## Data Model

Single file: agentc/agentc.json

**File Locking:** Commands use `scripts/lock.sh` to prevent race conditions when multiple sessions access agentc.json. Lock files (`.lock` directories) should be gitignored:
```
# Add to your project's .gitignore
*.lock
```

Schema version: 1.4

    {
      "version": "1.4",
      "current": {
        "loopState": "idle | assigned | executing",
        "lastAction": {
          "action": "next | do | done | skip",
          "timestamp": "ISO timestamp",
          "description": "What happened"
        },
        "humanTask": { ... },
        "humanTaskQueue": [],
        "aiTasks": [],
        "batchMode": false,
        "reviewDebt": [],
        "reviewPending": false,
        "prepWork": null,
        "lastCheckIn": null
      },
      "patterns": {
        "manualTasks": [
          { "pattern": "...", "count": 5, "firstSeen": "...", "lastSeen": "..." }
        ],
        "lastPatternAnalysis": null
      },
      ...
    }

**Loop State** determines what command to call next:
- idle -> DO: /next
- assigned -> DO: /do
- executing -> DO: /done
- autonomous -> Claude is driving (run /status to see progress)
- waiting_human -> Blocked on human tasks (run /next to get your task)
- complete -> Goal achieved (run /start for new goal)

**Pattern Tracking** identifies recurring manual tasks for skill creation.

**Stage Progress** tracks where each goal is in the journey (discovery to implementation).

Full schema:

    {
      "version": "1.4",
      "northStars": [{
        "id": "ns1",
    "name": "Secure Auth",
    "direction": "Secure user authentication",
    "why": "Users need to trust their data is safe",
    "not": ["Social login", "Enterprise SSO"],
    "design": {
      "questioningFlow": "problem-first",
      "brainstormedAt": "2025-12-12T10:00:00Z"
    },
    "status": "active",
    "frontOfMind": false
  }],
  "goals": [{
    "id": "g1",
    "northStarId": "ns1",
    "wish": "Implement login flow",
    "outcome": ["Login works", "Tests pass"],
    "obstacles": ["Complex legacy code"],
    "ifThen": [{"if": "Stuck on legacy", "then": "Write integration tests first"}],
    "stage": "discovery | design | implementation",
    "stageProgress": {
      "jtbd": { "status": "pending | done", "file": null },
      "stories": { "status": "pending | done", "file": null },
      "features": { "status": "pending | done", "path": null },
      "slices": { "status": "pending | done", "branches": [] }
    },
    "milestones": [
      {
        "id": "m1",
        "name": "Auth infrastructure",
        "description": "User model, JWT, middleware",
        "acceptance_criteria": ["User model exists", "JWT utilities work"],
        "status": "pending",
        "progress": 0
      }
    ],
    "deadline": "2025-12-20T23:59:59Z",
    "status": "active",
    "created": "2025-12-12T10:30:00Z"
  }],
  "current": {
    "loopState": "idle",
    "lastAction": {
      "action": "done",
      "timestamp": "2025-12-20T10:00:00Z",
      "description": "Completed: Send outreach to founders"
    },
    "humanTask": {
      "taskId": "t1",
      "description": "Task description",
      "languageMode": "ruby|javascript",
      "milkQuality": "semi-skimmed",
      "qualityVerification": {
        "happyCaseTested": false,
        "sadCasesTested": false,
        "madCasesTested": false,
        "loggingAdded": false,
        "monitoringAdded": false,
        "rbsTypesValid": false
      }
    },
    "humanTaskQueue": [
      {
        "taskId": "t2",
        "description": "Review email copy",
        "independent": true,
        "blockedBy": null,
        "points": 2,
        "requiredCapability": "subjective judgment"
      }
    ],
    "aiTasks": [
      {
        "id": "ai-001",
        "taskId": "background-task-id-from-Task-tool",
        "description": "Write unit tests for auth",
        "status": "running",
        "startedAt": "2025-12-20T10:00:00Z",
        "result": null
      }
    ],
    "batchMode": false,
    "reviewDebt": [
      {
        "taskId": "t0",
        "severity": "CRITICAL",
        "issue": "Missing null check",
        "skippedAt": "2025-12-20T09:00:00Z"
      }
    ],
    "reviewPending": false,
    "prepWork": {
      "failingTests": [],
      "researchNotes": null,
      "filesToModify": []
    },
    "lastCheckIn": null
  },
  "patterns": {
    "manualTasks": [],
    "lastPatternAnalysis": null
  },
  "velocity": {
    "totalPoints": 0,
    "totalBlocks": 0,
    "history": []
  },
  "journal": [],
  "suggestedCapabilities": [
    {
      "type": "mcp",
      "description": "Slack MCP for sending messages",
      "wouldAutomate": "Notification tasks",
      "suggestedAt": "2025-12-12T10:00:00Z"
    }
  ]
}
```

**Key insight:** Goals have MILESTONES, not pre-planned tasks. `/next` dynamically generates tasks from codebase reality + milestone acceptance criteria.

**Auto-migration:** Old schema (`goals`/`intents`) automatically migrates to new schema (`northStars`/`goals`) when commands run.

## Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| /add-north-star | Create north star with Socratic questioning |
| /add-goal [north-star-id] | Create goal with WOOP methodology |
| /next [in or out] | Get next optimal task (+ queue 2-3 more) |
| /do | Execute with TDD + code review |
| /done [blocks] | Complete with verification (+ auto-pop queue) |
| /skip | Skip to queued task if blocked on current |
| /status | Show all north stars and progress |
| /now | Quick current task check (read-only) |
| /focus [north-star-id or clear] | Priority override |
| /journal [entry] | Log observation |
| /timer [action] | Control block timer |

### Autonomous Mode
| Command | Purpose |
|---------|---------|
| /start [goal] | Kick off autonomous mode - Claude drives |
| /assess [goal-id] | Check goal quality / autonomy readiness |
| /skill | Create skill/MCP from recurring patterns |

### Git Workflow
| Command | Purpose |
|---------|---------|
| `/commit` | Auto-generate commit message and commit |
| `/commit-push-pr` | Full workflow: commit → push → create PR |
| `/clean-gone` | Remove stale local branches tracking deleted remotes |

### PR Review
| Command | Purpose |
|---------|---------|
| `/review-pr [aspects] [parallel]` | Comprehensive PR review with specialized agents |

**Review Aspects:** `comments`, `tests`, `errors`, `types`, `code`, `simplify`, `all`

### Autonomous Mode (Ralph Wiggum)
| Command | Purpose |
|---------|---------|
| `/ralph-loop PROMPT [--max-iterations N] [--completion-promise TEXT]` | Start autonomous iteration loop |
| `/cancel-ralph` | Cancel active Ralph loop |

### Custom Safety Rules (Hookify)
| Command | Purpose |
|---------|---------|
| `/hookify [behavior]` | Create hooks to prevent unwanted behaviors |
| `/hookify-list` | List all configured hookify rules |

## Skills (Embedded)

All 32 skills are embedded:

**Core Discipline:**
- `test-driven-development` - RED-GREEN-REFACTOR (JS + Ruby/RSpec)
- `systematic-debugging` - 4-phase root cause investigation
- `verification-before-completion` - Evidence before claims

**Product Discovery:**
- `jtbd-discovery` - Jobs-to-be-Done through Socratic dialogue
- `story-mapping` - Transform jobs into INVEST-compliant user stories
- `feature-writing` - Gherkin feature files with step definitions
- `vertical-slicing` - Thin vertical slices touching all layers
- `product-discovery` - Full discovery flow from JTBD to implementation

**Design & Planning:**
- `brainstorming` - Socratic design refinement
- `writing-plans` - Bite-sized implementation tasks
- `executing-plans` - Batch execution with checkpoints

**Quality:**
- `requesting-code-review` - Dispatch code reviewer
- `receiving-code-review` - Respond to feedback
- `testing-anti-patterns` - Common testing mistakes (JS + Ruby)
- `defense-in-depth` - Multiple validation layers
- `condition-based-waiting` - Replace arbitrary timeouts with condition polling

**Frontend (Auto-Activated):**
- `frontend-design` - Context-calibrated UI, font pairings, accessibility-first

**Ruby/Rails 8 (Auto-Activated):**
- `rbs-types` - RBS type signatures, strict gate enforcement
- `rails-hotwire` - Turbo Frames, Turbo Streams, Stimulus
- `rails-solid-stack` - Solid Queue, Cache, Cable

**Workflow:**
- `using-git-worktrees` - Isolated workspaces
- `finishing-a-development-branch` - Merge/PR decisions
- `subagent-driven-development` - Per-task subagents
- `dispatching-parallel-agents` - Concurrent workflows
- `sharing-skills` - Contribute skills upstream via PR

**Debugging:**
- `root-cause-tracing` - Trace bugs backward through call stack

**Meta:**
- `writing-skills` - TDD for process documentation
- `testing-skills-with-subagents` - Verify skills under pressure
- `writing-rules` - Rule syntax for custom safety hooks
- `using-agentc` - Establishes AgentC workflow
- `autonomous-loop` - Core autonomous execution loop
- `lock-and-deploy` - Lock plugin IP and deploy to marketplace

## Agents (Specialized)

**PR Review Agents:**
- `code-reviewer` - General code quality with confidence scoring (80+ threshold)
- `comment-analyzer` - Comment accuracy and maintainability
- `pr-test-analyzer` - Test coverage quality and completeness
- `silent-failure-hunter` - Error handling and silent failure detection
- `type-design-analyzer` - Type design with 1-10 ratings for encapsulation, invariants
- `code-simplifier` - Code clarity and maintainability (post-review polish)

**Automation Agents:**
- `conversation-analyzer` - Analyze conversation for hookify rule generation

## Hooks (Active)

**Security Guidance (PreToolUse):**
- Warns about security patterns: command injection, XSS, eval(), pickle, os.system
- Detects GitHub Actions workflow vulnerabilities
- Auto-fires once per file per session

**Ralph Loop (Stop):**
- Intercepts session exit when `/ralph-loop` is active
- Feeds prompt back for autonomous iteration
- Completion via `<promise>TEXT</promise>` tags

## Language Detection

AgentC auto-detects project language:

| File Present | Language Mode |
|--------------|---------------|
| `Gemfile` | Ruby/Rails |
| `package.json` | JavaScript/TypeScript |
| Neither (default) | Ruby/Rails |

**Default Stack (when no stack.md exists):**
- Ruby + RBS (strict type signatures)
- Rails 8 with Hotwire (Turbo Frames, Turbo Streams, Stimulus)
- Hotwire Native for iOS and Android

**Ruby mode enables:**
- RSpec test commands (`bundle exec rspec`)
- RBS strict gate (blocks `/done` if types missing)
- Rails 8 skills (Hotwire, Solid Stack)

**JavaScript mode enables:**
- Jest/Vitest commands (`npm test`)
- TypeScript examples

## Key Principles

### Recursive Task Decomposition
- Break tasks down recursively
- For each subtask: does THIS need human?
- If no → Claude does it
- Find the ATOMIC human action
- Human only does the minimum capability gap

Example:
```
"Deploy to production" → breaks down to:
  ✓ Write script → Claude
  ✓ Test locally → Claude
  → Run `ssh prod` → HUMAN (credential gap)
  ◦ Verify health → Claude after
```

### Task Queue + Skip
- Primary task is active focus
- Queue shows 2-3 independent tasks ahead
- /skip to queued task if blocked on current
- Zero decision fatigue - queue pre-analyzed

### Batch Mode (Energy-Based)
- Mechanical "out" tasks can batch together
- Single /do-batch for multiple small tasks
- Review runs once at batch end

### True Parallelism (AI + Human)
- AI agents run in BACKGROUND (run_in_background=true)
- Up to 5 AI agents work simultaneously
- Human works on their task AT THE SAME TIME
- Both are productive in parallel
- /now shows what AI is doing while you work
- /done checks AI completions and dispatches more

### Continuous Improvement
- Suggest MCPs for external access
- Suggest skills to codify knowledge
- Suggest automations for repetitive tasks
- Aim: expand Claude's capabilities over time

### System Never Idles
- After `/done`, immediately analyze for new work
- Dispatch AI agents if tasks available
- Queue next human task only if requires human capability

## Getting Started

1. **Add a north star:**
   ```
   /add-north-star
   ```
   Answer Socratic questions to unearth your guiding direction.

2. **Create a goal:**
   ```
   /add-goal ns1
   ```
   System generates milestones toward your north star.

3. **Start working:**
   ```
   /next
   /do
   /done
   ```
   Repeat until goal complete.

## Block Timer

Each block = 8 minutes of focused work.

- `/timer start` - Start timer
- `/timer stop` - Stop and get blocks
- `/timer status` - Check current time
