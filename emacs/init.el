(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("1d5e33500bc9548f800f9e248b57d1b2a9ecde79cb40c0b1398dec51ee820daf" default))
 '(package-selected-packages
   '(rainbow-mode company conda ivy-yasnippet which-key use-package org-roam wucuo ivy doom-themes pdf-tools sudo-edit yasnippet-snippets yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-ellipsis ((t (:foreground "gray40" :underline nil)))))

;; aesthetic:
(load-theme 'doom-dark+ t)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)

;; built-in utilities
(desktop-save-mode 1)
(winner-mode 1)
(setq backup-directory-alist
      '(("." . "~/.local/share/emacs/saves/")))
;;adjust frequency and history of backups next
(setq-default abbrev-mode t)
(setq save-abbrevs 'silently)

;; Interface with External Packages
;; package management
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure Use-Package: Enable init portability and enable concise configuration
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

;; Additional packages and their configurations:
;; modes:
;; all purpose backend for on-the-fly code and text completion
(use-package company
  :ensure t
  :config
  (global-company-mode))

;; org-mode
(use-package org
  :ensure t
  :config
  ;; LaTeX exporter and formula display 
  (setq org-latex-pdf-process (list "latexmk -pdflatex='lualatex -shell-escape -interaction nonstopmode' -pdf -f %f"))
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
  ;; org universal filesystem, keywords, appearance, log triggers and keeping, priority scheme
  (setq org-ellipsis " [+]") ;; Custom fold indicator because I often use ellipses and it's confusing
  (custom-set-faces '(org-ellipsis ((t (:foreground "gray40" :underline nil)))))
  (setq org-directory (concat (getenv "HOME") "/org")) ;; consolidate automated .org files (captures, project categories, logs; contacts, zettles)
  (setq org-use-fast-todo-selection 'auto) ;; present keyword hotkeys to user if available
  (setq org-treat-S-cursor-todo-selection-as-state-change nil) ;; cycle keywords without state logging with S-left\right
  (setq org-todo-keywords ;; set to timestamp deliberate state changes
	;; label scheduled tasks hierarchically
        '((sequence "TODO(t)" ;; any task to appear in the agenda. Any TODO heading with subheadings is a project. 
                    "NEXT(n!)" ;; typically, priority task in an ongoing project -- a project with no NEXT is stuck (log time on)
		    ;; also, catch-all for immediate actions: reply to, forward mail, return phone call, establish meeting, etc
                    "WAIT(w@/!)" ;; any task requiring action from others before proceeding (log note on, time off)
		    "|"
		    "DONE(d!)" ;; any completed task that stands only to be archived (log time on)
                    "INACTIVE(i@)" ;; a project that is not prioritized -- cant be stuck (log note on)
		    "CANCELED(q@/@)") ;; an aborted project that stands only to be archived (log note on, note off)
	  ;; label captures -- for documenting unplanned workaday occurrences as org trees
          (sequence "JOURNAL(j!)" ;; specific notes relevant to ongoing project. Journal entries should end up in reports (log time on)
		    "CONTACT(c!)" ;; add to professional address book and Contact/Customer Relationship Management (CRM) (log time on)
		    "MEETING(m!)" ;; for any and all meetings, specific capture templates optional (log time on)
		    "|")))
  (setq org-todo-keyword-faces
      (quote (("TODO" :foreground "blue" :weight bold) ;;project status setting and tracking words
              ("NEXT" :foreground "red" :weight bold)
	      ("WAIT" :foreground "orange" :weight bold)
	      ("DONE" :foreground "forest green" :weight bold)
              ("INACTIVE" :foreground "magenta" :weight bold)
              ("CANCELED" :foreground "forest green" :weight bold)
	      ("JOURNAL" :foreground "white" :weight bold) ;;capture type and report tagging words
	      ("CONTACT" :foreground "white" :weight bold)
	      ("MEETING" :foreground "white" :weight bold))))
  (setq org-enforce-todo-dependencies t) ;; hierarchically nested todos, so enforces progress with ORDERED property. overrule use NOBLOCKING property.
  (setq org-agenda-dim-blocked-tasks t) ;; try this on for size -- only effects agenda view
  (setq org-log-into-drawer "STATUSLOG") ;; hide state change history in drawer under headlines
  (setq org-priority-default 3) ;; strictly options for sorting the agenda
  (setq org-priority-highest 1)
  (setq org-priority-lowest 5)
  ;; universal properties?
  ;; universal tags? :STUDY:EMAIL:PERSONAL:PURCHASE:GROUP: -> org-tag-alist -- OR do this with category property? leaves tags free for meta-linking
  ;; fast meta-linking with org-tag-persistent-alist + file specific tagging -- OR configure org-complete-tags-always-offer-all-agenda-tags
  ;; tags management by C-c C-q and C-c C-c (fast?)
  ;; org-capture file -- compiles capture entries (all entries tagged :refile)
  (setq org-default-notes-file (concat org-directory "/refile.org"))
  ;; cabinets for refiling outstanding captures + sources populating org-agenda.
  (defcustom org-cabinets
    (list (concat org-directory "/logbook.org") ;; datetree chronicling clocktime, timestamped captures, with journal entries
	  (concat org-directory "/research.org") ;; my research, school, and study -- to be populated explicitly by capturing
	  (concat org-directory "/addressbook.org")) ;; CRM file. Networking contacts is accomplished through linking manually (so it sticks), and roam
    "Simply a single variable for customizing agenda source files and refile targets simultaneously"
    :type '(repeat string))
  ;; include all zettles? -- why not, eh? perhaps to keep tags distinct? Or be more meticulous, and use hierarchies to make tags more orderly+specific w/ regexp?
  ;; to-do items often arise while taking notes, so capturing can deal with that, but having the full context of the emergence is useful.
  ;; I need a system of zettlekasten that can push in-topic todos to the agenda. Even if those todos are just tangents of study to be perused!
  ;; archive file? or archive siblings?
  ;; diary for tabbing anniversaries, holidays, events? or bbdb integration?
  ;; make this init.el literate, and use it as a cabinet for emacs todos
  ;; org-agenda
  (setq org-agenda-files org-cabinets) ;; populate agenda from here
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t) ;; show only deadline on or after day deadlining task is scheduled
  (setq org-agenda-span 'day) ;; show day view by default
  (setq org-agenda-start-day "-0d") ;; show today's view by default (in org-read-date input form)
  (setq org-agenda-start-on-weekday nil) ;; weekly overview starts today and looks forward, leave the past be.
  ;; tags/TODO filters (see tag and property searches) for agenda organization:
  (setq org-stuck-projects 
        '("+LEVEL=1+TODO/-DONE-CANCELED-INACTIVE-NEXT" ("NEXT")))
  ;;  (setq org-tags-match-list-sublevels nil) ;; headings matched by tag/property searches carry don't carry subheadings to the agenda (not-reccommended)
  ;; instead, for getting only top level tasks matched by tag filters, configure tag inheritance or filter if this is a problem
  ;; org column view for rapid assessment of agenda-relevant node properties
  (setq org-columns-default-format ;;column view of task properties set default  -- individual files/headings may define different views
        "%TODO %2PRIORITY %25ITEM(Task) %10Effort(Est_Effort){est+} %CLOCKSUM %CLOCKSUM_T")
  ;; org-capture and refile automation and templates
  (defun pm/remove-empty-drawer-on-clock-out ()
    "Remove empty STATUSLOG drawers on clock out, use as hook to de-clutter ephemeral captures"
    (interactive)
    (save-excursion
      (beginning-of-line 0)
      (org-remove-empty-drawer-at "STATUSLOG" (point))))
  (add-hook 'org-clock-out-hook 'pm/remove-empty-drawer-on-clock-out 'append)
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
  ;; Notes from classes, research, reasoning, etc. are handled in the Zettlekasten method using org-roam, configured later.
  ;; refile targets include any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets '((org-cabinets :maxlevel . 9)))
  ;; Use full outline paths for refile targets - file directly into agenda position using Ivy
  (setq org-refile-use-outline-path t)
  ;; Targets complete directly with Ivy, org need not assist
  (setq org-outline-path-complete-in-steps nil)
  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  ;; Use Ivy for both buffer and file completion
  
  ;; Use the current window for indirect buffer display
  (setq org-indirect-buffer-display 'current-window)

  ;; Refile settings
  ;; Exclude DONE state tasks from refile targets
  (defun pm/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 4 (org-heading-components)) org-done-keywords)))
  (setq org-refile-target-verify-function 'pm/verify-refile-target)
  ;; org-attachment behaviors
  (setq org-id-link-to-org-use-id t) ;; always make unique id for attachments
  ;; org-babel
  (add-to-list 'org-babel-load-languages '(python . t))
  ;; org-mode core project management function bindings
  :bind (("C-c l" . org-store-link)
	 ("C-c a" . org-agenda) 
	 ("C-c c" . org-capture)))

;; configure org-roam
(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t) ;; Acknowledge no return to v1
  :custom
  ;; roam database for topical zettlekasten
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
  ;; If using org-roam-protocol -- find out what this is
  (require 'org-roam-protocol))

;; org-download for online and screencap images in notes
(use-package org-download
  :ensure t)

;; Mini-buffer Completion
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  :bind (:map ivy-minibuffer-map
	       ("TAB" . ivy-partial)))

(use-package ivy-yasnippet
  :ensure t
  :bind ("C-c y" . ivy-yasnippet)) ;; look into refining this and ensure consistency with bind logic
 
;; snippet insertion utilities
(use-package yasnippet
  :ensure t
  :config
  (yas-minor-mode 1))
;; set pdf-tools PDFview as default
(use-package pdf-tools
  :ensure t) ;;seems to take care of turning itself on
;; use hunspell spell checker
(use-package wucuo
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'wucuo-start)
  (add-hook 'text-mode-hook 'wucuo-start))
;;(undo-fu (define-key undo-fu-mode-map (kbd "C-?") #'undo-fu-only-redo))

;; ibuffer for improved buffer management
(use-package ibuffer
  :ensure t
  :bind ("C-x C-b" . ibuffer))

;; Which-Key on-the-fly keymaps navigation
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
  ;;(setq 'which-key-init-buffer-hook line-spacing 3))

;;IDE
;;python mode and package environment controls
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

;; mode keybinds or function aliases go with the relevant config block
;; global keybindings: (define-key is broken?)
;;dolist evaulates bind settings here, multiple keybindings may be defined for every function:
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

;; Cool elisp

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
                         tmpfile))) ;;oneday, get this to use dmenu or make it work with ivy and council linux apps?



;; minimize window just freezes it in dwm -- not nice
;;(unbind-key "C-z")
;;(unbind-key "C-x C-z")
