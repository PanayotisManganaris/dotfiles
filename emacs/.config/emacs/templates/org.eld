org-mode

(start & "#+STARTUP: " q)
(property & "#+PROPERTY: ")
(session (i property) "header-args" (p ":language ") ":session :pandoc org :async yes" %)
(export (i property) "header-args :eval never-export :exports results" %)
