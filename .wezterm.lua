local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { '/usr/local/bin/fish', '-l' }

config.color_scheme = 'catppuccin-mocha'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8
}

return config
