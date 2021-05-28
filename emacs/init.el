(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(yasnippet-snippets yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; modes:
;; pdf docviewer
(setq org-latex-pdf-process (list "latexmk -pdflatex='lualatex -shell-escape -interaction nonstopmode' -pdf -f %f"))

;; package management
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; Mini-buffer Completion
(require 'ido)
;; snippet insertion utilities
(require 'yasnippet)


;; keybindings:
;;dolist evaulates bind settings here, multiple keybindings may be defined for every function:
(setq bindlist '((windmove-swap-states-right "C-M-s-l" "C-M-s-<right>")
                 (windmove-swap-states-up "C-M-s-k" "C-M-s-<up>")
                 (windmove-swap-states-left "C-M-s-h" "C-M-s-<left>")
                 (windmove-swap-states-down "C-M-s-j" "C-M-s-<down>")
                 (windmove-right "C-s-l" "C-s-<right>")
                 (windmove-up "C-s-k" "C-s-<up>")
                 (windmove-left "C-s-h" "C-s-<left>")
                 (windmove-down "C-s-j" "C-s-<down>")
;;                 (spell-fu-goto-next-error "C-,")
;;                 (+spell/correct "C-.")
                 (backward-delete-char-untabify "C-S-d")))

(dolist (bind-to bindlist)
  (let ((keys (cdr bind-to)))
    (dolist (key keys)
      (define-key (current-global-map) (kbd key) (car bind-to)))))

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
