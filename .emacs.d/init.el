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

;; Scroll
(setq scroll-conservatively 1)
(setq scroll-margin 5)
(setq scroll-preserve-screen-position t)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Cica" :foundry "nil" :slant normal :weight regular :height 140 :width normal)))))

;; (setenv "PATH" (concat "/usr/local/opt/ruby/bin:" (getenv "PATH")))
;; (setq exec-path (cons "/usr/local/opt/ruby/bin" exec-path))

(load (expand-file-name "local.el" user-emacs-directory) t)
(message my/foobar)

(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
;; (add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
(elpaca-no-symlink-mode)
(setq elpaca-queue-limit 10)

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-dracula t)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(use-package nerd-icons)
(use-package doom-modeline
  :ensure t
  :hook
  (after-init . doom-modeline-mode))


;; For magit installation
;; https://github.com/progfolio/elpaca/issues/216#issuecomment-1868444883
(defun +elpaca-unload-seq (e)
  (and (featurep 'seq) (unload-feature 'seq t))
  (elpaca--continue-build e))
(defun +elpaca-seq-build-steps ()
  (append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
                       elpaca--pre-built-steps elpaca-build-steps))
          (list '+elpaca-unload-seq 'elpaca--activate-package)))
(elpaca `(seq :build ,(+elpaca-seq-build-steps)))

(use-package transient
  :elpaca (:host github :repo "magit/transient"))

;; Git
(use-package magit)

(use-package which-key
  :diminish which-key-mode
  :hook (after-init . which-key-mode))
(use-package amx)

(use-package hydra)

(use-package neotree)

;; Org
(setq org-directory "~/OneDrive/org/")
(setq org-tasks-dir (concat org-directory "tasks"))
(setq org-agenda-files '(
			 "~/OneDrive/org/life.org"
			 "~/OneDrive/org/tasks.org"
			 "~/OneDrive/org/journal"
			 ))
(setq org-agenda-start-on-weekday 0)
(setq org-todo-keywords
      '((sequence "INBOX" "TODAY" "THISWEEK" "PROJECT" "WAITING" "|" "SOMEDAY" "DONE")))
(setq org-todo-keyword-faces
      '(("TODAY" . (:foreground "pink" :weight bold))
	("THISWEEK" . (:foreground "yellow"))))
(setq org-log-done 'time)
(define-key global-map "\C-ca" 'org-agenda)

(use-package org-capture
  :elpaca nil
  :bind (("C-c c" . org-capture))
  :config
  (setq org-capture-templates
	`(("t" "Entry as Inbox" entry (file "~/OneDrive/org/tasks.org")
	   "* INBOX %? (wrote on %U)\n  %a"))))

(use-package org-bullets
  :custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
  :hook (org-mode . org-bullets-mode))

(use-package org-journal
  :ensure t
  :defer t
  :bind (("C-c l j" . org-journal-new-entry))
  :config
  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverithing")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded"))))
  (setq org-journal-dir (concat org-directory "journal/")
	org-journal-file-type 'weekly
	org-journal-file-header 'org-journal-file-header-func))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/OneDrive/org/roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n i" . org-roam-node-insert)
	 ("C-c n c" . org-roam-capture)
	 ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode))

(defun open-org-super-agenda()
  "Open org-super-agenda"
  (org-agenda nil "a"))

(use-package org-super-agenda
  :config
  (setq org-agenda-custom-commands
	       '(("d" "super view"
		  ((agenda "" ((org-agenda-span 'day)
			       (org-super-agenda-groups
				'((:name "Today"
					 :time-grid t
					 ;;:date today
					 ;;:todo "TODAY"
					 ;;:schedules today
					 :order 1)
				  (:discard (:anything t))))))
		   (alltodo "" ((org-agenda-overriding-header "")
				(org-super-agenda-groups
				 '((:name "Today todos"
					  :todo "TODAY"
					  :order 1)
				   (:name "Due today"
					  :deadline today
					  :order 2)
				   (:name "This week"
					  :todo "THISWEEK"
					  :order 3)
				   (:name "Overdue"
					  :deadline past
					  :order 4)
				   (:name "Due soon"
					  :deadline future
					  :order 5)
				   (:name "Waiting"
					  :todo "WAITING"
					  :order 6)
				   (:discard (:anything t)))))))))))


;; for nano-agenda
(use-package svg-lib)
(use-package nano-agenda
  :elpaca (:branch "rewrite"))

(use-package vertico
  :init
  (vertico-mode)
  (setq vertico-resize t)
  (setq vertico-cycle t)
  (setq vertico-count 20)
  (require 'savehist)
  (savehist-mode))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package emacs
  :elpaca nil
  :ensure t
  :init
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
		  (replace-regexp-in-string
		   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		   crm-separator)
		  (car args))
	  (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indirator)

  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq enable-recursive-minibuffers t))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
	completion-category-defaults nil
	completion-category-overrides '((file (styles partial-completion))))
  (with-eval-after-load 'corfu
    (add-hook 'corfu-mode-hook
	      (lambda ()
		(setq-local orderless-matching-styles '(orderless-flex))))))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
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
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package affe)

(use-package consult-ghq)

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (ruby-mode . lsp-mode)
         (ruby-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-disabled-clients '(typeprof-ls))
  :commands lsp)

;; optionally
(use-package lsp-ui
  :hook
  (lsp-mode . lsp-ui-mode))

(use-package imenu-list
  :config
  (global-set-key (kbd "C-'") #'imeny-list-smart-toggle))

(use-package corfu
  :elpaca (:files (:defaults "extensions/*"))
  :custom ((corfu-auto t)
           (corfu-auto-delay 0)
           (corfu-auto-prefix 1)
           (corfu-cycle t)
           (corfu-on-exact-match nil)
           (tab-always-indent 'complete))
  :bind (nil
         :map corfu-map
         ("RET" . nil)
         ("<return>" . nil))
  :init
  (global-corfu-mode +1)

  :config
  (defun my/corfu-remap-tab-command ()
    (global-set-key [remap c-indent-line-or-region] #'indent-for-tab-command))
  (add-hook 'java-mode-hook #'my/corfu-remap-tab-command)

  ;; https://github.com/minad/corfu#completing-in-the-minibuffer
  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
                (bound-and-true-p vertico--input))
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

  (with-eval-after-load 'lsp-mode
    (setq lsp-completion-provider :none)))

(use-package cape
  :hook `(((prog-mode
            text-mode
            eglot-managed-mode) . my/set-super-capf)
          (lsp-completion-mode . ,(my/set-super-capf 'lsp-completion-at-point)))
  :config
  (setq cape-dabbrev-check-other-buffers nil)

  (defun my/set-super-capf (&rest capf)
    (setq-local completion-at-point-functions
                (list (cape-capf-properties
                       (cape-capf-super
                        (if capf
                            capf
                          (car completion-at-point-functions))
                        #'tempel-complete
                        #'cape-dabbrev
                        #'cape-file)
                       :sort t
                       :exclusive 'no))))

  (with-eval-after-load 'eglot
    (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))
  (with-eval-after-load 'lsp-mode
    (advice-add 'lsp-completion-at-point :around #'cape-wrap-buster))

  (add-to-list 'completion-at-point-functions #'tempel-complete)
  (add-to-list 'completion-at-point-functions #'tabnine-completion-at-point)
  (add-to-list 'completion-at-point-functions #'cape-file t)
  (add-to-list 'completion-at-point-functions #'cape-tex t)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t)
  (add-to-list 'completion-at-point-functions #'cape-keyword t))

  (use-package prescient
    :config
    (setq prescient-aggressive-file-save t)
    (prescient-persist-mode +1))

  (use-package corfu-prescient
    :after corfu
    :config
    (with-eval-after-load 'orderless
      (setq corfu-prescient-enable-filtering nil))
    (corfu-prescient-mode +1))

(use-package kind-icon
  :after corfu
  :custom (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package corfu-popupinfo
  :elpaca nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode))

(use-package yasnippet
  :bind (nil
         :map yas-keymap
         ("<tab>" . nil)
         ("TAB" . nil)
         ("<backtab>" . nil)
         ("S-TAB" . nil)
         ("M-}" . yas-next-field-or-maybe-expand)
         ("M-{" . yas-prev-field))
  :init
  (yas-global-mode +1))

(use-package tempel
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert)))

;; RSS
(use-package elfeed
  :config
  (setq elfeed-feeds
	'("https://cprss.s3.amazonaws.com/rubyweekly.com.xml"
	  "https://sachachua.com/blog/category/emacs-news/feed/"
	  "https://this-week-in-rust.org/rss.xml"
	  "https://dotfyle.com/this-week-in-neovim/rss.xml"
	  "https://www.publickey1.jp/atom.xml"
	  "https://b.hatena.ne.jp/hotentry/it.rss"
	  "https://news.yahoo.co.jp/rss/topics/domestic.xml"
	  "https://news.yahoo.co.jp/rss/categories/world.xml"
    "https://lwn.net/headlines/rss"
	  "https://www.takeokunn.org/index.xml")))

(use-package puni
  :defer t
  :init
  (puni-global-mode)
  (add-hook 'term-mode-hook #'puni-disable-puni-mode))

(use-package nix-mode
  :ensure t
  )

(use-package markdown-mode
  :ensure t
  )

(use-package web-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  )

 ;; we recommend using use-package to organize your init.el
(use-package codeium
    :elpaca (:host github :repo "Exafunction/codeium.el")
    :init
    ;; use globally
    (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
    ;; or on a hook
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local completion-at-point-functions '(codeium-completion-at-point))))

    ;; if you want multiple completion backends, use cape (https://github.com/minad/cape):
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local completion-at-point-functions
    ;;             (list (cape-super-capf #'codeium-completion-at-point #'lsp-completion-at-point)))))
    ;; an async company-backend is coming soon!

    ;; codeium-completion-at-point is autoloaded, but you can
    ;; optionally set a timer, which might speed up things as the
    ;; codeium local language server takes ~0.2s to start up
    ;; (add-hook 'emacs-startup-hook
    ;;  (lambda () (run-with-timer 0.1 nil #'codeium-init)))

    ;; :defer t ;; lazy loading, if you want
    :config
    (setq use-dialog-box nil) ;; do not use popup boxes

    ;; if you don't want to use customize to save the api-key
    ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

    ;; get codeium status in the modeline
    (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
    (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
    ;; alternatively for a more extensive mode-line
    ;; (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

    ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
    (setq codeium-api-enabled
        (lambda (api)
            (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
    ;; you can also set a config for a single buffer like this:
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local codeium/editor_options/tab_size 4)))

    ;; You can overwrite all the codeium configs!
    ;; for example, we recommend limiting the string sent to codeium for better performance
    (defun my-codeium/document/text ()
        (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
    ;; if you change the text, you should also change the cursor_offset
    ;; warning: this is measured by UTF-8 encoded bytes
    (defun my-codeium/document/cursor_offset ()
        (codeium-utf8-byte-length
            (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
    (setq codeium/document/text 'my-codeium/document/text)
    (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset))

(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

(use-package whitespace
  :elpaca nil
  :config
  (setq whitespace-style '(face tabs spaces trailing line-trail newline empty indentation::space space-mark tab-mark newline-mark))
  (global-whitespace-mode t)
  (setq whitespace-display-mappings
      '((space-mark 32 [183] [46])  ; 32 SPACE, 183 MIDDLE DOT, 46 FULL STOP.
        (newline-mark 10 [182 10])  ; 10 LINE FEED.
        (tab-mark 9 [9655 9] [92 9]))) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE.
  (setq whitespace-space 'whitespace-space)
  (setq whitespace-trailing 'whitespace-trailing)
  (custom-set-faces
   '(whitespace-space ((t (:foreground "#636363"))))
   '(whitespace-trailing ((t (:background "#ff0000"))))
   '(whitespace-tab ((t (:foreground "#444444" :underline t)))))
  )

;; (use-package tree-sitter)
;; (use-package tree-sitter-langs)

(elpaca-process-queues)
