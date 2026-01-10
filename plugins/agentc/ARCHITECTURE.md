# AgentC Architecture (v2.1.43)

**Documentation created:** 2026-01-10
**Purpose:** Preserve current state before simplification refactor

---

## Overview

AgentC is a Claude Code plugin implementing a "human as orchestrated agent" workflow. The system orchestrates work between Claude and human, assigning tasks by capability requirement.

**Core interface:**
```
/next → /do → /done (repeat)
```

---

## Directory Structure

```
plugins/agentc/
├── CLAUDE.md              # System prompt / methodology
├── README.md              # User documentation
├── ARCHITECTURE.md        # This file
├── RATIONALE.md           # Why each component exists
├── commands/              # 22 slash commands
├── skills/                # 35 embedded skills
├── agents/                # 7 specialized agents
├── hooks/                 # Event triggers
├── scripts/               # Utilities
└── .claude-plugin/        # Deployed (tokenized) version
```

---

## Commands (22 total)

### Core Loop (3)
| Command | Purpose | State Transition |
|---------|---------|------------------|
| `/next` | Get optimal task | idle → assigned |
| `/do` | Execute with TDD discipline | assigned → executing |
| `/done` | Record completion with verification | executing → idle |

### Autonomous Mode (1)
| Command | Purpose |
|---------|---------|
| `/start` | Begin autonomous mode (Claude orchestrates) |

### Status & Inspection (3)
| Command | Purpose |
|---------|---------|
| `/now` | Quick status check |
| `/status` | Comprehensive status with metrics |
| `/assess` | Check goal quality before autonomous execution |

### Goal Management (2)
| Command | Purpose |
|---------|---------|
| `/add-north-star` | Create guiding direction (Socratic questioning) |
| `/add-goal` | Create achievable objective (WOOP methodology) |

### Navigation (2)
| Command | Purpose |
|---------|---------|
| `/skip` | Jump to queued task |
| `/focus` | Set priority north star |

### Git Operations (3)
| Command | Purpose |
|---------|---------|
| `/commit` | Auto-message commit |
| `/commit-push-pr` | Full workflow (commit + push + PR) |
| `/clean-gone` | Remove stale branches |

### Utilities (2)
| Command | Purpose |
|---------|---------|
| `/timer` | 8-minute block timer |
| `/journal` | Log observations |

### Meta/Hooks (3)
| Command | Purpose |
|---------|---------|
| `/hookify` | Create safety rules |
| `/hookify-list` | List hook rules |
| `/ralph-loop` | Iterative refinement mode |
| `/cancel-ralph` | Stop ralph loop |

### Deployment (1)
| Command | Purpose |
|---------|---------|
| `/lock-and-deploy` | Tokenize and deploy to marketplaces |

---

## Skills (35 total)

### Core Discipline (3)
| Skill | Purpose |
|-------|---------|
| `test-driven-development` | RED-GREEN-REFACTOR cycle |
| `systematic-debugging` | 4-phase root cause investigation |
| `verification-before-completion` | Evidence before claims |

### Workflow (7)
| Skill | Purpose |
|-------|---------|
| `brainstorming` | Socratic design refinement |
| `story-mapping` | Convert jobs → stories |
| `feature-writing` | Write Gherkin specs |
| `vertical-slicing` | Break stories into slices |
| `writing-plans` | Create implementation tasks |
| `executing-plans` | Batch execution with checkpoints |
| `requesting-code-review` | Dispatch code reviewer |

### Discovery (2)
| Skill | Purpose |
|-------|---------|
| `jtbd-discovery` | Jobs-to-be-Done discovery |
| `product-discovery` | Full discovery flow |

### Framework-Specific (3) - Auto-activate
| Skill | Purpose | Trigger |
|-------|---------|---------|
| `rbs-types` | Ruby strict type signatures | Gemfile present |
| `rails-hotwire` | Turbo Frames, Streams, Stimulus | Rails 8 project |
| `rails-solid-stack` | Solid Queue, Cache, Cable | Rails 8 project |

### Frontend (2) - Auto-activate
| Skill | Purpose | Trigger |
|-------|---------|---------|
| `frontend-design` | Context-calibrated UI | Frontend files |
| `lofi-wireframes` | Quick mockups | UI prototyping |

### ILX (2)
| Skill | Purpose |
|-------|---------|
| `ilx` | ILX notation system |
| `ilx-first-exploration` | Read ILX before source |

### Code Quality (4)
| Skill | Purpose |
|-------|---------|
| `receiving-code-review` | Respond to feedback |
| `testing-anti-patterns` | Common testing mistakes |
| `defense-in-depth` | Multi-layer validation |
| `condition-based-waiting` | Flaky test fixes |

### Debugging (1)
| Skill | Purpose |
|-------|---------|
| `root-cause-tracing` | Trace bugs backward |

### Execution Models (3)
| Skill | Purpose |
|-------|---------|
| `autonomous-loop` | Core autonomous execution |
| `subagent-driven-development` | Per-task subagents |
| `dispatching-parallel-agents` | Concurrent workflows |

### Infrastructure (2)
| Skill | Purpose |
|-------|---------|
| `using-git-worktrees` | Isolated workspaces |
| `finishing-a-development-branch` | Merge/PR decisions |

### Meta (4)
| Skill | Purpose |
|-------|---------|
| `using-agentc` | Overview/onboarding |
| `writing-skills` | Create new skills |
| `testing-skills-with-subagents` | Verify skills work |
| `sharing-skills` | Contribute upstream |

### Deployment (1)
| Skill | Purpose |
|-------|---------|
| `lock-and-deploy` | Marketplace deployment |

### Hooks (1)
| Skill | Purpose |
|-------|---------|
| `writing-rules` | Hookify rule syntax |

---

## Agents (7 total)

### PR Review Agents
| Agent | Purpose | Dispatch |
|-------|---------|----------|
| `code-reviewer` | General code quality (confidence 80+) | /review-pr |
| `comment-analyzer` | Comment accuracy | If comments changed |
| `pr-test-analyzer` | Test coverage quality | If tests changed |
| `silent-failure-hunter` | Error handling | If error handling changed |
| `type-design-analyzer` | Type design (1-10 rating) | If types added |
| `code-simplifier` | Clarity/maintainability | Post-review polish |

### Automation Agents
| Agent | Purpose | Dispatch |
|-------|---------|----------|
| `conversation-analyzer` | Find hookify patterns | /hookify (no args) |

---

## Hooks

### hooks.json Registry
```json
{
  "SessionStart": ["decode-session.sh"],
  "PreToolUse": ["security_reminder_hook.py", "ilx_emitter_hook.rb"],
  "Stop": ["stop-hook.sh"]
}
```

### Hook Details
| Hook | Event | Purpose |
|------|-------|---------|
| `decode-session.sh` | SessionStart | Restore state, show methodology |
| `security_reminder_hook.py` | PreToolUse (Edit/Write) | Security warnings |
| `ilx_emitter_hook.rb` | PreToolUse (Edit/Write) | Auto-generate ILX |
| `stop-hook.sh` | Stop | Ralph loop continuation |

---

## State Machine (agentc.json)

### Schema Version: 1.4

### Loop States
| State | Meaning | Next Command |
|-------|---------|--------------|
| `idle` | No task assigned | /next |
| `assigned` | Task ready | /do |
| `executing` | Task in progress | /done |
| `autonomous` | Claude orchestrating | /status |
| `waiting_human` | Blocked on human | /next |
| `complete` | Goal achieved | /start |

### Top-Level Structure
```json
{
  "version": "1.4",
  "northStars": [],
  "goals": [],
  "current": {
    "loopState": "idle",
    "lastAction": {},
    "humanTask": null,
    "humanTaskQueue": [],
    "aiTasks": [],
    "batchMode": false,
    "reviewDebt": [],
    "reviewPending": false,
    "prepWork": null,
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
  "suggestedCapabilities": []
}
```

---

## Quality Gates

### TDD Enforcement
- RED-GREEN-REFACTOR mandatory for code tasks
- Three tiers: skimmed (happy case), semi-skimmed (happy + sad), full-phat (comprehensive)
- 600+ lines including rationalization prevention

### Code Review
- Async dispatch (run_in_background=true)
- Confidence threshold: 80+
- Three severities: Critical (90-100), Important (80-89), Minor (<80)
- CRITICAL blocks completion, --force bypass available

### Verification
- Evidence required before claiming done
- Language policing ("should", "probably" flagged)
- Fresh test run required in session

### Tier Quality
- Checklist enforced in /done
- RBS gate for Ruby (strict type signatures)
- Frontend gate (no AI slop)

---

## Language Detection

| File | Mode | Effects |
|------|------|---------|
| Gemfile | Ruby | RSpec, RBS, Rails skills |
| package.json | JavaScript | Jest/Vitest |
| Neither | Ruby (default) | Full Rails 8 stack |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `detect-language.sh` | Ruby vs JavaScript mode |
| `timer.sh` | Block timer operations |
| `notify-human.sh` | Terminal notifications |
| `statusline.sh` | Format status output |
| `setup-ralph-loop.sh` | Initialize ralph loop |
| `ilx_domain_emitter.rb` | Generate entity ILX |
| `ilx_view_emitter.rb` | Generate view ILX |
| `ilx_ast_emitter.rb` | AST parsing |
| `ilx_batch_convert.rb` | Batch ILX conversion |
| `lock-and-deploy.sh` | Tokenize and deploy |
| `decode-session.sh` | Restore session state |

---

## Deployment Model

### Development
- Source in `/plugins/agentc/`
- Readable markdown files

### Production
- Locked (tokenized) in `.claude-plugin/`
- YAML frontmatter readable (name, description)
- Body encoded as space-separated token IDs
- Key: `~/.config/context-lock/keys/agentc/lock.yml`

---

## Known Issues (Pre-Simplification)

1. **Cognitive load:** 22 commands, 35 skills, 4 execution modes
2. **Hidden magic:** Skill auto-activation, stage task bypass
3. **Redundant gates:** Verification in /do AND /done
4. **Ceremony:** 600+ lines rationalization defense
5. **Escape hatches:** --force bypass undermines discipline
6. **Static system:** No feedback loops for improvement
