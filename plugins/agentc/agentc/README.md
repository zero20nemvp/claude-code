**Note:** This plugin requires `lock.yml` to be present in context to function.

# AgentC

**AI-powered development workflow with zero decision fatigue.**

## The Only Interface

```
/next → /do → /done (repeat)
```

That's it. The system handles everything else.

## How It Works

1. **Create a North Star** (`/add-north-star`) - Socratic questioning unearths your guiding direction
2. **Create a Goal** (`/add-goal`) - WOOP methodology generates milestones
3. **Get next task** (`/next`) - ONE optimal task, AI works in parallel
4. **Execute with discipline** (`/do`) - TDD + automatic code review
5. **Complete with verification** (`/done`) - Must show evidence
6. **Repeat**

## Built-in Discipline

- **TDD**: Test first → See RED → Implement → See GREEN
- **Code Review**: Runs after every `/do`
- **Verification**: Must see actual test output before `/done`

## Installation

```bash
# Add the Zero2One marketplace
/plugin marketplace add https://git.laki.zero2one.ee/claude/turg.git

# Install AgentC
/plugin install agentc@zero2one-turg
```

## Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| `/add-north-star` | Add a new North Star with Socratic questioning |
| `/add-goal [north-star-id]` | Add a new goal (WOOP commitment) with milestones |
| `/next [in\|out]` | Get your next optimal task (+ queue 2-3 more) |
| `/do [--tier skimmed\|semi\|full]` | Execute with TDD discipline and tier-based quality |
| `/done [blocks]` | Record task completion with verification evidence |
| `/skip` | Skip current task to work on a queued task instead |
| `/status` | Show all north stars with progress, deadlines, and velocity |
| `/now` | Read-only status check - safe to call multiple times |
| `/focus [north-star-id\|clear]` | Set priority override - front-of-mind north star |
| `/journal [entry]` | Log observations for pattern detection |
| `/timer [action]` | Control 8-minute block timer (start\|stop\|pause\|resume\|status) |

### Autonomous Mode
| Command | Purpose |
|---------|---------|
| `/start [goal]` | Start autonomous execution - Claude drives, you execute tasks |
| `/assess [goal-id]` | Assess goal quality and autonomy readiness |

### Git Workflow
| Command | Purpose |
|---------|---------|
| `/commit` | Create a git commit with auto-generated message |
| `/commit-push-pr` | Full workflow: commit, push, and create pull request |
| `/clean-gone` | Clean up stale local branches marked as [gone] |

### PR Review
| Command | Purpose |
|---------|---------|
| `/review-pr [aspects] [parallel]` | Comprehensive PR review with specialized agents |

**Review Aspects:** `comments`, `tests`, `errors`, `types`, `code`, `simplify`, `all`

### Autonomous Loop (Ralph Wiggum)
| Command | Purpose |
|---------|---------|
| `/ralph-loop PROMPT [--max-iterations N]` | Start autonomous iteration loop |
| `/cancel-ralph` | Cancel active Ralph loop |

### Custom Safety Rules (Hookify)
| Command | Purpose |
|---------|---------|
| `/hookify [behavior]` | Create hooks to prevent unwanted behaviors |
| `/hookify-list` | List all configured hookify rules |

### Plugin Tools
| Command | Purpose |
|---------|---------|
| `/lock-and-deploy [message]` | Lock plugin IP and deploy to both marketplaces |

## Philosophy

- Human is an **agent with capabilities** Claude lacks
- Tasks assigned by **capability requirement**, not importance
- If Claude can do it → Claude does it
- System suggests **efficiency improvements** (MCPs, skills, automations)
- **One task at a time** = zero decision fatigue

## 22 Embedded Skills

AgentC includes proven development skills:

- Test-driven development
- Systematic debugging
- Verification before completion
- Brainstorming & planning
- Code review workflows
- Git worktrees
- Parallel agent dispatch
- Defense in depth
- Root cause tracing
- And more...

## License

MIT
