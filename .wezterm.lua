local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { '/usr/bin/fish', '-l' }

config.color_scheme = 'catppuccin-mocha'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font_with_fallback { '0xProto', 'HackGen Console NF' }
config.font_size = 10
config.window_background_opacity = 0.9

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8
}

config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = '\\',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
  },
  {
    key = 't',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain'
  },
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = true }
  }
}

return config
