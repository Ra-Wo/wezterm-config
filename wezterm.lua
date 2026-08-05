-- ============================================================================
-- Antigravity Premium WezTerm Configuration
-- Theme: Dracula
--
-- ABOUT:
--   A high-performance, aesthetically refined WezTerm setup featuring:
--   - Dracula color palette with matching content & tab bar backgrounds (#282a36)
--   - Custom pill tab & status bar at the bottom with dynamic process icons & CWD
--   - Window auto-focus over all screens on alert/bell trigger + system sound
--   - Comprehensive workspace creation, switching, and termination shortcuts
--
-- KEYS QUICK REFERENCE:
--   Leader Prefix    : Ctrl + A (1000ms timeout)
--   Split Horizontal : Leader + H
--   Split Vertical   : Leader + V
--   Navigate Panes   : Alt + Arrow Keys (Left/Right/Up/Down)
--   New Tab          : Ctrl + Shift + T
--   Close Tab        : Ctrl + Shift + W
--   Rename Tab       : Ctrl + Shift + R
--   Search           : Ctrl + Shift + F
--   New Workspace    : Ctrl + Shift + N
--   Switch Workspace : Ctrl + Shift + S
--   Kill Workspace   : Ctrl + Shift + K
--   Command Palette  : Ctrl + Shift + P
--   Debug Overlay    : Ctrl + Shift + L
-- ============================================================================

local wezterm = require 'wezterm'
local act    = wezterm.action
local mux    = wezterm.mux
local config = wezterm.config_builder()


-- ----------------------------------------------------------------------------
-- 1. Performance & Shell Setup
-- ----------------------------------------------------------------------------
config.front_end = 'WebGpu'
config.max_fps = 60
config.scrollback_lines = 10000
config.automatically_reload_config = true

if wezterm.target_triple:find("windows") then
  config.default_prog = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-l' }
end

-- ----------------------------------------------------------------------------
-- 2. Theme & Visual Aesthetics
-- ----------------------------------------------------------------------------
-- Load Dracula theme and customize selection highlight
local dracula = wezterm.color.get_builtin_schemes()['Dracula']
dracula.selection_bg = '#bd93f9'  -- Dracula Purple active highlight
dracula.selection_fg = '#282a36'  -- Dark text for high contrast

dracula.tab_bar = {
  background = '#282a36',
  active_tab = {
    bg_color = '#44475a',
    fg_color = '#bd93f9',
  },
  inactive_tab = {
    bg_color = '#282a36',
    fg_color = '#6272a4',
  },
  inactive_tab_hover = {
    bg_color = '#343746',
    fg_color = '#f8f8f2',
  },
  new_tab = {
    bg_color = '#282a36',
    fg_color = '#6272a4',
  },
  new_tab_hover = {
    bg_color = '#343746',
    fg_color = '#f8f8f2',
  },
}

config.colors = dracula

-- Very subtle transparency (94% opaque)
config.window_background_opacity = 0.94
config.win32_system_backdrop = 'Disable'

-- Compact padding & window frame
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = '12pt',
  right = '12pt',
  top = '4pt',
  bottom = '8pt',
}

-- Tab bar & status bar font sizing (compact 8.0pt)
config.window_frame = {
  font = wezterm.font_with_fallback {
    { family = 'JetBrains Mono', weight = 'Medium' },
    { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  },
  font_size = 8.0,
  active_titlebar_bg = '#282a36',
  inactive_titlebar_bg = '#282a36',
}

-- ----------------------------------------------------------------------------
-- 3. Typography & Cursor
-- ----------------------------------------------------------------------------
config.font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono', weight = 'Medium' },
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  { family = 'FiraCode Nerd Font', weight = 'Medium' },
  { family = 'Symbols Nerd Font Mono' },
  { family = 'Consolas' },
}

config.font_size = 9.0
config.line_height = 1
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1', 'zero=1' }

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 650

-- ----------------------------------------------------------------------------
-- 4. Custom Bottom Tab Bar & Status Bar
-- ----------------------------------------------------------------------------
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.status_update_interval = 1000
config.show_tab_index_in_tab_bar = false

-- Process icon helper
local function get_process_icon(process_name)
  local name = string.lower(process_name or '')
  if name:find('bash') or name:find('git') then return ''
  elseif name:find('pwsh') or name:find('powershell') then return ''
  elseif name:find('cmd') then return '󰆍'
  elseif name:find('wsl') or name:find('ubuntu') then return ''
  elseif name:find('node') then return ''
  elseif name:find('python') then return ''
  elseif name:find('nvim') or name:find('vim') then return ''
  end
  return ''
end

-- Helper to extract and format current working directory path reliably
-- Uses get_current_working_dir() — correct API for WezTerm 20240203+
local function get_cwd_path(pane)
  local path = ''

  -- pcall guard so a bad API call never crashes the status bar
  local ok, cwd = pcall(function() return pane:get_current_working_dir() end)
  if ok and cwd and cwd.file_path then
    path = cwd.file_path
  end

  -- Fallback: pane.current_working_dir property
  if path == '' and pane.current_working_dir then
    path = pane.current_working_dir.file_path or ''
  end

  -- Fallback: pane title if it looks like a path
  if path == '' then
    local title = pane:get_title() or ''
    if title:find('^[A-Za-z]:') or title:find('^/') or title:find('~') then
      path = title
    else
      path = wezterm.home_dir
    end
  end

  -- Clean Windows drive prefix /C:/ and convert slashes
  path = path:gsub('^/([A-Za-z]:)', '%1'):gsub('/', '\\')

  -- Replace home directory with ~
  local home = wezterm.home_dir:gsub('/', '\\')
  if path:find(home, 1, true) == 1 then
    path = '~' .. path:sub(#home + 1)
  end

  return path
end

-- Custom Pill Tab Styling (Dracula Palette)
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local active_pane = tab.active_pane
  local process_name = active_pane.foreground_process_name or ''
  local icon = get_process_icon(process_name)
  
  -- Use user-set custom tab title if available
  local title = tab.tab_title
  if title and #title > 0 then
    -- user gave this tab a custom name, use it as-is
    if #title > 16 then title = string.sub(title, 1, 13) .. '…' end
  else
    -- fallback: process icon + short process name
    local pname = process_name:match("([^/\\]+)$") or process_name
    pname = pname:gsub("%.exe$", "")  -- strip .exe on Windows
    if #pname > 10 then pname = string.sub(pname, 1, 8) .. '…' end
    title = pname ~= '' and pname or 'terminal'
  end

  local index = tab.tab_index + 1
  local zoom = active_pane.is_zoomed and ' ' or ''
  
  local bg = '#282a36'  -- Dracula: Background (matches content background)
  local fg = '#6272a4'  -- Dracula: Comment (muted)
  
  if tab.is_active then
    bg = '#44475a'  -- Dracula: Current Line / Selection (active tab)
    fg = '#bd93f9'  -- Dracula: Purple
  elseif hover then
    bg = '#343746'  -- Dracula: Selection (hover)
    fg = '#f8f8f2'  -- Dracula: Foreground
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = string.format(' %d %s %s%s ', index, icon, title, zoom) },
  }
end)

-- Custom Right Status Bar at Bottom of Window (Path + Workspace)
wezterm.on('update-status', function(window, pane)
  local leader = window:leader_is_active() and ' 󰈸 LEADER ' or ''
  local workspace = ' 󰉋 ' .. window:active_workspace() .. ' '

  local cwd = get_cwd_path(pane)
  local path_display = cwd ~= '' and (' 󰉖 ' .. cwd .. ' ') or ''

  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#ff5555' } },  -- Dracula: Red
    { Text = leader },
    { Foreground = { Color = '#8be9fd' } },  -- Dracula: Cyan
    { Text = path_display },
    { Foreground = { Color = '#12cc40' } },  -- Dracula: Green
    { Text = workspace },
  }))
end)

config.audible_bell = 'SystemBeep'

-- Bring terminal on top of all open windows on screen when a bell occurs
wezterm.on('bell', function(window, pane)
  window:focus()
end)

-- ----------------------------------------------------------------------------
-- 5. Essential Keybindings
-- ----------------------------------------------------------------------------
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Split Horizontal (Leader + H / h)
  { key = 'h', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'H', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Split Vertical (Leader + V / v)
  { key = 'v', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'V', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'P', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|COMMANDS', title = '  Command Palette' } },
  -- Debug overlay (Ctrl+Shift+L)
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
  -- Rename current tab  (Ctrl+Shift+R)
  {
    key = 'r', mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { Color = '#bd93f9' } },
        { Text = '  Rename tab › ' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:active_tab():set_title(line)
        elseif line == '' then
          window:active_tab():set_title('')
        end
      end),
    },
  },
  -- New workspace in a new window (Ctrl+Shift+N)
  {
    key = 'n', mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { Color = '#50fa7b' } },
        { Text = '  New workspace name › ' },
      },
      action = wezterm.action_callback(function(window, pane, name)
        if name and #name > 0 then
          mux.spawn_window({ workspace = name })
        end
      end),
    },
  },
  -- Switch workspace (Ctrl+Shift+S)
  {
    key = 's', mods = 'CTRL|SHIFT',
    action = act.ShowLauncherArgs { flags = 'WORKSPACES', title = '  Switch workspace' },
  },
  -- Kill / Delete current workspace (Ctrl+Shift+K)
  {
    key = 'k', mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local current_ws = window:active_workspace()
      for _, win in ipairs(mux.all_windows()) do
        if win:get_workspace() == current_ws then
          for _, tab in ipairs(win:tabs()) do
            for _, p in ipairs(tab:panes()) do
              window:perform_action(act.CloseCurrentPane { confirm = false }, p)
            end
          end
        end
      end
    end),
  },
}

-- ----------------------------------------------------------------------------
-- 6. Command Palette Customization & Custom Actions
-- ----------------------------------------------------------------------------
config.command_palette_font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono', weight = 'Medium' },
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
}
config.command_palette_font_size = 11.0
config.command_palette_rows = 12
config.command_palette_bg_color = '#282a36'
config.command_palette_fg_color = '#f8f8f2'

-- Add custom quick actions directly into Command Palette (Ctrl+Shift+P)
wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Workspace: New Workspace',
      icon = 'md_folder_plus',
      action = act.PromptInputLine {
        description = 'Enter new workspace name',
        action = wezterm.action_callback(function(win, p, line)
          if line and #line > 0 then
            mux.spawn_window({ workspace = line })
          end
        end),
      },
    },
    {
      brief = 'Workspace: Switch Workspace',
      icon = 'md_folder_switch',
      action = act.ShowLauncherArgs { flags = 'WORKSPACES', title = 'Switch Workspace' },
    },
    {
      brief = 'Workspace: Kill Current Workspace',
      icon = 'md_folder_remove',
      action = wezterm.action_callback(function(win, p)
        local current_ws = win:active_workspace()
        for _, w in ipairs(mux.all_windows()) do
          if w:get_workspace() == current_ws then
            for _, tab in ipairs(w:tabs()) do
              for _, pane_item in ipairs(tab:panes()) do
                win:perform_action(act.CloseCurrentPane { confirm = false }, pane_item)
              end
            end
          end
        end
      end),
    },
    {
      brief = 'Tab: Rename Active Tab',
      icon = 'md_rename_box',
      action = act.PromptInputLine {
        description = 'Enter new tab title',
        action = wezterm.action_callback(function(win, p, line)
          if line then win:active_tab():set_title(line) end
        end),
      },
    },
    {
      brief = 'Pane: Split Horizontal',
      icon = 'md_view_column',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      brief = 'Pane: Split Vertical',
      icon = 'md_view_stream',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
  }
end)

return config
