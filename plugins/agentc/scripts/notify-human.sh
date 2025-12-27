#!/bin/bash
# Human Task Notification Script
# Sends terminal message, desktop notification, and sound alert

set -euo pipefail

# Defaults
TITLE="AgentC"
MESSAGE=""
TASK_ID=""
SOUND="Glass"
COMMAND=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --title)
      TITLE="$2"
      shift 2
      ;;
    --message)
      MESSAGE="$2"
      shift 2
      ;;
    --task-id)
      TASK_ID="$2"
      shift 2
      ;;
    --sound)
      SOUND="$2"
      shift 2
      ;;
    --command)
      COMMAND="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Terminal notification banner
echo ""
echo "════════════════════════════════════════════════════════════"
echo " NEW TASK IN YOUR QUEUE"
echo "════════════════════════════════════════════════════════════"
echo ""
if [ -n "$TASK_ID" ]; then
  echo " Task: $TASK_ID"
fi
if [ -n "$MESSAGE" ]; then
  echo " $MESSAGE"
fi
if [ -n "$COMMAND" ]; then
  echo ""
  echo " Command to run:"
  echo "   $COMMAND"
fi
echo ""
echo " Run /next to start"
echo ""
echo "════════════════════════════════════════════════════════════"

# Desktop notification (macOS)
if command -v osascript &> /dev/null; then
  SUBTITLE=""
  if [ -n "$TASK_ID" ]; then
    SUBTITLE="Task: $TASK_ID"
  fi

  if [ -n "$SUBTITLE" ]; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" subtitle \"$SUBTITLE\" sound name \"$SOUND\""
  else
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\""
  fi
fi

# Bell character for terminal alert
printf '\a'
