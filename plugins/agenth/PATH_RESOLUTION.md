# AgentH Path Resolution Strategy

## Problem

AgentH commands need to execute shell scripts (like `timer.sh`) that live in the agenth directory structure. However, the path to these scripts differs depending on installation mode:

1. **Plugin Mode**: AgentH installed from marketplace into another project
2. **Repo Mode**: Working directly in the agentme/agenth source repository

## Solution

Use the `${CLAUDE_PLUGIN_ROOT}` environment variable provided by Claude Code.

### How It Works

Claude Code automatically sets `${CLAUDE_PLUGIN_ROOT}` when commands are executed from an installed plugin. This variable points to the plugin's installation directory.

**Detection Logic:**

```bash
if [ -n "${CLAUDE_PLUGIN_ROOT}" ]; then
  # Plugin mode - use CLAUDE_PLUGIN_ROOT
  SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/agenth/timer.sh"
elif [ -f "./marketplace/agenth/agenth/timer.sh" ]; then
  # Repo mode - marketplace repository structure
  SCRIPT_PATH="./marketplace/agenth/agenth/timer.sh"
elif [ -f "./agenth/timer.sh" ]; then
  # Repo mode - standalone agenth directory
  SCRIPT_PATH="./agenth/timer.sh"
else
  echo "Error: script not found. Check agenth installation."
  exit 1
fi

"$SCRIPT_PATH" "$@"
```

## Directory Structures

### Plugin Mode
When installed as marketplace plugin:
```
${CLAUDE_PLUGIN_ROOT}/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── timer.md
└── agenth/
    ├── timer.sh
    ├── goals.json
    ├── state.json
    └── velocity.json
```

Path to timer.sh: `${CLAUDE_PLUGIN_ROOT}/agenth/timer.sh`

### Repo Mode (marketplace)
When working in marketplace source repository:
```
./marketplace/
└── agenth/
    └── agenth/
        ├── timer.sh
        ├── goals.json
        ├── state.json
        └── velocity.json
```

Path to timer.sh: `./marketplace/agenth/agenth/timer.sh`

### Repo Mode (agenth)
When working in agenth source repository:
```
./agenth/
├── timer.sh
├── goals.json
├── state.json
└── velocity.json
```

Path to timer.sh: `./agenth/timer.sh`

## Implementation Pattern

Any command that needs to execute agenth scripts should follow this pattern:

1. **Check `${CLAUDE_PLUGIN_ROOT}` first** - indicates plugin mode
2. **Fall back to relative paths** - check common repo structures
3. **Error gracefully** - inform user if scripts can't be found

## Benefits

- **Portability**: Works in both plugin and repo modes
- **No hardcoding**: Paths discovered dynamically
- **Reusable**: Pattern works for all commands needing scripts
- **Future-proof**: Adapts to Claude Code plugin system changes

## Commands Using This Pattern

- `/timer` - timer.sh script execution
- (Future commands that need agenth scripts will use same pattern)

## Testing

To verify path resolution works:

**In marketplace repo:**
```bash
/timer status  # Should find ./marketplace/agenth/agenth/timer.sh
```

**In project with agenth plugin installed:**
```bash
/timer status  # Should find ${CLAUDE_PLUGIN_ROOT}/agenth/timer.sh
```

## References

- [Claude Code Plugin Reference](https://code.claude.com/docs/en/plugins-reference.md)
- `${CLAUDE_PLUGIN_ROOT}` environment variable documentation
