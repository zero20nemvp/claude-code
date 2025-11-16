# AgentH Plugin

**AI-orchestrated project building as a portable Claude Code plugin**

## Directory Auto-Detection ✨ NEW

AgentH automatically detects which directory to use for its data files:
- Checks for `agenth/` first (standard for new projects)
- Falls back to `agentme/` if found (for AgentMe repository compatibility)
- Works seamlessly in both development and deployment contexts

**No configuration needed** - the plugin adapts to your project structure automatically!

## What is AgentH?

AgentH inverts traditional development: Instead of you orchestrating AI, the AI orchestrates you (Agent H) as one specialized execution agent among autonomous AI agents building your project holistically.

You focus on **creative work**: architecture, novel problems, strategic tradeoffs, judgment calls.

**AI agents** handle mechanical work autonomously: refactoring, testing, documentation, boilerplate.

## Plugin vs Standalone

### This Plugin
- ✅ Install once, use across any project
- ✅ No setup per project (just run `/add-goal`)
- ✅ Consistent commands everywhere
- ✅ Easy updates (plugin versioning)
- ✅ Shareable via marketplaces

### Standalone AgentH
- ❌ Manual copying to each project
- ❌ Per-project setup required
- ❌ Updates require re-copying files

## Installation

### Install AgentH Plugin

```bash
# Add the AgentMe marketplace
/plugin marketplace add http://git.laki.zero2one.ee/claude/turg.git

# Install AgentH plugin
/plugin install agenth@agentme-marketplace
```

### Verify Installation

```bash
# Check available commands
/add-goal  # Should be available in any project
```

## Quick Start

### 1. Navigate to Your Project

```bash
cd ~/my-awesome-project
```

### 2. Add Your First Goal

```bash
/add-goal
```

The AI guides you through WOOP methodology:
- **Wish**: What do you want to achieve?
- **Current State**: Where are you now?
- **Done When**: Acceptance criteria
- **Obstacles**: What might prevent success?
- **Deadline**: When complete?

**Goal Types:**
- Feature: "Add user authentication"
- Testing: "Achieve 80% test coverage"
- Deployment: "Docker + Kubernetes"
- Architecture: "Refactor to clean architecture"
- Performance: "Page load <2s"
- Security: "Pass security audit"

### 3. Start Working

```bash
/next out
```

The AI:
1. Analyzes your codebase
2. Reasons holistically across goals
3. Generates optimal task
4. Starts timer automatically

Execute the task. That's it.

### 4. Complete and Continue

```bash
/done
```

AI records velocity, updates progress, generates next task.

**Repeat:** `/next` → work → `/done`

## Core Commands

```bash
/next [in|out]    # Get optimal task (out=creative, in=mechanical)
/done [X]         # Complete task (X=blocks used, optional)
/add-goal         # Add new goal
/status           # Show all goal progress
/focus goal-xxx   # Override priority
/journal <entry>  # Log observations (AI adapts)
/now              # Check status (read-only, no state changes)
```

## How It Works

### State Management

The plugin creates an `agenth/` directory in your project:

```
your-project/
├── agenth/              # Created automatically
│   ├── goals.json       # Your goals & milestones
│   ├── velocity.json    # Performance tracking
│   ├── state.json       # Current work state
│   ├── journal.md       # Your observations
│   └── plans/           # WOOP plans per goal
```

**Each project has its own state.** AgentH is project-aware.

### Holistic Reasoning

AI doesn't optimize each goal independently - it reasons across ALL goals:

**Example:**
```
You're implementing authentication.

AI sees you also have deployment goal (Docker planned).

AI adjusts implementation:
- Use environment variables (not hardcoded secrets)
- Stateless sessions (works in containers)
- Health check endpoints (k8s ready)
- Graceful shutdown

Result: Works now AND deploys cleanly later
```

### Progressive Automation

System detects repetitive work and suggests building tools:

```bash
/journal "Manual test data setup again"  # 1st time
/journal "Test data setup tedious"        # 2nd time
/journal "Wish I had test data tool"      # 3rd time

AI: "I notice 3 mentions of test data setup.
     Should I add 'Build test data generator' as goal?"
```

## Example Session

```bash
$ cd ~/my-api-project
$ /next out

🔍 Codebase Analysis:
   - API has inconsistent error handling (12 endpoints)
   - Test coverage: 23%
   - Hardcoded secrets in 3 files

   Strategic Decision: Standardize API before OAuth
   Reason: Inconsistent API = harder testing + riskier deployment

TASK [5 points | Est: 4 blocks]
Standardize API error handling across all endpoints

[Instructions...]

Why this matters: Unblocks testing goal, simplifies monitoring,
sets pattern for auth goal. Prevents technical debt.

Advances: goal-api → M1
Prepares: goal-testing, goal-monitoring, goal-auth

Timer started

# [You work...]

$ /done

✓ Task complete
Estimated: 4 blocks | Actual: 3 blocks

Meanwhile, AI agents completed:
✓ Updated 8 docs files
✓ Generated 12 tests
✓ Fixed 3 lint errors
```

## Advanced Features

### Energy States

```bash
/next out   # High energy (architecture, novel problems, complex)
/next in    # Low energy (config, docs, simple bugs)
```

### Stack Documentation

Create `stack.md` in project root for better AI decisions:

```markdown
# Project Stack

## Technology Stack
- Next.js 14, React 18, TypeScript 5
- PostgreSQL 15 with Prisma ORM

## Architecture
- Feature-based modular architecture
- Server components by default

## Conventions
- Named exports preferred
- ESLint + Prettier
```

See `agenth/stack.md.template` after first goal.

### Focus Override

```bash
/focus goal-auth    # Work ONLY on auth
/focus clear        # Return to auto priority
```

Use when anxiety doesn't match AI's priority calculation.

## Philosophy

### 1. Reality First
AI analyzes codebase before planning. Goals transform actual state.

### 2. Holistic Optimization
Decisions consider ALL goals, not just immediate task.

### 3. Zero Decision Fatigue
You see ONE task. No prioritization, no context switching.

### 4. Progressive Automation
System identifies repetitive work, suggests building tools.

### 5. Agent H = Creative Work Only
Mechanical work → AI agents. You → judgment & creativity.

## What's Different from Standalone?

### Same:
- All commands work identically
- Same orchestration algorithm
- Same holistic reasoning
- Same state management

### Different:
- ✅ Install once vs copy per project
- ✅ Automatic updates via plugin system
- ✅ Works in any project immediately
- ✅ Shareable via marketplaces
- ✅ No manual .claude/commands setup

## Project Types Supported

- **Web Apps**: Next.js, React, Vue
- **APIs**: REST, GraphQL, gRPC
- **Automation**: Scripts, workflows
- **Infrastructure**: Docker, K8s, Terraform
- **Tools**: CLIs, utilities
- **Mobile**: React Native, Flutter
- **Desktop**: Electron, Tauri
- **Libraries**: npm, PyPI packages

## Requirements

- **Claude Code**: Plugin requires Claude Code CLI
- **jq**: For timer script JSON parsing
  ```bash
  # macOS
  brew install jq

  # Linux
  sudo apt-get install jq
  ```

## Tips for Success

1. **Start Small**: One goal, few tasks, learn the pattern
2. **Trust the AI**: Holistic reasoning = surprising priorities
3. **Log Everything**: Journal freely, AI adapts automatically
4. **Use Energy States**: Match tasks to mental state
5. **Stack Documentation**: Create `stack.md` for better decisions
6. **Let It Automate**: Build tools when AI suggests them

## Uninstalling

```bash
# Remove plugin
claude plugin uninstall agenth

# Per-project state remains in agenth/ directory
# Remove manually if desired:
rm -rf agenth/
```

## Meta: AgentH & AgentMe

**AgentMe** = Genesis system (life/goals/learning)
**AgentH** = Specialized for project building

AgentH inherits methodology from AgentMe. Innovations backfill between systems.

## Version

**0.1.0** - Initial plugin release

## Philosophy in Practice

**You are not managing a project.**
**You are being orchestrated to build a project optimally.**

This is the inversion. Embrace it.

---

Welcome to AgentH. Let's build something great. 🚀
