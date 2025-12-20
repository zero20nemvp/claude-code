---
name: agentc-release-workflow
enabled: true
event: file
conditions:
  - field: file_path
    operator: contains
    pattern: plugins/agentc
---

**AgentC Release Workflow Reminder**

You're editing agentc plugin files. When done, remember to:

1. **Commit** - with descriptive message
2. **Update plugin.json** - bump version in plugins/agentc/.claude-plugin/plugin.json
3. **Update marketplace.json** - bump version in .claude-plugin/marketplace.json
4. **Tag** - create git tag matching version (e.g., v2.2.1)
5. **Push** - push main branch AND tags

Do all five steps together every time.
