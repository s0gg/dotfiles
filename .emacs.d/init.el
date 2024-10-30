;; -*- lexical-bingding: t -*-

(load "custom.el")

(if (file-readable-p "custom.el")
    (load "custom.el"))

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

(add-to-list 'default-frame-alist '(font . "0xProto-14"))
(set-fontset-font "fontset-default" 'unicode "HackGen Console NF")

(setopt make-backup-files nil)
(setopt backup-by-copying t)

(setq-default show-trailing-whitespace t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(setq scroll-conservatively 1)
(setq scroll-margin 5)
(setq scroll-preserve-screen-position t)

(setq make-backup-files nil)
(setq backup-inhibited nil)
(setq create-lockfiles nil)

(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(setenv "GHQ_ROOT" (concat (getenv "HOME") "/.local/ghq"))
(setq exec-path (append exec-path (list (concat (getenv "HOME") "/go/bin"))))
(setq exec-path (append exec-path (list (concat (getenv "HOME") "/.deno/bin"))))
(setq rbenv-path (concat (getenv "HOME") "/.rbenv/shims"))
(setq exec-path (append exec-path (list rbenv-path)))

(require 'package)

(add-to-list 'package-archives '("gnu-elpa-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

(set-face-attribute 'default nil :font "HackGen Console NF" :height 100)

(add-hook 'js-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(setq package-archive-priorities
      '(("gnu-elpa-devel" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(setq package-install-upgrade-built-in t
      package-native-compile t
      )

(use-package use-package
  :config
  (setq use-package-always-ensure t))

(use-package nerd-icons :ensure t)
(use-package all-the-icons :ensure t)

(use-package catppuccin-theme
  :ensure t
  :config
  (setq catppuccin-enlarge-headings nil)
  (load-theme 'catppuccin :no-confirm))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package fill-column-indicator
  :ensure t
  :config
  (setq fci-rule-column 80
        fci-rule-width 1
        fci-rule-color "darkgray")
  (add-hook 'prog-mode-hook 'fci-mode))

(use-package org-capture
  :ensure nil
  :init
  (global-set-key (kbd "C-c c") 'org-capture)
  :config
  (setq org-capture-templates
      '(("t" "Todo entry" entry (file "~/org/todo.org")
         "* TODO %?\n:LOGBOOK:\n- Added: %U\n:END:")
        ("p" "Plan entry" entry (file+datetree "~/org/plan.org")
         "- [ ] %?")
        ("j" "Journal entry" entry (file+datetree "~/org/journal.org")
         "* weekly review\n- good:%?\n- bad:\n- try:\n")
        ("r" "Review entry" entry (file+datetree "~/org/review.org") (file "~/org/review-template.org"))
        )
      ))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package hydra
  :ensure t
  :config
  (defhydra hydra-zoom (global-map "<f2>")
            "zoom"
            ("g" text-scale-increase "in")
            ("l" text-scale-decrease "out")))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(use-package emacs
  :ensure t
  :custom
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

(use-package markdown-mode
  :ensure t)

(use-package slime
  :ensure t
  :init
  (setq inferior-lisp-program "ros run"))

(use-package web-mode
  :mode (("\\.html?\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-style-padding 2
        web-mode-script-padding 2
        web-mode-enable-auto-closing t
        web-mode-enable-auto-opening t
        web-mode-enable-auto-pairing t
        web-mode-enable-auto-indentation t))

(use-package affe
  :ensure t
  :config
  (consult-customize affe-grep :preview-key "M-."))

(use-package consult
  :bind (("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ;;("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

(use-package consult-ghq
  :ensure t
  :bind
  ("C-c g f" . consult-ghq-find))

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :after
  (consult embark)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable nil)
  :hook
  ((ruby-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui
  :commands lsp-ui-mode
  :ensure t)

(use-package elfeed
  :ensure t
  :init
  (global-set-key (kbd "C-x c") 'elfeed)
  :config
  (setq elfeed-feeds
        '("https://dotfyle.com/this-week-in-neovim/rss.xml"
          "https://sachachua.com/blog/category/emacs-news/feed/index.xml"
          "https://this-week-in-rust.org/rss.xml"
          "https://cprss.s3.amazonaws.com/rubyweekly.com.xml"
          "https://world.hey.com/this.week.in.rails/feed.atom"
          "http://b.hatena.ne.jp/hotentry/it.rss"
          "https://news.ycombinator.com/rss"
          "https://qiita.com/popular-items/feed"
          "https://zenn.dev/feed"
          "https://www.publickey1.jp/atom.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/all.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/rust.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/common-lisp.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/ruby.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/c++.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/c.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/go.xml"
          "https://mshibanami.github.io/GitHubTrendingRSS/daily/typescript.xml"
          "https://rss.slashdot.org/Slashdot/slashdotMain"
          "http://feeds.feedburner.com/blogspot/RLXA.xml")))

(use-package org
  :ensure nil
  :init
  (global-set-key "\C-ca" 'org-agenda)
  (setq org-directory "~/org"
        org-todo-keywords '((sequence "INBOX" "TODO" "|" "DONE" "CANCELED"))
        org-agenda-files (list (expand-file-name org-directory))
        org-startup-indented t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t))))


(use-package org-roam
  :ensure t
  :config
  (setq org-roam-directory (file-truename (concat org-directory "/roam"))))

(use-package org-super-agenda
  :ensure t)

(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "C-:") 'avy-goto-char))

(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-o") 'ace-window)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package typescript-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.ts" . typescript-ts-mode))
  ;;:hook
  ;; ((typescript-ts-mode . lsp))
  :config
  (setq typescript-indent-level 2))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode +1)
  :config
  (setq corfu-auto t
        corfu-quit-no-match 'separator)
  (setq global-corfu-minibuffer
        (lambda ()
          (not (or (bound-and-true-p mct--active)
                   (bound-and-true-p vertico--input)
                   (eq (current-local-map) read-passwd-map))))))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode))

(use-package git-gutter
  :ensure t
  :init
  (global-git-gutter-mode +1))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package tree-sitter
  :ensure t
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs :ensure t)
(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install t)
  (global-treesit-auto-mode))

;; (use-package gleam-ts-mode
;;   :load-path "~/.local/ghq/github.com/gleam-lang/gleam-mode")

(use-package flycheck
  :ensure t)

(use-package yasnippet
  :ensure t
  :config (yas-global-mode))

(use-package lsp-treemacs
  :ensure t)

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t)
  :config
  (add-hook 'rust-mode-hook #'lsp))

(use-package tide
  :ensure t
  :config
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    (corfu-mode +1))
  (add-hook 'before-save-hook 'tide-format-before-save)
  (add-hook 'typescript-mode-hook #'setup-tide-mode)
  (add-hook 'typescript-ts-mode-hook #'setup-tide-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ignored-local-variable-values '((lsp-enabled-clients deno-ls)))
 '(package-selected-packages
   '(ace-window affe all-the-icons catppuccin-theme consult-ghq corfu
                ddskk doom-modeline elfeed emacs-reveal embark
                embark-consult fill-column-indicator flycheck
                git-gutter helm-lsp hydra lsp-treemacs lsp-ui magit
                marginalia nix-mode orderless org-bullets
                org-re-reveal org-ref org-roam org-super-agenda
                rust-mode slime tree-sitter-langs treesit-auto
                typescript-mode vertico web-mode yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
