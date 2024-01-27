(define-configuration buffer
  ((default-modes
    (pushnew 'nyxt/mode/emacs:emacs-mode %slot-value%))))

(nyxt:define-nyxt-user-system-and-load "nyxt-user/nx-zotero-mode-proxy"
  :description "This proxy system saves us if nx-zotero fails to load.
Otherwise it will break all the config loading."
  :depends-on ("nx-zotero-mode"))

(define-configuration web-buffer
  ((default-modes
    (pushnew 'zotero-mode %slot-value%))))
