# AgentC Component Rationale (v2.1.43)

**Documentation created:** 2026-01-10
**Purpose:** Explain why each component exists before simplification

---

## Core Philosophy

AgentC exists to flip the traditional human-AI relationship:
- **Traditional:** Human orchestrates AI
- **AgentC:** Human is an orchestrated agent with specific capabilities

The goal: Minimize human cognitive load, maximize throughput, scale with AI progress.

---

## Commands Rationale

### Core Loop (3) - ESSENTIAL

| Command | Why It Exists |
|---------|---------------|
| `/next` | Single point of task assignment. System decides what's next, not human. Reduces "what should I work on?" decision fatigue. |
| `/do` | Enforces discipline (TDD, verification) at execution time. Separates task assignment from task execution. |
| `/done` | Verification gate. Prevents false completion claims. Records metrics for velocity tracking. |

**Assessment:** These three form the minimal viable loop. Cannot be removed.

### Autonomous Mode (1) - ESSENTIAL

| Command | Why It Exists |
|---------|---------------|
| `/start` | Entry point to "Claude orchestrates, human is an agent" mode. Without this, system is manual-only. |

**Assessment:** Essential for the core paradigm shift.

### Status & Inspection (3) - REDUNDANT

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/now` | Quick "where am I?" check. Lighter than /status. | Overlaps with /status |
| `/status` | Comprehensive view of all north stars, goals, metrics. | Could absorb /now |
| `/assess` | Pre-flight check for goal quality before autonomous mode. | Could be part of /start |

**Assessment:** Three ways to ask "where am I?" One is enough.

### Goal Management (2) - SHOULD MERGE

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/add-north-star` | Socratic questioning to unearth guiding direction. | Separate workflow from /add-goal |
| `/add-goal` | WOOP methodology to create achievable objectives. | Could be one /create flow |

**Assessment:** Goal creation is one workflow with two entry points. Could be `/create [north-star|goal]`.

### Navigation (2) - KEEP

| Command | Why It Exists |
|---------|---------------|
| `/skip` | Jump to queued task when blocked on current. Prevents single-point blocking. |
| `/focus` | Priority override when one north star matters more than optimization. |

**Assessment:** Useful, not redundant. Keep both.

### Git Operations (3) - REDUNDANT

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/commit` | Auto-generate commit message from changes. | Core utility |
| `/commit-push-pr` | Full workflow: commit + push + PR. | Just flags on /commit |
| `/clean-gone` | Remove stale local branches. | Git utility, not AgentC |

**Assessment:** `/commit --push --pr` is cleaner. `/clean-gone` doesn't belong in AgentC.

### Utilities (2) - MIXED

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/timer` | Track 8-minute blocks for velocity metrics. | Useful, keep |
| `/journal` | Log observations for pattern detection. | Rarely used, notes can go in tasks |

**Assessment:** Keep timer, remove journal.

### Meta/Hooks (4) - SHOULD CONSOLIDATE

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/hookify` | Create safety rules from conversation patterns. | Core meta feature |
| `/hookify-list` | List existing rules. | Could be /hookify --list |
| `/ralph-loop` | Iterative autonomous refinement. | Confuses main loop, niche use |
| `/cancel-ralph` | Stop ralph loop. | Only needed if ralph exists |

**Assessment:** Keep hookify, merge list into it. Ralph is experimental/confusing.

### Deployment (1) - SHOULD BE SCRIPT

| Command | Why It Exists | Problem |
|---------|---------------|---------|
| `/lock-and-deploy` | Tokenize and deploy to marketplaces. | Internal dev tool, not user command |

**Assessment:** Move to scripts, not user-facing command.

---

## Skills Rationale

### Core Discipline (3) - ESSENTIAL

| Skill | Why It Exists |
|-------|---------------|
| `test-driven-development` | Enforces RED-GREEN-REFACTOR. Prevents "code first, test maybe" anti-pattern. |
| `systematic-debugging` | 4-phase approach prevents random "try this" debugging. |
| `verification-before-completion` | Prevents false claims. Evidence before assertions. |

**Assessment:** Core discipline. Cannot remove. Can trim ceremony.

### Workflow (7) - ESSENTIAL

| Skill | Why It Exists |
|-------|---------------|
| `brainstorming` | Socratic design refinement before implementation. |
| `story-mapping` | Structured conversion from jobs to stories. |
| `feature-writing` | Gherkin specs for executable documentation. |
| `vertical-slicing` | Break features into thin, deployable slices. |
| `writing-plans` | Create bite-sized implementation tasks. |
| `executing-plans` | Batch execution with review checkpoints. |
| `requesting-code-review` | Dispatch reviewer for quality gate. |

**Assessment:** Full workflow chain. Keep all.

### Discovery (2) - SHOULD MERGE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `jtbd-discovery` | Jobs-to-be-Done questioning. | Subset of product-discovery |
| `product-discovery` | Full discovery flow (JTBD + stories + features + slices). | Chains other skills |

**Assessment:** One discovery skill that calls phases as needed.

### Framework-Specific (3) - KEEP (AUTO-ACTIVATE)

| Skill | Why It Exists |
|-------|---------------|
| `rbs-types` | Strict Ruby type signatures. Auto-activates for Gemfile. |
| `rails-hotwire` | Rails 8 real-time patterns. Auto-activates for Rails. |
| `rails-solid-stack` | Rails 8 infrastructure. Auto-activates for Rails. |

**Assessment:** Auto-activate based on stack. Low friction. Keep.

### Frontend (2) - KEEP (AUTO-ACTIVATE)

| Skill | Why It Exists |
|-------|---------------|
| `frontend-design` | Context-calibrated UI patterns. Prevents "AI slop." |
| `lofi-wireframes` | Quick mockups before implementation. |

**Assessment:** Auto-activate for UI work. Keep.

### ILX (2) - SHOULD MERGE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `ilx` | ILX notation system for semantic compression. | Core system |
| `ilx-first-exploration` | Read ILX before source code. | Just usage pattern of ilx |

**Assessment:** One ILX skill covering reading and writing.

### Code Quality (4) - SHOULD MERGE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `receiving-code-review` | How to respond to feedback. | Could be part of requesting-code-review |
| `testing-anti-patterns` | Common testing mistakes. | Could be part of TDD |
| `defense-in-depth` | Multi-layer validation patterns. | Could be part of feature-writing |
| `condition-based-waiting` | Fix flaky tests with polling. | Could be part of TDD |

**Assessment:** Merge into parent skills. Reduces surface area.

### Debugging (1) - SHOULD MERGE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `root-cause-tracing` | Trace bugs backward through call stack. | Subset of systematic-debugging |

**Assessment:** Merge into systematic-debugging.

### Execution Models (3) - SHOULD CONSOLIDATE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `autonomous-loop` | Core autonomous execution. | Should be embedded in /start |
| `subagent-driven-development` | Per-task subagents with review between. | Alternative execution model |
| `dispatching-parallel-agents` | Concurrent agent work. | Task tool already does this |

**Assessment:** One execution model (autonomous). Others add confusion.

### Infrastructure (2) - KEEP

| Skill | Why It Exists |
|-------|---------------|
| `using-git-worktrees` | Isolated workspaces for parallel development. |
| `finishing-a-development-branch` | Decision tree for merge/PR. |

**Assessment:** Useful, distinct purposes. Keep both.

### Meta (4) - SHOULD REMOVE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `using-agentc` | Onboarding overview. | Session prompt already does this |
| `writing-skills` | Create new skills. | Internal/rare |
| `testing-skills-with-subagents` | Verify skills work. | Internal/rare |
| `sharing-skills` | Contribute upstream. | Internal/rare |

**Assessment:** Internal development tools, not user-facing. Move to docs.

### Deployment (1) - SHOULD REMOVE

| Skill | Why It Exists | Problem |
|-------|---------------|---------|
| `lock-and-deploy` | Tokenize and deploy. | Internal dev tool |

**Assessment:** Move to scripts, not skill.

### Hooks (1) - KEEP

| Skill | Why It Exists |
|-------|---------------|
| `writing-rules` | How to write hookify rules. |

**Assessment:** Useful for hookify users. Keep.

---

## Agents Rationale

### PR Review Agents (6) - KEEP

| Agent | Why It Exists |
|-------|---------------|
| `code-reviewer` | General quality with confidence scoring. |
| `comment-analyzer` | Comment accuracy verification. |
| `pr-test-analyzer` | Test coverage quality. |
| `silent-failure-hunter` | Error handling patterns. |
| `type-design-analyzer` | Type design quality. |
| `code-simplifier` | Post-review polish. |

**Assessment:** Specialized agents for different review aspects. Keep all.

### Automation Agents (1) - KEEP

| Agent | Why It Exists |
|-------|---------------|
| `conversation-analyzer` | Find patterns for hookify rules. |

**Assessment:** Supports hookify. Keep.

---

## Hooks Rationale

| Hook | Why It Exists |
|------|---------------|
| `decode-session.sh` | Restore session state on start. |
| `security_reminder_hook.py` | Warn about security patterns. |
| `ilx_emitter_hook.rb` | Auto-generate ILX on file save. |
| `stop-hook.sh` | Ralph loop continuation check. |

**Assessment:** Security and ILX hooks valuable. Ralph hook only needed if ralph exists.

---

## State Machine Rationale

### Fields to Keep
| Field | Why It Exists |
|-------|---------------|
| `loopState` | Core state machine. Essential. |
| `humanTask` | Current assigned task. Essential. |
| `humanTaskQueue` | Queue for skip/parallelism. Essential. |
| `aiTasks` | Track background AI work. Essential. |
| `velocity` | Metrics for improvement. Essential. |

### Fields to Remove
| Field | Why It Exists | Problem |
|-------|---------------|---------|
| `reviewDebt` | Deferred code review issues. | Can use task queue instead |
| `prepWork` | Pre-implementation setup. | Unclear trigger/consumption |
| `suggestedCapabilities` | MCP/skill suggestions. | Surface in /status, don't persist |
| `lastCheckIn` | Last human interaction. | Rarely used |

---

## Quality Gates Rationale

### TDD Enforcement
**Why:** Prevents "code first, test maybe" anti-pattern. Catches bugs at creation time.
**Problem:** 600+ lines of rationalization defense adds cognitive load. Trust engineers.

### Code Review
**Why:** Second set of eyes catches issues. Async dispatch doesn't block human.
**Problem:** --force bypass undermines discipline. Either enforce or don't.

### Verification
**Why:** Prevents false completion claims. Evidence before assertions.
**Problem:** Language policing ("should" flagged) is friction without value.

### Tier Quality
**Why:** Calibrate testing effort to risk level.
**Problem:** Three tiers is fine. RBS gate for all Ruby files is too strict.

---

## Summary

### Components Worth Keeping
- Core loop: /next, /do, /done
- Autonomous mode: /start
- Navigation: /skip, /focus
- Utilities: /timer, /commit, /hookify
- Core discipline skills: TDD, debugging, verification
- Workflow skills: full chain
- Framework skills: auto-activate based on stack
- All agents: specialized review

### Components to Consolidate
- Status commands: 3 → 1
- Goal creation: 2 → 1
- Git operations: 3 → 1
- Discovery skills: 2 → 1
- ILX skills: 2 → 1
- Code quality skills: 4 → merge into parents
- Execution models: 3 → 1

### Components to Remove
- /ralph-loop, /cancel-ralph (confuses main loop)
- /lock-and-deploy (internal dev)
- /clean-gone (git utility)
- /journal (rarely used)
- Meta skills (internal dev)
- Deployment skill (internal dev)

### Ceremony to Remove
- Rationalization defense chapters
- Language policing in verification
- Redundant verification gates
- Escape hatches (--force)
