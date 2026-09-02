;;; init.el --- s0gg's Emacs configuration  -*- lexical-binding: t; -*-

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq make-backup-files nil)
(setq auto-save-default nil)
(set-default 'truncate-lines t)
(setq ring-bell-function 'ignore)
(setq display-warning-minimum-level :error)

;; On a pgtk build, WSLg's clipboard bridge (the RDP backend of Weston) offers
;; only `text/plain;charset=utf-8' and `STRING' as selection targets -- there
;; is no `UTF8_STRING'.  Its `STRING' target carries the Windows ANSI code page
;; (CP932 here), while Emacs decodes `STRING' as Latin-1, so text yanked from
;; Windows comes out mojibake.  Ask for the UTF-8 MIME type first.
;;
;; An X11 build needs none of this -- XWayland normalises every target to
;; `UTF8_STRING' -- and there asking for the MIME type is harmful: the request
;; can come back as the TARGETS vector, which `gui-selection-value' then
;; chokes on.  So apply it only when actually running on Wayland.
(when (and (eq initial-window-system 'pgtk)
           (not (equal (getenv "GDK_BACKEND") "x11")))
  (setq x-select-request-type
        '(text/plain\;charset=utf-8 UTF8_STRING COMPOUND_TEXT STRING)))

;; Killing text makes the Emacs frame itself the owner of the Wayland
;; selection, and WSLg only fetches the data lazily: the hand-off to the
;; Windows clipboard is flaky, and whatever was killed disappears from it as
;; soon as Emacs exits.  Push kills through wl-copy instead -- it leaves a
;; small daemon owning the selection, which WSLg picks up every time and which
;; outlives Emacs.
(when (executable-find "wl-copy")
  (defun s0gg/wl-copy (text)
    "Put TEXT on the Wayland clipboard via wl-copy."
    (let ((coding-system-for-write 'utf-8-unix))
      (call-process-region text nil "wl-copy" nil 0 nil
                           "--type" "text/plain;charset=utf-8")))
  (setq interprogram-cut-function #'s0gg/wl-copy))

(let ((font "HackGen Console NF"))
  (add-to-list 'default-frame-alist `(font . ,(concat font "-10")))
  (set-face-attribute 'default nil :family font :height 100)
  (set-frame-font (concat font "-10") nil t)
  ;; Apply HackGen to every character range (kanji, kana, symbols, etc.),
  ;; not just Latin, so all glyphs share the same font.
  (set-fontset-font t 'unicode (font-spec :family font) nil 'prepend))

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

(leaf orderless
  :doc "Completion style for matching regexps in any order"
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion)))))

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
  :after consult
  :bind (("M-s g" . affe-grep)
         ("M-s F" . affe-find))
  :config
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler))

(defun ediff-with-current-buffer (file)
  "Ediff FILE with the current buffer's file."
  (let ((current-file (buffer-file-name)))
    (unless current-file
      (error "Current buffer is not visiting a file"))
    (ediff-files (expand-file-name file) current-file)))

(leaf embark
  :doc "Conveniently act on minibuffer completions."
  :req "emacs-28.1" "compat-30"
  :tag "convenience" "emacs>=28.1"
  :url "https://github.com/oantolin/embark"
  :added "2025-11-16"
  :emacs>= 28.1
  :ensure t
  :after compat
  :bind (("C-." . embark-act))
  :config
  (define-key embark-file-map (kbd "D") #'ediff-with-current-buffer))

(leaf consult
  :doc "Consulting completing-read"
  :req "emacs-29.1" "compat-30"
  :tag "completion" "files" "matching" "emacs>=29.1"
  :url "https://github.com/minad/consult"
  :added "2025-11-16"
  :emacs>= 29.1
  :ensure t
  :after compat
  :bind (("M-s l" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-s r" . consult-ripgrep)
         ("M-s f" . consult-fd)))

(leaf consult-gh
  :doc "Consulting GitHub Client."
  :req "emacs-29.4" "consult-2.0" "markdown-mode-2.6" "ox-gfm-1.0" "yaml-1.2.0"
  :tag "vc" "tools" "matching" "convenience" "emacs>=29.4"
  :url "https://github.com/armindarvish/consult-gh"
  :added "2025-11-16"
  :emacs>= 29.4
  :ensure t
  :after consult markdown-mode ox-gfm yaml
  :config
  (defun my/consult-gh-pr-review-requested ()
    "List PRs requesting review from me in the current repo."
    (interactive)
    (let* ((repo (consult-gh--get-repo-from-directory))
           (consult-gh-search-prs-args (append consult-gh-search-prs-args (list "is:open"))))
      (unless repo
        (user-error "Not in a GitHub repository"))
      (consult-gh-search-prs "review-requested:@me" repo)))

  (defun my/consult-gh-pr-assigned ()
    "List PRs assigned to me in the current repo."
    (interactive)
    (let* ((repo (consult-gh--get-repo-from-directory))
           (consult-gh-search-prs-args (append consult-gh-search-prs-args (list "is:open"))))
      (unless repo
        (user-error "Not in a GitHub repository"))
      (consult-gh-search-prs "assignee:@me" repo))))

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
  :after consult consult-gh embark-consult which-key
  :global-minor-mode consult-gh-embark-mode
  :config
  (defun my/consult-gh-embark-pr-checkout (cand)
    "Checkout the PR of CAND using `gh pr checkout'."
    (let ((repo (get-text-property 0 :repo cand))
          (number (get-text-property 0 :number cand)))
      (unless (and repo number)
        (user-error "Cannot determine repo or PR number"))
      (let ((output (shell-command-to-string (format "gh pr checkout %s -R %s" number repo))))
        (message "gh pr checkout: %s" (string-trim output)))))
  (define-key consult-gh-embark-prs-actions-map (kbd "C") '("gh pr checkout" . my/consult-gh-embark-pr-checkout)))

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
  :hook
  ((typescript-ts-mode . lsp)))

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
  :after editorconfig jsonrpc track-changes
  :hook ((lsp-mode-hook . copilot-mode))
  :bind (:copilot-completion-map
         ("<tab>" . copilot-accept-completion)
         ("TAB" . copilot-accept-completion)))

(leaf catppuccin-theme
  :doc "Catppuccin for Emacs - 🍄 Soothing pastel theme for Emacs"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/catppuccin/emacs"
  :added "2025-11-02"
  :emacs>= 27.1
  :ensure t
  :config
  (setq catppuccin-flavor 'latte)
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

(leaf vterm
  :doc "Fully-featured terminal emulator"
  :req "emacs-25.1"
  :tag "terminals" "emacs>=25.1"
  :url "https://github.com/akermu/emacs-libvterm"
  :added "2026-03-03"
  :emacs>= 25.1
  :ensure t)

(defun insert-current-time ()
  "Insert current time in HH:mm format."
  (interactive)
  (insert (format-time-string "%H:%M")))

(defun diff-current-buffer-with-file ()
  "Fuzzy-find a file with consult-fd and ediff it with the current buffer's file."
  (interactive)
  (let ((current-file (buffer-file-name)))
    (unless current-file
      (error "Current buffer is not visiting a file"))
    (let* ((other-buffer (consult-fd))
           (other-file (buffer-file-name other-buffer)))
      (unless other-file
        (error "Selected buffer is not visiting a file"))
      (ediff-files other-file current-file))))

(leaf org
  :bind (("C-c a" . org-agenda)
         (:org-mode-map
          ("C-c t" . insert-current-time)))
  :custom
  (org-todo-keywords . '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)")))
  (org-agenda-files . '(""))
  (org-agenda-custom-commands
   . '(("p" "private (main)" agenda ""
        ((org-agenda-files '(""))))
       ("m" "mpainternal (work)" agenda ""
        ((org-agenda-files '("")))))))

;;; Insert an org link to a pull request awaiting my review

(require 'let-alist)

(defvar gh-org-link-limit 50
  "Maximum number of pull requests to fetch.")

(defvar gh-org-link--process nil
  "The running gh process, kept to prevent concurrent runs.")

(defun gh-org-link--command ()
  "Return the argument list passed to gh.
`--review-requested=@me' matches both direct requests and ones
that arrive through a team."
  (list "gh" "search" "prs"
        "--state=open"
        "--review-requested=@me"
        "--sort=updated"
        (format "--limit=%d" gh-org-link-limit)
        "--json" "number,title,url,repository,author,updatedAt,isDraft"))

(defun gh-org-link--fetch-async (callback)
  "Run gh asynchronously and call CALLBACK with the list of pull requests."
  (when (process-live-p gh-org-link--process)
    (user-error "gh is already running"))
  (let ((stdout (generate-new-buffer " *gh-org-link-out*"))
        (stderr (generate-new-buffer " *gh-org-link-err*")))
    (setq gh-org-link--process
          (make-process
           :name "gh-org-link"
           :buffer stdout
           :stderr stderr
           :noquery t
           :connection-type 'pipe
           :command (gh-org-link--command)
           :sentinel
           (lambda (proc _event)
             (when (memq (process-status proc) '(exit signal))
               (setq gh-org-link--process nil)
               ;; Passing a buffer as :stderr makes Emacs create a pipe
               ;; process behind the scenes.  Output can still be queued
               ;; on it when this sentinel runs, so drain it first.
               (let ((err-proc (get-buffer-process stderr)))
                 (when (process-live-p err-proc)
                   (accept-process-output err-proc 0.2))
                 (when (process-live-p err-proc)
                   (delete-process err-proc)))
               (unwind-protect
                   (if (zerop (process-exit-status proc))
                       (funcall callback
                                (with-current-buffer stdout
                                  (goto-char (point-min))
                                  (json-parse-buffer :object-type 'alist
                                                     :array-type 'list)))
                     (message "gh failed (exit %d): %s"
                              (process-exit-status proc)
                              (string-trim (with-current-buffer stderr
                                             (buffer-string)))))
                 (kill-buffer stdout)
                 (kill-buffer stderr))))))))

(defun gh-org-link--label (pr)
  "Return the completion candidate string for PR."
  (let-alist pr
    (format "%s#%s  %s%s"
            .repository.nameWithOwner
            .number
            (if (eq .isDraft t) "[draft] " "")
            .title)))

(defun gh-org-link--annotator (candidates)
  "Return an annotation-function over CANDIDATES."
  (lambda (label)
    (when-let* ((pr (cdr (assoc label candidates))))
      (let-alist pr
        (propertize (format "  @%s  %s"
                            .author.login
                            (format-time-string "%Y-%m-%d"
                                                (date-to-time .updatedAt)))
                    'face 'shadow)))))

(defun gh-org-link--table (candidates)
  "Return a completion table over CANDIDATES keeping gh's ordering.
Without this, vertico sorts the candidates alphabetically and the
most recently updated pull requests no longer come first."
  (lambda (string pred action)
    (if (eq action 'metadata)
        `(metadata (category . gh-pr)
                   (annotation-function . ,(gh-org-link--annotator candidates))
                   (display-sort-function . identity)
                   (cycle-sort-function . identity))
      (complete-with-action action candidates string pred))))

(defun gh-org-link--org-link (pr)
  "Return PR as an org-mode link string."
  (require 'ol)
  (let-alist pr
    (org-link-make-string
     .url
     (format "%s#%s %s" .repository.nameWithOwner .number .title))))

(defun gh-org-link--select-and-insert (prs marker)
  "Prompt for one of PRS and insert its org link at MARKER."
  (unwind-protect
      (let ((candidates (mapcar (lambda (pr) (cons (gh-org-link--label pr) pr))
                                prs)))
        (unless candidates
          (user-error "No pull request is awaiting your review"))
        (unless (buffer-live-p (marker-buffer marker))
          (user-error "The buffer to insert into has been killed"))
        (let* ((label (completing-read "Review PR: "
                                       (gh-org-link--table candidates) nil t))
               (pr (cdr (assoc label candidates))))
          (with-current-buffer (marker-buffer marker)
            (goto-char marker)
            (insert (gh-org-link--org-link pr)))))
    (set-marker marker nil)))

(defun gh-org-link-insert-review-pr ()
  "Pick a pull request awaiting my review and insert it as an org link."
  (interactive)
  ;; Remember the position with a marker so that the link still lands
  ;; where it was requested even if point moves while gh runs.
  (let ((marker (point-marker)))
    (message "gh: fetching pull requests awaiting review...")
    (gh-org-link--fetch-async
     (lambda (prs)
       ;; Calling completing-read straight from the sentinel could
       ;; interrupt an unrelated minibuffer session, so hand it back to
       ;; the command loop through a timer first.
       (run-at-time 0 nil #'gh-org-link--select-and-insert prs marker)))))

(defun copy-org-link-as-markdown ()
  "Copy the org link at point to the kill ring in Markdown format.
A link with a description becomes \"[desc](url)\" and a bare link
becomes \"<url>\", which is what the ox-md exporter would produce."
  (interactive)
  (require 'org-element)
  (let ((link (org-element-context)))
    (if (not (eq (org-element-type link) 'link))
        (message "Not on an org link")
      (let* ((url (org-element-property :raw-link link))
             (begin (org-element-property :contents-begin link))
             (description (and begin
                               (buffer-substring-no-properties
                                begin
                                (org-element-property :contents-end link))))
             (markdown (if description
                           (format "[%s](%s)" description url)
                         (format "<%s>" url))))
        (kill-new markdown)
        (message "Copied: %s" markdown)))))

(leaf browse-url
  :doc "Open links in the Windows default browser from WSL"
  :custom
  (browse-url-browser-function . 'browse-url-generic)
  (browse-url-generic-program . "explorer.exe"))

(leaf git-link
  :doc "Get the GitHub/Bitbucket/GitLab URL for a buffer location"
  :req "emacs-24.3"
  :tag "convenience" "azure" "aws" "sourcehut" "gitlab" "bitbucket" "github" "vc" "git" "emacs>=24.3"
  :url "https://github.com/sshaw/git-link"
  :added "2026-03-09"
  :emacs>= 24.3
  :ensure t
  :config
  (setq git-link-use-commit t))

(leaf consult-wt
  :vc (
  :url "https://github.com/tomoya/consult-wt" )
  :ensure t
  :config
  (setq consult-wt-find-function #'consult-fd)
  (setq consult-wt-grep-function #'consult-ripgrep))

(leaf agent-shell
  :ensure t)

(leaf prisma-mode
  :vc (:url "https://github.com/pimeys/emacs-prisma-mode")
  :ensure t)

(leaf terraform-mode
  :ensure t
  :hook
  ((terraform-mode-hook . outline-minor-mode)))

(leaf timecard
  :load-path ""
  :config
  (setq timecard-endpoints '(""))
  (setq timecard-token ""))

(require 'timecard)

(leaf ghreview
  :load-path "")

(require 'ghreview)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(agent-shell blackout catppuccin-theme ddskk el-get hydra
		 leaf-convert leaf-tree magit marginalia markdown-mode
		 obsidian prisma-mode transient-dwim tree-sitter-langs
		 treesit-auto vertico yaml-mode))
 '(package-vc-selected-packages
   '((prisma-mode :url "")
     (consult-wt :url ""))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
