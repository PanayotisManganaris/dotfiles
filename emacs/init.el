(defun pm/org-babel-tangle-config ()
  (when (equal (buffer-file-name)
	       (expand-file-name "~/.config/emacs/litinit.org"))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'pm/org-babel-tangle-config)))

(load-theme 'doom-dark+ t)
(setq inhibit-startup-screen t)
(setq visible-bell t)

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

(use-package bufler
  :ensure t
  :config
  ;; function for grouping roam buffers
  ;; (defun agenda-buffer-p (buffer)
  ;;   "Return non-nil if BUFFER’s file satisfies ‘org-agenda-file-p’"
  ;;   (org-agenda-file-p (buffer-file-name buffer)))
  ;; (push 'agenda-buffer-p bufler-workspace-switch-buffer-filter-fns)

  ;; this is slow. investigate memoization of these things?
  ;; (bufler-buffer-alist-at nil :filter-fns bufler-workspace-switch-buffer-filter-fns)
  ;; (bufler-buffers :path nil :filter-fns bufler-workspace-switch-buffer-filter-fns)

  ;; if Dir: /home/panos/org and org-mode exist, collapse the section upon bufler open...
  ;; if fast autogrouping can be done, do it...
  ;; (magit-section-toggle (magit-get-section (magit-section-ident)))

  :bind (:map global-map
              (("C-x C-b" . bufler)
               ("C-x b" . bufler-switch-buffer))))

(use-package multiple-cursors
  :bind
  ("C-S-c C-S-c" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C-<" . mc/mark-all-like-this))

(use-package avy
  :ensure t
  :bind ("C-S-s" . avy-goto-char-2))

(use-package swiper
  :ensure t
  :bind (:map global-map
              ("C-s" . swiper)))

(use-package dogears
  :ensure t
  :config
  (dogears-mode 1)
  :bind (:map global-map
              (("M-g d" . dogears-go)
               ("M-g M-b" . dogears-back)
               ("M-g M-f" . dogears-forward)
               ("M-g M-d" . dogears-list)
               ("M-g M-D" . dogears-sidebar))))

(use-package dired
  :init
  (setq dired-listing-switches "-ahl -v --group-directories-first")
  (setq dired-auto-revert-buffer t
        dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'top)
  :config
  (add-hook 'dired-mode-hook 'dired-hide-details-mode)
  ;;dealing with extenuating circumstances in remote sessions
  ;;(defun pm/dired-disable-gnu-ls-flags-in-tramp-buffers ()
  ;;  "For when dired in tramp displays blank screen when remote system
  ;;   does not use GNU ls, which is the only variant that supports
  ;;   --group-directories-first."
  ;;  (when (file-remote-p default-directory)
  ;;    (setq-local dired-actual-switches (car args))))

  ;; Don't complain about this command being disabled
  (put 'dired-find-alternate-file 'disabled nil)
  :bind (:map dired-mode-map
              (("C-c C-e" . wdired-change-to-wdired-mode)))) ;; To be consistent with ivy and wgrep integration

  ;; :init
  ;; Where to store image caches
  ;;        image-dired-dir (concat doom-cache-dir "image-dired/")
  ;;        image-dired-db-file (concat image-dired-dir "db.el")
  ;;        image-dired-gallery-dir (concat image-dired-dir "gallery/")
  ;;        image-dired-temp-image-file (concat image-dired-dir "temp-image")
  ;;        image-dired-temp-rotate-image-file (concat image-dired-dir "temp-rotate-image")
  ;; Screens are larger nowadays, we can afford slightly larger thumbnails
  ;;        image-dired-thumb-size 150)
  ;; :config
  ;; cool thumbnails
  ;;  (set-popup-rule! "^\\*image-dired"
  ;;    :slot 20 :size 0.8 :select t :quit nil :ttl 0)
  ;;  (set-evil-initial-state! 'image-dired-display-image-mode 'emacs)

(use-package gnuplot-mode
  :ensure t)
(use-package gnuplot
  :ensure t)

(use-package calc
  :bind ("M-#" . calc-dispatch))

(use-package company
  :ensure t
  :config
  (global-company-mode))

(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))

(use-package projectile
  :ensure t
  :config
  (require 'subr-x)
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  :bind (:map global-map
              (("C-c p" . projectile-command-map))))

(use-package epa-file
  :config
  (epa-file-enable))

(use-package lsp-mode
  :ensure t)

(use-package org
  :ensure t
  :init (setq org-export-backends '(ascii html icalendar latex odt)) ;; org exports establish prior to loading org.el
  :config
  (setq org-startup-indented t) ;; simplify heirarchies management in org
  (setq org-ellipsis " [+]") ;; Custom fold indicator because I often use ellipses and it's confusing
  (custom-set-faces '(org-ellipsis ((t (:foreground "gray40" :underline nil)))))
  (setq org-use-property-inheritance t) ;; in trees children inherent properties fields from parents
  (setq org-directory (concat (getenv "HOME") "/org"))
  (setq org-use-fast-todo-selection 'auto) ;; present keyword hotkeys to user if available
  (setq org-treat-S-cursor-todo-selection-as-state-change nil) ;; cycle keywords without state logging using S-left\right
  (setq org-todo-keywords ;; set ! to timestamp deliberate state changes
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
                    "|")
          (sequence "ATTEND(a!)" "|" "DONE(d!)" "MISSED(f!)") ;; pure calendar events?
          (sequence "SEQ(s)" "|"))) ;; notebook navigational labels?
  ;;        (sequence "REPORT" "BUG" "KNOWNCAUSE" "|" "FIXED"))) ;; development task labels
  (defun pm/modify-org-done-face ()
    (setq org-fontify-done-headline t)
    (set-face-attribute 'org-done nil :strike-through t)
    (set-face-attribute 'org-headline-done nil
                        :strike-through t
                        :foreground "light gray"))

  (eval-after-load "org"
    (add-hook 'org-add-hook 'pm/modify-org-done-face))

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
  (setq org-priority-default 3) ;; options for sorting the agenda
  (setq org-priority-highest 1)
  (setq org-priority-lowest 5))

(use-package org
  :ensure t
  :init
  (setq org-default-notes-file (concat org-directory "/refile.org")) ;; org-capture file -- compiles capture entries (all entries tagged :refile)     
  ;; default cabinets for refiling outstanding captures + organized sources populating org-agenda.
  (setq org-cabinets (list (concat org-directory "/logbook.org") ;; datetree chronicling clocktime, timestamped captures, with journal entries
                           (concat org-directory "/research.org") ;; my research, school, and study -- to be populated explicitly by capturing
                           (concat org-directory "/addressbook.org") ;; CRM file. Network contacts by linking manually (so it sticks), use roam
                           (concat org-directory "/occurance.org")
                           (concat org-directory "/zettles/")
                           "~/src/"
                           "~/.config/emacs/litinit.org")))

(use-package org
  :ensure t
  :init
  (setq org-agenda-files (cons org-default-notes-file org-cabinets)) ;; populate agenda from cabinets + refile.org
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t) ;; show only deadline on or after day deadlining task is scheduled
  (setq org-agenda-span 'week) ;; show week view by default
  (setq org-agenda-start-day "-0d") ;; start at today by default (in org-read-date input form)
  (setq org-agenda-start-on-weekday nil) ;; weekly overview starts today and looks forward, leave the past be.
  ;; tags/TODO filters (see tag and property searches) for agenda organization:
  (setq org-stuck-projects 
        '("+LEVEL=1+TODO/-DONE-CANCELED-INACTIVE-NEXT" ("NEXT")))
  ;; Use the current window for indirect buffer display
  (setq org-indirect-buffer-display 'current-window))

(use-package org
  :ensure t
  :init
  (setq org-columns-default-format
        "%TODO %2PRIORITY %25ITEM(Task) %10Effort(Est_Effort){est+} %CLOCKSUM %CLOCKSUM_T")
  (setq org-clock-persist t) ;; continue any running clock when emacs exits. Also save all set clock history accross sessions.
  (setq org-clock-idle-time 10) ;; and prompt to resolve running clocks when restarting, or after 10 minutes of emacs idle time.
  :config
  (org-clock-persistence-insinuate))  ;; set up hooks for clock persistence through sessions

(use-package org
  :ensure t
  :init
  (setq org-capture-templates
        (quote (("p" "project outlining") ;; new project definitions and reports on predefined projects
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
                ("c" "Contact" entry (file "~/org/refile.org") ;; document professional contact
                 "* CONTACT"))))
  :config
  (defun pm/remove-empty-drawer-on-clock-out ()
    "Remove empty STATUSLOG drawers on clock out, use as hook to de-clutter ephemeral captures"
    (interactive)
    (save-excursion
      (beginning-of-line 0)
      (org-remove-empty-drawer-at "STATUSLOG" (point))))
  (add-hook 'org-clock-out-hook 'pm/remove-empty-drawer-on-clock-out 'append))

(use-package org
  :ensure t
  :init
  ;; refile targets include any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets '((org-agenda-files :maxlevel . 9)))
  ;; Use full outline paths for refile targets - file directly into agenda position using Ivy
  (setq org-refile-use-outline-path t)
  ;; Targets complete directly with Ivy, org need not assist
  (setq org-outline-path-complete-in-steps nil)
  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  :config
  (defun pm/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 4 (org-heading-components)) org-done-keywords)))
  (setq org-refile-target-verify-function 'pm/verify-refile-target))

(use-package org
  :ensure t
  :init
  (setq org-id-link-to-org-use-id t) ;; always make unique id for attachments
  (setq org-image-actual-width '(200)))

(use-package ob-ipython
  :ensure t
  :config
  (add-to-list 'company-backends 'company-ob-ipython)
  (setq ob-ipython-command "jupyter")
  (setq org-babel-python-command "python")
  :bind (:map org-mode-map (("M-." . ob-ipython-inspect)))) ;; idea: bind ide doc tools to C-c lang-abbrev i?

(use-package jupyter
  :ensure t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (ipython . t)
   (latex . t)
   (ditaa . t)
   (ruby . t)))
(use-package org
  :ensure t
  :config
  (setq org-confirm-babel-evaluate nil)
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append))

(use-package org
  :ensure t
  :init
  (setq org-latex-pdf-process (list "latexmk -pdflatex='lualatex -shell-escape -bibtex -interaction nonstopmode' -pdf -f %f"))
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0)))
  ;;(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

(use-package org
  :ensure t
  :bind (("C-c l" . org-store-link) ;; global organization bindings
         ("C-c a" . org-agenda) 
         ("C-c c" . org-capture)))

(use-package org-tempo ;; builtin
  ;;:config
  ;;(eval-after-load 'org-tempo (add-to-list 'org-structure-template-alist '("sh" . "src shell")))
  :bind (:map org-mode-map (("C-c C-," . org-insert-structure-template))))

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t) ;; Acknowledge no return to v1
  :custom
  ;; roam database for focused zettlekasten
  (org-roam-directory (file-truename (concat org-directory "/zettles/")))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n r" . org-roam-node-random)		    
         (:map org-mode-map
               (("C-c n i" . org-roam-node-insert) ;; Insert
                ("C-c n o" . org-id-get-create) ;; Organize
                ("C-c n t" . org-roam-tag-add) ;; Tag
                ("C-c n a" . org-roam-alias-add) ;; Alias
                ("C-c n l" . org-roam-buffer-toggle) ;; backLink
                ("C-c n c" . org-roam-extract-subtree)))) ;; Create (use in conjunction with organize)
  :config
  (org-roam-db-autosync-mode)
  (setq org-roam-capture-templates
        (quote (("d" "default" plain "%?"
                 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
                 :unnarrowed t)
                ("l" "Literatue Notes") ;; fully contextual notes. Necessarily Integrated with lit docs via org-noter and org-ref
                ("ln" "noter" entry (file "~/org/zettles/") ;; noter academic pdf note. (consider dedicated epub template too.)
                 "* TODO %?\n%U\n%a\n")
                ("lb" "book" entry (file "~/org/zettles/") ;; physical book note. limited automation + meticulous capture
                 "* TODO %?\n%^T") ;;book, author, pagenumber, full manual bibtex?
                ("r" "Reference Notes") ;; Reflective notes. lectures, seminars, videos; bookmarks; ongoing projects
                ("rl" "lecture" entry (file "~/org/zettles/") ;; general lecture limited automation
                 "* TODO %?\n%^T") ;;lecturer, date, 
                ("rm" "meeting" entry (file "~/org/zettles/") ;; general meeting: timestamped with agenda schedule keyword
                 "%?\n%^T"
                 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
                 :unnarrowed t)
                ("p" "Permanent Notes") ;; standalone notes. hub notes, dedicated thoughts, musings, philosophy
                ("ph" "hub" entry (file "~/org/zettles/")
                 "* TODO %?\n%^T") ;; maybe redundant? possible that proper backlink utilization eliminates need to clarify conncections in hubs
                ("pm" "muse" entry (file "~/org/zettles/")
                 "* TODO %?\n%^T")))) ;; time. context/reason/event?
  (require 'org-roam-protocol))

(use-package org-ref
  :ensure t
  :init
  (setq org-ref-completion-library 'org-ref-ivy-cite) ;; org-ref manager use ivy-bibtex's retreival machinery
  ;; (setq org-ref-default-citation-link "autocite") ;; decide which natbib style is predominant
  (require 'bibtex)
  (setq bibtex-autokey-year-length 4
        bibtex-autokey-name-year-separator "-"
        bibtex-autokey-year-title-separator "-"
        bibtex-autokey-titleword-separator "-"
        bibtex-autokey-titlewords 2
        bibtex-autokey-titlewords-stretch 1
        bibtex-autokey-titleword-length 5) ;; variables informing entry cleanup function
  (require 'org-ref-ivy)
  (require 'org-ref-arxiv)
  (require 'org-ref-scopus)
  (require 'org-ref-wos)
  :config
  (setq reftex-default-bibliography '("~/org/bibliotex/bibliotex.bib")) ;; redundant?
  (setq org-ref-bibliography-notes "~/org/zettles/" ;; replace this variable with the setting from orb?
        org-ref-default-bibliography '("~/org/bibliotex/bibliotex.bib")
        org-ref-pdf-directory '("~/org/bibliotex/paper_pdfs/" "~/org/bibliotex/ebooks/" "~/org/bibliotex/srcbooks"))
  ;; put citation source materials, separated for enote access convenience
  :bind ((:map bibtex-mode-map ("C-c b" . 'org-ref-bibtex-hydra/body))
         (:map org-mode-map (("C-c ]" . 'org-ref-insert-link)
                             ("C-c [" . 'org-ref-insert-link-hydra/body)))))



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
  :bind ("C-c y" . ivy-yasnippet)) ;; ensure consistency with bind logic

(use-package ivy-bibtex
  :ensure t
  :init
  (setq bibtex-completion-bibliography '("~/org/bibliotex/bibliotex.bib") ;; feel free to expand
        bibtex-completion-library-path '("~/org/bibliotex/papers_pdfs/" "~/org/bibliotex/ebooks/" "~/org/bibliotex/srcbooks/")
        ;; doi utils uses path to install pdf downloads. org ref uses path to open source material from cite
        bibtex-completion-notes-path "~/org/zettles/" ;; Keep this concentrated. Might get heavy, but optimize later
        bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"
        bibtex-completion-additional-search-fields '(keywords)
        bibtex-completion-display-formats
        '((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
          (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
          (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
          (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
          (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
        bibtex-completion-pdf-open-function 'find-file)) ;;open pdfs in emacs--best, obviously.
        ;;          (lambda (fpath)
        ;;          (call-process "open" nil 0 nil fpath)))) ;;open pdfs

(use-package org-ref-ivy
  :disabled ;; this is not present on melpa, it's a scimax convenience for the ivy-bound
  :ensure nil
  :load-path (lambda () (expand-file-name "org-ref" scimax-dir))
  :init (setq org-ref-insert-link-function 'org-ref-insert-link-hydra/body
              org-ref-insert-cite-function 'org-ref-cite-insert-ivy
              org-ref-insert-label-function 'org-ref-insert-label-link
              org-ref-insert-ref-function 'org-ref-insert-ref-link
              org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body))))

(use-package yasnippet ;; extensible codeblock insertion utility
  :ensure t
  :config
  (setq-default yas-wrap-around-region t) ;; global option to place selected region at $0
  (yas-global-mode))
;; Notice: it is possible to assign unique keybindings to certain snippets.
;; These bindings are added to the relevant mode's map. This might be reasonable. but...
;; look into building a hydra? or perhaps just rely on the completion menu on C-c y...
(use-package wucuo ;; fast emacs spell-checker. uses hunspell
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'wucuo-start)
  (add-hook 'text-mode-hook 'wucuo-start))
;;(use-package undo-fu (define-key undo-fu-mode-map (kbd "C-?") #'undo-fu-only-redo))
;; (use-package flyspell
;;   :config
;;   (add-hook 'prog-mode-hook #'flyspell-prog-mode)
;;   (add-hook 'text-mode-hook #'flyspell-mode))
(use-package flyspell-correct
  :after wucuo
  :bind (:map flyspell-mode-map
              (("C-."   . flyspell-auto-correct-word)
               ("C-,"   . flyspell-goto-next-error)
               ("C-;"   . flyspell-correct-next)
               ("C-M-;" . flyspell-buffer))))

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
  :ensure t
  :magic ("%PDF" .  pdf-view-mode) ;; open pdfs please, thank you
  :config (pdf-tools-install)) ;; don't break when libpoppler.so updates.

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
  :bind
  (("C-`"   . popper-toggle-latest)
   ("M-`"   . popper-cycle)
   ("C-~" . popper-toggle-type)))

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

(use-package notmuch
  :ensure t
  :init
  (setq message-sendmail-envelope-from 'header)
  :config
  ;; (add-to-list 'company-backends )
  (setq-default notmuch-search-oldest-first nil)
  (setq my-searches '((:name "mannodi group" :query "from:amannodi@purdue.edu OR from:yang1494@purdue.edu OR from:pmangana@purdue.edu OR from:dfarache@purdue.edu OR from:rahma103@purdue.edu" :key "j")))
  (unless (member (car my-searches) notmuch-saved-searches)
    (setq notmuch-saved-searches (append notmuch-saved-searches my-searches)))
  :bind (:map global-map
              ("C-x m" . notmuch)
              ("C-x C-m" . notmuch-mua-new-mail)))

(use-package elfeed
  :ensure t
  :init
  (setq elfeed-feeds
        '("https://github.com/rougier/scientific-visualization-book/tree/master/pdf/book.pdf.atom" ;;data viz w/ matplot
          "https://github.com/Ramprasad-Group/polyga.atom"
          "https://github.com/rougier.atom"))
  :bind ("C-x w" . elfeed))

(use-package python
  :ensure t
  :config
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt --InteractiveShell.display_page=True")

  (defun set-company-backends-for-python ()
    (setq-local company-backends '(company-yasnippet
                                   company-capf
                                   company-files
                                   (company-dabbrev-code company-keywords)
                                   company-dabbrev)))
  (add-hook 'python-mode-hook 'set-company-backends-for-python))

(use-package conda
  :ensure t
  :config
  (setq conda-anaconda-home "/opt/miniconda3") ;; specify install location
  (setq conda-env-home-directory "/opt/miniconda3") ;;conda envs explicit location
  (conda-env-initialize-interactive-shells) ;; conda awareness will be enabled for inferior shell processes
  (conda-env-initialize-eshell) ;; and eshell
  ;; NOTE: eshell and emacs share an evironment. Change one change the other.
  ;;set current environment from instance of interactive shell
  (conda-env-activate (getenv-internal "CONDA_DEFAULT_ENV" (split-string (shell-command-to-string "$SHELL --interactive -c printenv") "\n")))
  ;; display env in modline ~ if modline is customized, :exec keyword can be redirected there.
  (setq-default mode-line-format (cons '(:exec conda-env-current-name) mode-line-format))
  (conda-env-autoactivate-mode -1)) ;; t causes annoying error. But useful for jumping projectile python projects

(use-package poetry
  :ensure t
  :bind ("C-x p" . poetry))

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

(defun pm/ansi-term (&optional path name)
  "Opens an ansi terminal at PATH. If no PATH is given, it uses
    the value of `default-directory'. PATH may be a tramp remote path.
    (username should be requested, or default to local user name).
    The ansi-term buffer is named based on `name' 
    ----
    modification of code by dfeich"
  (interactive)
  (unless path (setq path default-directory))
  (unless name (setq name "ansi-term"))
  (ansi-term "/bin/sh" name)
  (let ((path (replace-regexp-in-string "^file:" "" path))
        (cd-str 
         "fn=%s; if test ! -d $fn; then fn=$(dirname $fn); fi; cd $fn;")
        (bufname (concat "*" name "*" )))
    (if (tramp-tramp-file-p path)
        (let ((tstruct (tramp-dissect-file-name path)))
          (cond 
           ((equal (tramp-file-name-method tstruct) "ssh")
            (process-send-string bufname (format
                                          (concat  "ssh -t %s@%s '"
                                                   cd-str
                                                   "exec bash'; exec bash; clear\n")
                                          (tramp-file-name-user tstruct)
                                          (tramp-file-name-host tstruct)
                                          (tramp-file-name-localname tstruct))))
           (t (error "not implemented for method %s"
                     (tramp-file-name-method tstruct)))))
      (process-send-string bufname (format (concat cd-str " exec bash;clear\n")
                                           path)))))

(defun scp-bell-ipython ()
  "scp remote jupyter session files from Purdue HPC cluster bell.rcac.purdue.edu to local"
  (interactive)
  (find-file "/scp:pmangana@bell.rcac.purdue.edu:/home/pmangana/.local/share/jupyter/runtime/*.json /run/user/1000/jupyter"))

(defun ssh-2-bell ()
  "ssh remote connection to Purdue HPC cluster bell.rcac.purdue.edu"
  (interactive)
  (find-file "/ssh:pmangana@bell.rcac.purdue.edu:/home/pmangana"))

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
(use-package macrostep
  :ensure t
  :bind ((:map emacs-lisp-mode-map
               ("C-c C-e" . macrostep-expand))
         (:map lisp-interaction-mode-map
               ("C-c C-e" . macrostep-expand))))

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-x |") 'toggle-window-split) ;; ediff-like keybinding

(fset 'pm/org-clone-3d-subtree-with-1w-timeshift
      (kmacro-lambda-form [?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down M-down ?\C-c ?\C-p ?\C-c ?\C-p] 0 "%d"))
(fset 'pm/org-clone-2d-subtree-with-1w-timeshift
      (kmacro-lambda-form [?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down ?\C-c ?\C-p ?\C-c ?\C-x ?c ?1 return ?+ ?1 ?w return ?\C-c ?\C-n M-down ?\C-c ?\C-p] 0 "%d"))
