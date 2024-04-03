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
     (i commentary) n n r n n
     (i tail))

(group "(defgroup " (i fbase) " (" p ")"
       n> "\"" p "\""
       n> ":group " p
       n> ":prefix \"" (i fbase) "-\""
       % > r ")")
(custom "(defcustom " (p "name") (p "default-value")
        n> "\"" p "\""
        n> ":type '" (p "widget")
        % > r ")")
(face "(defface " (p "name") "'(t :inherit " (p "default") ")"
      n> "\"" p "\""
      % > r ")")

(autoload & ";;;###autoload")
(fun "(defun " (p "name") " (" (p "arg") ")" n>
     "\"" p "\"" (i interactive-maybe) r> ")")
(lam "(lambda (" p ") " (i interactive-maybe) r ")")
(interactive-maybe (if (yes-or-no-p "interactive?") '(i interactive) ""))
(interactive & > "(interactive" (p " p") ")" o >)
