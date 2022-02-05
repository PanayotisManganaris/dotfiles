;; my nyxt browser config
;; load dependencies
(in-package #:nyxt-user)

;; make externally controllable
(define-configuration browser
    ((remote-execution-p :t)))

;; my keymap
(define-configuration buffer
  ((override-map (let ((map (make-keymap "override-map")))
                   (define-key map
                       "M-x" 'execute-command
;;		       "C-space" 'mark-set
		       "s-space" 'nothing)))))

;; custom nyxt visual theme
;; Import Files
(dolist (file (list (nyxt-init-file "statusline.lisp")
                    (nyxt-init-file "stylesheet.lisp")))
  (load file))
