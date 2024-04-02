emacs-lisp-mode

(head ";;; " (file-name-nondirectory (or (buffer-file-name) (buffer-name)))
      " -- " (p "description" nil) " -*- lexical-binding: t -*-")
(comm ";;; Commentary:" n p n ";;; Code:")
(tail "(provide '" (file-name-base (or (buffer-file-name) (buffer-name))) ")" n
      ";;; " (file-name-nondirectory (or (buffer-file-name) (buffer-name))) " ends here")

(pkg (i head) n (i comm) n q n (i tail))
