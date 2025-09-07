# Zed Harpoon

Harpoon-like functionality for Zed editor: quickly add and open file marks using tasks and keybindings.

## Installation

> ⚠️ **Warning**: This will modify your Zed config files (`~/.config/zed/tasks.json` and `keymap.json`) and create backups with `.harpoon_backup` suffix.

Run the installer from the [repo](https://github.com/thomasgormley/zed-harpoon):

```bash
curl -sSL https://raw.githubusercontent.com/thomasgormley/zed-harpoon/main/scripts/install.sh | bash
```

This appends tasks and keybindings to your Zed config. A confirmation prompt is shown in interactive mode (TTY); in non-interactive mode (e.g., piped curl), it proceeds automatically. Backups are always created.

## Usage

- **Add mark**: Ctrl+A (adds current file to project marks file)
- **Open mark 1-4**: Ctrl+Q, Ctrl+W, Ctrl+E, Ctrl+R
- **Edit marks**: Ctrl+I (opens the marks file in Zed)

Marks are stored per project in `~/.config/zed/{project_name}__harpoon.txt`.

## Keybindings

Installed in Editor context. Edit in `~/.config/zed/keymap.json`.

## Uninstall

Manually remove Harpoon tasks and keybindings from your Zed config files.
