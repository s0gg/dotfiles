(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq make-backup-files nil)
(setq auto-save-default nil)
(set-default 'truncate-lines t)
(setq ring-bell-function 'ignore)
(setq display-warning-minimum-level :error)

(add-to-list 'default-frame-alist '(font . "HackGen Console NF-11"))
(set-face-attribute 'default t
		    :family "HackGen Console NF"
		    :height  110)
(set-frame-font "HackGen Console NF-11" nil t)

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))
(leaf leaf-tree :ensure t)
(leaf leaf-convert :ensure t)
(leaf transient-dwim
  :ensure t
  :bind (("M-=" . transient-dwim-dispatch)))

(setq skk-sticky-key ";")
(setq skk-sticky-key-enable t)

(leaf ddskk
  :doc "Daredevil SKK (Simple Kana to Kanji conversion program)"
  :req "ccc-1.43" "cdb-20141201.754"
  :tag "input method" "mule" "japanese"
  :url "https://github.com/skk-dev/ddskk"
  :added "2025-10-09"
  :ensure t
  :after ccc cdb
  :bind (("C-x C-j" . skk-mode)))

(defun skk-isearch-setup-maybe ()
  (require 'skk-vars)
  (when (or (eq skk-isearch-mode-enable 'always)
            (and (boundp 'skk-mode)
                 skk-mode
                 skk-isearch-mode-enable))
    (skk-isearch-mode-setup)))

(defun skk-isearch-cleanup-maybe ()
  (require 'skk-vars)
  (when (and (featurep 'skk-isearch)
             skk-isearch-mode-enable)
    (skk-isearch-mode-cleanup)))

(add-hook 'isearch-mode-hook #'skk-isearch-setup-maybe)
(add-hook 'isearch-mode-end-hook #'skk-isearch-cleanup-maybe)
(setq default-input-method "japanese-skk")

(leaf autorevert
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :global-minor-mode delete-selection-mode)

(leaf paren
  :global-minor-mode show-paren-mode)

(leaf which-key
  :ensure t
  :global-minor-mode t)

(leaf vertico
  :ensure t
  :global-minor-mode t)

(leaf marginalia
  :ensure t
  :global-minor-mode t)

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs."
  :req "emacs-29.1" "consult-2.8"
  :tag "completion" "files" "matching" "emacs>=29.1"
  :url "https://github.com/minad/affe"
  :added "2025-11-16"
  :emacs>= 29.1
  :ensure t
  :after consult)

(leaf embark
  :doc "Conveniently act on minibuffer completions."
  :req "emacs-28.1" "compat-30"
  :tag "convenience" "emacs>=28.1"
  :url "https://github.com/oantolin/embark"
  :added "2025-11-16"
  :emacs>= 28.1
  :ensure t
  :after compat)

(leaf consult
  :doc "Consulting completing-read"
  :req "emacs-29.1" "compat-30"
  :tag "completion" "files" "matching" "emacs>=29.1"
  :url "https://github.com/minad/consult"
  :added "2025-11-16"
  :emacs>= 29.1
  :ensure t
  :after compat)

(leaf consult-gh
  :doc "Consulting GitHub Client."
  :req "emacs-29.4" "consult-2.0" "markdown-mode-2.6" "ox-gfm-1.0" "yaml-1.2.0"
  :tag "vc" "tools" "matching" "convenience" "emacs>=29.4"
  :url "https://github.com/armindarvish/consult-gh"
  :added "2025-11-16"
  :emacs>= 29.4
  :ensure t
  :after consult markdown-mode ox-gfm yaml)

(leaf consult-ghq
  :doc "Ghq interface using consult."
  :req "emacs-26.1" "consult-0.8"
  :tag "ghq" "consult" "usability" "convenience" "emacs>=26.1"
  :url "https://github.com/tomoya/consult-ghq"
  :added "2025-11-16"
  :emacs>= 26.1
  :ensure t
  :after consult)

(leaf consult-gh-embark
  :doc "Embark Actions for consult-gh."
  :req "emacs-29.4" "consult-2.0" "consult-gh-3.0" "embark-consult-1.1" "which-key-3.6.0"
  :tag "completion" "forges" "repositories" "git" "matching" "emacs>=29.4"
  :url "https://github.com/armindarvish/consult-gh"
  :added "2025-11-16"
  :emacs>= 29.4
  :ensure t
  :after consult consult-gh embark-consult which-key)

(leaf magit
  :doc "A Git porcelain inside Emacs"
  :req "emacs-28.1"
  :tag "vc" "tools" "git" "emacs>=28.1"
  :url "https://github.com/magit/magit"
  :added "2025-11-15"
  :emacs>= 28.1
  :ensure t)

(leaf git-gutter
  :doc "Port of Sublime Text plugin GitGutter"
  :req "emacs-25.1"
  :tag "emacs>=25.1"
  :url "https://github.com/emacsorphanage/git-gutter"
  :added "2025-11-18"
  :emacs>= 25.1
  :ensure t
  :config
  (global-git-gutter-mode +1)
  (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
  (global-set-key (kbd "C-x v p") 'git-gutter:previous-hunk)
  (global-set-key (kbd "C-x v n") 'git-gutter:next-hunk)
  (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
  (global-set-key (kbd "C-x v r") 'git-gutter:stage-hunk)
  (global-set-key (kbd "C-x v SPC") #'git-gutter:mark-hunk))

(leaf markdown-mode
  :doc "Major mode for Markdown-formatted text"
  :req "emacs-28.1"
  :tag "itex" "github flavored markdown" "markdown" "emacs>=28.1"
  :url "https://jblevins.org/projects/markdown-mode/"
  :added "2025-10-13"
  :emacs>= 28.1
  :ensure t)

(leaf typescript-ts-mode
  :doc "tree sitter support for TypeScript"
  :tag "builtin"
  :added "2025-11-15"
  :mode (("\\\\.tsx\\\\'" . tsx-ts-mode)
	 ("\\\\.ts\\\\'" . tsx-ts-mode))
  :config
  (setq typescript-ts-mode-indent-offset 2))

(leaf treesit
  :doc "tree-sitter utilities"
  :tag "builtin" "languages" "tree-sitter" "treesit"
  :added "2025-11-15"
  :config
  (setq treesit-font-lock-level 4))

(leaf treesit-auto
  :doc "Automatically use tree-sitter enhanced major modes"
  :req "emacs-29.0"
  :tag "convenience" "fallback" "mode" "major" "automatic" "auto" "treesitter" "emacs>=29.0"
  :url "https://github.com/renzmann/treesit-auto.git"
  :added "2025-11-15"
  :emacs>= 29.0
  :ensure t
  :init
  (require 'treesit-auto)
  (global-treesit-auto-mode)
  :config
  (setq treesit-auto-install t))

(leaf tree-sitter
  :doc "Incremental parsing system"
  :req "emacs-25.1" "tsc-0.18.0"
  :tag "tree-sitter" "parsers" "tools" "languages" "emacs>=25.1"
  :url "https://github.com/emacs-tree-sitter/elisp-tree-sitter"
  :added "2025-11-15"
  :emacs>= 25.1
  :ensure t
  :after tsc
  :hook
  ((typescript-ts-mode . tree-sitter-hl-mode)
   (tsx-ts-mode . tree-sitter-hl-mode))
  :config
  (global-tree-sitter-mode))

(leaf tree-sitter-langs
  :doc "Grammar bundle for tree-sitter"
  :req "emacs-25.1" "tree-sitter-0.15.0"
  :tag "tree-sitter" "parsers" "tools" "languages" "emacs>=25.1"
  :url "https://github.com/emacs-tree-sitter/tree-sitter-langs"
  :added "2025-11-15"
  :emacs>= 25.1
  :ensure t
  :after tree-sitter
  :config
  (tree-sitter-require 'tsx)
  (add-to-list 'tree-sitter-major-mode-language-alist '(tsx-ts-mode . tsx)))

(leaf projectile
  :doc "Manage and navigate projects in Emacs easily."
  :req "emacs-26.1"
  :tag "convenience" "project" "emacs>=26.1"
  :url "https://github.com/bbatsov/projectile"
  :added "2025-11-16"
  :emacs>= 26.1
  :ensure t)

(leaf lsp-mode
  :doc "LSP mode."
  :req "emacs-28.1" "dash-2.18.0" "f-0.20.0" "ht-2.3" "spinner-1.7.3" "markdown-mode-2.3" "lv-0" "eldoc-1.11"
  :tag "languages" "emacs>=28.1"
  :url "https://github.com/emacs-lsp/lsp-mode"
  :added "2025-11-16"
  :emacs>= 28.1
  :ensure t
  :after spinner markdown-mode lv eldoc
  :config
  (add-hook 'typescript-ts-mode-hook 'lsp))

(leaf flycheck
  :doc "On-the-fly syntax checking."
  :req "emacs-27.1" "seq-2.24"
  :tag "tools" "languages" "convenience" "emacs>=27.1"
  :url "https://www.flycheck.org"
  :added "2025-11-16"
  :emacs>= 27.1
  :ensure t)

(leaf corfu
  :doc "COmpletion in Region FUnction"
  :req "emacs-29.1" "compat-30"
  :tag "text" "completion" "matching" "convenience" "abbrev" "emacs>=29.1"
  :url "https://github.com/minad/corfu"
  :added "2025-11-16"
  :emacs>= 29.1
  :ensure t
  :after compat)

(leaf copilot
  :doc "An unofficial Copilot plugin."
  :req "emacs-27.2" "editorconfig-0.8.2" "jsonrpc-1.0.14" "f-0.20.0" "track-changes-1.4"
  :tag "copilot" "convenience" "emacs>=27.2"
  :url "https://github.com/copilot-emacs/copilot.el"
  :added "2025-11-16"
  :emacs>= 27.2
  :ensure t
  :after editorconfig jsonrpc track-changes)

(leaf catppuccin-theme
  :doc "Catppuccin for Emacs - 🍄 Soothing pastel theme for Emacs"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/catppuccin/emacs"
  :added "2025-11-02"
  :emacs>= 27.1
  :ensure t
  :config
  (load-theme 'catppuccin :no-confirm))

(leaf prisma-ts-mode
  :doc "Major mode for prisma using tree-sitter"
  :req "emacs-29.1"
  :tag "tree-sitter" "languages" "prisma" "emacs>=29.1"
  :url "https://github.com/nverno/prisma-ts-mode"
  :added "2025-11-18"
  :emacs>= 29.1
  :ensure t)

(leaf yaml-ts-mode
  :doc "tree-sitter support for YAML"
  :tag "builtin"
  :added "2025-11-20"
  :mode "\\.ya?ml\\'")

(leaf mermaid-mode
  :doc "Major mode for working with mermaid graphs"
  :req "emacs-25.3"
  :tag "processes" "tools" "graphs" "mermaid" "emacs>=25.3"
  :url "https://github.com/abrochard/mermaid-mode"
  :added "2025-11-27"
  :emacs>= 25.3
  :ensure t)

(leaf clojure-ts-mode
  :doc "Major mode for Clojure code"
  :req "emacs-30.1"
  :tag "lisp" "clojurescript" "clojure" "languages" "emacs>=30.1"
  :url "http://github.com/clojure-emacs/clojure-ts-mode"
  :added "2025-12-07"
  :emacs>= 30.1
  :ensure t)

(leaf cider
  :doc "Clojure Interactive Development Environment that Rocks"
  :req "emacs-27" "clojure-mode-5.19" "parseedn-1.2.1" "queue-0.2" "spinner-1.7" "seq-2.22" "sesman-0.3.2" "transient-0.4.1"
  :tag "cider" "clojure" "languages" "emacs>=27"
  :url "https://www.github.com/clojure-emacs/cider"
  :added "2025-12-07"
  :emacs>= 27
  :ensure t
  :after clojure-mode parseedn queue spinner sesman)

(leaf sly
  :doc "Sylvester the Cat's Common Lisp IDE"
  :req "emacs-24.5"
  :tag "sly" "lisp" "languages" "emacs>=24.5"
  :url "https://github.com/joaotavora/sly"
  :added "2025-12-09"
  :emacs>= 24.5
  :ensure t)

(leaf sly-quicklisp
  :doc "Quicklisp support for SLY"
  :req "sly-1.0.0.-2.2"
  :tag "sly" "lisp" "languages"
  :url "https://github.com/capitaomorte/sly-quicklisp"
  :added "2025-12-09"
  :ensure t
  :after sly)

(leaf sly-asdf
  :doc "ASDF system support for SLY"
  :req "emacs-24.3" "sly-1.0.0.-2.2" "popup-0.5.3"
  :tag "asdf" "sly" "lisp" "languages" "emacs>=24.3"
  :url "https://github.com/mmgeorge/sly-asdf"
  :added "2025-12-09"
  :emacs>= 24.3
  :ensure t
  :after sly)

(leaf sly-macrostep
  :doc "Fancy macro-expansion via macrostep.el"
  :req "sly-1.0.0.-2.2" "macrostep-0.9"
  :tag "sly" "lisp" "languages"
  :url "https://github.com/capitaomorte/sly-macrostep"
  :added "2025-12-09"
  :ensure t
  :after sly macrostep)

(leaf sly-overlay
  :doc "Overlay Common Lisp evaluation results"
  :req "emacs-24.4" "sly-1.0"
  :tag "lisp" "emacs>=24.4"
  :url "https://github.com/fosskers/sly-overlay"
  :added "2025-12-09"
  :emacs>= 24.4
  :ensure t
  :after sly)

(leaf expand-region
  :doc "Increase selected region by semantic units"
  :req "emacs-24.4"
  :tag "region" "marking" "emacs>=24.4"
  :url "https://github.com/magnars/expand-region.el"
  :added "2025-12-10"
  :emacs>= 24.4
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(blackout catppuccin-theme ddskk el-get hydra leaf-convert leaf-tree
	      magit marginalia markdown-mode transient-dwim
	      tree-sitter-langs treesit-auto vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
