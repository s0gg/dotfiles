#!/bin/bash

echo "INSTALL s0gg's dotfiles..."

"Create symlink for .wezterm.lua"
ln -s `pwd`/.wezterm.lua $HOME/.wezterm.lua

"Create symlink for .emacs.d"
ln -s `pwd`/.emacs.d $HOME/.emacs.d

echo "Done."
