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

(fname (file-name-nondirectory (or (buffer-file-name) (buffer-name))))
(fbase (file-name-base (or (buffer-file-name) (buffer-name))))
(copyright (push-mark) "Copyright (C) " copyright-current-year "  "
           user-full-name " <" user-mail-address ">"
           :post (comment-region (mark) (point)))
(gplshort (push-mark) "
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING.  If not, write to the
Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA.
" :post (comment-region (mark) (point)))
