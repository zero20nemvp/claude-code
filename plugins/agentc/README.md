# AgentC

**Zero cognitive load. Trust the process. Just execute.**

## The Only Interface

```
/next → /do → /done (repeat)
```

Or let Claude drive:

```
/start → Claude orchestrates, you execute assigned tasks
```

## Quick Start

```bash
# Add the Zero2One marketplace
/plugins marketplace add https://git.laki.zero2one.ee/claude/turg.git

# Install AgentC
/plugins install agentc
```

## How It Works

1. **Create a North Star** (`/add-north-star`) - Socratic questioning unearths your guiding direction
2. **Create a Goal** (`/add-goal`) - WOOP methodology generates milestones
3. **Start working** - Choose your mode:
   - **Manual**: `/next` → `/do` → `/done` (repeat)
   - **Autonomous**: `/start` - Claude drives, you handle capability gaps

## Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| `/next` | Get next optimal task |
| `/do` | Execute with TDD + code review |
| `/done` | Complete with verification |
| `/skip` | Skip to queued task if blocked |
| `/now` | Quick current task check |
| `/status` | Show all progress |

### Goal Management
| Command | Purpose |
|---------|---------|
| `/add-north-star` | Create north star with Socratic questioning |
| `/add-goal` | Create goal with WOOP methodology |
| `/focus` | Priority override |
| `/journal` | Log observation |

### Autonomous Mode
| Command | Purpose |
|---------|---------|
| `/start` | Claude drives, you become an agent |
| `/assess` | Check goal quality before autonomous execution |
| `/skill` | Create skill/MCP from recurring patterns |

### Git & PR
| Command | Purpose |
|---------|---------|
| `/commit` | Auto-generate commit message |
| `/commit-push-pr` | Full workflow: commit → push → PR |
| `/review-pr` | Comprehensive PR review with agents |
| `/clean-gone` | Remove stale local branches |

### Automation
| Command | Purpose |
|---------|---------|
| `/ralph-loop` | Start autonomous iteration loop |
| `/cancel-ralph` | Cancel active Ralph loop |
| `/hookify` | Create custom safety hooks |
| `/hookify-list` | List configured hooks |
| `/timer` | Control 8-minute block timer |

## Built-in Discipline

- **TDD**: Test first → See RED → Implement → See GREEN
- **Code Review**: Automatic after every `/do`
- **Verification**: Must see actual output before `/done`
- **Quality Tiers**: Skimmed / Semi-skimmed / Full phat

## 32 Embedded Skills

**Core Discipline:** test-driven-development, systematic-debugging, verification-before-completion

**Product Discovery:** jtbd-discovery, story-mapping, feature-writing, vertical-slicing, product-discovery

**Design & Planning:** brainstorming, writing-plans, executing-plans

**Quality:** requesting-code-review, receiving-code-review, testing-anti-patterns, defense-in-depth, condition-based-waiting

**Frontend:** frontend-design (auto-activated)

**Ruby/Rails 8:** rbs-types, rails-hotwire, rails-solid-stack (auto-activated)

**Workflow:** using-git-worktrees, finishing-a-development-branch, subagent-driven-development, dispatching-parallel-agents, sharing-skills

**Debugging:** root-cause-tracing

**Meta:** writing-skills, testing-skills-with-subagents, writing-rules, using-agentc, autonomous-loop, lock-and-deploy

## 7 Specialized Agents

- `code-reviewer` - General code quality (80+ confidence threshold)
- `comment-analyzer` - Comment accuracy and maintainability
- `pr-test-analyzer` - Test coverage quality
- `silent-failure-hunter` - Error handling detection
- `type-design-analyzer` - Type design ratings
- `code-simplifier` - Post-review polish
- `conversation-analyzer` - Hookify rule generation

## Philosophy

- Human is an **agent with capabilities** Claude lacks
- Tasks assigned by **capability requirement**, not importance
- If Claude can do it → Claude does it
- Human only does what ONLY human can do
- System suggests **efficiency improvements** continuously

## License

MIT
