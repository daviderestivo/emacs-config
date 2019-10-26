;;; org.el --- Galactic Emacs org-mode configuration

;;
;; Copyright (C) 2016-2019 Davide Restivo
;;
;; Author: Davide Restivo <davide.restivo@yahoo.it>
;; Maintainer: Davide Restivo <davide.restivo@yahoo.it>
;; URL: https://github.com/daviderestivo/galactic-emacs/blob/master/conf/org.el
;; Version: 11.0.0
;; Keywords: emacs config dotemacs


;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


;;; Commentary:

;; An org-mode configuration on steroids.


;; Org-Mode: main section
(use-package org
  :ensure org-plus-contrib
  :defer t
  :init
  ;; Org 9.2 comes with a new template expansion mechanism [C-c C-,]
  ;; The previous behavior, e.g. <s, is still available and activated
  ;; by requiring org-tempo library.
  (require 'org-tempo)
  ;; `org-crypt' allows to encrypt subtrees using GPG
  (require 'org-crypt)
  (setq galactic-emacs-org-electric-pair-inhibit-list '(?\<))
  :hook
  (org-agenda-mode . (lambda ()
                       (setq org-agenda-files
                             (when (file-directory-p org-directory)
                               (append
                                (find-lisp-find-files org-directory "\.org$"))))))
  (org-mode . (lambda ()
                (setq-local electric-pair-inhibit-predicate
                            (lambda (c)
                              (if (member c galactic-emacs-org-electric-pair-inhibit-list)
                                  t
                                (electric-pair-default-inhibit c))))
                (setq show-trailing-whitespace t)
                (flyspell-prog-mode)
                (org-indent-mode)
                (diminish 'org-indent-mode)
                (superword-mode 1)
                (if (display-graphic-p)
                    (progn
                      (load-theme 'org-beautify t)
                      (set-face-attribute 'org-agenda-structure nil :height 1.0 :family "Lucida Grande")))))
  :config
  (load-library "find-lisp")
  ;; Org directories and files
  (setq org-directory "~/org/")
  (when (file-directory-p org-directory)
    (setq org-default-notes-file (concat org-directory "refile.org")))
  ;; Additional files to be searched in addition to the default ones
  ;; contained in the agenda folder
  (setq org-agenda-text-search-extra-files
        (when (file-directory-p org-directory)
          (append
           (find-lisp-find-files (concat org-directory "home-projects") "\.org$")
           (find-lisp-find-files (concat org-directory "work-projects") "\.org$")
           (find-lisp-find-files (concat org-directory "notebooks") "\.org$")
           (list (concat org-directory "refile-beorg.org"))
           (list (concat org-directory "refile.org")))))
  ;; Configure refiling
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-targets '((org-agenda-files :maxlevel . 1)))
  (setq org-refile-allow-creating-parent-nodes t)
  ;; A timestamp or a note will be recorded when an entry has been refiled
  (setq  org-log-refile t)
  ;; Set org ellipsis style to a downward arrow "⤵" instead of "..."
  (setq org-ellipsis "⤵")
  ;; Save all org buffers every hour
  (run-at-time "00:59" 3600 'org-save-all-org-buffers)
  ;; Add "CLOSED: [timestamp]" when a task is marked as DONE
  (setq org-log-done t)
  ;; Equivalent of "#+STARTUP: showeverything " on all org files
  (setq org-startup-folded nil)
  ;; Images inlined on opening an org buffer
  (setq org-startup-with-inline-images t)
  ;; Set images default width to 320. Emacs requires ImageMagick support "--with-imagemagick@6"
  (setq org-image-actual-width '(320))
  ;; Default file applications on a macOS system
  (when (string= system-type "darwin")
    (setq org-file-apps org-file-apps-defaults-macosx))
  ;; Org default TODO keywords
  ;; The below can be customized per file using:
  ;;
  ;; #+TODO: "TODO(t)" "DOING(d)" "WAIT OTHERS(w)" "DELEGATED(g)" "REVIEW(r)" "|" "DONE(D)" "CANCELED(C)" "REVIEWED(R)")
  ;;
  (setq org-todo-keywords
        '((sequence "TODO(t)" "DOING(d)" "WAIT OTHERS(w)" "DELEGATED(g)" "REVIEW(r)" "|" "DONE(D)" "CANCELED(C)" "REVIEWED(R)")))
  ;; Org-Mode has its own markup syntax but seeing the emphasis
  ;; markers is distracting. The below setting hides it.
  (setq org-hide-emphasis-markers t)
  ;; Wrap long lines. Don't let it disappear to the right
  (setq org-startup-truncated nil)
  ;; When in a URL pressing enter key opens it
  (setq org-return-follows-link t)
  ;; Capture templates for: TODO tasks and notes
  (setq org-capture-templates
        (quote (("n" "Note"   entry (file (lambda () (concat org-directory "refile.org")))
                 "* %?\n%a\n%U\n")
                ("t" "Todo"   entry (file (lambda () (concat org-directory "refile.org")))
                 "* TODO %?\n%a\n%U\n"))))
  ;; Org tags shortcuts
  (setq org-tag-alist '(("HIGH" . ?h)
                        ("MEDIUM" . ?m)
                        ("LOW" . ?l)
                        ("NOTE" . ?n)
                        ("REVIEW" . ?r)))
  ;; The maximum level for Imenu access to Org headlines
  (setq org-imenu-depth 5)
  ;; org-archive-subtree
  ;; Archive subtrees under the same hierarchy as the original org file.
  ;; Link: https://gist.github.com/Fuco1/e86fb5e0a5bb71ceafccedb5ca22fcfb
  (load-library "org-archive-subtree")
  ;; Load org agenda at startup if running in daemon mode
  (if (daemonp)
      (add-hook 'after-init-hook 'org-agenda-list)
    (setq org-agenda-inhibit-startup t))
  ;;
  ;; org-crypt configuration
  ;;
  ;; Prevent the crypt tag from using inheritance so that there is no
  ;; encrypted data inside encrypted data
  (setq org-tags-exclude-from-inheritance (quote ("crypt")))
  ;; Any text below a headline that has a ‘:crypt:’ tag will be
  ;; automatically be encrypted when the file is saved
  (org-crypt-use-before-save-magic)
  ;; GPG key to use for encryption
  ;; Either the Key ID or set to nil to use symmetric encryption.
  ;; The `gpg-key' variable is defined in personal.el
  (setq org-crypt-key gpg-key)
  ;; Auto-saving does not cooperate with org-crypt.el: so you need
  ;; to turn it off if you plan to use org-crypt.el quite often.
  ;; Otherwise, you'll get an (annoying) message each time you
  ;; start org.
  ;; To turn it off only locally, you can insert this:
  ;; # -*- buffer-auto-save-file-name: nil; -*-
  (setq auto-save-default nil)
  ;; Set crypt as default tag available in org files.
  (setq org-tag-alist '(("crypt" . ?c)))
  :bind
  ("\C-ce"  . org-encrypt-entry)
  ("\C-cd"  . org-decrypt-entry)
  ("\C-cl"  . org-store-link)
  ("\C-ca"  . org-agenda)
  ("\C-cc"  . org-capture)
  ("\C-cb"  . org-iswitchb)
  ("\C-ci"  . org-insert-heading)
  ("\C-cj"  . galactic-emacs-org-show-current-heading-tidily)
  ("<f6>"   . galactic-emacs-org-directory-search-ag))

;; Beautify org buffers
(use-package org-beautify-theme
  :ensure t
  :defer t
  :defer t
  ;; This theme is loaded when entering org-mode. Please see the above
  ;; org section.
  )

;; org-bullets
(use-package org-bullets
  :ensure t
  :defer t
  :hook
  (org-mode . (lambda ()
                (org-bullets-mode 1))))

;; org-download
(use-package org-download
  :ensure t
  :config
  ;; Change screen capture command only for macOS
  (when (string= system-type "darwin")
    (setq org-download-screenshot-method "screencapture -s -x %s"))
  (setq org-download-method  'galactic-emacs-org-download-method)
  (setq org-download-heading-lvl 0)
  ;; org-download default directory
  ;; (setq-default org-download-image-dir "./images")
  (setq org-download-image-html-width '320))

;; Org Babel: main section
(use-package ob
  :defer t
  :hook
  ;; Display images inline in the same buffer
  (org-babel-after-execute . org-display-inline-images)
  :config
  ;; Make org-mode allow eval elisp, python and ruby
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (clojure . t)
     (python . t)
     ;; Disable ob-ipython because of:
     ;; https://github.com/gregsexton/ob-ipython/issues/135
     ;;(ipython . t)
     (ruby . t)
     (plantuml . t)))
  ;; Stop Emacs asking for confirmation when evaluating a code block
  (setq org-confirm-babel-evaluate nil)
  ;; Turn on syntax highlight
  (setq org-src-fontify-natively t)
  ;; Set python3 as default python interpreter
  (setq org-babel-python-command "python3"))

;; Org Babel: clojure section
(use-package ob-clojure
  :defer t
  :config
  ;; To compile and run Clojure code, you will need to connect to a
  ;; REPL: M-x cider-jack-in RET
  (setq org-babel-clojure-backend 'cider))

;; Org Babel: ipython section
(use-package ob-ipython
  :ensure t
  :defer t
  :config
  (setq ob-ipython-command "ipython3"))

;; Org Babel: plantuml section
(use-package ob-plantuml
  :defer t
  :config
  (setq org-plantuml-jar-path
        (concat user-emacs-directory "lib/" "plantuml.jar")))

;; This is an Emacs package that creates graphviz directed graphs from
;; the headings of an org file
(use-package org-mind-map
  :init
  (require 'ox-org)
  :ensure t
  :defer t
  :ensure-system-package (gvgen . graphviz)
  :config
  (setq org-mind-map-engine "dot")       ; Default. Directed Graph
  ;; (setq org-mind-map-engine "neato")  ; Undirected Spring Graph
  ;; (setq org-mind-map-engine "twopi")  ; Radial Layout
  ;; (setq org-mind-map-engine "fdp")    ; Undirected Spring Force-Directed
  ;; (setq org-mind-map-engine "sfdp")   ; Multiscale version of fdp for the layout of large graphs
  ;; (setq org-mind-map-engine "twopi")  ; Radial layouts
  ;; (setq org-mind-map-engine "circo")  ; Circular Layout
  )

;; A package that shows your agenda when Emacs is idle
(use-package idle-org-agenda
  :after org-agenda
  :disabled t
  :ensure t
  :config (idle-org-agenda-mode))


;;; org.el ends here