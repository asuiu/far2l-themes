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

## Technical Details: Color Configuration & Internals

For advanced users or tool developers, here is how `far2l` handles colors internally, specifically for `colors.ini` (File Highlighting).

### 1. The 64-bit Color Structure (`colors.ini`)

Attributes like `NormalColor`, `SelectedColor`, and `CursorColor` are stored as **64-bit unsigned integers**.
When using TrueColor (RGB), the structure is:

```text
0xBBGGRRbbggrrAAAA
```

*   **High 24 bits (`BBGGRR`)**: Background Color (in **BGR** order).
*   **Middle 24 bits (`bbggrr`)**: Foreground Color (in **BGR** order).
*   **Low 16 bits (`AAAA`)**: Attributes & Flags.

#### The `AAAA` Attribute Block
The lowest 16 bits contain flags that tell `far2l` whether to use the RGB values or legacy 4-bit palette indices.

*   **Bit 8 (`0x0100`)**: `FOREGROUND_TRUECOLOR`
    *   If SET: Use `bbggrr` (RGB) for text color.
    *   If UNSET: Use legacy 4-bit palette index (lowest nibble of AAAA).
*   **Bit 9 (`0x0200`)**: `BACKGROUND_TRUECOLOR`
    *   If SET: Use `BBGGRR` (RGB) for background color.
    *   If UNSET: Use legacy 4-bit palette index (high nibble of lowest byte).

### 2. Constructing a Color Value

To set **Background=#102060** (Dark Blue) and **Foreground=#B5C5CF** (Light Grey) with standard attributes:

1.  **Background (BGR)**: Red=`10`, Green=`20`, Blue=`60` -> `0x602010`
2.  **Foreground (BGR)**: Red=`CF`, Green=`C5`, Blue=`B5` -> `0xCFC5B5`
3.  **Attributes**: `0x0300` (Set both TrueColor flags) + `0x00` (Normal Text) -> `0x0300`
    *   *Note: Legacy themes often use `0x0087` or similar. If keeping existing attributes is desired, preserve the lower byte.*

**Resulting Hex String:** `0x602010CFC5B50300`

### 3. NormalColor vs. CursorColor

*   **`NormalColor`**: The color of the file name in the list.
*   **`CursorColor`**: The color of the file name **when the cursor is on it**.
    *   To change the text color *under the cursor* (e.g., to White `#FFFFFF`), modify the **Foreground** part of `CursorColor`.
    *   Example: `0x......FFFFFF0136` (Sets Text to White, keeps Background transparent/legacy).

### 4. Group Processing Priority

`far2l` processes highlighting groups in order (Group 0 to Group 15+).

*   **Stop Condition**: If a group has `ContinueProcessing=0` (common for specific file extensions like `*.ini`, `*.zip`), processing **stops** immediately upon a match.
*   **The Catch-All**: The final group (often Group 15 `*.*`) is only applied if the file was **not** matched by any previous group (or if previous groups allowed continuation).
*   **Implication**: Changing Group 15 will **not** affect files already colored by Group 1 (e.g., `*.ini` files). You must edit the specific group responsible for that file type.
