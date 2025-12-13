#!/bin/bash

STATE_FILE="$(dirname "$0")/timer-state.json"

start_timer() {
    if [ -f "$STATE_FILE" ]; then
        # Validate JSON
        if ! jq empty "$STATE_FILE" 2>/dev/null; then
            echo "Error: Timer state file corrupted. Removing invalid state."
            rm "$STATE_FILE"
        else
            STATUS=$(jq -r '.running // false' "$STATE_FILE" 2>/dev/null)
            if [ "$STATUS" = "true" ]; then
                echo "Timer already running. Use './timer.sh status' to check or './timer.sh stop' to end."
                exit 1
            fi
        fi
    fi

    START_TIME=$(date +%s)

    # Get project name from parent directory structure
    # Path: project/turg/plugins/agenth/timer.sh → need to go up 4 levels
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_NAME="$(basename "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")"

    echo "{\"running\":true,\"startTime\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",\"_startEpoch\":$START_TIME,\"elapsedBlocks\":0,\"pausedAt\":null,\"lastNotifiedBlock\":0,\"projectName\":\"$PROJECT_NAME\"}" > "$STATE_FILE"
    echo "Timer started at $(date '+%H:%M:%S')"
    echo "Run './timer.sh status' to check progress"
    echo "Notifications will fire every 8 minutes"

    # Start background monitor for notifications
    nohup "$0" monitor > /dev/null 2>&1 &
}

pause_timer() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No timer running"
        exit 1
    fi

    # Validate JSON
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "Error: Timer state file corrupted. Removing invalid state."
        rm "$STATE_FILE"
        exit 1
    fi

    STATUS=$(jq -r '.running // false' "$STATE_FILE" 2>/dev/null)
    PAUSED=$(jq -r '.pausedAt // "null"' "$STATE_FILE" 2>/dev/null)

    if [ "$STATUS" != "true" ]; then
        echo "No timer running"
        exit 1
    fi

    if [ "$PAUSED" != "null" ]; then
        echo "Timer already paused"
        exit 1
    fi

    PAUSE_TIME=$(date +%s)
    TEMP_FILE="${STATE_FILE}.tmp"
    jq ".pausedAt = $PAUSE_TIME | .running = false" "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE"

    echo "Timer paused at $(date '+%H:%M:%S')"
}

resume_timer() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No timer to resume"
        exit 1
    fi

    # Validate JSON
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "Error: Timer state file corrupted. Removing invalid state."
        rm "$STATE_FILE"
        exit 1
    fi

    PAUSED=$(jq -r '.pausedAt // "null"' "$STATE_FILE" 2>/dev/null)

    if [ "$PAUSED" = "null" ]; then
        echo "Timer is not paused"
        exit 1
    fi

    # Calculate pause duration and adjust start time
    START_EPOCH=$(jq -r '._startEpoch' "$STATE_FILE")
    RESUME_TIME=$(date +%s)
    PAUSE_DURATION=$((RESUME_TIME - PAUSED))
    NEW_START=$((START_EPOCH + PAUSE_DURATION))

    TEMP_FILE="${STATE_FILE}.tmp"
    jq "._startEpoch = $NEW_START | .pausedAt = null | .running = true" "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE"

    echo "Timer resumed at $(date '+%H:%M:%S')"
    echo "Paused for $((PAUSE_DURATION / 60))m $((PAUSE_DURATION % 60))s"

    # Restart background monitor
    nohup "$0" monitor > /dev/null 2>&1 &
}

stop_timer() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No timer running"
        exit 1
    fi

    # Validate JSON and extract state
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "Error: Timer state file corrupted. Removing invalid state."
        rm "$STATE_FILE"
        exit 1
    fi

    STATUS=$(jq -r '.running // false' "$STATE_FILE" 2>/dev/null)
    PAUSED=$(jq -r '.pausedAt // "null"' "$STATE_FILE" 2>/dev/null)

    if [ "$STATUS" != "true" ] && [ "$PAUSED" = "null" ]; then
        echo "No timer running"
        exit 1
    fi

    START_TIME=$(jq -r '._startEpoch // .startTime' "$STATE_FILE")
    END_TIME=$(date +%s)

    # If paused, use pause time as end time
    if [ "$PAUSED" != "null" ]; then
        END_TIME=$PAUSED
    fi

    # Handle epoch vs ISO timestamp
    if [[ "$START_TIME" =~ ^[0-9]+$ ]]; then
        ELAPSED=$((END_TIME - START_TIME))
    else
        # Legacy support: convert ISO to epoch (macOS format)
        START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_TIME" +%s 2>/dev/null || echo "$END_TIME")
        ELAPSED=$((END_TIME - START_EPOCH))
    fi

    MINUTES=$((ELAPSED / 60))
    SECONDS=$((ELAPSED % 60))
    BLOCKS=$(((ELAPSED + 479) / 480))  # Round up - any time = at least 1 block (480s = 8min)

    echo "Timer stopped"
    echo "Elapsed: ${MINUTES}m ${SECONDS}s"
    echo "Blocks: $BLOCKS"

    rm "$STATE_FILE"
}

status_timer() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No timer running"
        exit 0
    fi

    # Validate JSON
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "Error: Timer state file corrupted"
        exit 1
    fi

    STATUS=$(jq -r '.running // false' "$STATE_FILE" 2>/dev/null)
    PAUSED=$(jq -r '.pausedAt // "null"' "$STATE_FILE" 2>/dev/null)

    if [ "$STATUS" != "true" ] && [ "$PAUSED" = "null" ]; then
        echo "No timer running"
        exit 0
    fi

    START_TIME=$(jq -r '._startEpoch // .startTime' "$STATE_FILE")
    CURRENT_TIME=$(date +%s)

    # If paused, use pause time instead of current time
    if [ "$PAUSED" != "null" ]; then
        CURRENT_TIME=$PAUSED
    fi

    # Handle epoch vs ISO timestamp
    if [[ "$START_TIME" =~ ^[0-9]+$ ]]; then
        ELAPSED=$((CURRENT_TIME - START_TIME))
    else
        START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_TIME" +%s 2>/dev/null || echo "$CURRENT_TIME")
        ELAPSED=$((CURRENT_TIME - START_EPOCH))
    fi

    MINUTES=$((ELAPSED / 60))
    SECONDS=$((ELAPSED % 60))
    BLOCKS=$((ELAPSED / 480))
    BLOCK_PROGRESS=$((ELAPSED % 480))
    BLOCK_PROGRESS_MIN=$((BLOCK_PROGRESS / 60))

    if [ "$PAUSED" != "null" ]; then
        echo "Timer paused"
    else
        echo "Timer running"
    fi
    echo "Elapsed: ${MINUTES}m ${SECONDS}s"
    echo "Completed blocks: $BLOCKS"
    echo "Current block progress: ${BLOCK_PROGRESS_MIN}/8 minutes"
}

monitor_timer() {
    while true; do
        if [ ! -f "$STATE_FILE" ]; then
            exit 0
        fi

        STATUS=$(jq -r '.running // false' "$STATE_FILE" 2>/dev/null)
        if [ "$STATUS" != "true" ]; then
            exit 0
        fi

        START_TIME=$(jq -r '._startEpoch // .startTime' "$STATE_FILE")
        LAST_NOTIFIED=$(jq -r '.lastNotifiedBlock // 0' "$STATE_FILE")
        CURRENT_TIME=$(date +%s)

        # Handle epoch vs ISO timestamp
        if [[ "$START_TIME" =~ ^[0-9]+$ ]]; then
            ELAPSED=$((CURRENT_TIME - START_TIME))
        else
            START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_TIME" +%s 2>/dev/null || echo "$CURRENT_TIME")
            ELAPSED=$((CURRENT_TIME - START_EPOCH))
        fi

        CURRENT_BLOCK=$((ELAPSED / 480))

        # Check if we've completed a new block
        if [ "$CURRENT_BLOCK" -gt "$LAST_NOTIFIED" ]; then
            # Send notification banner with project name
            TOTAL_MINUTES=$(($CURRENT_BLOCK * 8))
            PROJECT_NAME=$(jq -r '.projectName // "Unknown"' "$STATE_FILE")
            osascript -e "display notification \"Block $CURRENT_BLOCK completed (${TOTAL_MINUTES} min total)\" with title \"$PROJECT_NAME Timer\" sound name \"Glass\""

            # Update state with new notification block
            TEMP_FILE="${STATE_FILE}.tmp"
            jq ".lastNotifiedBlock = $CURRENT_BLOCK" "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE"
        fi

        # Check every 30 seconds
        sleep 30
    done
}

case "$1" in
    start)
        start_timer
        ;;
    pause)
        pause_timer
        ;;
    resume)
        resume_timer
        ;;
    stop)
        stop_timer
        ;;
    status)
        status_timer
        ;;
    monitor)
        monitor_timer
        ;;
    *)
        echo "Usage: $0 {start|pause|resume|stop|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start a new timer with automatic block notifications"
        echo "  pause   - Pause the timer (preserves elapsed time)"
        echo "  resume  - Resume a paused timer"
        echo "  stop    - Stop the timer and show total blocks"
        echo "  status  - Check current timer progress"
        exit 1
        ;;
esac
