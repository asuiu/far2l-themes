# Far2l Themes Collection

This repository contains a collection of themes for `far2l` (Linux port of FAR Manager) and a switcher script to easily toggle between them.

It specifically addresses the issue of **TrueColor (RGB)** support in terminal emulators, ensuring that themes look consistent in both GUI and TTY modes by forcing RGB sequences.

## Included Themes

1.  **Default**
    *   Restores `far2l` to its built-in default settings (blue panels, standard terminal colors).
    *   Re-enables `TTYPaletteOverride=1` to allow standard terminal palette remapping.

2.  **FarDefault-RGB**
    *   The classic "Far Blue" look, but updated to use explicit **TrueColor RGB** values (`#102060` background).
    *   Ensures consistent colors in modern terminals (Konsole, Kitty) without relying on palette remapping.
    *   Fixes "White Dialogs" and "Grey File Lists" issues.

3.  **StarryDark**
    *   The original "Starry Dark" theme by [sclea](https://github.com/sclea/far2l-starry-dark-theme).
    *   Uses legacy palette indexing (may require terminal color scheme tweaks).

4.  **StarryDark-RGB**
    *   An automatically generated version of StarryDark that forces **TrueColor RGB** output.
    *   Uses the `background:#RRGGBB` syntax to ensure the theme looks exactly as intended in any TrueColor terminal, regardless of the terminal's color scheme.

## Installation

1.  Clone or download this repository to `~/far2l-themes`.
2.  Run the installation script:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```
3.  This creates a command `far2l-theme` (or you can run `switcher.sh` directly).

## Usage

Run the switcher:
```bash
far2l-theme
```
Select a theme from the menu. Restart `far2l` to see the changes.

## Development Tools

This repository includes Python scripts in the `tools/` directory to help convert legacy themes to TrueColor (RGB) format.

### 1. `fix_theme_rgb.py`
**Purpose:** Updates `farcolors.ini` (Interface Colors) to use explicit RGB values.
**Usage:**
```bash
python3 tools/fix_theme_rgb.py path/to/your/theme/folder
```
*   Reads `palette.ini` to find the RGB values for standard indices (0-15).
*   Updates `farcolors.ini` by prepending `background:#RRGGBB` to entries, forcing `far2l` to enable RGB mode for dialogs, menus, and panels.

### 2. `upgrade_colors_ini.py`
**Purpose:** Updates `colors.ini` (File Highlighting) to use 64-bit TrueColor attributes.
**Usage:**
```bash
python3 tools/upgrade_colors_ini.py path/to/your/theme/folder
```
*   Reads `palette.ini`.
*   Converts legacy bitmasks (e.g., `0x82`) into 64-bit TrueColor integers (e.g., `0x602010...`).
*   **Special Feature:** Automatically detects `SelectedColor` and forces the background to match the main panel background (typically Index 8 or 0) while keeping the foreground text color. This fixes the "Red Stripe" issue common in legacy themes when used with custom palettes.

## How the Switcher Works

The switcher handles the critical `TTYPaletteOverride` setting in `~/.config/far2l/settings/config.ini`:
*   **Default:** Sets `TTYPaletteOverride=1`.
*   **RGB Themes:** Sets `TTYPaletteOverride=0`.

It also copies the necessary `.ini` files (`palette.ini`, `colors.ini`, `farcolors.ini`) to the configuration directory.

## Credits

*   **Starry Dark Theme:** [https://github.com/sclea/far2l-starry-dark-theme](https://github.com/sclea/far2l-starry-dark-theme)
