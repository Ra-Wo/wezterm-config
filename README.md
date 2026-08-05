# WezTerm Configuration

A premium, customized [WezTerm](https://wezfurlong.org/wezterm/) terminal configuration styled with the **Dracula** theme, customized bottom tab bar, automatic process icons, workspace management shortcuts, and alert auto-focus behavior.

---

## 🎨 Features

- **Dracula Palette Integration**: Seamless colors matching the content background (`#282a36`) across the main window, window frames, and bottom tab bar.
- **Custom Bottom Status & Tab Bar**:
  - Displays at the bottom of the window (`tab_bar_at_bottom = true`).
  - Active/inactive tab pills with custom font fallback (`JetBrains Mono` / `Nerd Fonts`).
  - Dynamic process icons for `bash`/`git`, `pwsh`/`powershell`, `cmd`, `wsl`, `node`, `python`, and `nvim`/`vim`.
  - Clean CWD formatting with `~` substitution and Windows path normalization.
  - Displays Leader key status and active workspace name.
- **Auto-Focus & Alert Notifications**:
  - Automatically pops up the terminal window on top of all open screens when a bell/alert (`\a`) sequence occurs.
  - Plays the system audible beep (`SystemBeep`).
- **Workspace Shortcuts**:
  - Create, switch, rename, and kill entire workspaces with quick keybindings.

---

## ⌨️ Keybindings Reference

| Action | Shortcut | Description |
| :--- | :--- | :--- |
| **Leader Key** | `Ctrl + A` | Timeout: 1000ms |
| **Split Horizontal** | `Leader + |` | Split current pane horizontally |
| **Split Vertical** | `Leader + -` | Split current pane vertically |
| **Navigate Panes** | `Alt + ← / → / ↑ / ↓` | Move focus between split panes |
| **New Tab** | `Ctrl + Shift + T` | Open new tab in current pane domain |
| **Close Current Tab** | `Ctrl + Shift + W` | Close active tab (with confirmation) |
| **Rename Tab** | `Ctrl + Shift + R` | Interactive tab title prompt |
| **New Workspace** | `Ctrl + Shift + N` | Interactive workspace name prompt |
| **Switch Workspace** | `Ctrl + Shift + S` | Open workspace launcher menu |
| **Kill Current Workspace** | `Ctrl + Shift + K` | Instantly close all tabs & panes in active workspace |
| **Command Palette** | `Ctrl + Shift + P` | Open WezTerm command palette |
| **Debug Overlay** | `Ctrl + Shift + L` | Open WezTerm debug overlay |

---

## 🚀 Installation & Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Ra-Wo/wezterm-config.git
   ```

2. **Copy configuration to user home directory**:
   - **Windows**:
     ```powershell
     Copy-Item -Path .\wezterm.lua -Destination $env:USERPROFILE\.wezterm.lua -Force
     ```
   - **Linux / macOS**:
     ```bash
     cp wezterm.lua ~/.wezterm.lua
     # or
     mkdir -p ~/.config/wezterm && cp wezterm.lua ~/.config/wezterm/wezterm.lua
     ```

3. **Reload Configuration**:
   WezTerm will automatically reload when `.wezterm.lua` is modified (`automatically_reload_config = true`).
