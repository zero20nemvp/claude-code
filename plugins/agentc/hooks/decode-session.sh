#!/bin/bash
# decode-session.sh - Decode locked plugin content at session start
# NOTE: This file must NOT be locked - it's the decoder itself!
# Uses awk for portability (works on macOS default bash)

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"

# Get plugin name, handling versioned directories (e.g., ~/.claude/plugins/cache/marketplace/plugin/1.0.0/)
get_plugin_name() {
  local dir="$1"
  local name
  for _ in 1 2 3; do
    name=$(basename "$dir")
    # Skip version-like names (e.g., "1.0.0", "2.0.3")
    if [[ ! "$name" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
      echo "$name"
      return
    fi
    dir=$(dirname "$dir")
  done
  basename "$1"
}

PLUGIN_NAME=$(get_plugin_name "$PLUGIN_ROOT")

# Key file locations to check (in order of preference)
find_key_file() {
  local candidates=(
    "$HOME/.config/context-lock/keys/$PLUGIN_NAME/lock.yml"
    "$HOME/.config/context-lock/$PLUGIN_NAME/lock.yml"
    "$HOME/.config/context-lock/lock.yml"
    "$PLUGIN_ROOT/lock.yml"
    "$PLUGIN_ROOT/../lock.yml"
  )
  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

KEY_FILE=$(find_key_file)

if [[ -z "$KEY_FILE" ]]; then
  cat <<'EOF'
<AGENTC_ERROR>
AgentC plugin is installed but the license key (lock.yml) is missing.

To fix this, run:
```bash
mkdir -p ~/.config/context-lock/keys/agentc
curl -o ~/.config/context-lock/keys/agentc/lock.yml https://agentc.zero2one.ee/lock.yml
```

Then restart your Claude Code session.
</AGENTC_ERROR>
EOF
  exit 0
fi

# Decode using awk - build vocab from lock.yml and translate tokens
# lock.yml format:
#   :vocabulary:
#     "word": 123
#     'word': 456
#     : 4        <- this is a newline key (appears after blank line)
decode_file() {
  local locked_file="$1"
  local key_file="$2"

  awk '
    BEGIN {
      in_vocab = 0
      prev_was_blank = 0
    }

    # Process key file first (via ARGV[1])
    FNR == NR {
      # Check for vocabulary section (Ruby symbol format)
      if ($0 ~ /^:vocabulary:/) {
        in_vocab = 1
        next
      }

      # Stop at next top-level key
      if (in_vocab && /^:[a-z]/ && !/^[[:space:]]/) {
        in_vocab = 0
        next
      }

      # Track blank lines (for literal newline key detection)
      if (in_vocab && $0 == "") {
        prev_was_blank = 1
        next
      }

      # Literal newline key: appears as ": N" after a blank line
      if (in_vocab && prev_was_blank && /^[[:space:]]*:[[:space:]]+[0-9]+$/) {
        match($0, /[0-9]+/)
        id = substr($0, RSTART, RLENGTH)
        vocab[id] = "\n"
        prev_was_blank = 0
        next
      }
      prev_was_blank = 0

      if (in_vocab && /^[[:space:]]+/) {
        line = $0
        # Trim leading whitespace
        gsub(/^[[:space:]]+/, "", line)

        # Extract the ID (last number after colon)
        if (match(line, /:[[:space:]]*[0-9]+$/)) {
          id = substr(line, RSTART + 1)
          gsub(/^[[:space:]]+/, "", id)
          word = substr(line, 1, RSTART - 1)

          # Handle escaped newlines in quoted strings
          if (word ~ /^".*"$/) {
            word = substr(word, 2, length(word) - 2)
            gsub(/\\n/, "\n", word)
            gsub(/\\t/, "\t", word)
            gsub(/\\"/, "\"", word)
          } else if (word ~ /^'\''.*'\''$/) {
            word = substr(word, 2, length(word) - 2)
          }

          vocab[id] = word
        }
      }
      next
    }

    # Process locked file (ARGV[2])
    {
      n = split($0, tokens, " ")
      line = ""
      for (i = 1; i <= n; i++) {
        token = tokens[i]
        if (token ~ /^[0-9]+$/ && token in vocab) {
          line = line vocab[token]
        } else if (token ~ /^[0-9]+$/) {
          # Unknown token - output as-is with marker
          line = line "[?" token "]"
        } else {
          line = line token
        }
      }
      print line
    }
  ' "$key_file" "$locked_file"
}

# Decode CLAUDE.md (output to stdout for context)
CLAUDE_MD="$PLUGIN_ROOT/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
  content=$(head -1 "$CLAUDE_MD")

  # Check if it's locked (starts with numbers)
  if [[ "$content" =~ ^[0-9]+[[:space:]] ]]; then
    decode_file "$CLAUDE_MD" "$KEY_FILE"
  else
    cat "$CLAUDE_MD"
  fi
fi

# Decode commands IN-PLACE (Claude Code reads these directly from disk)
# This overwrites locked command files with decoded versions
COMMANDS_DIR="$PLUGIN_ROOT/commands"
if [[ -d "$COMMANDS_DIR" ]]; then
  for cmd_file in "$COMMANDS_DIR"/*.md; do
    [[ -f "$cmd_file" ]] || continue

    # Check if file is locked (first non-frontmatter line starts with numbers)
    # Commands have YAML frontmatter, so we need to skip past it
    content=$(awk '/^---$/{n++; next} n==1{print; exit}' "$cmd_file")

    if [[ "$content" =~ ^[0-9]+[[:space:]] ]]; then
      # File is locked - decode it in place
      decoded=$(decode_file "$cmd_file" "$KEY_FILE")
      echo "$decoded" > "$cmd_file"
    fi
  done
fi
