#!/bin/bash
# AgentC workflow status for Claude Code status bar
# Outputs current position in /next -> /do -> /done loop

# Find agentc.json - check common locations
if [[ -n "$AGENTC_PROJECT_DIR" ]]; then
  AGENTC_FILE="$AGENTC_PROJECT_DIR/agentc/agentc.json"
elif [[ -f "$PWD/agentc/agentc.json" ]]; then
  AGENTC_FILE="$PWD/agentc/agentc.json"
elif [[ -f "$PWD/../agentc/agentc.json" ]]; then
  AGENTC_FILE="$PWD/../agentc/agentc.json"
else
  # Silent exit if no agentc.json found
  exit 0
fi

if [[ ! -f "$AGENTC_FILE" ]]; then
  exit 0
fi

# Parse current workflow state
HUMAN_TASK=$(jq -r '.current.humanTask' "$AGENTC_FILE" 2>/dev/null)

if [[ "$HUMAN_TASK" == "null" || -z "$HUMAN_TASK" ]]; then
  echo "⏭️ /next"
else
  STATUS=$(jq -r '.current.humanTask.status' "$AGENTC_FILE" 2>/dev/null)
  case "$STATUS" in
    "assigned")
      echo "▶️ /do"
      ;;
    "in_progress")
      echo "✅ /done"
      ;;
    *)
      echo "⏭️ /next"
      ;;
  esac
fi
