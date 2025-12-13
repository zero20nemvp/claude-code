# AgentC

**AI-powered development workflow with zero decision fatigue.**

## The Only Interface

```
/next → /do → /done (repeat)
```

That's it. The system handles everything else.

## How It Works

1. **Create a goal** (`/add-goal`) - Brainstorming refines your direction
2. **Create an intent** (`/add-intent`) - Generates bite-sized tasks (2-5 min each)
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

| Command | Purpose |
|---------|---------|
| `/add-goal` | Create goal with brainstorming |
| `/add-intent` | Create intent with implementation plan |
| `/next` | Get next optimal task |
| `/do` | Execute with TDD + code review |
| `/done` | Complete with verification |
| `/status` | Show all goals and progress |
| `/now` | Quick current task check |
| `/focus` | Priority override |
| `/journal` | Log observation |
| `/timer` | Control 8-minute block timer |

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
