python-base-mode

(fun "def " p "(" p ")" p ":" n> r)
(main "def main():" n> r)

(iff "if " p ":" n> p
     (let ((branch (yes-or-no-p "else if?")))
       (if branch '(l n> "elif " p ":" n>)))
     (let ((end (yes-or-no-p "else?")))
       (if end '(l n> "else:" n> p)))
     %)
