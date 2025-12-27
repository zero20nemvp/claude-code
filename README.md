# Zero2One Claude Code Marketplace

**Official marketplace for Zero2One Claude Code plugins**

## Available Plugins

### AgentC

AI-powered development workflow with zero decision fatigue. One simple interface: `/next` → `/do` → `/done`

**Features:**
- Goal-driven development with WOOP methodology
- TDD discipline (RED-GREEN-REFACTOR)
- Automatic code review after every task
- Verification before completion
- Dynamic task generation based on codebase reality
- 22 embedded skills for debugging, collaboration, and best practices
- 8-minute block timer for focus

**Use Cases:**
- Web applications (Next.js, React, Vue)
- APIs (REST, GraphQL)
- Infrastructure (Docker, Kubernetes)
- Automation scripts and tools
- Any project with deliverable milestones

[→ View AgentC Documentation](./plugins/agentc/README.md)

## Installation

### Add This Marketplace

```bash
/plugin marketplace add https://github.com/zero20nemvp/claude-code.git
```

### Install AgentC

```bash
/plugin install agentc@zero20nemvp-claude-code
```

### Get Your License Key

AgentC requires a license key (`lock.yml`) to run. Sign up at **https://agentc.zero2one.ee** to download your key.

Place the key file at:
```
~/.config/context-lock/keys/agentc/lock.yml
```

**Important:** When the plugin is updated, download the latest `lock.yml` from your account. The key must match the plugin version.

## Support

- Email: delaney@zero2one.ee
- Repository: https://github.com/zero20nemvp/claude-code

## License

MIT

---

**Zero2One** - Building better development tools
