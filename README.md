# Zed Harpoon

Harpoon-like functionality for Zed editor: quickly add and open file marks using tasks and keybindings.

## Installation

Run the installer:

```bash
curl -sSL https://raw.githubusercontent.com/thomasgormley/zed-harpoon/main/scripts/install.sh | bash
```

This appends tasks and keybindings to your Zed config (`~/.config/zed/tasks.json` and `keymap.json`). Backups are created, and a confirmation prompt is shown.

## Usage

- **Add mark**: Ctrl+A (adds current file to project marks file)
- **Open mark 1-4**: Ctrl+Q, Ctrl+W, Ctrl+E, Ctrl+R
- **Edit marks**: Ctrl+I (opens the marks file in Zed)

Marks are stored per project in `~/.config/zed/{project_name}__harpoon.txt`.

## Keybindings

Installed in Editor context. Edit in `~/.config/zed/keymap.json`.

## Uninstall

Manually remove Harpoon tasks and keybindings from your Zed config files.
