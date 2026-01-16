#!/bin/bash
# decode-locked-hook.sh - Intercept Read on .locked files and provide decoded content
# This hook is called by Claude Code's PreToolUse for Read operations

# Get the plugin root
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"

# Read tool call info from stdin (JSON format)
read -r INPUT 2>/dev/null || INPUT=""

# Extract file_path from the tool call
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Only process .locked files
if [[ "$FILE_PATH" != *.locked ]]; then
  exit 0
fi

# Try to find the decode binary
DECODE_BIN=""
if [[ -x "$PLUGIN_ROOT/decode" ]]; then
  DECODE_BIN="$PLUGIN_ROOT/decode"
elif command -v decode &>/dev/null; then
  DECODE_BIN="decode"
elif [[ -x "$HOME/.cargo/bin/decode" ]]; then
  DECODE_BIN="$HOME/.cargo/bin/decode"
fi

# If decode binary found, provide instructions
if [[ -n "$DECODE_BIN" ]]; then
  cat <<EOF
<system-reminder>
Reading a .locked file. Use the decode command to get the content:

\`\`\`bash
$DECODE_BIN "$FILE_PATH"
\`\`\`

This will output the decoded content to stdout. Use Bash tool to run it.
</system-reminder>
EOF
else
  cat <<EOF
<system-reminder>
Reading a .locked file but decode binary not found.

To decode, ensure context-lockr is installed:
\`\`\`bash
cargo install --path /path/to/context-lockr
\`\`\`

Or download the decode binary to $PLUGIN_ROOT/decode
</system-reminder>
EOF
fi

# Exit 0 to allow the Read to proceed (hook is advisory)
exit 0
