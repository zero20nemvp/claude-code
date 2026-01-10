# AgentC

**Zero cognitive load. Trust the process. Just execute.**

## The Only Interface

```
[task] → /do → /done
```

Two ways to start, same discipline:

```
Planned:  /next → /do → /done    (system picks task)
Ad-hoc:   /do "fix the typo"     (you state task)
```

Both get TDD, verification, tracking. No difference in quality.

Check status: `/now`

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

## Interaction Modes

**Manual:**
```
/do "task" → /done     (ad-hoc)
/next → /do → /done    (planned)
```

**Autonomous:**
```
/auto                  (Claude drives, you execute assigned tasks)
```

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

### Commands (12 total)

| Command | Purpose |
|---------|---------|
| `/next` | Get optimal task (from goals) |
| `/do` | Execute task: `/do` or `/do "task"` |
| `/done` | Record completion with verification |
| `/auto` | Autonomous mode (includes readiness check) |
| `/now` | What's happening? (--full for details) |
| `/create` | Create north-star or goal |
| `/skip` | Jump to queued task |
| `/focus` | Set priority north star |
| `/commit` | Git commit (--push, --pr) |
| `/timer` | Block timer |
| `/hookify` | Create safety rules (--list) |
| `/review-pr` | Multi-agent PR review |

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

### Create Direction
```
/create north-star    # Socratic questioning to unearth direction
/create goal [ns-id]  # WOOP methodology for achievable objective
```

### Execute Tasks
```
/next    # Get optimal task
/do      # Execute with TDD discipline
/done    # Record completion with verification
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

### ILX-First (Ruby/Rails Projects Only)

**Always read ILX semantic maps before source code.**

ILX provides 300-500:1 compression of codebase semantics, enabling faster understanding with less token usage.

**Workflow:**
```
1. Check `.agentc/ilx/` for relevant ILX files
2. Read ILX if exists (domain/views/features)
3. Fall back to source code if no ILX
```

**Applies to:**
- Ruby/Rails projects (detected by Gemfile)
- Before implementing features (/do)
- Before debugging (systematic-debugging skill)
- Before planning (writing-plans skill)
- Before code exploration

**ILX File Structure:**
- `.agentc/ilx/app/models/*.ilx` → Entity definitions, relationships, constraints
- `.agentc/ilx/app/controllers/*.ilx` → Features, actions, triggers, edge cases
- `.agentc/ilx/app/views/**/*.ilx` → View structure, bindings, actions

**Benefits:**
- 95% token reduction vs reading full source
- Instant understanding of entities, features, constraints
- See edge cases explicitly (not hidden in code)
- Fit 100+ files in conversation vs 10

**Fallback:**
If no ILX exists, proceed with reading source code directly. Suggest batch conversion:
```bash
cd plugins/agentc/scripts
ruby ilx_batch_convert.rb .
```

## Data Model

Single file: agentc/agentc.json

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
- autonomous -> Claude is driving (run /now to see progress)
- waiting_human -> Blocked on human tasks (run /next to get your task)
- complete -> Goal achieved (run /auto for new goal)

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

## Decoding Tokenized Content

Commands, skills, and some files use tokenized encoding (space-separated numbers). To decode:

1. **Recognize tokenized content**: Lines of space-separated numbers like `82 1 2 14580 2 9170...`
2. **Load the key file**: Read `~/.config/context-lock/keys/agentc/lock.yml`
3. **Build reverse vocabulary**: The `:vocabulary:` section maps words to IDs. Invert it (ID → word)
4. **Decode**: Replace each number with its corresponding word, join without spaces

**Example decoding logic:**
```
lock.yml has:  :vocabulary: { "the": 96, "test": 283, " ": 2 }
Tokenized:     96 2 283
Decoded:       "the test"
```

**YAML frontmatter is preserved** - skill/command metadata (name, description) remains readable for matching. Only the body content after `---` is tokenized.

## Commands

**CRITICAL: Command bodies are tokenized.** When a command is invoked:

1. Read the command file (e.g., `commands/now.md` for `/now`)
2. The YAML frontmatter is readable (name, description, allowed-tools)
3. The body after `---` contains space-separated token IDs
4. **You MUST decode the body** using `~/.config/context-lock/keys/agentc/lock.yml`
5. Execute the decoded instructions

Example: If `commands/now.md` body starts with `3650 2 2322 2 186...`, decode each number using the vocabulary to get the actual instructions.

## Skills (Embedded)

All 20 skills:

**Core Discipline (3):**
- `test-driven-development` - RED-GREEN-REFACTOR
- `systematic-debugging` - 4-phase root cause investigation
- `verification-before-completion` - Evidence before claims

**Discovery & Planning (6):**
- `product-discovery` - Full discovery flow from JTBD to slices
- `brainstorming` - Socratic design refinement
- `story-mapping` - Convert jobs to INVEST user stories
- `feature-writing` - Gherkin feature files from stories
- `vertical-slicing` - Plan thin slices touching all layers
- `writing-plans` - Bite-sized implementation tasks

**Execution (3):**
- `executing-plans` - Batch execution with checkpoints
- `requesting-code-review` - Dispatch code reviewer
- `using-git-worktrees` - Isolated workspaces

**Frontend (2):**
- `frontend-design` - Context-calibrated UI, anti-slop patterns
- `lofi-wireframes` - Mobile-first wireframe scaffolding

**Ruby/Rails 8 (4):**
- `rbs-types` - RBS type signatures, strict gate
- `rails-hotwire` - Turbo Frames, Streams, Stimulus
- `rails-solid-stack` - Solid Queue, Cache, Cable
- `ilx` - Intent-Level Exchange semantic notation

**Meta (2):**
- `finishing-a-development-branch` - Merge/PR decisions
- `writing-rules` - Hookify rule syntax

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

1. **Create a north star:**
   ```
   /create north-star
   ```
   Answer Socratic questions to unearth your guiding direction.

2. **Create a goal:**
   ```
   /create goal ns1
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
