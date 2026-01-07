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

## How it Works

The switcher handles the critical `TTYPaletteOverride` setting in `~/.config/far2l/settings/config.ini`:
*   **Default:** Sets `TTYPaletteOverride=1`.
*   **RGB Themes:** Sets `TTYPaletteOverride=0`.

It also copies the necessary `.ini` files (`palette.ini`, `colors.ini`, `farcolors.ini`) to the configuration directory.

## Credits

*   **Starry Dark Theme:** [https://github.com/sclea/far2l-starry-dark-theme](https://github.com/sclea/far2l-starry-dark-theme)