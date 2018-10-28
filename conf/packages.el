;;; packages.el --- Packages settings

;;
;; Copyright (C) 2016-2018 Davide Restivo
;;
;; Author: Davide Restivo <davide.restivo@yahoo.it>
;; Maintainer: Davide Restivo <davide.restivo@yahoo.it>
;; URL: https://github.com/daviderestivo/emacs-config/blob/master/conf/packages.el
;; Version: 0.1
;; Keywords: emacs config


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

;; cisco-router-mode
(load-library "cisco-router-mode")

;; load-bash-shell-aliases
(load-library "load-bash-shell-aliases")
(setq lbsa/bashrc-file "~/.bashrc")
(setq lbsa/exclude-aliases-regexp "^alias magit\\|^alias oc")

;; transpose-frame
;; https://www.emacswiki.org/emacs/TransposeFrame
(load-library "transpose-frame")

;; system-packages
(use-package system-packages
  :ensure t
  :config
  (when (string= system-type "darwin")
    (setq system-packages-use-sudo nil)
    (setq system-packages-package-manager 'brew))
  (when (string= system-type "gnu/linux")
    (setq system-packages-use-sudo t)))

;; All the icons
(use-package all-the-icons
  :ensure t
  :config
  ;; The below command needs to be run only once manually to install the
  ;; needed fonts (all-the-icons-install-fonts)
  )

;; atom-one-dark-theme
(use-package atom-one-dark-theme
  :ensure t
  :init
  (add-hook 'after-make-frame-functions 'drestivo/setup-frame-appearance 'append)
  (drestivo/setup-frame-appearance)
  :config
  ;; The below theme is used both for the case of Emacs running in
  ;; console or GUI mode
  (load-theme 'atom-one-dark))

;; exec-path-from-shell
(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-check-startup-files nil)
  ;; http://stackoverflow.com/questions/35286203/exec-path-from-shell-message-when-starting-emacs
  (when (string= system-type "darwin")
    (exec-path-from-shell-initialize)))

;; magit
(use-package magit
  :ensure t
  :defer t
  :init
  (setq magit-repository-directories
        (list '("~/.emacs.d" . 1 )
              '("~/.emacs.d/elpa" . 1 )
              '("~/.dotfiles" . 1 )
              '("~/org" . 1 )))
  :config
  ;; Expand "unpushed to upstream or recent" magit section
  (push (cons [unpushed status] 'show) magit-section-initial-visibility-alist)
  :bind
  ("<f2>" . magit-status)
  ("<f5>" . magit-list-repositories))

;; magit-org-todos - Get todo.org into your magit status.
(use-package magit-org-todos
  :ensure t
  :config
  (magit-org-todos-autoinsert))

;; ORG
(use-package org
  :ensure org-plus-contrib
  :defer t
  :hook ((org-agenda-mode . (lambda ()
                              (setq org-agenda-files
                                    (append
                                     (find-lisp-find-files (concat org-directory "agenda") "\.org$")
                                     (find-lisp-find-files (concat org-directory "home-projects") "\.org$")
                                     (find-lisp-find-files (concat org-directory "work-projects") "\.org$")
                                     (find-lisp-find-files (concat org-directory "notebooks") "\.org$")
                                     (list (concat org-directory "refile-beorg.org"))
                                     (list (concat org-directory "refile.org"))))))
         (org-mode . (lambda ()
                       (setq show-trailing-whitespace t)
                       (flyspell-prog-mode)
                       (org-indent-mode)
                       (diminish 'org-indent-mode)
                       (superword-mode 1)
                       (if (display-graphic-p)
                           (progn
                             (load-theme 'org-beautify t)
                             (set-face-attribute 'org-agenda-structure nil :height 1.0 :family "Lucida Grande"))))))
  :config
  (load-library "find-lisp")
  ;; ORG directories and files
  (setq org-directory "~/org/")
  (setq org-default-notes-file (concat org-directory "refile.org"))
  ;; Additional files to be searched in addition to the default ones
  ;; contained in the agenda folder
  (setq org-agenda-text-search-extra-files
        (append
         (find-lisp-find-files (concat org-directory "home-projects") "\.org$")
         (find-lisp-find-files (concat org-directory "work-projects") "\.org$")
         (find-lisp-find-files (concat org-directory "notebooks") "\.org$")
         (list (concat org-directory "refile-beorg.org"))
         (list (concat org-directory "refile.org"))))
  ;; Configure refiling
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-targets '((org-agenda-files :maxlevel . 1)))
  (setq org-refile-allow-creating-parent-nodes t)
  ;; A timestamp or a note will be recorded when an entry has been refiled
  (setq  org-log-refile t)
  ;; Set ORG ellipsis style to a downward arrow "⤵" instead of "..."
  (setq org-ellipsis "⤵")
  ;; Save all ORG buffers every hour
  (run-at-time "00:59" 3600 'org-save-all-org-buffers)
  ;; Add "CLOSED: [timestamp]" when a task is marked as DONE
  (setq org-log-done t)
  ;; Equivalent of "#+STARTUP: showeverything " on all ORG files
  (setq org-startup-folded nil)
  ;; Images inlined on opening an org buffer
  (setq org-startup-with-inline-images t)
  ;; Set images default width to 320. Emacs requires ImageMagick support "--with-imagemagick@6"
  (setq org-image-actual-width '(320))
  ;; Default file applications on a macOS system
  (when (string= system-type "darwin")
    (setq org-file-apps org-file-apps-defaults-macosx))
  ;; ORG default TODO keywords
  ;; The below can be customized per file using:
  ;;
  ;; #+TODO: "TODO(t)" "DOING(d)" "WAIT OTHERS(w)" "DELEGATED(g)" "REVIEW(r)" "|" "DONE(D)" "CANCELED(C)" "REVIEWED(R)")
  ;;
  (setq org-todo-keywords
        '((sequence "TODO(t)" "DOING(d)" "WAIT OTHERS(w)" "DELEGATED(g)" "REVIEW(r)" "|" "DONE(D)" "CANCELED(C)" "REVIEWED(R)")))
  ;; ORG mode has its own markup syntax but seeing the emphasis
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
  ;; ORG tags shortcuts
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
  :bind
  ("\C-cl" . org-store-link)
  ("\C-ca" . org-agenda)
  ("\C-cc" . org-capture)
  ("\C-cb" . org-iswitchb)
  ("\C-cj" . drestivo/org-show-current-heading-tidily)
  ("<f6>"  . drestivo/org-directory-search-ag))

;; ORG Babel: Main section
(use-package ob
  :defer t
  :config
  ;; Make ORG mode allow eval elisp, python and ruby
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (ruby . t)))
  ;; Stop Emacs asking for confirmation when evaluating a code block
  (setq org-confirm-babel-evaluate nil)
  ;; Turn on syntax highlight
  (setq org-src-fontify-natively t)
  ;; Set python3 as default python interpreter
  (setq org-babel-python-command "python3"))

;; ORG Babel: Ipython section
(use-package ob-ipython
  :ensure t
  :defer t
  :hook
  ;; Display images inline in the same buffer
  (org-babel-after-execute . org-display-inline-images)
  :config
  (setq ob-ipython-command "ipython3")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((ipython . t))))

;; org-download
(use-package org-download
  :ensure t
  :defer t
  :config
  ;; Change screen capture command only for macOS
  (when (string= system-type "darwin")
    (setq org-download-screenshot-method "screencapture -s -x %s"))
  (setq org-download-method  'drestivo/org-download-method)
  (setq org-download-heading-lvl 0)
  ;; org-download default directory
  ;; (setq-default org-download-image-dir "./images")
  (setq org-download-image-html-width '320))

;; org-bullets
(use-package org-bullets
  :ensure t
  :defer t
  :hook
  (org-mode . (lambda ()
                (org-bullets-mode 1))))

;; Beautify org buffers
(use-package org-beautify-theme
  :ensure t
  :defer t
  :defer t
  ;; This theme is loaded when entering ORG mode. Please see the above
  ;; ORG section.
  )

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

;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; auto-package-update
(use-package auto-package-update
  :ensure t
  :defer t
  :config
  ;; Automatically delete old packages
  (setq auto-package-update-delete-old-versions t))

;; smart-mode-line
(use-package smart-mode-line
  :ensure t
  :requires all-the-icons
  :config
  (setq sml/no-confirm-load-theme t)
  ;; The below elisp code configures the sml `respectful' theme when
  ;; Emacs is running in console. Please look at
  ;; `drestivo/setup-frame-appearance' for the case when Emacs runs in
  ;; GUI mode.
  (if (not (display-graphic-p))
      (progn
        (setq sml/theme 'respectful)
        (sml/setup)))
  (display-time-mode)
  (progn
    ;; Temporary workaround for display-battery-mode for emacs-version<= 25.2.1 on macOS
    (when (string= system-type "darwin")
      (if (version<= emacs-version "25.2.1")
          (setq battery-status-function 'drestivo/battery-pmset)))
    ;; The below elisp code setup the battery modeline format when
    ;; Emacs is running in console. Please look at
    ;; `drestivo/setup-frame-appearance' for the case when Emacs runs
    ;; in GUI mode.
    (if (not (display-graphic-p))
        (setq battery-mode-line-format " [%b%p%%]"))
    (setq battery-echo-area-format "Power %L, battery %B (%p%% charged, remaining time %t")
    (display-battery-mode)))

;; An atom-one-dark theme for smart-mode-line
(use-package smart-mode-line-atom-one-dark-theme
  :ensure t)

;; yaml-mode
(use-package yaml-mode
  :ensure t
  :defer t
  :hook
  (yaml-mode . (lambda ()
                 (define-key yaml-mode-map "\C-m" 'newline-and-indent)
                 (setq show-trailing-whitespace t)
                 (flyspell-prog-mode)
                 (superword-mode 1)))
  :config
  (add-to-list 'auto-mode-alist '("\\.\\(yml\\|knd)\\)\\'" . yaml-mode)))

;; jinja2-mode
(use-package jinja2-mode
  :ensure t
  :defer t
  :hook
  (jinja2-mode . (lambda ()
                   (setq show-trailing-whitespace t)
                   (flyspell-prog-mode)
                   (superword-mode 1)))
  :config
  (add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode)))

;; helm-config
(use-package helm-config
  :config
  (global-set-key (kbd "C-c h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c")))

;; helm - Helm is an incremental completion and selection narrowing
;; framework for Emacs.
(use-package helm
  :ensure t
  :hook
  (helm-minibuffer-set-up . drestivo/helm-hide-minibuffer-maybe)
  :diminish helm-mode
  :commands helm-mode
  :config
  (helm-mode 1)
  ;; Increase max length of buffer names (default 20) to the longest
  ;; buffer-name length found.
  (setq helm-buffer-max-length nil)
  ;; Enable fuzzy matching
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-recentf-fuzzy-match t)
  (setq helm-M-x-fuzzy-match t)
  ;;--------------------------------------------------------------------------;;
  ;;       Work with Spotlight on macOS instead of the regular locate         ;;
  ;;--------------------------------------------------------------------------;;
  (if (string= system-type "darwin")
      (progn
        (setq drestivo/helm-locate-spotlight-command "mdfind -name -onlyin ~ %s %s")
        (setq drestivo/helm-locate-exclude-dirs "~/Library")
        (setq drestivo/helm-locate-exclude-command " | egrep -v ")
        (setq helm-locate-command
              (concat drestivo/helm-locate-spotlight-command
                      drestivo/helm-locate-exclude-command
                      drestivo/helm-locate-exclude-dirs))
        (setq helm-locate-fuzzy-match nil))
    (setq helm-locate-fuzzy-match t))
  ;;--------------------------------------------------------------------------;;
  ;;     END Work with Spotlight on macOS instead of the regular locate       ;;
  ;;--------------------------------------------------------------------------;;
  (setq helm-semantic-fuzzy-match t)
  (setq helm-imenu-fuzzy-match t)
  (setq helm-ff-file-name-history-use-recentf t)
  (setq helm-autoresize-mode t)
  (setq helm-echo-input-in-header-line t)
  (setq helm-follow-mode-persistent t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 40)
  (helm-autoresize-mode 1)
  (define-key minibuffer-local-map (kbd "C-c C-l") 'helm-minibuffer-history)
  ;; Replace the default helm grep command with ag.
  ;; Requires "The Silver Searcher" (ag) to be installed.
  ;; On macOS use: 'brew install the_silver_searcher'
  (when (executable-find "ag")
    ;; For helm to recognize correctly the matches we need to enable
    ;; line numbers and columns in its output, something the
    ;; --vimgrep option does.
    (setq helm-grep-default-command         "ag -i --vimgrep --nogroup --nocolor -z %p %f"
          helm-grep-default-recurse-command "ag -i --vimgrep --nogroup --nocolor -z %p %f"))
  :bind
  ;; bind keys because of this commit:
  ;; https://github.com/emacs-helm/helm/commit/1de1701c73b15a86e99ab1c5c53bd0e8659d8ede
  ("M-x"       . helm-M-x)
  ("M-y"       . helm-show-kill-ring)
  ("C-x b"     . helm-mini)
  ("C-x r b"   . helm-filtered-bookmarks)
  ("C-x C-f"   . helm-find-files)
  ("C-x C-r"   . helm-recentf)
  ("C-c h x"   . helm-register)
  ("C-c h SPC" . helm-all-mark-rings))

;; helm-ag
;; Requires "The Silver Searcher" (ag) to be installed.
;; On macOS use: 'brew install the_silver_searcher'
(use-package helm-ag
  :ensure t
  :ensure-system-package (ag . "brew install the_silver_searcher || sudo apt-get install silversearcher-ag")
  :config
  ;; Use .agignore file at project root
  (setq helm-ag-use-agignore t)
  ;; Enable  approximate string matching (fuzzy matching)
  (setq helm-ag-fuzzy-match t)
  ;; :bind together with lambdas is unsupported in use-package
  (global-set-key (kbd "M-s") '(lambda (P)
                                 (interactive "P")
                                 (if (eq P nil)
                                     (helm-do-ag-this-file)
                                   (helm-do-ag-buffers)))))

;; helm-descbinds
(use-package helm-descbinds
  :ensure t
  :defer t
  :config
  (helm-descbinds-mode))

;; helm-projectile
(use-package helm-projectile
  :ensure t
  :defer t
  :config
  (helm-projectile-on))

;; company
(use-package company
  :ensure t
  :diminish company-mode
  :config
  (global-company-mode)
  (setq company-idle-delay 0.2)
  (setq company-selection-wrap-around t)
  (define-key company-active-map [tab] 'company-complete)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous))

;; projectile
(use-package projectile
  :ensure t
  :defer t
  :diminish projectile-mode
  :config
  (projectile-mode)
  (setq projectile-completion-system 'helm)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; py-autopep8
(use-package py-autopep8
  :ensure t
  :defer t
  :hook
  ;; Configure elpy autopep8 support
  (elpy-mode . py-autopep8-enable-on-save))

;; elpy
(use-package elpy
  :ensure t
  :defer t
  :diminish elpy-mode
  :hook
  (python-mode . elpy-mode)
  :config
  (elpy-enable)
  (setq elpy-rpc-python-command "python3")
  (setq python-shell-interpreter "jupyter"
        python-shell-interpreter-args "console --simple-prompt"
        python-shell-prompt-detect-failure-warning nil)
  (add-to-list 'python-shell-completion-native-disabled-interpreters "jupyter"))

;; highlight-indentation-mode
(use-package highlight-indentation
  :ensure t
  :diminish highlight-indentation-mode
  :config
  (set-face-attribute 'highlight-indentation-face nil
                      :background "gray18")
  (set-face-attribute 'highlight-indentation-current-column-face nil
                      :background "gray18"))

;; markdown-mode
(use-package markdown-mode
  :ensure t
  :defer t
  :hook
  (markdown-mode . (lambda ()
                     (setq show-trailing-whitespace t)
                     (flyspell-prog-mode)
                     (superword-mode 1)))
  :config
  (set-face-attribute 'markdown-code-face nil :background "#282C34")
  (set-face-attribute 'markdown-code-face nil :foreground "#ABB2BF"))

;; yasnippet
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs
        '("~/.emacs.d/snippets"           ;; AndreaCrotti/yasnippet-snippets
          "~/.emacs.d/snippets-addons"    ;; Personal snippets
          ))
  (yas-reload-all))

;; undo-tree
(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode 1)
  (setq undo-tree-visualizer-diff 1)
  (setq undo-tree-visualizer-timestamps 1))

;; psession
(use-package psession
  :ensure t
  :config
  (psession-mode 1)
  ;; Save minibuffer history
  (psession-savehist-mode 1)
  ;; Save periodically (autosave) the Emacs session
  (psession-autosave-mode 1))

;; volatile-highlights
(use-package volatile-highlights
  :ensure t
  :diminish volatile-highlights-mode
  :config
  (volatile-highlights-mode t))

;; wttrin - Weather application
(use-package wttrin
  :ensure t
  :defer t
  :commands (wttrin)
  :init
  (setq wttrin-default-accept-language '("Accept-Language" . "en-US"))
  (setq wttrin-default-cities '("Aarau"
                                "Bern"
                                "Zurich")))

;; which-key
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :init
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom))

;; whitespace - Highlight lines that exceed 80 chars length
(use-package whitespace
  :ensure t
  :diminish global-whitespace-mode
  :config
  (set-face-attribute 'whitespace-line nil :background "gray20" :foreground "dark gray")
  ;; whitespace-mode is not compatible with magit. Disabling it on
  ;; magit-mode.
  (defun drestivo/prevent-whitespace-mode-for-magit ()
    (not (derived-mode-p 'magit-mode)))
  (add-function :before-while whitespace-enable-predicate 'drestivo/prevent-whitespace-mode-for-magit)
  (setq whitespace-line-column 80) ;; limit line length
  (setq whitespace-style '(face lines-tail))
  (setq whitespace-global-modes '(not org-mode lisp-interaction-mode))
  (global-whitespace-mode t))

;; gnutls customization
;;
;; Please look at: https://blogs.fsfe.org/jens.lechtenboerger/2014/03/23/certificate-pinning-for-gnu-emacs/
(use-package gnutls
  :ensure t
  :defer t
  :ensure-system-package (gnutls-cli . "brew install gnutls || sudo apt-get install gnutls-bin")
  :config
  (setq tls-program '("gnutls-cli -p %p %h")
        imap-ssl-program '("gnutls-cli -p %p %s")
        smtpmail-stream-type 'starttls))

;; dired customization
(use-package dired
  :defer t
  :hook
  (dired-mode . (lambda ()
                  (dired-hide-details-mode 1)))
  :config
  (setq dired-dwim-target nil))

;; ElDoc
(use-package eldoc
  :defer t
  :diminish eldoc-mode)

;; diff-hl
(use-package diff-hl
  :ensure t
  :hook
  ;; Highlight changed files in the fringe of dired
  ((dired-mode . diff-hl-dired-mode)
   (magit-post-refresh . diff-hl-magit-post-refresh))
  :diminish diff-hl-mode
  :init
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                '(lambda (frame)
                   (select-frame frame)
                   (if (display-graphic-p)
                       (global-diff-hl-mode)
                     (progn
                       (setq diff-hl-side 'right)
                       (global-diff-hl-mode)
                       (diff-hl-margin-mode)))))
    ;; Emacs not running in daemon mode
    (if (display-graphic-p)
        (global-diff-hl-mode)
      (progn
        (setq diff-hl-side 'right)
        (global-diff-hl-mode)
        (diff-hl-margin-mode)))))

;; Eshell
(use-package eshell
  :ensure t
  :hook
  (eshell-exit . (lambda ()
                   (delete-window)))
  (eshell-mode . (lambda ()
                   ;; (setq eshell-destroy-buffer-when-process-dies t)
                   ;; Programs that need special displays
                   (setq helm-eshell-fuzzy-match t)
                   (eshell-cmpl-initialize)
                   ;; Date: Sat Sep  8 08:33:37 CEST 2018 - Comment it out because it's buggy in Emacs 27
                   ;;(define-key eshell-mode-map [remap eshell-pcomplete] 'helm-esh-pcomplete)
                   (add-to-list 'eshell-visual-subcommands '("git" "diff" "help" "log" "show"))
                   (define-key eshell-mode-map (kbd "C-c C-l")  'helm-eshell-history)
                   (define-key eshell-mode-map (kbd "C-c C-;")  'helm-eshell-prompts)))

  :config
  ;; Eshell prompt customization
  (setq eshell-highlight-prompt nil)
  (setq eshell-prompt-function 'drestivo/eshell-prompt))

;; YANG mode
(use-package yang-mode
  :ensure t
  :defer t)

;; Display the keys you typed in a special buffer: *command-log*
(use-package command-log-mode
  :ensure t
  :defer t)

;; A Dockerfile mode for Emacs
(use-package dockerfile-mode
  :ensure t
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))

;; Pop-up a shell
(use-package shell-pop
  :ensure t
  :init
  (setq shell-pop-shell-type '("eshell" "*eshell*" (lambda () (eshell)))
        shell-pop-term-shell "eshell"
        shell-pop-universal-key (kbd "C-x t")
        shell-pop-window-size 50
        shell-pop-full-span t
        shell-pop-window-position "bottom"))

;; Fish-like autosuggestions in eshell
(use-package esh-autosuggest
  :ensure t
  :hook (eshell-mode . esh-autosuggest-mode))

;; When find-file and dired-mode try to access a non writable file
;; auto-sudoedit re-opens the file automatically using sudo in TRAMP
(use-package auto-sudoedit
  :ensure t
  :diminish auto-sudoedit-mode
  :config
  (auto-sudoedit-mode 1))

;; Multiple cursors support
(use-package multiple-cursors
  :ensure t
  :defer t
  :init
  (require 'mc-hide-unmatched-lines-mode)
  :bind
  ;; When you have an active region that spans multiple lines
  ;; mc/edit-lines will add a cursor to each line:
  ("C-S-c C-S-c"   . mc/edit-lines)
  ("C->"           . mc/mark-next-like-this)
  ("C-<"           . mc/mark-previous-like-this)
  ("M-C->"         . mc/mark-next-like-this-symbol)
  ("M-C-<"         . mc/mark-previous-like-this-symbol)
  ("C-c C-<"       . mc/mark-all-like-this)
  ("C-c C->"       . mc/mark-all-like-this-symbol)
  ("C-c C-n"       . mc/insert-numbers)
  ("C-c C-r"       . mc/reverse-regions)
  ("C-c C-s"       . mc/sort-regions)
  ("C-S-<mouse-1>" . mc/add-cursor-on-click)
  (:map mc/keymap
        ("<return>" . nil)))

;; ibuffer-sidebar
(if (not (version< emacs-version "25.1"))
    (use-package ibuffer-sidebar
      :ensure t
      :defer t
      :hook
      (ibuffer-mode . (lambda ()
                        (drestivo/disable-number-and-visual-line)))
      :config
      (setq ibuffer-sidebar-use-custom-font nil)
      :bind
      ("C-<f12>" . ibuffer-sidebar-toggle-sidebar)))

;; imenu-list
(use-package imenu-list
  :ensure t
  :defer t
  :hook
  (imenu-list-major-mode . (lambda ()
                             (drestivo/disable-number-and-visual-line)))
  :config
  (setq imenu-list-position 'right
        imenu-list-auto-resize t)
  :bind
  ("<f12>" . imenu-list-smart-toggle))

;; cider - Clojure Interactive Development Environment
(use-package cider
  :ensure t
  :defer t
  :ensure-system-package (lein . leiningen))

;; Automatically debug and bisect your init file
(use-package bug-hunter
  :ensure t
  :defer t)

;; Global minor mode for Emacs that allows you to manage your window
;; configurations in a simple manner, just like tiling window managers.
(use-package eyebrowse
  :ensure t
  :config
  (eyebrowse-mode)
  ;; Display the *scratch* buffer for every newly created workspace
  (setq eyebrowse-new-workspace t))

;; An extensible Emacs startup screen showing you what’s most important
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (diminish 'page-break-lines-mode)
  ;; Configure initial-buffer-choice to show the dashboard in frames
  ;; created with `emacsclient -c'
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
  ;; Set banner logo text face family
  (set-face-attribute 'dashboard-banner-logo-title-face nil :height 1.2 :family "Helvetica Light")
  ;; Set the banner text
  (setq dashboard-banner-logo-title "“Patience you must have, my young padawan” (Yoda)")
  ;; Set an alternate Emacs logo
  (setq dashboard-startup-banner (expand-file-name "emacs-logo.png"
                                                   user-emacs-directory))
  ;; Customize banner font
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5))))

;; Provides capabilities to fetch your starred repositories from
;; github and select one for browsing
(use-package helm-github-stars
  :ensure t
  :defer t
  :config
  (setq helm-github-stars-username "daviderestivo")
  (setq helm-github-stars-refetch-time 0.5))

;; A GNU Emacs package for jumping to visible text using a char-based
;; decision tree
(use-package avy
  :ensure t
  :config
  ;; Full path before target, leaving all original text
  (setq avy-styles-alist '((avy-goto-char . pre)))
  ;; When nil, the searches does not ignore case
  (setq avy-case-fold-search nil)
  :bind
  ("s-/" . avy-goto-char))

;; Utility package that return vscode icons for Emacs
(use-package vscode-icon
  :ensure t
  :defer t
  :commands
  (vscode-icon-for-file))

;; Sidebar for Emacs leveraging dired
(use-package dired-sidebar
  :ensure t
  :defer t
  :hook
  (dired-sidebar-mode .
                      (lambda ()
                        (unless (file-remote-p default-directory)
                          (auto-revert-mode))
                        (drestivo/disable-number-and-visual-line)))
  :bind
  (("M-<f12>" . dired-sidebar-toggle-sidebar))
  :commands
  (dired-sidebar-toggle-sidebar)
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-theme 'vscode)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

;; A linter for the metadata in Emacs Lisp files which are intended to
;; be packages
(use-package package-lint
  :ensure t
  :defer t)

;; A reformat tool for JSON (required by json-mode)
(use-package json-reformat
  :ensure t
  :defer t)

;; Get the path to a JSON element in Emacs (required by json-mode)
(use-package json-snatcher
  :ensure t
  :defer t)

;; Major mode for editing JSON files
(use-package json-mode
  :ensure t
  :defer t
  :requires (json-reformat json-snatcher))


;;; packages.el ends here