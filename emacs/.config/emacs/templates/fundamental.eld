fundamental-mode ;; Available everywhere

(today (format-time-string "%Y-%m-%d"))
(NOW (format-time-string "<%Y-%0m-%0d %a %H:%0M>"))
(yesterday (format-time-string "<%Y-%0m-%0d %a>" (time-subtract nil (* 24 60 60))))
(tomorrow (format-time-string "<%Y-%0m-%0d %a>" (time-add nil (* 24 60 60))))

(parenthesis-pair-maybe (if (use-region-p) '(l "(" r ")") "("))
(bracket-pair-maybe (if (use-region-p) '(l "[" r "]") "["))
(brace-pair-maybe (if (use-region-p) '(l "{" r "}") "{"))
(abracket-pair-maybe (if (use-region-p) '(l "<" r ">") "<"))
(qquote-pair-maybe (if (use-region-p) '(l "\"" r "\"") "\""))
(quote-pair-maybe (if (use-region-p) '(l "\'" r "\'") "\'"))
(tick-pair-maybe (if (use-region-p) '(l "`" r "`") "`"))
