emacs-lisp-mode

(head ";;; " (i fname) " --- " (p "description") " -*- lexical-binding: t -*-")
(metadata "
;; Author: " (user-full-name) "
;; URL: " nil "
;; Keywords: " p "
;; Version: " (p "0.0.0") "
;; Package-Requires: " (p "packages-alist") "
")
(legal ";; This file is NOT part of GNU Emacs." n (i gplshort))
(commentary ";;; Commentary:" n ";; " p n ";;; Code:")
(tail "(provide '" (i fbase) ")" n
      ";;; " (i fname) " ends here")

(pkg (i head) n n
     ;; (i copyright) n
     (i metadata) n
     ;; (i legal) n
     (i commentary) n n q n n
     (i tail))

(autoload & ";;;###autoload")
(fun "(defun " (p "name") " (" (p "arg") ")" n>
     "\"" p "\"" (i interactive-maybe) r> ")")
(lam "(lambda (" p ") " (i interactive-maybe) r ")")
(interactive-maybe (if (yes-or-no-p "interactive?") '(i interactive) ""))
(interactive & > "(interactive" (p " p") ")" o >)
