go-mode go-ts-mode

(fun "func " p "(" p ") {" n> r n "}")
(main "func main() {" n> r n "}")
(test "func Test" p " (t *testing.T) { " n> r n "}")

(iff "if " p " {" n> p n> "}"
     (let ((branch (yes-or-no-p "else if?")))
       (if branch '(l n> "else if " p " {" n> p n> "}")))
     (let ((end (yes-or-no-p "else?")))
       (if end '(l n> "else {" n> p n> "}")))
     %)
(ifr "if err != nil {" n> r n> "}")
