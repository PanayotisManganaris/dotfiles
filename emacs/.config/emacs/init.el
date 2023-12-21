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
  :init
  (column-number-mode 1)
  (setq-default indent-tabs-mode nil)
  :custom
  (visible-bell t)
  (inhibit-startup-screen t))
					; user interface
(use-package markdown-mode
  :ensure t)

(use-package mermaid-mode
  :config
  (add-to-list 'auto-mode-alist
	       '("\\.\\(mermaid\\|mmd\\)$" . mermaid-mode))
  :ensure t)

(use-package python)
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
	      ("C-c e" . macrostep-expand)))

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
  :after (tempel)
  :config
  (defun tempel--region ()
    "Return region bounds."
    (when (use-region-p)
      (when (< (mark) (point)) (exchange-point-and-mark))
      ;; (deactivate-mark)
      (cons (point-marker) (mark-marker))))

  (tempel-key "(" parenthesis-pair-maybe)
  (tempel-key "[" bracket-pair-maybe)
  (tempel-key "{" brace-pair-maybe)
  (tempel-key "<" abracket-pair-maybe)
  (tempel-key "\"" qquote-pair-maybe)
  (tempel-key "'" quote-pair-maybe)
  :bind (:map global-map
              ("C-S-d" . backward-delete-char-untabify)
              ("C-%" . replace-regexp)
	      ("C-z" . nil)
	      ("C-x C-z" . nil)))
					; tree-sitter
(use-package combobulate
  :hook ((python-ts-mode . combobulate-mode))
  :load-path "~/src/combobulate"
  :after treesit)

(use-package treesit
  :init
  (setq treesit-language-source-alist
	'((python "https://github.com/tree-sitter/tree-sitter-python")
	  (elisp "https://github.com/Wilfred/tree-sitter-elisp")))
  :bind (:map global-map
	      ("C-c t i" . treesit-inspect-mode)
	      ("C-c t t" . treesit-explore-mode)))
					; failure recovery
(use-package recentf
  :init
  (recentf-mode 1))

(use-package emacs
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
        explicit-shell-file-name shell-file-name))
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
              ("C-j" . vertico-insert)))

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
                                    corfu-auto nil))))

(use-package cape
  :ensure t
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
  (setq cape-dict-file "/usr/share/dict/usa"))

(use-package eglot
  :hook ((python-base-mode . eglot-ensure))
  :config
  ;; configure to increase performance OR reliability of completions
  (setq-default eglot-workspace-configuration
		'((haskell (maxCompletions . 200))))
  ;; NOTICE: this can and SHOULD be configured per project directory
  :init
  (add-to-list 'completion-category-overrides
	       '(eglot (styles . (orderless)))))
					; autotyping
(use-package abbrev
  :custom
  (save-abbrevs 'silently)
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
  :config
  (defun tempel--eval (form)
    "Eval arbitrary forms in templates. The form should return a valid
tempel element."
    (eval form))
  (add-to-list 'tempel-user-elements #'tempel--eval)
  :bind ((:map global-map
               ("C-c y" . tempel-insert))
         (:map tempel-map
               ("M-}" . tempel-next)
               ("M-{" . tempel-previous))))
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
              ([remap isearch-forward] . phi-search)
              ([remap isearch-backward] . phi-search-backward)))

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
  :bind ("C-x g" . magit-status))
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
  (org-cycle-include-plain-lists nil))

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename (concat org-directory "/zettles/")))
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
	       ("C-c n l" . org-roam-buffer-toggle)
	       ("C-c n c" . org-roam-extract-subtree))))

(use-package org-roam-ui
  :after org-roam
  :custom
  (org-roam-ui-sync-theme t)
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
     (ditaa . t)
     (mermaid . t)
     (shell . t)))

  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images))

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
  :bind (:map global-map
	      ("C-c l" . org-store-link)))

(use-package ol-man)

(use-package org-download
  :ensure t
  :config
  (setq org-image-actual-width '(800))
  (setq org-download-display-inline-images nil
	org-download-screenshot-method "flameshot gui --raw > %s"))

(use-package org-agenda
  :after (org-roam)
  :custom
  (org-agenda-files (list org-roam-directory))
  :bind ((:map org-mode-map
	       ("C-'" . nil)
	       ("C-," . nil))
	 (:map global-map
               ("C-c a" . org-agenda))))
					; org-mode and tex
(use-package latex)

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
  :custom
  (org-format-latex-options
   (plist-put org-format-latex-options :scale 2.5))
  (org-preview-latex-default-process 'imagemagick))

(use-package ox-latex
  :config
  (defun seed-random-generator (_)
    (random (buffer-name)))
  (add-hook 'org-export-before-processing-hook #'seed-random-generator)
  :custom
  (org-latex-pdf-process
   (list
    "latexmk -f -pdf -%latex -bibtex -interaction=nonstopmode -shell-escape -output-directory=%o %f"))
  (org-latex-src-block-backend 'engraved)
  (org-export-dispatch-use-expert-ui t))
					; reference management
(use-package oc
  :custom
  (org-cite-global-bibliography
   (list (file-truename (concat org-directory "/lib.bib"))))
  :after org)

(use-package citar
  :ensure t
  :custom
  (citar-bibliography org-cite-global-bibliography)
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :after oc)
                                        ; communication
(use-package notmuch
  :bind (:map global-map
              ("C-x m" . notmuch)
              ("C-x C-m" . notmuch-mua-new-mail))
  :ensure t)

(use-package ol-notmuch
  :ensure t)
                                        ; documentation
(use-package man
  :custom
  (Man-switches "-a"))
					; TRAMP
(use-package tramp
  :init
  (add-to-list 'completion-category-overrides
	       '((file (styles . (basic partial-completion)))))
  (add-to-list 'tramp-remote-path "~/.local/bin"))
