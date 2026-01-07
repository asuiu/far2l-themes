import re
import sys
import os

if len(sys.argv) < 2:
    sys.exit(1)

theme_dir = sys.argv[1]
palette_path = os.path.join(theme_dir, "palette.ini")
farcolors_path = os.path.join(theme_dir, "farcolors.ini")
if not os.path.exists(farcolors_path):
    farcolors_path = os.path.join(theme_dir, "settings", "farcolors.ini")

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
except:
    pass

defaults = {0:"#000000",1:"#000080",2:"#008000",3:"#008080",4:"#800000",5:"#800080",6:"#808000",7:"#c0c0c0",8:"#808080",9:"#0000ff",10:"#00ff00",11:"#00ffff",12:"#ff0000",13:"#ff00ff",14:"#ffff00",15:"#ffffff"}
for i in range(16):
    if i not in palette:
        palette[i] = defaults[i]

color_map = {"BLACK":0,"BLUE":1,"GREEN":2,"CYAN":3,"RED":4,"MAGENTA":5,"BROWN":6,"LIGHTGRAY":7,"DARKGRAY":8,"LIGHTBLUE":9,"LIGHTGREEN":10,"LIGHTCYAN":11,"LIGHTRED":12,"LIGHTMAGENTA":13,"YELLOW":14,"WHITE":15}

def process_line(line):
    if '=' not in line or line.startswith('['):
        return line
    key, val = line.split('=', 1)
    val = val.strip()
    legacy_part = val.split(';')[0].strip()
    legacy_part = re.sub(r'(background|foreground):#[0-9a-fA-F]{6}\s*,?\s*', '', legacy_part)
    
    bg_idx = -1
    fg_idx = -1
    
    m_bg = re.search(r'B_([A-Z]+)', legacy_part)
    if m_bg:
        grp = m_bg.group(1)
        if grp in color_map:
            bg_idx = color_map[grp]
            
    m_fg = re.search(r'F_([A-Z]+)', legacy_part)
    if m_fg:
        grp = m_fg.group(1)
        if grp in color_map:
            fg_idx = color_map[grp]
            
    prefix_parts = []
    if bg_idx != -1:
        prefix_parts.append("background:" + palette[bg_idx])
    if fg_idx != -1:
        prefix_parts.append("foreground:" + palette[fg_idx])
        
    if not prefix_parts:
        return line
        
    new_val = " ".join(prefix_parts) + ", " + legacy_part
    return key + "=" + new_val

lines = []
with open(farcolors_path, 'r') as f:
    for line in f:
        lines.append(process_line(line.strip()))

with open(farcolors_path, 'w') as f:
    f.write("\n".join(lines) + "\n")