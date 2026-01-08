import sys
import os
import re

if len(sys.argv) < 2:
    print("Usage: python3 upgrade_colors_ini.py <theme_dir>")
    sys.exit(1)

theme_dir = sys.argv[1]
palette_path = os.path.join(theme_dir, "palette.ini")
colors_path = os.path.join(theme_dir, "colors.ini")
if not os.path.exists(colors_path):
    colors_path = os.path.join(theme_dir, "settings", "colors.ini")

if not os.path.exists(palette_path) or not os.path.exists(colors_path):
    print(f"Error: Missing files in {theme_dir}")
    sys.exit(1)

palette = {}
try:
    with open(palette_path, 'r') as f:
        current_section = None
        for line in f:
            line = line.strip()
            if line.startswith('[') and line.endswith(']'):
                current_section = line[1:-1].lower()
            elif '=' in line and current_section == 'background':
                idx, hex_val = line.split('=')
                palette[int(idx)] = hex_val.strip()
except Exception as e:
    print(f"Error reading palette: {e}")

defaults = {
    0: "#000000", 1: "#000080", 2: "#008000", 3: "#008080",
    4: "#800000", 5: "#800080", 6: "#808000", 7: "#c0c0c0",
    8: "#808080", 9: "#0000ff", 10: "#00ff00", 11: "#00ffff",
    12: "#ff0000", 13: "#ff00ff", 14: "#ffff00", 15: "#ffffff"
}
for i in range(16):
    if i not in palette:
        palette[i] = defaults[i]

def hex_to_int(hex_str):
    hex_str = hex_str.lstrip('#')
    return int(hex_str, 16)

def make_truecolor(legacy_val_str):
    try:
        legacy_val = int(legacy_val_str, 16)
    except:
        return legacy_val_str

    fg_idx = legacy_val & 0x0F
    bg_idx = (legacy_val >> 4) & 0x0F
    
    # FORCE SelectedColor to use Background Index 8 (Navy) 
    # to avoid "Red Stripe" effect, matching user request.
    # We only do this if the key name suggests it's a selection style we want to flatten.
    # However, 'make_truecolor' doesn't know the key name. 
    # We'll handle this in the caller loop.
    
    fg_rgb = hex_to_int(palette[fg_idx])
    bg_rgb = hex_to_int(palette[bg_idx])
    
    def to_bgr(rgb_int):
        r = (rgb_int >> 16) & 0xFF
        g = (rgb_int >> 8) & 0xFF
        b = rgb_int & 0xFF
        return (b << 16) | (g << 8) | r

    bg_bgr = to_bgr(bg_rgb)
    fg_bgr = to_bgr(fg_rgb)
    
    flags = 0x300
    
    val = (bg_bgr << 40) | (fg_bgr << 16) | flags | legacy_val
    return f"0x{val:X}"

new_lines = []
with open(colors_path, 'r') as f:
    for line in f:
        line = line.strip()
        if line.startswith('CurrentPalette=') or line.startswith('TempColors'):
            continue
        # Update NormalColor=...
        if line.startswith('NormalColor=') or line.startswith('SelectedColor=') or line.startswith('CursorColor=') or line.startswith('SelectedCursorColor='):
            key, val = line.split('=', 1)
            if val.startswith('0x') and len(val) <= 6:
                # FORCE SelectedColor to match Panel (Index 8 - Navy)
                if key == 'SelectedColor':
                    try:
                        # Force Background 8 (Navy) and Foreground 14 (Yellow)
                        # Hex 14 is E? No, 14 is E (0-F: 0..9, A=10, B=11, C=12, D=13, E=14, F=15).
                        # Wait, Standard ANSI: 14 is Yellow.
                        # far2l palette index 14.
                        
                        # So we want legacy byte 0x8E (Back 8, Fore 14)
                        val = "0x8E" 
                    except:
                        pass

                new_val = make_truecolor(val)
                new_lines.append(f"{key}={new_val}")
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)

with open(colors_path, 'w') as f:
    f.write("\n".join(new_lines) + "\n")

print(f"Upgraded {colors_path} to TrueColor")
