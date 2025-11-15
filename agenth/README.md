# AgentH - AI-Orchestrated Project Building

**You are Agent H.** The AI orchestrates you as one specialized execution agent among many autonomous AI agents, building your project holistically.

## What is AgentH?

AgentH is a revolutionary project orchestration system that inverts the traditional development model:

- **Traditional**: You orchestrate AI tools
- **AgentH**: AI orchestrates you (Agent H) + autonomous AI agents

You focus on **creative work only**: architectural decisions, novel problems, strategic tradeoffs, judgment calls.

**AI agents** handle mechanical work autonomously: refactoring, testing, documentation, boilerplate, code generation.

## Philosophy

### 1. **Codebase Analysis First**
Reality before planning. AI analyzes your actual codebase before suggesting tasks.

### 2. **Holistic Reasoning**
AI reasons across ALL goals simultaneously. Decisions consider impact on features, testing, deployment, architecture, security, performance.

### 3. **Dynamic Task Generation**
No pre-planned task lists. Tasks synthesized in real-time based on codebase reality + goal milestones + deadline pressure + cross-goal leverage.

### 4. **Progressive Automation**
System detects repetitive work (3+ journal mentions) and suggests building tools to automate it. Agent H graduates to higher-value work over time.

### 5. **Zero Decision Fatigue**
You see ONE task at a time. No prioritization, no context switching. Pure execution mode.

## Quick Start

### 1. Installation

Install AgentH as a Claude Code plugin:

```bash
# Add the AgentMe marketplace
/plugin marketplace add http://git.laki.zero2one.ee/claude/turg.git

# Install AgentH plugin
/plugin install agenth@agentme-marketplace
```

### 2. Your First Goal

Define what you want to build:

```bash
/add-goal
```

The AI will guide you through the WOOP methodology:
- **Wish**: What do you want to achieve?
- **Current State**: Where are you now?
- **Done When**: What are the acceptance criteria?
- **Obstacles**: What might prevent success?
- **Deadline**: When must this be complete?

Then AI generates milestone checkpoints and shows you the plan.

**Goal Types:**
- Feature goals: "Add user authentication", "Build dashboard"
- Testing goals: "Achieve 80% test coverage"
- Deployment goals: "Automated CI/CD pipeline"
- Architecture goals: "Refactor to clean architecture"
- Performance goals: "Page load <2s"
- Security goals: "Pass security audit"
- Automation goals: "Build deployment scripts"
- Infrastructure goals: "Docker + Kubernetes setup"

### 3. Start Working

Get your first task:

```bash
/next out
```

The AI:
1. Analyzes your codebase
2. Reasons holistically across all goals
3. Generates the optimal task for right now
4. Starts the timer automatically

You execute the task. That's it.

### 4. Complete and Continue

When done:

```bash
/done
```

The AI:
- Stops the timer
- Records velocity
- Updates milestone progress
- Generates next optimal task

**Repeat:** `/next` → work → `/done` → repeat

## Core Commands

```bash
/next [in|out]    # Get optimal task (in=low energy, out=high energy)
/done [X]         # Record completion (X=blocks, optional if timer running)
/add-goal         # Add a new goal (any type)
/status           # Show progress on all goals
/focus goal-xxx   # Override priority (anxiety doesn't match deadline)
/journal <entry>  # Log observations (system detects patterns)
```

## Example Session

```bash
$ /next out

🔍 Codebase Analysis:
   - API has inconsistent error handling (12 endpoints, 4 patterns)
   - Test coverage: 23% (critically low)
   - Hardcoded secrets found in 3 files

   Strategic Decision: Standardize API before adding OAuth
   Reason: Inconsistent API makes testing harder, deployment riskier

TASK [5 points | Est: 4 blocks]

Standardize API error handling across all endpoints

[Detailed instructions...]

Why this matters: Unblocks testing goal (standard tests), simplifies
monitoring goal (consistent errors), sets pattern for auth goal.
Prevents deploying technical debt.

Advances:
- goal-api → M1: Error handling
Prepares:
- goal-testing, goal-monitoring, goal-auth

Timer started at 14:30:00

# [You work...]

$ /done

Timer stopped: 3 blocks used

✓ Task complete: API error standardization
Estimated: 4 blocks | Actual: 3 blocks
Efficiency: 133%

Meanwhile, AI agents completed:
✓ Updated 8 files of documentation
✓ Generated 12 new test cases
✓ Fixed 3 linting errors

Ready for next task.
```

## How AgentH Works

### Holistic Orchestration Example

**Scenario:** You're building a web app with goals for:
- Authentication (feature)
- Testing (quality)
- Deployment (infrastructure)

**Without holistic reasoning:**
```
Task: Add JWT authentication
Implementation: Hardcode secret, store in memory
Result: Works but breaks on deployment
```

**With holistic reasoning:**
```
AI sees deployment goal (Docker planned)
AI adjusts authentication task:
- Use environment variables
- Stateless session handling
- Health check endpoints
- Graceful shutdown

Result: Works now AND deploys cleanly later
Cost: Same time, no future refactor
```

### Progressive Automation Example

```
Week 1: You manually set up test data (journal: "tedious setup")
Week 2: You manually set up test data again (journal: "setup again")
Week 3: You manually set up test data again (journal: "wish I had a tool")

AI: "I notice you've mentioned test data setup 3 times.
     Should I add 'Build test data generator' as a goal?"

You: Yes

AI: Goal added. Next task: Build test data generator
[You build it]

Week 4+: AI agents use test data generator automatically
```

## Project Types

AgentH works for any project with deliverables:

- **Web Apps**: Next.js, React, Vue, etc.
- **APIs**: REST, GraphQL, gRPC
- **Automation**: Bash scripts, Python workflows
- **Infrastructure**: Docker, Kubernetes, Terraform
- **Tools**: CLIs, internal utilities
- **Mobile Apps**: React Native, Flutter
- **Desktop Apps**: Electron, Tauri
- **Libraries**: npm packages, Python packages

## Advanced Features

### Energy States

`/next out` - High energy (creative, complex)
- Architectural decisions
- Novel problem-solving
- Complex algorithms
- System design

`/next in` - Low energy (mechanical, simple)
- Config updates
- Writing tests for existing code
- Documentation
- Bug fixes with clear reproduction

### Front of Mind

Override deadline-driven prioritization:

```bash
/focus goal-auth    # Work ONLY on authentication
/focus clear        # Return to automatic prioritization
```

Use when anxiety/focus doesn't match AI's priority calculation.

### Journal-Driven Adaptation

Log observations without requesting changes:

```bash
/journal "OAuth callback took 2x longer than expected, docs were unclear"
/journal "Setting up Docker locally is painful, third time this week"
/journal "API tests are slow, maybe need test database"
```

AI detects patterns and adapts automatically.

## AI Agent Network

While you work, AI agents work autonomously:

**Refactoring Agent**: Extracts constants, renames variables, removes dead code
**Testing Agent**: Generates tests, runs suites, reports coverage
**Documentation Agent**: Updates README, generates API docs, writes JSDoc
**Code Gen Agent**: Creates boilerplate, CRUD endpoints, migrations
**Analysis Agent**: Scans for security issues, profiles performance

**The result:** Project advances on multiple fronts simultaneously.

## File Structure

```
your-project/
├── stack.md               # Technology stack documentation (IMPORTANT!)
├── CLAUDE.md              # AgentH documentation (guides Claude)
├── README.md              # This file
├── agenth/
│   ├── goals.json         # Your goals and milestones
│   ├── velocity.json      # Performance tracking
│   ├── state.json         # Current system state
│   ├── journal.md         # Your observations
│   ├── timer.sh           # 8-minute block timer
│   ├── stack.md.template  # Template for your stack.md
│   └── plans/             # WOOP plans for each goal
└── .claude/
    └── commands/          # Slash command definitions
```

## Stack Documentation

**IMPORTANT:** Create a `stack.md` file in your project root to document your technology stack.

This helps AgentH:
- Understand your tech stack, dependencies, and architecture
- Make informed decisions about which libraries/patterns to use
- Ensure compatibility when adding new dependencies
- Maintain architectural consistency

See `agenth/stack.md.template` for an example.

**Example stack.md:**
```markdown
# Project Stack

## Technology Stack
- Next.js 14, React 18, TypeScript 5
- PostgreSQL 15 with Prisma ORM
- TailwindCSS + shadcn/ui

## Key Dependencies
- @tanstack/react-query: ^5.0.0
- zod: ^3.22.0
- next-auth: ^4.24.0

## Architecture
- Feature-based modular architecture
- Server components by default
- API routes with tRPC for type safety

## Conventions
- Named exports preferred
- ESLint + Prettier (auto-format)
- Conventional Commits
```

## Meta: AgentH & AgentMe

**AgentMe** = Genesis orchestration system (life/goals/learning)
**AgentH** = Specialized for project building

**Evolution:** AgentMe can have a goal to evolve AgentH (dogfooding!)

Innovations backfill between systems when relevant.

## Tips for Success

1. **Start Small**: Add one goal, work through a few tasks, see the pattern
2. **Trust the AI**: It reasons holistically - priorities may surprise you
3. **Log Everything**: Journal observations freely, AI adapts automatically
4. **Use Energy States**: Match tasks to your current mental state
5. **Let It Automate**: When AI suggests building a tool, do it - you'll thank yourself

## Requirements

- **jq**: For JSON parsing in timer script
  ```bash
  # macOS
  brew install jq

  # Linux
  sudo apt-get install jq
  ```

- **Claude Code**: AgentH is designed for Claude Code environment

## Philosophy in Practice

**You are not managing a project.**
**You are being orchestrated to build a project optimally.**

This is the inversion. Embrace it.

---

Welcome to AgentH. Let's build something great. 🚀
