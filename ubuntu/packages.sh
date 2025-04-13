#!/bin/bash

echo "Hello, Ubuntu!"

sudo apt update && sudo apt upgrade -y

sudo apt install -y \
	git \
	fish \
	tmux \
	unzip \
	make \
	gcc \
	libgtk-4-dev \
	libgtk-3-dev \
	gnutls \
	libtree-sitter-dev \
	libxpm-dev \
	libgit-dev \
	libgnutls28-dev \
	libncurses-dev \
	openvpn
