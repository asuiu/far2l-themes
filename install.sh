#!/bin/bash

# Install Script for Far2l Themes
# Links the switcher to ~/.local/bin/far2l-theme and performs initial backup.

INSTALL_DIR="$HOME/.local/bin"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$INSTALL_DIR/far2l-theme"
CONFIG_DIR="$HOME/.config/far2l"

echo "Installing Far2l Theme Switcher..."

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Create Symlink
ln -sf "$PROJECT_DIR/far2l-theme.sh" "$TARGET"
chmod +x "$PROJECT_DIR/far2l-theme.sh"

# Perform initial backup to ensure a clean state without data loss
echo "Backing up existing color and plugin settings..."

backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo "Backing up $(basename "$file") to $(basename "$file").bak"
        mv "$file" "${file}.bak"
    fi
}

backup_file "$CONFIG_DIR/palette.ini"
backup_file "$CONFIG_DIR/settings/colors.ini"
backup_file "$CONFIG_DIR/settings/farcolors.ini"
backup_file "$CONFIG_DIR/settings/maskgroups.ini"

if [ -d "$CONFIG_DIR/plugins/colorer" ]; then
    echo "Backing up colorer plugin to colorer.bak"
    mv "$CONFIG_DIR/plugins/colorer" "$CONFIG_DIR/plugins/colorer.bak"
fi

echo "Done! You can now run 'far2l-theme' from anywhere."
echo "Themes are located in: $PROJECT_DIR/themes"
