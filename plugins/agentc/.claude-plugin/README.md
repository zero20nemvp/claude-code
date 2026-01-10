# AgentC

**Zero cognitive load from empty directory to shipped product.**

AgentC is a self-bootstrapping workflow plugin for Claude Code that implements a `/next → /do → /done` loop. The system guides you through discovery, design, and implementation with systematic discipline—TDD, code review, and tier-based quality control built in.

## Features

- **Self-bootstrapping**: Start with nothing, the system guides you
- **North Star Navigation**: Define guiding directions you navigate toward
- **Goal-driven Development**: Break north stars into achievable goals with acceptance criteria
- **Quality Tiers**: Choose your milk quality (skimmed, semi-skimmed, full-phat)
- **TDD Discipline**: Test-first development with RED-GREEN-REFACTOR cycle
- **Autonomous Execution**: AI orchestrates, human executes assigned tasks
- **Frontend Design System**: Aesthetic-first approach, no AI slop
- **Comprehensive PR Review**: Multi-agent code review system
- **Ralph Wiggum Loop**: Iterative refinement until completion criteria met

## Installation

### From Marketplace (Recommended)

```bash
cc plugin install agentc
```

### From Source

Clone this repository and link it to Claude Code:

```bash
git clone <repository-url>
cc --plugin-dir /path/to/agentc/.claude-plugin
```

## Quick Start

1. **Create a North Star** (your guiding direction):
   ```
   /add-north-star
   ```

2. **Add a Goal** (achievable objective):
   ```
   /add-goal [north-star-id]
   ```

3. **Start the loop**:
   ```
   /next   # Get your next task
   /do     # Execute it with TDD discipline
   /done   # Mark complete and continue
   ```

## Core Commands

### Discovery & Planning

- **`/add-north-star`** - Add a new North Star with Socratic questioning
- **`/add-goal [north-star-id]`** - Create achievable goals under a north star
- **`/focus [north-star-id|clear]`** - Set priority override for front-of-mind north star
- **`/assess [goal-id]`** - Assess goal quality and autonomy readiness

### Execution Loop

- **`/next`** - Get the next optimal task to work on
- **`/do [--tier skimmed|semi|full]`** - Execute current task with TDD discipline
- **`/done [--force]`** - Mark task complete and trigger review gates
- **`/skip`** - Skip current task to work on a queued task instead
- **`/now`** - Read-only status check of current loop state

### Quality & Review

- **`/review-pr [aspects] [parallel]`** - Comprehensive PR review using specialized agents
  - Aspects: `comments`, `tests`, `errors`, `types`, `code`, `simplify`, `all`
  - Add `parallel` to run all agents simultaneously
- **`/assess [goal-id]`** - Assess goal quality before autonomous execution

### Git Workflow

- **`/commit`** - Create git commit with auto-generated message
- **`/commit-push-pr`** - Full workflow: commit, push branch, create pull request
- **`/clean-gone`** - Clean up stale local branches marked as [gone]

### Autonomy

- **`/start [goal]`** - Start autonomous execution mode
- **`/ralph-loop PROMPT [--max-iterations N] [--completion-promise TEXT]`** - Start Ralph Wiggum iterative loop
- **`/cancel-ralph`** - Cancel active Ralph loop

### Customization

- **`/hookify [behavior]`** - Create hooks to prevent unwanted behaviors
- **`/hookify-list`** - List all configured hookify rules

### Utilities

- **`/status`** - Show north stars, goals, and current progress
- **`/journal`** - Record learnings and reflections
- **`/timer [action]`** - Check or control the block timer (8-minute focused work blocks)
  - Actions: `status`, `start`, `stop`, `pause`, `resume`
- **`/lock-and-deploy [message]`** - Lock plugin IP and deploy to marketplace

## Milk Quality Tiers

AgentC uses tier-based quality control for task execution:

| Tier | Tests Required | Code Approach | When to Use |
|------|----------------|---------------|-------------|
| **Skimmed** | Happy case only | Bare minimum | Quick prototypes, throwaway code |
| **Semi-Skimmed** (default) | Happy + essential sad cases | Extensible, no overengineering | Most production code |
| **Full-Phat** | Comprehensive + mad cases + logging | Production-ready | Critical paths, public APIs |

Set tier with `/do --tier [skimmed|semi|full]`

## TDD Discipline

All code tasks follow RED-GREEN-REFACTOR:

1. **RED**: Write failing test first
2. **GREEN**: Minimal code to make it pass
3. **REFACTOR**: Clean up while staying green

## North Stars vs Goals

**North Stars** are guiding directions you navigate toward—they never "complete":
- Example: "Build sustainable marketplace for zero-to-one founders"
- Status: active, shelved
- Can have multiple (max 3 active)

**Goals** are achievable objectives with acceptance criteria:
- Example: "User can log in and view dashboard"
- Must have testable acceptance criteria
- Scored for autonomy readiness (testable, specific, measurable, independent)

## Frontend Design Philosophy

AgentC enforces aesthetic-first design to prevent "AI slop":

1. **Choose aesthetic direction** before coding
2. **Document the design decision**: typography, palette, memorable element
3. **Execute with chosen vision**
4. **Verify no AI slop**: no Inter/Roboto, no purple gradients on white

Frontend tasks must pass the design gate before `/done`.

## Autonomous Mode

Start autonomous execution with `/start [goal]`:

- AI orchestrates and runs tasks in parallel
- Human becomes an agent executing assigned tasks via `/next → /do → /done`
- Quality gates ensure goals are autonomy-ready (50%+ score required)
- Track AI tasks and human queue simultaneously

## Ralph Wiggum Loop

Named after the character who keeps trying, Ralph loops are iterative refinement:

```
/ralph-loop "Implement user authentication" --max-iterations 10 --completion-promise "All auth tests pass"
```

- Keeps iterating until completion promise is true
- Cannot exit early even if stuck (forces genuine completion)
- Work persists in files and git history between iterations

## Hookify Rules

Prevent unwanted behaviors by creating custom hooks:

```
/hookify Don't use console.log in production code
```

Creates `.claude/hookify.*.local.md` files that trigger on tool use (bash, file edits, etc.)

## Configuration

AgentC stores state in `agentc/agentc.json` at your project root:

```json
{
  "version": "1.1",
  "northStars": [],
  "goals": [],
  "current": {
    "humanTask": null,
    "aiTasks": [],
    "loopState": "idle"
  },
  "velocity": {
    "totalPoints": 0,
    "totalBlocks": 0
  },
  "journal": []
}
```

## Examples

### Create a new feature with TDD

```
# Define the direction
/add-north-star
> "Marketplace for zero-to-one founders"

# Add achievable goal
/add-goal ns1
> "Users can create and browse startup listings"

# Execute with discipline
/next  # Gets: "Implement listing model with validation"
/do --tier semi
> RED: Write failing test for listing model
> GREEN: Implement minimal model
> REFACTOR: Clean up
> Code review dispatched (async)
> Verification passed

/done
> Review gate: PASSED
> Tier gate: PASSED (semi-skimmed)
```

### Start autonomous execution

```
/start ns1
> Goal assessed: 85% ready ✓
> Autonomous mode started
> AI working on: Database schema, API routes, Tests
> Your next task: Run migrations
```

### Multi-agent PR review

```
/review-pr all parallel
> Dispatching: code-reviewer, test-analyzer, type-checker, simplifier
> Critical: 0, Important: 2, Suggestions: 5
> Fix important issues before merging
```

## Keywords

workflow, tdd, productivity, ai-orchestration, north-star, jtbd, product-discovery, self-bootstrapping, zero-cognitive-load, pr-review, frontend, design

## License

MIT

## Author

**db**

Version: 2.0.34
