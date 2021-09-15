(load-theme 'doom-dark+ t)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(setq inhibit-startup-screen t)

(require 'package)
     (add-to-list 'package-archives
		  '("melpa" . "https://melpa.org/packages/") t)
     (package-initialize)
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

;; (desktop-save-mode 1) ;; recover frame between sessions -- OBSOLETE, save/load perspectives instead
(winner-mode 1) 
(setq backup-directory-alist '(("." . "~/.local/share/emacs/saves/")))
(setq backup-by-copying t ;; backup by copying to preserve symlinked files and creation times
      version-control t ;; number versions unconditionally
      delete-old-versions t
      kept-new-versions 6 ;; keep 6 versions from the current session
      kept-old-versions 2) ;; keep 2 versions from past sessions
(setq auto-save-default t ;; auto save every buffer that visits a file
      auto-save-timeout 60 ;; default autosave on 30 second idle
      auto-save-interval 200) ;; default autosave every 300 keystrokes

(load "~/.config/emacs/my-alias.el") ;; load aliases making some commands into other commands, or shortcuts
(setq-default abbrev-mode t) ;; universally expand abbreviations and make new ones dynamically
(setq save-abbrevs 'silently)
;; (setq auto-mode-alist
;;       (append
;;        (list '("\\.\\(vcf\\|gpg\\)$" . sensitive-minor-mode))
;;        auto-mode-alist))

(use-package dired
  :init
  (setq dired-auto-revert-buffer t)  ;; don't prompt to revert; just do it
  (setq dired-dwim-target t)  ;; suggest a target for moving/copying intelligently
  (setq dired-hide-details-hide-symlink-targets nil)
;; Always copy/delete recursively
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'top)
;; Where to store image caches
;;        image-dired-dir (concat doom-cache-dir "image-dired/")
;;        image-dired-db-file (concat image-dired-dir "db.el")
;;        image-dired-gallery-dir (concat image-dired-dir "gallery/")
;;        image-dired-temp-image-file (concat image-dired-dir "temp-image")
;;        image-dired-temp-rotate-image-file (concat image-dired-dir "temp-rotate-image")
;; Screens are larger nowadays, we can afford slightly larger thumbnails
;;        image-dired-thumb-size 150)
  :config
  ;; cool thumbnails
;;  (set-popup-rule! "^\\*image-dired"
;;    :slot 20 :size 0.8 :select t :quit nil :ttl 0)
;;  (set-evil-initial-state! 'image-dired-display-image-mode 'emacs)
  (let ((args (list "-ahl" "-v" "--group-directories-first"))))
;;dealing with extenuating circumstances in remote sessions
;;    (add-hook! 'dired-mode-hook 
;;      (defun pm/dired-disable-gnu-ls-flags-in-tramp-buffers-h ()
;;        "Fix #1703: dired over TRAMP displays a blank screen.
;;
;;This is because there's no guarantee the remote system has GNU ls, which is the
;;only variant that supports --group-directories-first."
;;        (when (file-remote-p default-directory)
;;          (setq-local dired-actual-switches (car args))))))

  ;; Don't complain about this command being disabled
;;  (put 'dired-find-alternate-file 'disabled nil)
  :bind (:map dired-mode-map
	      (("C-c C-e" . wdired-change-to-wdired-mode)))) ;; To be consistent with ivy and wgrep integration

(use-package company
  :ensure t
  :config
  (global-company-mode))

(defun pm/org-babel-tangle-config ()
  (when (equal (buffer-file-name)
	       (expand-file-name "~/.config/emacs/litinit.org"))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'pm/org-babel-tangle-config)))

(use-package org
  :ensure t
  :config
  (setq org-ellipsis " [+]") ;; Custom fold indicator because I often use ellipses and it's confusing
  (custom-set-faces '(org-ellipsis ((t (:foreground "gray40" :underline nil))))) ;; using custom -- consider editing theme?
  (setq org-directory (concat (getenv "HOME") "/org"))
  (setq org-use-fast-todo-selection 'auto) ;; present keyword hotkeys to user if available
  (setq org-treat-S-cursor-todo-selection-as-state-change nil) ;; cycle keywords without state logging using S-left\right
  (setq org-todo-keywords ;; set to timestamp deliberate state changes
	'((sequence "TODO(t)"
		    "NEXT(n!)"
		    "WAIT(w@/!)"      
		    "|"	          
		    "DONE(d!)"        
		    "INACTIVE(i@)"    
		    "CANCELED(q@/@)") 	                                   
	  (sequence "JOURNAL(j!)"     
		    "CONTACT(c!)"     
		    "MEETING(m!)"     
		    "|")))
  ;;        (sequence "REPORT" "BUG" "KNOWNCAUSE" "|" "FIXED"))) ;; development task labels
  (setq org-todo-keyword-faces
	(quote (("TODO" :foreground "blue" :weight bold)
		("NEXT" :foreground "red" :weight bold)
		("WAIT" :foreground "orange" :weight bold)
		("DONE" :foreground "forest green" :weight bold)
		("INACTIVE" :foreground "magenta" :weight bold)
		("CANCELED" :foreground "forest green" :weight bold)
		("JOURNAL" :foreground "white" :weight bold)
		("CONTACT" :foreground "white" :weight bold)
		("MEETING" :foreground "white" :weight bold))))
  (setq org-enforce-todo-dependencies t)
  (setq org-agenda-dim-blocked-tasks t) ;; try this on for size -- only effects agenda view
  (setq org-log-into-drawer "STATUSLOG") ;; hide state change history in drawer under headlines
  (setq org-priority-default 3) ;; strictly options for sorting the agenda
  (setq org-priority-highest 1)
  (setq org-priority-lowest 5)

(setq org-default-notes-file (concat org-directory "/refile.org")) ;; org-capture file -- compiles capture entries (all entries tagged :refile)     
;; default cabinets for refiling outstanding captures + organized sources populating org-agenda.
(setq org-cabinets (list (concat org-directory "/logbook.org") ;; datetree chronicling clocktime, timestamped captures, with journal entries
			 (concat org-directory "/research.org") ;; my research, school, and study -- to be populated explicitly by capturing
			 (concat org-directory "/addressbook.org"))) ;; CRM file. Network contacts by linking manually (so it sticks), use roam

;; org-agenda
(setq org-agenda-files (cons org-default-notes-file org-cabinets)) ;; populate agenda from cabinets + refile.org
(setq org-agenda-skip-scheduled-if-deadline-is-shown t) ;; show only deadline on or after day deadlining task is scheduled
(setq org-agenda-span 'week) ;; show week view by default
(setq org-agenda-start-day "-0d") ;; start at today by default (in org-read-date input form)
(setq org-agenda-start-on-weekday nil) ;; weekly overview starts today and looks forward, leave the past be.
;; tags/TODO filters (see tag and property searches) for agenda organization:
(setq org-stuck-projects 
      '("+LEVEL=1+TODO/-DONE-CANCELED-INACTIVE-NEXT" ("NEXT")))
;; Use the current window for indirect buffer display
(setq org-indirect-buffer-display 'current-window)

(setq org-columns-default-format
      "%TODO %2PRIORITY %25ITEM(Task) %10Effort(Est_Effort){est+} %CLOCKSUM %CLOCKSUM_T")
(org-clock-persistence-insinuate) ;; set up hooks for clock persistence through sessions
(setq org-clock-persist t) ;; continue any running clock when emacs exits. Also save all set clock history accross sessions.
(setq org-clock-idle-time 10) ;; and prompt to resolve running clocks when restarting, or after 10 minutes of emacs idle time.

(setq org-capture-templates
      (quote (("p" "project outlining and reporting") ;; new project definitions and reports on predefined projects
	      ("pt" "todo" entry (file "~/org/refile.org") ;; a new task needing to be defined and inserted into ongoing project
	       "* TODO %?\n%U\n%a\n")
	      ("ps" "todo" entry (file "~/org/refile.org") ;; schedule a new event.
	       "* TODO %?\n%^T")
	      ;; template current time, link in ring (or current file), capture new task name, pause other clocks, clock time, resume other clocks
	      ;; ex :: good for a job in any given piece of code because it links to the line that inspired it.
	      ;;		("pr" "reflect" entry (file "~/org/refile.org")
	      ;;		 "* JOURNAL")
	      ;; OR
	      ;;		("n" "note" entry (file "~/org/refile.org")
	      ;;               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
	      ;; not sure what this looks like yet. On-the-clock thoughts about current work (look at %k), look at organizing by :tag
	      ("i" "interruptions")
	      ("ir" "respond" entry (file "~/org/refile.org")
	       "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
	      ;; fully automated reaction cache for differed inquiries, requests, solicitations, etc.
	      ("ii" "idea" entry (file "~/org/refile.org")
	       "* INACTIVE")
	      ;; for academic questions, topics of investigation, project proposals, paper subject.
	      ;;		("w" "org-protocol" entry (file "~/org/refile.org")
	      ;;		 "* TODO Review %c\n%U\n" :immediate-finish t)
	      ;; tracking org workflow and planning adaptations TAG = :ENV?
	      ("m" "Meeting" entry (file "~/org/refile.org")
	       "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
	      ;; documenting essentials of scheduled and spontaneous meetings/encounters.
	      ("c" "CONTACT" entry (file "~/org/refile.org") ;; document professional contact
	       "* CONTACT"))))
(defun pm/remove-empty-drawer-on-clock-out ()
  "Remove empty STATUSLOG drawers on clock out, use as hook to de-clutter ephemeral captures"
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at "STATUSLOG" (point))))
(add-hook 'org-clock-out-hook 'pm/remove-empty-drawer-on-clock-out 'append)

;; refile targets include any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets '((org-agenda-files :maxlevel . 9)))
;; Use full outline paths for refile targets - file directly into agenda position using Ivy
(setq org-refile-use-outline-path t)
;; Targets complete directly with Ivy, org need not assist
(setq org-outline-path-complete-in-steps nil)
;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes 'confirm)
(defun pm/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
(not (member (nth 4 (org-heading-components)) org-done-keywords)))
(setq org-refile-target-verify-function 'pm/verify-refile-target)

(setq org-id-link-to-org-use-id t) ;; always make unique id for attachments

(add-to-list 'org-babel-load-languages '(python . t))
(setq org-confirm-babel-evaluate nil)

(setq org-latex-pdf-process (list "latexmk -pdflatex='lualatex -shell-escape -interaction nonstopmode' -pdf -f %f"))
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

:bind (("C-c l" . org-store-link) ;; global organization bindings
       ("C-c a" . org-agenda) 
       ("C-c c" . org-capture)))

(use-package org-tempo ;; builtin
  :config
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  :bind (:map org-mode-map (("C-c C-," . org-insert-structure-template))))

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t) ;; Acknowledge no return to v1
  :custom
  ;; roam database for focused zettlekasten
  (org-roam-directory (file-truename (concat org-directory "/zettles")))
  :bind (("C-c n f" . org-roam-node-find)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n r" . org-roam-node-random)		    
	 (:map org-mode-map
	       (("C-c n i" . org-roam-node-insert)
		("C-c n o" . org-id-get-create)
		("C-c n t" . org-roam-tag-add)
		("C-c n a" . org-roam-alias-add)
		("C-c n l" . org-roam-buffer-toggle))))
  :config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(use-package org-download
  :ensure t
  :config
  (setq org-download-screenshot-method "flameshot gui --raw > %s"))

(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  :bind (:map ivy-minibuffer-map
	      ("TAB" . ivy-partial)))
(use-package ivy-yasnippet
  :ensure t
  :bind ("C-c y" . ivy-yasnippet)) ;; look into refining this and ensure consistency with bind logic

(use-package yasnippet ;; extensible codeblock insertion utility
  :ensure t
  :config
  (yas-minor-mode 1))
(use-package wucuo ;; use hunspell spell checker
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'wucuo-start)
  (add-hook 'text-mode-hook 'wucuo-start))
;;(use-package undo-fu (define-key undo-fu-mode-map (kbd "C-?") #'undo-fu-only-redo))

(setq bindlist '((windmove-swap-states-right "C-M-s-f" "C-M-s-<right>")
		 (windmove-swap-states-up "C-M-s-p" "C-M-s-<up>")
		 (windmove-swap-states-left "C-M-s-b" "C-M-s-<left>")
		 (windmove-swap-states-down "C-M-s-n" "C-M-s-<down>")
		 (windmove-right "C-s-f" "C-s-<right>")
		 (windmove-up "C-s-p" "C-s-<up>")
		 (windmove-left "C-s-b" "C-s-<left>")
		 (windmove-down "C-s-n" "C-s-<down>")
		 ;;                 (spell-fu-goto-next-error "C-,")
		 ;;                 (+spell/correct "C-.")
		 (backward-delete-char-untabify "C-S-d")))

(dolist (bind-to bindlist)
  (let ((keys (cdr bind-to)))
    (dolist (key keys)
      (define-key (current-global-map) (kbd key) (car bind-to)))))

;; minimize window just freezes it in dwm -- not nice
;;(unbind-key "C-z")
;;(unbind-key "C-x C-z")

(use-package pdf-tools
  :ensure t) ;;seems to take care of turning itself on

(use-package perspective
  :ensure t
  :init
  (persp-mode)  
  (setq persp-initial-frame-name 'Prime)
  :config
  (add-hook 'after-init-hook (lambda () (persp-state-load "~/.config/emacs/perspectives/Agenda"))) ;; load todos, switch to agenda perspective on startup
  (add-hook 'persp-state-after-load-hook (lambda () (when (equal (persp-current-name) "Agenda")
						      (org-agenda-list)))) ;; show todos by opening Agenda
  (require 'ibuffer)
  :bind (("C-x C-b" . persp-ibuffer) ;; this doesn't seem to be working nicely, shows too much
	 ("C-x b" . persp-ivy-switch-buffer)
	 ("C-x k" . persp-kill-buffer*)))

(use-package which-key
  :init
  (setq which-key-sort-order #'which-key-key-order-alpha
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10)
  :config
  ;; general improvements to which-key readability
  (which-key-setup-side-window-bottom)
  (which-key-mode 1))

(defun python-setup ()
  "Sets company backends"
  (interactive)
  ;; (setq company-backends '(company-matlab-shell))
  (company-mode 1))

(use-package python
  :ensure t
  :config
  (add-hook 'python-mode-hook 'python-setup))

(use-package conda
  :ensure t
  :config
  (setq conda-env-home-directory "/opt/miniconda3") ;;conda is root...
  ;;get current environment--from environment variable CONDA_DEFAULT_ENV
  (setq conda-anaconda-home "/opt/miniconda3")
  ;; (conda-env-activate (getenv "CONDA_DEFAULT_ENV")) ;; default to (base) or whetever is set
  (conda-env-autoactivate-mode t) ;;useful for python projects
  (conda-env-initialize-interactive-shells)
  (setq-default mode-line-format (cons '(:exec conda-env-current-name) mode-line-format))
  ;;  (setq eshell-prompt-function ;; customizes the eshell prompt -- here because it includes the env
  ;;        (lambda ()
  ;;          (concat conda-env-current-name
  ;;                  (getenv "USER") "@"
  ;;                  (car (split-string (getenv "HOSTNAME") "[.]"))
  ;;                  (if (= (user-uid) 0) " # " " $ ")))))
  )

;; org agenda and calendar customization and automation
;;(defun my-open-calendar ()
;;  (interactive)
;;  (cfw:open-calendar-buffer
;;   :contents-sources
;;   (list
;;    (cfw:org-create-source "Green")  ; org-agenda source
;;    (cfw:org-create-file-source "cal" "/path/to/cal.org" "Cyan")  ; other org source
;;    (cfw:howm-create-source "Blue")  ; howm source
;;    (cfw:cal-create-source "Orange") ; diary source
;;    (cfw:ical-create-source "Moon" "~/moon.ics" "Gray")  ; ICS source1
;;    (cfw:ical-create-source "gcal" "https://..../basic.ics" "IndianRed") ; google calendar ICS
;;   )))

(defun smb-2-dee ()
  "smb remote connection to Uc's ceas1 domain clusterfsnew server"
  (interactive)
  (find-file "/smb:manganpt%ceas1@clusterfsnew.ceas1.uc.edu:/DEE/"))

(defun copy-file-to-tmp (file)
  "delegate for dired-open-remote-tmpfile"
  (copy-file file "/tmp/" 1)
  (let* ((extension (file-name-extension file))
	 (base (file-name-base file)))
    (format "/tmp/%s.%s" base extension)))

(defun dired-open-remote-tmpfile (localprog)
  "copies file in remote dired to local tmp, opens with local program, and returns modified file to remote dired"
  (interactive "sLocal Program Name: ")
  (let* ((remote-file (dired-filename-at-point))
	 (tmpfile (copy-file-to-tmp remote-file)))
    (async-start-process localprog
			 localprog
			 (lambda (process-obj)
			   "move tmpfile back to remote directory"
			   (copy-file tmpfile remote-file 1))
			 tmpfile)))

(fset 'pm/org-clone-3d-subtree-with-1w-timeshift
      (kmacro-lambda-form [?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p] 0 "%d"))
(fset 'pm/org-clone-2d-subtree-with-1w-timeshift
      (kmacro-lambda-form [?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down ?\C-c ?\C-p] 0 "%d"))
