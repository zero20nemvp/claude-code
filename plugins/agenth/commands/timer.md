You are executing the AgentH timer command.

**Parse the command arguments:**
- `/timer start` - Start a new timer
- `/timer stop` - Stop the timer and show total blocks
- `/timer status` - Check current timer progress
- `/timer` (no args) - Show status if running, otherwise show usage

**Find timer.sh script using smart path resolution:**

Use this bash logic to detect the correct path:

```bash
if [ -n "${CLAUDE_PLUGIN_ROOT}" ]; then
  # Plugin mode - agenth installed from marketplace
  SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/agenth/timer.sh"
elif [ -f "./marketplace/agenth/agenth/timer.sh" ]; then
  # Repo mode - marketplace repository structure
  SCRIPT_PATH="./marketplace/agenth/agenth/timer.sh"
elif [ -f "./agenth/timer.sh" ]; then
  # Repo mode - standalone agenth directory
  SCRIPT_PATH="./agenth/timer.sh"
else
  echo "Error: timer.sh not found. Check agenth installation."
  exit 1
fi
```

**Execute:**
Run the timer script with the detected path:
- `"$SCRIPT_PATH" start`
- `"$SCRIPT_PATH" stop`
- `"$SCRIPT_PATH" status`

**Output:**
Display the script output directly to the user. Keep it clean and minimal.
