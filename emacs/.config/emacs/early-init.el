;; Early init file is for configuration before the frame's GUI and
;; package.el are initialized.

;; Disable the menu-bar, tool-bar, scroll bars,
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

(setq package-enable-at-startup nil)
(startup-redirect-eln-cache
 (expand-file-name "emacs/" (getenv "XDG_CACHE_HOME")))
;; think about playing around with window fringes

;; transparency config
;; (add-to-list 'default-frame-alist '(alpha . (85 . 85)))
