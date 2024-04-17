#!/bin/bash

echo "INSTALL s0gg's dotfiles..."

"Create symlink for .wezterm.lua"
ln -s `pwd`/.wezterm.lua $HOME/.wezterm.lua

echo "Done."
