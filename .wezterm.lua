local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'catppuccin-mocha'
config.default_prog = { '/usr/local/bin/fish', '-l' }

return config
