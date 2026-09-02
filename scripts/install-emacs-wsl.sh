#!/usr/bin/env bash

set -euo pipefail

SRCDIR="/home/s0gg/.local/ghq/github.com/emacs-mirror/emacs"

(
    echo "==========INSTALL EMACS=========="
    cd "$SRCDIR"
    echo "move directory..."
    echo $PWD
    echo "done."
    echo "git pull..."
    git pull -p
    echo "done."
    echo "autogen..."
    ./autogen.sh
    echo "done."
    echo "configure..."
    # X11 (GTK3) rather than pgtk: under WSLg this runs through XWayland, whose
    # clipboard bridge normalises every target to UTF8_STRING.  WSLg's Wayland
    # side, which a pgtk build talks to, offers only `text/plain;charset=utf-8'
    # and a `STRING' target carrying the Windows ANSI code page.
    ./configure --with-native-compilation=aot \
            --with-x-toolkit=gtk3 \
            --with-tree-sitter \
            --without-pop \
            --with-mailutils \
            CFLAGS="-O3 -march=native"
    echo "done."
    echo "build..."
    make -j"$(nproc)"
    echo "done."
    echo "install..."
    sudo make install
    echo "done."
)
