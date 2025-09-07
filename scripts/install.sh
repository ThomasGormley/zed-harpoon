#!/bin/bash

# Install harpoon script to ~/bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARPOON_SRC="$SCRIPT_DIR/../harpoon.lua"
HARPOON_DEST="/usr/local/bin/harpoon"

if [ ! -d "/usr/local/bin" ]; then
    echo "Error: /usr/local/bin does not exist"
    exit 1
fi

cp "$HARPOON_SRC" "$HARPOON_DEST"

chmod +x "$HARPOON_DEST"

echo "Installed harpoon to $HARPOON_DEST"
