#!/bin/bash

set -e

# Install Harpoon tasks and keybindings to Zed config

if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required but not installed.${NC}"
  exit 1
fi

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  Warning: This installation will strip JSON comments from tasks.json and keymap.json, but a backup will be created.${NC}"

read -p "Do you want to continue? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo -e "${RED}Installation cancelled.${NC}"
  exit 1
fi

echo -e "🚀 Installing Harpoon tasks and keybindings to Zed config..."

ZED_CONFIG="$HOME/.config/zed"
PROJECT_TASKS="tasks.json"
PROJECT_KEYMAP="keymap.json"
BACKUP_SUFFIX=".harpoon_backup"

# Ensure Zed config directory exists
mkdir -p "$ZED_CONFIG"

# Function to backup file if exists (handles symlinks by mutating target)
backup_if_exists() {
  local file_path="$1"
  local real_path=$(realpath "$file_path" 2>/dev/null || echo "$file_path")
  if [ -f "$real_path" ]; then
    local backup_path="${real_path}${BACKUP_SUFFIX}"
    cp "$real_path" "$backup_path"
    echo -e "💾 Backed up $real_path to $backup_path"
  fi
}

# Function to get real path (handles symlinks idiomatically)
get_real_path() {
  realpath "$1" 2>/dev/null || readlink -f "$1" 2>/dev/null || echo "$1"
}

# Function to strip and process JSON (strips comments and pipes to jq)
process_json() {
  local file="$1"
  local real_file=$(get_real_path "$file")
  sed 's|//.*||g' "$real_file"
}

# Install tasks.json - append to existing array if present
TASKS_PATH="$ZED_CONFIG/tasks.json"
CANONICAL_TASKS=$(get_real_path "$TASKS_PATH")
backup_if_exists "$TASKS_PATH"

if [ -f "$CANONICAL_TASKS" ]; then
  # Merge: read existing (processed), add new tasks
  process_json "$TASKS_PATH" | jq -s '.[0] + .[1]' - "$PROJECT_TASKS" > /tmp/tasks_merged.json
  mv /tmp/tasks_merged.json "$CANONICAL_TASKS"
  echo -e "${GREEN}✅ Appended Harpoon tasks to tasks.json${NC}"
else
  cp "$PROJECT_TASKS" "$CANONICAL_TASKS"
  echo -e "${GREEN}✅ Created tasks.json with Harpoon tasks${NC}"
fi

# Install keymap.json - append project keymap as another object in the array
KEYMAP_PATH="$ZED_CONFIG/keymap.json"
CANONICAL_KEYMAP=$(get_real_path "$KEYMAP_PATH")
backup_if_exists "$KEYMAP_PATH"

if [ -f "$CANONICAL_KEYMAP" ]; then
  # Check if array
  if process_json "$KEYMAP_PATH" | jq -e 'type == "array"' - > /dev/null; then
    process_json "$KEYMAP_PATH" | jq --slurpfile project "$PROJECT_KEYMAP" '. + $project[0]' - > /tmp/keymap_merged.json
  else
    process_json "$KEYMAP_PATH" | jq --slurpfile project "$PROJECT_KEYMAP" '[. , $project[0]]' - > /tmp/keymap_merged.json
  fi
  mv /tmp/keymap_merged.json "$CANONICAL_KEYMAP"
  echo -e "${GREEN}✅ Appended Harpoon keybindings to keymap.json${NC}"
else
  # Create as array with project keymap
  jq '[.]' "$PROJECT_KEYMAP" > "$CANONICAL_KEYMAP"
  echo -e "${GREEN}✅ Created keymap.json with Harpoon keybindings${NC}"
fi

echo -e "${GREEN}\n🎉 Harpoon installation complete.${NC}"

echo -e "Default keybindings (in Editor context):"
for key in $(jq -r 'if type == "array" then .[0].bindings | keys[] else .bindings | keys[] end' "$PROJECT_KEYMAP"); do
  task_name=$(jq -r --arg k "$key" 'if type == "array" then .[0].bindings[$k][1].task_name else .bindings[$k][1].task_name end' "$PROJECT_KEYMAP")
  echo -e "  ${YELLOW}$key${NC}: $task_name"
done
echo -e "You can edit these in ${YELLOW}$ZED_CONFIG/keymap.json"
