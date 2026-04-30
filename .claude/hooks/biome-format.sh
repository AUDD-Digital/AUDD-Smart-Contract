#!/bin/bash
# Hook: Auto-format edited files with Biome
# Runs after Edit/Write tool calls to keep code formatted

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json)
    ;;
  *)
    exit 0
    ;;
esac

# Skip generated files, node_modules, and non-project files
case "$FILE_PATH" in
  */node_modules/*|*/dist/*|*/build/*|*/.claude/*)
    exit 0
    ;;
esac

# Run biome check on the specific file (write mode, quiet)
cd "$CLAUDE_PROJECT_DIR"
bun biome check --write --files-ignore-unknown=true "$FILE_PATH" 2>/dev/null

exit 0
