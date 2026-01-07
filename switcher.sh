#!/bin/bash

# far2l Theme Switcher
# Installs/Switches themes for far2l by copying configuration files.
# Handles RGB TrueColor settings automatically.

THEMES_DIR="$(dirname "$(readlink -f "$0")")/themes"
CONFIG_DIR="$HOME/.config/far2l"
COLORER_CONFIG="$CONFIG_DIR/plugins/colorer/config.ini"

# Check if Themes dir exists
if [ ! -d "$THEMES_DIR" ]; then
    echo "Error: Themes directory not found at $THEMES_DIR"
    exit 1
fi

echo "Available Themes:"
options=($(ls "$THEMES_DIR"))
PS3="Select a theme (enter number): "

select theme in "${options[@]}"; do
    if [ -n "$theme" ]; then
        echo "Switching to theme: $theme"
        
        if [ "$theme" == "Default" ]; then
            # Restore Defaults (Remove overrides)
            echo "Removing custom color overrides (Restoring Built-in Default)..."
            rm -f "$CONFIG_DIR/palette.ini"
            rm -f "$CONFIG_DIR/settings/colors.ini"
            rm -f "$CONFIG_DIR/settings/farcolors.ini"
            
            # Restore Palette Override (Default behavior for terminal palette mapping)
            if [ -f "$CONFIG_DIR/settings/config.ini" ]; then
                 if grep -q "TTYPaletteOverride=" "$CONFIG_DIR/settings/config.ini"; then
                     sed -i 's/TTYPaletteOverride=./TTYPaletteOverride=1/g' "$CONFIG_DIR/settings/config.ini"
                 fi
            fi
            
            # Reset Colorer Background to Default (0)
            if [ -f "$COLORER_CONFIG" ]; then
                sed -i 's/ChangeBgEditor\=1/ChangeBgEditor\=0/g' "$COLORER_CONFIG"
                # Reset catalog to system default if needed
                sed -i 's|Catalog=.*|Catalog=/usr/share/far2l/Plugins/colorer/base/catalog.xml|g' "$COLORER_CONFIG"
            fi
            
        else
            # Apply Custom Theme
            THEME_PATH="$THEMES_DIR/$theme"
            
            echo "Applying $theme..."
            
            if [ -f "$THEME_PATH/palette.ini" ]; then
                cp "$THEME_PATH/palette.ini" "$CONFIG_DIR/"
            fi
            
            # Handle colors.ini location (root or settings subdir)
            if [ -f "$THEME_PATH/colors.ini" ]; then
                cp "$THEME_PATH/colors.ini" "$CONFIG_DIR/settings/"
            elif [ -f "$THEME_PATH/settings/colors.ini" ]; then
                cp "$THEME_PATH/settings/colors.ini" "$CONFIG_DIR/settings/"
            fi

            # Handle farcolors.ini location
            if [ -f "$THEME_PATH/farcolors.ini" ]; then
                cp "$THEME_PATH/farcolors.ini" "$CONFIG_DIR/settings/"
            elif [ -f "$THEME_PATH/settings/farcolors.ini" ]; then
                cp "$THEME_PATH/settings/farcolors.ini" "$CONFIG_DIR/settings/"
            fi
            
            # Enable RGB mode (Disable Palette Override) for custom themes
            # This ensures TrueColor sequences (background:#...) are sent directly.
            if [ -f "$CONFIG_DIR/settings/config.ini" ]; then
                 # Ensure setting exists or replace it
                 if grep -q "TTYPaletteOverride=" "$CONFIG_DIR/settings/config.ini"; then
                     sed -i 's/TTYPaletteOverride=./TTYPaletteOverride=0/g' "$CONFIG_DIR/settings/config.ini"
                 else
                     # If missing, add it to [Interface] section
                     sed -i '/\[Interface\]/a TTYPaletteOverride=0' "$CONFIG_DIR/settings/config.ini"
                 fi
            fi
            
            # Special handling for StarryDark (or similar dark themes requiring editor bg change)
            if [[ "$theme" == *"StarryDark"* ]] && [ -f "$COLORER_CONFIG" ]; then
                sed -i 's/ChangeBgEditor\=0/ChangeBgEditor\=1/g' "$COLORER_CONFIG"
                 # Use local catalog if it exists in the theme (optional, kept from original logic)
                 if [ -f "$CONFIG_DIR/plugins/colorer/base/catalog.xml" ]; then
                     sed -i "s|Catalog=.*|Catalog=$CONFIG_DIR/plugins/colorer/base/catalog.xml|g" "$COLORER_CONFIG"
                 fi
            fi
        fi
        
        echo "Theme '$theme' applied successfully."
        echo "Please restart far2l."
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
