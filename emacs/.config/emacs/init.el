;; -*- lexical-binding: t; -*-
                                        ; elpaca bootstrap
(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca
                       :repo "https://github.com/progfolio/elpaca.git"
                       :ref nil :depth 1
                       :files (:defaults "elpaca-test.el"
                                         (:exclude "extensions"))
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
        (if-let ((buffer
                  (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop
                   (apply #'call-process
                          `("git" nil ,buffer t "clone"
                            ,@(when-let ((depth (plist-get order :depth)))
                                (list (format "--depth=%d" depth)
                                 "--no-single-branch"))
                            ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "."
                                       "--batch" "--eval"
                                       "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
                                        ; supplementary files
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-hook 'elpaca-after-init-hook
          (lambda () (unless (load custom-file t)
                       (write-region "" nil custom-file))))

(setq alias-file (expand-file-name "alias.el" user-emacs-directory))
(add-hook 'elpaca-after-init-hook
          (lambda () (unless (load alias-file t)
                       (write-region "" nil alias-file))))
                                        ; elpaca + use-package macro
(elpaca elpaca-use-package (elpaca-use-package-mode))
(elpaca-wait)
                                        ; user experience
(use-package popper
  :demand t
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     help-mode
     compilation-mode))
  :config
  (popper-mode 1)
  (popper-echo-mode 1)
  :bind (("C-`" . popper-toggle-latest)
         ("M-`" . popper-cycle)
         ("M-~" . popper-toggle-type))
  :ensure t)

(use-package unkillable-scratch
  :config
  (unkillable-scratch t)
  :ensure t)

(use-package ws-butler
  :config
  (ws-butler-global-mode 1)
  :ensure t)

(use-package doom-themes
  :config
  (load-theme 'doom-dark+ t)
  :ensure t)

(use-package emacs
  :init
  (column-number-mode 1)
  (setq-default indent-tabs-mode nil)
  :custom
  (visible-bell t)
  (inhibit-startup-screen t)
  :ensure nil)
                                        ; user interface
(use-package js
  :init
  ;; a dirty hack
  (define-derived-mode js-auto-mode prog-mode "JSA"
    "automatically decide which mode to use"
    (if (treesit-ready-p 'javascript t)
        (js-ts-mode) (js-mode)))
  (add-to-list 'major-mode-remap-alist
               '(js-mode . js-auto-mode))
  ;; js-base-mode is mutual base mode
  :after treesit
  :mode ("\\.js" . js-mode)
  :ensure nil)

(use-package mhtml-mode
  :init
  ;; a dirty hack
  (define-derived-mode html-auto-mode prog-mode "HTMLA"
    "automatically decide which mode to use"
    (if (treesit-ready-p 'html t)
        (html-ts-mode) (mhtml-mode)))
  (add-to-list 'major-mode-remap-alist
               '(mhtml-mode . html-auto-mode))
  ;; html-mode is mutual base mode
  :after treesit
  :mode ("\\.html" . mhtml-mode)
  :config
  (tempel-key "C-c C-c y" style-tag)
  (tempel-key "C-c C-c k" link-tag)
  (tempel-key "C-c C-c s" script-tag)
  :bind (:map sgml-mode-map
              ("C-c h" . html-html5-template))
  :ensure nil)

(use-package markdown-mode
  :mode "\\.md"
  :ensure t)

(use-package mermaid-mode
  :mode ("\\.mmd" "\\.mermaid")
  :ensure t)

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode)
  :ensure nil)

(use-package sudo-edit
  :commands sudo-edit
  :ensure t)

(use-package paredit
  :hook ((emacs-lisp-mode . paredit-mode))
  :config
  ;; move to combobulate when appropriate
  (keymap-set paredit-mode-map "M-R"
              (keymap-lookup paredit-mode-map "M-r"))
  (keymap-set paredit-mode-map "M-r" nil)
  :ensure t)

(use-package macrostep
  :bind (:map emacs-lisp-mode-map
              ("C-c e" . macrostep-expand))
  :ensure t)

(use-package calc
  :bind ("M-#" . calc-dispatch)
  :ensure nil)

(use-package ediff
  :defer t
  :custom
  (ediff-make-buffers-readonly-at-startup nil)
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  :ensure nil)

(use-package wgrep
  :ensure t)

(use-package emacs
  :bind (:map global-map
              ("C-S-d" . backward-delete-char-untabify)
              ("C-%" . replace-regexp)
              ("C-x C-c" . nil)
              ("C-z" . nil)
              ("C-x C-z" . nil))
  :ensure nil)
                                        ; tree-sitter
(use-package combobulate
  :hook ((python-ts-mode . combobulate-mode)
         (js-ts-mode . combobulate-mode)
         (html-ts-mode . combobulate-mode))
  :after treesit
  :ensure (:host github :repo "PanayotisManganaris/combobulate" :depth 1))

(use-package treesit
  :init
  (setq treesit-language-source-alist
        '((python "https://github.com/tree-sitter/tree-sitter-python")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")))
  :bind (:map global-map
              ("C-c t i" . treesit-inspect-mode)
              ("C-c t t" . treesit-explore-mode))
  :ensure nil)
                                        ; failure recovery
(use-package recentf
  :init
  (recentf-mode 1)
  :ensure nil)

(use-package emacs
  :custom
  (desktop-restore-forces-onscreen nil)
  :config
  (if (not (daemonp))
      (desktop-save-mode 1)
    (defun restore-desktop (frame)
      "Restores desktop and cancels hook after first frame opens. So the
daemon can run at startup and it'll still work"
      (with-selected-frame frame
        (desktop-save-mode 1)
        (let ((desktop-load-locked-desktop t))
          (desktop-read)
          (remove-hook 'after-make-frame-functions 'restore-desktop))))
    (add-hook 'after-make-frame-functions 'restore-desktop))

  (winner-mode 1)

  (setq bookmark-save-flag 1)
  (setq backup-directory-alist
        '(("." . "~/.local/share/emacs/saves/")))
  (setq backup-by-copying t
        ;; symlinked files + metadata
        version-control t
        delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2)
  (setq auto-save-default t
        auto-save-timeout 60
        auto-save-interval 200)
  :ensure nil)
                                        ; server
(use-package windmove
  ;; replace this with the tm/functions and new vm
  :bind (:map global-map
              ("C-M-s-f" . windmove-swap-states-right)
              ("C-M-s-p" . windmove-swap-states-up)
              ("C-M-s-b" . windmove-swap-states-left)
              ("C-M-s-n" . windmove-swap-states-down)
              ("C-s-f" . windmove-right)
              ("C-s-p" . windmove-up)
              ("C-s-b" . windmove-left)
              ("C-s-n" . windmove-down))
  :ensure nil)
                                        ; shell interaction
(use-package shell
  :commands shell
  :config
  (defun zsh-shell-mode-setup ()
    (setq-local comint-process-echoes t))
  (add-hook 'shell-mode-hook #'zsh-shell-mode-setup)
  :init
  ;; precaution when redirecting zsh IO
  (setq explicit-zsh-args '("--login" "--interactive")
        explicit-shell-file-name shell-file-name)
  :ensure nil)
                                        ; completion framework
(use-package vertico
  :init
  (vertico-mode 1)
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-resize nil)
  (vertico-cycle t)
  :config
  (defun vertico-partial-insert ()
    "Insert next word of current candidate in minibuffer."
    (interactive)
    (when (> vertico--total 0)
      (let* ((vertico--index (max 0 vertico--index))
             (current (minibuffer-contents))
             (candidate (vertico--candidate)))
        (insert (car (s-slice-at
                      (rx bow)
                      (substring candidate
                                 (+ (string-match current candidate)
                                    (seq-length current)))))))))
  :bind (:map vertico-map
              ("TAB" . vertico-partial-insert)
              ("C-j" . vertico-insert))
  :ensure t)

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil)
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t)
  :ensure t)

(use-package marginalia
  :init
  (marginalia-mode 1)
  :custom
  (marginalia-align 'right)
  (marginalia-align-offset -5)
  :bind (:map minibuffer-local-map
              ("M-a" . marginalia-cycle))
  :ensure t)

(use-package corfu
  :init
  (global-corfu-mode 1)
  :custom
  (corfu-cycle t)
  (corfu-auto nil)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 2)
  (corfu-on-exact-match nil)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match t)
  :config
  (add-hook 'minibuffer-setup-hook #'corfu-mode)
  :bind (:map corfu-map
              ("M-a" . corfu-reset)
              ([remap corfu-complete] . corfu-next)
              ("<backtab>" . corfu-previous)
              ([remap next-line] . nil)
              ([remap previous-line] . nil)
              ("RET" . nil))
  :hook (shell-mode . (lambda ()
                        (setq-local corfu-quit-at-boundary t
                                    corfu-quit-no-match t
                                    corfu-auto nil)))
  :ensure t)

(use-package cape
  :bind (("C-c p a" . cape-abbrev)
         ("C-c p d" . cape-dabbrev)
         ("C-c p f" . cape-file)
         ("C-c p w" . cape-dict)
         ("C-c p \\" . cape-tex)
         ("C-c p p" . completion-at-point))
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dict)
  (add-to-list 'completion-category-overrides
               '((cape-dict (styles . (basic)))))
  ;; doesn't work?
  (add-to-list 'completion-at-point-functions #'cape-abbrev)
  :config
  (setq cape-dabbrev-check-other-buffers nil)
  (setq cape-dict-file "/usr/share/dict/usa")
  :ensure t)

(use-package eglot
  :hook ((python-base-mode . eglot-ensure))
  :config
  ;; configure to increase performance OR reliability of completions
  (setq-default eglot-workspace-configuration
                '((haskell (maxCompletions . 200))))
  ;; NOTICE: this can and SHOULD be configured per project directory
  :init
  (add-to-list 'completion-category-overrides
               '(eglot (styles . (orderless))))
  :ensure nil)
                                        ; autotyping
(use-package abbrev
  :custom
  (save-abbrevs 'silently)
  :bind (("C-x a r" . expand-region-abbrevs)
         ("C-x a a" . list-abbrevs)
         ("C-x a w" . edit-abbrevs)
         ("C-x a u" . unexpand-abbrev))
  :ensure nil)

(use-package tempel
  :demand t
  :custom
  (tempel-path
   (expand-file-name "templates/*.eld" user-emacs-directory))
  :init
  (defun tempel--region ()
    "Return region bounds."
    (when (use-region-p)
      (when (< (mark) (point)) (exchange-point-and-mark))
      ;; (deactivate-mark)
      (cons (point-marker) (mark-marker))))

  (defun tempel-setup-capf ()
    "Add `tempel-complete' to `completion-at-point-functions' to check
while typing. Add it *before* the mode's main Capf, so it will be
tried first."
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  :config
  (defun tempel--eval (form)
    "Eval arbitrary forms in templates. The form should return a valid
tempel element."
    (eval form))
  (add-to-list 'tempel-user-elements #'tempel--eval)

  (defun tempel-include (elt)
    "include templates by name in another template."
    (when (eq (car-safe elt) 'i)
      (if-let (template (alist-get (cadr elt) (tempel--templates)))
          (cons 'l template)
        (message "Template %s not found" (cadr elt))
        nil)))
  (add-to-list 'tempel-user-elements #'tempel-include)

  (tempel-key "(" parenthesis-pair-maybe)
  (tempel-key "[" bracket-pair-maybe)
  (tempel-key "{" brace-pair-maybe)
  (tempel-key "<" abracket-pair-maybe)
  (tempel-key "\"" qquote-pair-maybe)
  (tempel-key "'" quote-pair-maybe)
  :bind ((:map global-map
               ("C-c y" . tempel-insert))
         (:map tempel-map
               ("<tab>" . tempel-next)
               ("<backtab>" . tempel-previous)
               ("M-}" . tempel-next)
               ("M-{" . tempel-previous)))
  :ensure t)
                                        ; spell checking
(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-,"   . jinx-previous)
         ("C-."   . jinx-next)
         ("C-M-$" . jinx-languages))
  :ensure t)
                                        ; interactive command framework
(use-package consult
  :init
  (setq consult-dir-shadow-filenames nil
        register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)
  :config
  (keymap-global-set "C-s"
                     (keymap-lookup global-map "M-s"))
  (keymap-global-set "M-s" nil)
  :demand t ;; force remap of anonymous search map on startup
  :bind ((:map global-map
               ("C-x b" . consult-buffer)
               ;; includes bookmarks
               ("C-x C-d" . consult-dir)
               ("M-y" . consult-yank-pop)
               ("C-x R" . consult-register-store)
               ("C-x r l" . consult-register)
               ("C-s s" . isearch-forward)
               ("C-s r" . isearch-backward)
               ("C-s l" . consult-line)
               ("C-s L" . consult-line-multi)
               ("C-s G" . consult-git-grep)
               ("C-s r" . consult-ripgrep)
               ("C-s d" . consult-find)
               ("M-g i" . consult-imenu)
               ("M-g I" . consult-imenu-multi)
               ("M-g m" . consult-mark)
               ("M-g M" . consult-global-mark)
               ("M-g e" . consult-compile-error)
               ("C-c k" . consult-kmacro)
               ("C-c m" . consult-minor-mode-menu)
               ("C-x p b" . consult-project-buffer))
         (:map vertico-map
               ("M-s" . consult-history)))
  :ensure t)

(use-package embark-consult
  :after (embark consult)
  ;; :demand t
  ;; :hook
  ;; (embark-collect-mode . consult-preview-at-point-mode)
  :bind (:map embark-collect-mode-map
              ("C-j" . #'consult-preview-at-point))
  :ensure t)

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click))
  :ensure t)

(use-package phi-search
  :bind (:map mc/keymap
              ([remap isearch-forward] . phi-search)
              ([remap isearch-backward] . phi-search-backward))
  :ensure t)

(use-package avy
  :bind ("M-j" . avy-goto-char-2)
  :ensure t)

(use-package bufler
  :custom
  (bufler-filter-buffer-modes '(bufler-list-mode
                                calendar-mode
                                helm-major-mode
                                magit-diff-mode
                                magit-process-mode
                                magit-revision-mode
                                magit-section-mode
                                special-mode
                                timer-list-mode))
  :config
  (setf bufler-groups
        (bufler-defgroups
          ;; group all named workspaces.
          (group (auto-workspace))
          ;; group all `help-mode' and `info-mode' buffers.
          (group
           (group-or "*Help/Info*"
                     (mode-match "*Help*" (rx bos "help-"))
                     (mode-match "*Info*" (rx bos "info-"))))
          ;; group all special buffers except Dired, Forge, and
          ;; Magit buffers which fall through to their project groups
          (group
           (group-not "*Special"
                      (group-or "*Special*"
                                (mode-match "Magit" (rx bos "magit-"))
                                (mode-match "Forge" (rx bos "forge-"))
                                (mode-match "Dired" (rx bos "dired"))
                                (mode-match "grep" (rx bos "grep-"))
                                (mode-match "compilation" (rx bos "compilation-"))
                                (auto-file)))
           ;; subgroup "special special" buffers separately
           (group
            (name-match "**Special**"
                        (rx bos "*" (or "Messages" "Warnings" "scratch" "Backtrace") "*")))
           ;; subgroup all other Magit buffers, grouped by directory.
           (group
            (mode-match "*Magit* (non-status)" (rx bos "magit-"))
            (auto-directory))
           ;; subgroup remaining special buffers by mode.
           (auto-mode))
          ;; group all buffers under emacs config directory
          (dir user-emacs-directory)
          ;; group buffers in `org-directory'
          (group
           (dir (if (bound-and-true-p org-directory)
                    org-directory
                  "~/org"))
           ;; subgroup indirect Org buffers by file.
           ;; very useful when used with `org-tree-to-indirect-buffer'.
           (group
            (auto-indirect)
            (auto-file))
           ;; subgroup remaining buffers by file-backed status, then mode.
           (group-not "*special*" (auto-file))
           (auto-mode))
          ;; group buffers in git projects by directory, by
          ;; dired/magit type, or by other special status
          (group
           (auto-parent-project)
           (group-not "special"
                      (group-or "Non-file-backed and neither Dired nor Magit"
                                (mode-match "Magit Status" (rx bos "magit-status"))
                                (mode-match "Dired" (rx bos "dired-"))
                                (auto-file))))
          ;; group remaining buffers by directory, then major mode.
          (auto-directory)
          (auto-mode)))

  ;; function for grouping roam buffers
  ;; (defun agenda-buffer-p (buffer)
  ;;   "Return non-nil if BUFFER’s file satisfies ‘org-agenda-file-p’"
  ;;   (org-agenda-file-p (buffer-file-name buffer)))
  ;; (push 'agenda-buffer-p bufler-workspace-switch-buffer-filter-fns)

  ;; this is slow. try memoization?
  ;; (bufler-buffer-alist-at nil :filter-fns bufler-workspace-switch-buffer-filter-fns)
  ;; (bufler-buffers :path nil :filter-fns bufler-workspace-switch-buffer-filter-fns)

  ;; if Dir: /home/panos/org and org-mode exist, collapse the section upon bufler open...
  ;; if fast autogrouping can be done, do it...
  ;; (magit-section-toggle (magit-get-section (magit-section-ident)))

  :bind (:map global-map
              ("C-x C-b" . bufler)
              ("C-x b" . bufler-switch-buffer))
  :ensure t)

(use-package project
  :ensure nil)
                                        ; source control
(use-package magit
  :bind ("C-x g" . magit-status)
  :ensure t)
                                        ; contextual action framework
(use-package embark
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind (:map global-map
              ("C-;" . embark-act)
              ("M-." . embark-dwim)
              ("C-h B" . embark-bindings)
              ("C-:" . embark-act-all)
              ("C-(" . embark-collect-snapshot))
  :ensure t)
                                        ; directory edit
(use-package dired
  :custom
  (dired-guess-shell-alist-user
   '(("\\.pdf\\'" "xdg-open &")))
  :init
  (setq dired-listing-switches "-ahl -v --group-directories-first")
  (setq dired-omit-files "\\`[.]?#\\|\\`[.][.]?\\|^[.].+\\'")
  (setq dired-auto-revert-buffer t
        dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'top)
  :config
  (add-hook 'dired-mode-hook 'dired-hide-details-mode)

  (defun pm/dired-disable-gnu-ls-flags-in-tramp-buffers ()
    "For when dired in tramp displays blank screen when remote system
does not use GNU ls, which is the only variant that supports
--group-directories-first."
    (when (file-remote-p default-directory)
      (setq-local dired-actual-switches (car args))))

  (put 'dired-find-alternate-file 'disabled nil)
  :bind (:map dired-mode-map
              ("C-x M-o" . dired-omit-mode))
  :ensure nil)

(use-package wdired
  :bind (:map dired-mode-map
              ("C-c C-e" . wdired-change-to-wdired-mode))
  :ensure nil)
                                        ; direnv
(use-package direnv
  :config
  (direnv-mode 1)
  :ensure t)
                                        ; org-mode notes
(use-package org
  :init
  (setq org-directory
        (file-truename
         (file-name-concat (getenv "HOME") "org")))
  (setq org-startup-indented t)
  (setq org-ellipsis " [+]")
  (custom-set-faces '(org-ellipsis ((t (:foreground "gray40" :underline nil)))))
  :config
  ;; GTD implementation
  (setq org-use-fast-todo-selection 'auto)
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)
  (setq org-todo-keywords
        '((sequence "TODO(t)"
                    "NEXT(n!)"
                    "WAIT(w@/!)"
                    "|"
                    "DONE(d!)"
                    "INACTIVE(i@)"
                    "CANCELED(q@/@)")))
  (setq org-todo-keyword-faces
        (quote (("TODO" :foreground "blue" :weight bold)
                ("NEXT" :foreground "red" :weight bold)
                ("WAIT" :foreground "orange" :weight bold)
                ("DONE" :foreground "forest green" :weight bold)
                ("INACTIVE" :foreground "magenta" :weight bold)
                ("CANCELED" :foreground "forest green" :weight bold))))

  (defun pm/modify-org-done-face ()
    (setq org-fontify-done-headline t)
    (set-face-attribute 'org-done nil :strike-through t)
    (set-face-attribute 'org-headline-done nil
                        :strike-through t
                        :foreground "light gray"))
  (eval-after-load "org"
    (add-hook 'org-add-hook 'pm/modify-org-done-face))

  (setq org-stuck-projects
        '("+LEVEL=1+TODO/-DONE-CANCELED-INACTIVE-NEXT" ("NEXT")))
  (setq org-enforce-todo-dependencies t)
  (setq org-agenda-dim-blocked-tasks t)
  (setq org-log-into-drawer t)
  (setq org-priority-default 3)
  (setq org-priority-highest 1)
  (setq org-priority-lowest 5)
  ;; tree-sitter org mode navigation?
  :bind (:map org-mode-map
              ("M-[" . org-backward-paragraph)
              ("M-]" . org-forward-paragraph)
              ("M-{" . org-backward-element)
              ("M-}" . org-forward-element))
  :ensure nil)

(use-package org
  ;; customize checklists
  :config
  (defun pm/insert-stats-cookie (&optional arg)
    "insert statistics cookie in list item/heading at point.
Insert fractional progress cookie. With prefix, insert percentage
cookie."
    (interactive "p")
    (save-excursion
      (let* ((struct (ignore-errors (org-list-struct)))
             (cpos (cond ((not struct) (org-up-heading-safe) (point))
                         ((org-in-item-p))))
             (parents (org-list-parents-alist struct))
             (cookie (cond ((eq arg 1) "[/] ")
                           ((eq arg 4) "[%] "))))
        (if struct
            (progn
              (if (member cpos (map-values parents))
                  ;; there is children
                  (beginning-of-line)
                (if-let (ppos (map-elt parents cpos))
                    ;; there is a parent
                    (goto-char ppos)
                  (error "Nothing to track in this task")))
              (looking-at org-list-full-item-re))
          (looking-at
           ;; create regexp from user's keywords
           "^\\(\\*+\\)\\(?: +\\(TODO\\|NEXT\\|WAIT\\|DONE\\) +\\)"))
        (goto-char (match-end 0))
        (insert cookie)))
    (org-update-statistics-cookies 'nil))
  :bind (:map org-mode-map
              ("C-c C-x s" . pm/insert-stats-cookie))
  :custom
  (org-cycle-include-plain-lists nil)
  :ensure nil)

(use-package org-roam
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename (file-name-concat
                                      org-directory "roam")))
  (org-roam-capture-templates
   (quote (("d" "dispatch")
           ;; (fkey description type template
           ;;  :target (type etc)
           ;;  :etc)
           ("f" "default" plain "%?"
            :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                               "#+title: ${title}")
            :unnarrowed t))))
  :config
  (org-roam-db-autosync-mode 1)
  (require 'org-roam-protocol)
  :bind ((:map global-map
               ("C-c n f" . org-roam-node-find)
               ("C-c n r" . org-roam-node-random))
         (:map org-mode-map
               ("C-c n i" . org-roam-node-insert)
               ("C-c n o" . org-id-get-create)
               ("C-c n t" . org-roam-tag-add)
               ("C-c n a" . org-roam-alias-add)
               ("C-c n b" . org-roam-ref-add)
               ("C-c n l" . org-roam-buffer-toggle)
               ("C-c n c" . org-roam-extract-subtree)))
  :ensure t)

(use-package org-roam-ui
  :after org-roam
  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-browser-function #'browse-url-chromium)
  :bind ("C-c n g" . org-roam-ui-mode)
  :ensure t)

(use-package ob
  :after (org)
  :custom
  (org-confirm-babel-evaluate nil)
  (org-ditaa-jar-path "/usr/share/java/ditaa/ditaa-0.11.jar")
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (js . t)
     (makefile . t)
     (ditaa . t)
     (mermaid . t)
     (shell . t)))

  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  :ensure nil)

(use-package ol
  :init
  (dolist (scheme '((org-web-link "blue violet" "color web links")
                    (org-file-link "lime green" "color file links")
                    (org-help-link "dark turquoise" "color manual links")))
    (let ((linkey (nth 0 scheme))
          (color (nth 1 scheme))
          (doc (nth 2 scheme)))
      (eval `(defface ,linkey '((t :inherit 'org-link
                                   :foreground ,color))
               ,doc
               :group 'org-faces))))
  :config
  (org-link-set-parameters "https" :face 'org-web-link)
  (org-link-set-parameters "http" :face 'org-web-link)
  (org-link-set-parameters "file" :face 'org-file-link)
  (org-link-set-parameters "info" :face 'org-help-link)
  (org-link-set-parameters "man" :face 'org-help-link)
  (org-link-set-parameters "help" :face 'org-help-link)
  :bind (:map global-map
              ("C-c l" . org-store-link))
  :ensure nil)

(use-package ol-man
  :autoload (org-man-store-link org-man-open)
  :ensure nil)

(use-package org-download
  :config
  (setq org-image-actual-width '(800))
  (setq org-download-display-inline-images nil
        org-download-screenshot-method "flameshot gui --raw > %s")
  :ensure t)

(use-package org-agenda
  :after (org-roam)
  :custom
  (org-agenda-files (list org-roam-directory))
  :bind ((:map org-mode-map
               ("C-'" . nil)
               ("C-," . nil))
         (:map global-map
               ("C-c a" . org-agenda)))
  :ensure nil)
                                        ; tex and tex integration
(use-package tex-mode
  :config
  (defun pm/p2l ()
    "Format current paragraph into single lines."
    (interactive "*")
    (let ((i (current-indentation)))
      (save-excursion
        (forward-paragraph)
        (let ((foo (point)))
          (backward-paragraph)
          (replace-regexp "\n *" " " nil (1+ (point)) foo))
        (message (s-append ".\n" (spaces-string i)))
        (let ((foo (point)))
          (beginning-of-line)
          (replace-regexp "\\. " (s-append (spaces-string i) ".\n") nil (point) foo)))))
  :ensure nil)

(use-package org
  :config
  (setf (plist-get (alist-get
                    'imagemagick org-preview-latex-process-alist)
                   :latex-compiler)
        '("cd %o && pdflatex -interaction nonstopmode -output-directory %o --shell-escape %f"))

  (add-to-list 'org-latex-packages-alist
               '("" "ptm" t ("pdflatex")))
  (add-to-list 'org-latex-packages-alist
               '("" "tikz" t))
  (eval-after-load "preview"
    '(add-to-list 'preview-default-preamble
                  "\\PreviewEnvironment{tikzpicture}" t))
  (eval-after-load "preview"
    '(add-to-list 'preview-default-preamble
                  "\\PreviewEnvironment{prooftree}" t))

  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 2.5))
  :custom
  (org-preview-latex-default-process 'imagemagick)
  :ensure nil)
                                        ; org-mode export
(use-package ox
  :custom
  (org-export-dispatch-use-expert-ui t)
  :config
  (defun seed-random-generator (_)
    (random (buffer-name)))
  (add-hook 'org-export-before-processing-functions #'seed-random-generator)
  :ensure nil)

(use-package ox-latex
  :custom
  (org-latex-pdf-process
   (list
    "latexmk -f -pdf -%latex -bibtex -interaction=nonstopmode -shell-escape -output-directory=%o %f"))
  (org-latex-src-block-backend 'engraved)
  :ensure nil)
                                        ; reference management
(use-package oc
  :custom
  (org-cite-global-bibliography
   (list (file-truename (file-name-concat org-directory "lib.bib"))))
  :after org
  :ensure nil)

(use-package citar
  :custom
  (citar-bibliography org-cite-global-bibliography)
  ;; citar-notes-paths not needed
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :after oc
  :ensure t)

(use-package citar-org-roam
  :custom
  (citar-org-roam-note-title-template
   "${title}\n#+filetags: :article:${tags keywords}\n#+author: ${author}\n")
  :config
  (citar-org-roam-mode 1)
  :after (citar org-roam)
  :ensure t)
                                        ; communication
(use-package notmuch
  :bind (:map global-map
              ("C-x m" . notmuch)
              ("C-x C-m" . notmuch-mua-new-mail))
  :ensure (:pre-build
           (("make" "IS_GIT=no" "emacs/notmuch-version.el"))
           :version
           (lambda (_) (require 'notmuch-version)
             notmuch-emacs-version)))

(use-package ol-notmuch
  :ensure t)
                                        ; documentation
(use-package man
  :custom
  (Man-switches "-a")
  :ensure nil)
                                        ; TRAMP
(use-package tramp
  :config
  (add-to-list 'completion-category-overrides
               '((file (styles . (basic partial-completion)))))
  (add-to-list 'tramp-remote-path "~/.local/bin")
  :ensure nil)
