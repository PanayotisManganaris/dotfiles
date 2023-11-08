;; -*- lexical-binding: t; -*-
					; supplementary files
(setq custom-file (concat user-emacs-directory "custom.el"))
(unless (load custom-file t)
  (write-region "" nil custom-file))

(setq alias-file (concat user-emacs-directory "alias.el"))
(unless (load alias-file t)
  (write-region "" nil alias-file))
					; package repositories and use-package macro
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))
					; user experience
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-dark+ t))

(use-package emacs
  :config
  ;; (setq scroll-conservatively 5)
  (column-number-mode 1)
  (setq visible-bell t)
  (setq inhibit-startup-screen t))
					; user interface
(use-package popper
  :ensure t
  :config
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Org Select\\*"
          "\\*Backtrace\\*"
          "\\*ob-ipython-out\\*"
          "\\*ob-ipython-traceback\\*"
          "\\*Async Shell Command\\*"
          "\\*Python\\*"
          "shell\\*$"
          help-mode
          compilation-mode))
  (popper-mode 1)
  (popper-echo-mode 1)
  :bind  (("C-`" . popper-toggle-latest)
	  ("M-`" . popper-cycle)
	  ("M-~" . popper-toggle-type)))

(use-package calc
  :bind ("M-#" . calc-dispatch))

(use-package ediff
  :config
  (setq ediff-make-buffers-readonly-at-startup nil)
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package wgrep
  :ensure t)

(use-package unkillable-scratch
  :ensure t
  :config
  (unkillable-scratch t))

(use-package ws-butler
  :ensure t
  :config
  (ws-butler-global-mode 1))

(use-package emacs
  :config
  (setq skeleton-pair t)
  :bind (:map global-map
              ("C-S-d" . backward-delete-char-untabify)
              ("C-%" . replace-regexp)
              ("(" . skeleton-pair-insert-maybe)
              ("[" . skeleton-pair-insert-maybe)
              ("{" . skeleton-pair-insert-maybe)
              ("\"" . skeleton-pair-insert-maybe)))

(global-set-key (kbd "C-z") 'ignore)
(global-set-key (kbd "C-x C-z") 'ignore)
					; failure recovery
(use-package recentf
  :init
  (recentf-mode 1))

(use-package emacs
  :config
  (if (not (daemonp))
      (desktop-save-mode 1)
    (defun restore-desktop (frame)
      "Restores desktop and cancels hook after first frame opens.
     So the daemon can run at startup and it'll still work"
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
        auto-save-interval 200))
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
              ("C-s-n" . windmove-down)))
					; completion framework
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-resize nil)
  (vertico-cycle t)
  :bind (:map vertico-map
	      ;; minibuffer local
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous)
              ("M-w" . vertico-save)
              ("M-<" . vertico-first)
              ("M->" . vertico-last)
              ("M-{" . vertico-previous-group)
              ("M-}" . vertico-next-group)
              ("TAB" . nil)
              ("C-j" . vertico-insert)
              ("RET" . vertico-exit)
              ("M-RET" . vertico-exit-input)))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil)
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1)
  :custom
  (marginalia-align 'right)
  (marginalia-align-offset -5)
  :bind (:map minibuffer-local-map
              ("M-a" . marginalia-cycle)))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode 1)
  :config
  (setq corfu-auto t
        corfu-auto-prefix 2
        corfu-quit-at-boundary t
        corfu-auto-delay 0
        corfu-cycle t
        corfu-preselect-first nil)
  :bind (:map corfu-map
	      ("M-a" . corfu-reset)
              ("C-j" . corfu-complete)
              ("RET" . nil))
  :hook (shell-mode . (lambda ()
                        (setq-local corfu-quit-at-boundary t
                                    corfu-quit-no-match t
                                    corfu-auto nil))))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-abbrev)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-dict)
  (add-to-list 'completion-category-overrides
	       '((cape-dict (styles . (basic)))))
  ;; doesn't work?
  (add-to-list 'completion-at-point-functions #'cape-file)
  :config
  (setq cape-dabbrev-check-other-buffers nil)
  (setq cape-dict-file "/usr/share/dict/usa"))

(use-package eglot
  :config
  ;; configure to increase performance OR reliability of completions
  (setq-default eglot-workspace-configuration
		'((haskell (maxCompletions . 200))))
  ;; NOTICE: this can and SHOULD be configured per project directory
  :init
  (add-to-list 'completion-category-overrides
	       '(eglot (styles . (orderless)))))
					; snippets and templates
(use-package abbrev
  :init
  (setq save-abbrevs 'silently
	abbrev-suggest t)
  :config
  (abbrev-mode 1)
  :bind (("C-x a r" . expand-region-abbrevs)
	 ("C-x a a" . list-abbrevs)
	 ("C-x a w" . edit-abbrevs)
	 ("C-x a u" . unexpand-abbrev)))

(use-package tempel
  :ensure t
  :init
  (setq tempel-path (file-name-concat user-emacs-directory
				      "templates/*.eld"))
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
  :bind ((:map global-map
               ("C-c y" . tempel-insert))
         (:map tempel-map
               ("M-}" . tempel-next)
               ("M-{" . tempel-previous))))

(use-package tempel-collection
  :ensure t
  :after tempel)
					; spell checking
(use-package jinx
  :ensure t
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-,"   . jinx-previous)
         ("C-."   . jinx-next)
         ("C-M-$" . jinx-languages)))
					; interactive command framework
(use-package consult
  :ensure t
  :init
  (setq consult-dir-shadow-filenames nil
	register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)

  :bind ((:map global-map
	       ("C-x b" . consult-buffer)
	       ("C-x C-d" . consult-dir)
               ("M-y" . consult-yank-pop)
	       ("C-x R" . consult-register-store)
	       ("C-x r l" . consult-register)
	       ;; bookmarks listed in consult-buffer
               ("M-s l" . consult-line)
               ("M-s L" . consult-line-multi)
               ("M-s G" . consult-git-grep)
               ("M-s r" . consult-ripgrep)
               ("M-s d" . consult-find)
               ("M-g i" . consult-imenu)
               ("M-g I" . consult-imenu-multi)
               ("M-g m" . consult-mark)
               ("M-g M" . consult-global-mark)
               ("M-g e" . consult-compile-error)
               ("C-c k" . consult-kmacro)
               ("C-c m" . consult-minor-mode-menu)
	       ("C-x p b" . consult-project-buffer))
	 (:map vertico-map
	       ("C-x C-d" . consult-dir)
	       ("M-s" . consult-history))))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  ;; :demand t
  ;; :hook
  ;; (embark-collect-mode . consult-preview-at-point-mode)
  :bind (:map embark-collect-mode-map
	      ("C-j" . #'consult-preview-at-point)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)
	 ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package phi-search
  :ensure t
  :bind (:map mc/keymap
              ("C-s" . phi-search)
              ("C-r" . phi-search-backward)))

(use-package avy
  :ensure t
  :bind ("M-j" . avy-goto-char-2))

(use-package bufler
  :ensure t
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
              ("C-x b" . bufler-switch-buffer)))

(use-package project)
					; source control
(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))
					; contextual action framework
(use-package embark
  :ensure t
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind (:map global-map
	      ("C-;" . embark-act)
              ("M-." . embark-dwim)
              ("C-h B" . embark-bindings)
              ("C-:" . embark-act-all)
              ("C-(" . embark-collect-snapshot)))
					; directory edit
(use-package dired
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
              ("C-c C-e" . wdired-change-to-wdired-mode)))
					; direnv
(use-package direnv
  :ensure t
  :config
  (direnv-mode 1))
					; org-mode notes
(use-package org
  :init
  (setq org-directory (concat (getenv "HOME") "/org"))
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
              ("M-}" . org-forward-element)))

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename (concat org-directory "/zettles/")))
  :config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol)
  :bind ((:map global-map
               ("C-c n f" . org-roam-node-find)
	       ("C-c n g" . org-roam-ui-mode)
	       ("C-c n r" . org-roam-node-random))
         (:map org-mode-map
	       ("C-c n i" . org-roam-node-insert)
	       ("C-c n o" . org-id-get-create)
	       ("C-c n t" . org-roam-tag-add)
	       ("C-c n a" . org-roam-alias-add)
	       ("C-c n l" . org-roam-buffer-toggle)
	       ("C-c n c" . org-roam-extract-subtree))))

(use-package ol
  :init
  (dolist (scheme '((org-web-link "blue violet" "color web links")
		    (org-file-link "lime green" "color file links")
		    (org-info-link "dark turquoise" "color texinfo links")))
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
  (org-link-set-parameters "info" :face 'org-info-link)
  :bind (:map global-map
	      ("C-c l" . org-store-link)))

(use-package org-download
  :ensure t
  :config
  (setq org-image-actual-width '(800))
  (setq org-download-display-inline-images nil
	org-download-screenshot-method "flameshot gui --raw > %s"))

					; TRAMP
(use-package tramp
  :init
  (add-to-list 'completion-category-overrides
	       '((file (styles . (basic partial-completion)))))
  (add-to-list 'tramp-remote-path "~/.local/bin"))
