(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-language-environment "UTF-8")

(set-default-coding-systems 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)

(set-buffer-file-coding-system 'utf-8-unix)
(set-file-name-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(setq locale-coding-system 'utf-8-unix)
(setq coding-system-for-read 'utf-8-unix)
(setq coding-systme-for-write 'utf-8-unix)

(setopt make-backup-files nil)
(setopt backup-by-copying t)

(setq-default show-trailing-whitespace t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(setq scroll-conservatively 1)
(setq scroll-margin 5)
(setq scroll-preserve-screen-position t)
