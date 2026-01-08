#!/bin/bash

# Install Script for Far2l Themes
# Links the switcher to ~/.local/bin/far2l-theme

INSTALL_DIR="$HOME/.local/bin"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$INSTALL_DIR/far2l-theme"

echo "Installing Far2l Theme Switcher..."

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Create Symlink
ln -sf "$PROJECT_DIR/far2l-theme.sh" "$TARGET"
chmod +x "$PROJECT_DIR/far2l-theme.sh"

echo "Done! You can now run 'far2l-theme' from anywhere."
echo "Themes are located in: $PROJECT_DIR/themes"
