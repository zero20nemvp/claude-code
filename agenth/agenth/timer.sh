#!/bin/bash

STATE_FILE="$(dirname "$0")/timer-state.json"

start_timer() {
    if [ -f "$STATE_FILE" ]; then
        STATUS=$(jq -r '.status' "$STATE_FILE" 2>/dev/null)
        if [ "$STATUS" = "running" ]; then
            echo "Timer already running. Use './timer.sh status' to check or './timer.sh stop' to end."
            exit 1
        fi
    fi

    START_TIME=$(date +%s)
    echo "{\"status\":\"running\",\"startTime\":$START_TIME,\"lastNotifiedBlock\":0}" > "$STATE_FILE"
    echo "Timer started at $(date '+%H:%M:%S')"
    echo "Run './timer.sh status' to check progress"
    echo "Notifications will fire every 8 minutes"

    # Start background monitor for notifications
    nohup "$0" monitor > /dev/null 2>&1 &
}

stop_timer() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No timer running"
        exit 1
    fi

    STATUS=$(jq -r '.status' "$STATE_FILE" 2>/dev/null)
    if [ "$STATUS" != "running" ]; then
        echo "No timer running"
        exit 1
    fi

    START_TIME=$(jq -r '.startTime' "$STATE_FILE")
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))

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

    STATUS=$(jq -r '.status' "$STATE_FILE" 2>/dev/null)
    if [ "$STATUS" != "running" ]; then
        echo "No timer running"
        exit 0
    fi

    START_TIME=$(jq -r '.startTime' "$STATE_FILE")
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    MINUTES=$((ELAPSED / 60))
    SECONDS=$((ELAPSED % 60))
    BLOCKS=$((ELAPSED / 480))
    BLOCK_PROGRESS=$((ELAPSED % 480))
    BLOCK_PROGRESS_MIN=$((BLOCK_PROGRESS / 60))

    echo "Timer running"
    echo "Elapsed: ${MINUTES}m ${SECONDS}s"
    echo "Completed blocks: $BLOCKS"
    echo "Current block progress: ${BLOCK_PROGRESS_MIN}/8 minutes"
}

monitor_timer() {
    while true; do
        if [ ! -f "$STATE_FILE" ]; then
            exit 0
        fi

        STATUS=$(jq -r '.status' "$STATE_FILE" 2>/dev/null)
        if [ "$STATUS" != "running" ]; then
            exit 0
        fi

        START_TIME=$(jq -r '.startTime' "$STATE_FILE")
        LAST_NOTIFIED=$(jq -r '.lastNotifiedBlock // 0' "$STATE_FILE")
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        CURRENT_BLOCK=$((ELAPSED / 480))

        # Check if we've completed a new block
        if [ "$CURRENT_BLOCK" -gt "$LAST_NOTIFIED" ]; then
            # Send notification banner
            TOTAL_MINUTES=$(($CURRENT_BLOCK * 8))
            osascript -e "display notification \"Block $CURRENT_BLOCK completed (${TOTAL_MINUTES} min total)\" with title \"AgentH Timer\" sound name \"Glass\""

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
        echo "Usage: $0 {start|stop|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start a new timer with automatic block notifications"
        echo "  stop    - Stop the timer and show total blocks"
        echo "  status  - Check current timer progress"
        exit 1
        ;;
esac
