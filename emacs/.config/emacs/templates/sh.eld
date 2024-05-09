sh-base-mode

(! & "#!/usr/bin/env bash" n q)
(for "for " p " in " p n "do" n> q n "done")

(iff "if [ " p " ]; then" n> p
     (let ((branch (yes-or-no-p "else if?")))
       (if branch '(l n> "elif [" p "]; then")))
     (let ((end (yes-or-no-p "else?")))
       (if end '(l n> "else" n> p)))
     n> "fi" %)
(switch "case " p " in"
        n> p ")" p ";;"
        n> "esac")
