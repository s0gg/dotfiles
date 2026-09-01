#!/usr/bin/env bash

set -euo pipefail

SRCDIR="/home/s0gg/.local/ghq/github.com/emacs-mirror/emacs"

(
    cd "#{SRCDIR}"
    git pull -p
    ./autogen.sh
    ./configure --with-native-compilation=aot \
            --with-pgtk \
            --with-tree-sitter \
            --without-pop \
            --with-mailutils \
            CFLAGS="-O3 -march=native"
    make -j(nproc)
    sudo make install
)
