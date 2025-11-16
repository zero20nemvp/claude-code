# Zero2One Claude Code Marketplace

**Official marketplace for Zero2One Claude Code plugins**

This marketplace provides production-ready plugins to enhance your Claude Code development workflow.

## Available Plugins

### AgentH - Autonomous Project Orchestration

AI-orchestrated project building where Claude manages you (Agent H) alongside autonomous AI agents to build projects holistically.

**Key Features:**
- Goal-driven development with WOOP methodology
- Holistic reasoning across features, testing, deployment, and architecture
- Dynamic task generation based on codebase reality
- Progressive automation that learns from patterns
- Velocity tracking and estimation
- 8-minute block timer for focus

**Use Cases:**
- Web applications (Next.js, React, Vue)
- APIs (REST, GraphQL)
- Infrastructure (Docker, Kubernetes)
- Automation scripts and tools
- Any project with deliverable milestones

[→ View AgentH Documentation](./plugins/agenth/README.md)

## Installation

### Add This Marketplace

```bash
# Add the Zero2One marketplace to Claude Code
/plugin marketplace add https://git.laki.zero2one.ee/claude/turg.git
```

### Install Plugins

```bash
# Install AgentH
/plugin install agenth@zero2one-marketplace
```

## Plugin Structure

```
zero2one-marketplace/
├── README.md (this file)
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── agenth/
        ├── README.md
        ├── CLAUDE.md
        ├── commands/
        └── agenth/
```

## Development

This marketplace follows the Claude Code marketplace standards:
- Semantic versioning
- Comprehensive documentation
- Command-based interfaces
- Plugin metadata in `marketplace.json`

## Support

- Email: delaney@zero2one.ee
- Repository: https://git.laki.zero2one.ee/claude/turg

## License

Individual plugins are licensed separately. See plugin directories for details.

---

**Zero2One** - Building better development tools
