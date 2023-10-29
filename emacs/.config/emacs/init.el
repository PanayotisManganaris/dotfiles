;; -*- lexical-binding: t; -*-
					; supplementary files
(setq custom-file (concat user-emacs-directory "custom.el"))
(unless (load custom-file)
  (write-region "" nil custom-file))

(setq alias-file (concat user-emacs-directory "alias.el"))
(unless (load alias-file)
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
(use-package emacs
  :config
  (setq skeleton-pair t)
  :bind (:map global-map
              (("C-S-d" . backward-delete-char-untabify)
               ("C-%" . replace-regexp)
               ("(" . skeleton-pair-insert-maybe)
               ("[" . skeleton-pair-insert-maybe)
               ("{" . skeleton-pair-insert-maybe)
               ("\"" . skeleton-pair-insert-maybe))))

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
              (("C-M-s-f" . windmove-swap-states-right)
               ("C-M-s-p" . windmove-swap-states-up)
               ("C-M-s-b" . windmove-swap-states-left)
               ("C-M-s-n" . windmove-swap-states-down)
               ("C-s-f" . windmove-right)
               ("C-s-p" . windmove-up)
               ("C-s-b" . windmove-left)
               ("C-s-n" . windmove-down))))
					; completion framework
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  (setq vertico-scroll-margin 0
        vertico-count 20
        vertico-resize nil)
  :custom
  (vertico-cycle t)
  :bind (:map vertico-map
	      ;; minibuffer local
              (("C-n" . vertico-next)
               ("C-p" . vertico-previous)
               ("M-w" . vertico-save)
               ("M-<" . vertico-first)
               ("M->" . vertico-last)
               ("M-{" . vertico-previous-group)
               ("M-}" . vertico-next-group)
               ("TAB" . vertico-insert)
               ("RET" . vertico-exit)
               ("M-RET" . vertico-exit-input))))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;; For tramp:
        completion-category-overrides '((file (styles basic partial-completion))))
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode)
  :bind (:map minibuffer-local-map
              (("M-a" . marginalia-cycle))))

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
  (unbind-key "RET" corfu-map)
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
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  :config
  (setq cape-dabbrev-check-other-buffers nil))

(use-package abbrev
  :config
  (abbrev-mode t)
  (setq save-abbrevs 'silently))

(use-package eglot)
					; spell checking
(use-package jinx
  ;; use libenchant to talk to hunspell
  :ensure t
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(use-package flyspell-correct
  ;; avoid cursor slowdown
  :after flyspell
  :config
  (unbind-key "C-;" flyspell-mode-map)
  :bind (:map flyspell-mode-map
              (("C-,"   . flyspell-auto-correct-word)
               ("C-."   . flyspell-goto-next-error)
               ("C-M-;" . flyspell-buffer)
               ("C-M-i" . nil))))
					; interactive command framework
(use-package consult
  :ensure t
  :init
  (defun pm/make-case-sensitive (orig-fun &rest args)
    (let ((case-fold-search nil))
      (apply orig-fun args)))

  (advice-add 'consult-grep :around #'make-case-sensitive)
  :bind (:map global-map
              ("C-s" . consult-line)
	      ("M-s g" . consult-grep)
              ("M-s G" . consult-git-grep)
              ("M-s r" . consult-ripgrep)))

(use-package multiple-cursors
  :ensure t
  :bind
  ("C-S-c C-S-c" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C-<" . mc/mark-all-like-this)
  ("C-S-<mouse-1>" . mc/add-cursor-on-click))

(use-package avy
  :ensure t
  :bind ("C-S-s" . avy-goto-char-2))

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
              (("C-x C-b" . bufler)
               ("C-x b" . bufler-switch-buffer))))

(use-package project)
					; source control
(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))
