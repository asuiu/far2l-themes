#!/bin/bash

# far2l Theme Switcher
# Installs/Switches themes for far2l by copying configuration files.
# Handles RGB TrueColor settings automatically.

THEMES_DIR="$(dirname "$(readlink -f "$0")")/themes"
CONFIG_DIR="$HOME/.config/far2l"
COLORER_CONFIG="$CONFIG_DIR/plugins/colorer/config.ini"
COLORER_ROOT="$CONFIG_DIR/plugins/colorer"

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
        
        # Always remove existing color/group files before applying any changes
        echo "Clearing existing color and mask group settings..."
        rm -f "$CONFIG_DIR/palette.ini"
        rm -f "$CONFIG_DIR/settings/colors.ini"
        rm -f "$CONFIG_DIR/settings/farcolors.ini"
        rm -f "$CONFIG_DIR/settings/maskgroups.ini"
        
        # Cleanup colorpicker plugin
        if [ -d "$CONFIG_DIR/plugins/colorpicker" ]; then
            rm -rf "$CONFIG_DIR/plugins/colorpicker"
        fi
        if [ -d "$CONFIG_DIR/plugins/colorpicker.bak" ]; then
            rm -rf "$CONFIG_DIR/plugins/colorpicker.bak"
        fi
        
        # Explicitly clean up loose colorer files from root if they exist
        rm -f "$COLORER_ROOT/catalog.xml" "$COLORER_ROOT/CHANGELOG.md"
        rm -rf "$COLORER_ROOT/hrc" "$COLORER_ROOT/hrd"
        
        if [ "$theme" == "Default" ]; then
            # Restore Defaults (Remove overrides)
            echo "Restoring Built-in Defaults..."
            
            # Restore Palette Override
            if [ -f "$CONFIG_DIR/settings/config.ini" ]; then
                 if grep -q "TTYPaletteOverride=" "$CONFIG_DIR/settings/config.ini"; then
                     sed -i 's/TTYPaletteOverride=./TTYPaletteOverride=1/g' "$CONFIG_DIR/settings/config.ini"
                 fi
            fi
            
            # Reset Colorer Background to Default (0)
            if [ -f "$COLORER_CONFIG" ]; then
                sed -i 's/ChangeBgEditor\=1/ChangeBgEditor\=0/g' "$COLORER_CONFIG"
                sed -i 's|Catalog=.*|Catalog=/usr/share/far2l/Plugins/colorer/base/catalog.xml|g' "$COLORER_CONFIG"
            fi
            
            # Clean up custom colorer base
            rm -rf "$COLORER_ROOT/base"
            
        else
            # Apply Custom Theme
            THEME_PATH="$THEMES_DIR/$theme"
            echo "Applying $theme..."
            
            [ -f "$THEME_PATH/palette.ini" ] && cp "$THEME_PATH/palette.ini" "$CONFIG_DIR/"
            
            # Handle colors.ini
            if [ -f "$THEME_PATH/colors.ini" ]; then
                cp "$THEME_PATH/colors.ini" "$CONFIG_DIR/settings/"
            elif [ -f "$THEME_PATH/settings/colors.ini" ]; then
                cp "$THEME_PATH/settings/colors.ini" "$CONFIG_DIR/settings/"
            fi

            # Handle farcolors.ini
            if [ -f "$THEME_PATH/farcolors.ini" ]; then
                cp "$THEME_PATH/farcolors.ini" "$CONFIG_DIR/settings/"
            elif [ -f "$THEME_PATH/settings/farcolors.ini" ]; then
                cp "$THEME_PATH/settings/farcolors.ini" "$CONFIG_DIR/settings/"
            fi

            # Handle maskgroups.ini
            if [ -f "$THEME_PATH/maskgroups.ini" ]; then
                cp "$THEME_PATH/maskgroups.ini" "$CONFIG_DIR/settings/"
            elif [ -f "$THEME_PATH/settings/maskgroups.ini" ]; then
                cp "$THEME_PATH/settings/maskgroups.ini" "$CONFIG_DIR/settings/"
            fi
            
            # Handle hrd directory (explicit contents copy)
            if [ -d "$THEME_PATH/hrd" ]; then
                echo "Applying custom colorer HRD files..."
                rm -rf "$COLORER_ROOT/base"
                mkdir -p "$COLORER_ROOT/base"
                # Copy system base contents first
                cp -rf /usr/share/far2l/Plugins/colorer/base/* "$COLORER_ROOT/base/"
                # Overlay custom hrd
                cp -rf "$THEME_PATH/hrd" "$COLORER_ROOT/base/"
                
                if [ -f "$COLORER_CONFIG" ]; then
                    sed -i "s|Catalog=.*|Catalog=$COLORER_ROOT/base/catalog.xml|g" "$COLORER_CONFIG"
                fi
            fi

            # Enable RGB mode
            if [ -f "$CONFIG_DIR/settings/config.ini" ]; then
                 if grep -q "TTYPaletteOverride=" "$CONFIG_DIR/settings/config.ini"; then
                     sed -i 's/TTYPaletteOverride=./TTYPaletteOverride=0/g' "$CONFIG_DIR/settings/config.ini"
                 else
                     sed -i '/\[Interface\]/a TTYPaletteOverride=0' "$CONFIG_DIR/settings/config.ini"
                 fi
            fi
            
            # Special handling for StarryDark
            if [[ "$theme" == *"StarryDark"* ]] && [ -f "$COLORER_CONFIG" ]; then
                sed -i 's/ChangeBgEditor\=0/ChangeBgEditor\=1/g' "$COLORER_CONFIG"
            fi
        fi
        
        echo "Theme '$theme' applied successfully."
        echo "Please restart far2l."
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
