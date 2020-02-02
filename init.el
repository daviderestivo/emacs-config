;;; init.el --- Galactic Emacs init file

;;
;; Copyright (C) 2016-2020 Davide Restivo
;;
;; Author: Davide Restivo <davide.restivo@yahoo.it>
;; Maintainer: Davide Restivo <davide.restivo@yahoo.it>
;; URL: https://github.com/daviderestivo/galactic-emacs/blob/master/init.el
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

;; This is the Galactic Emacs config file. Feel free to drop me an
;; email in case of questions or if you want to collaborate.


;;; Improve Emacs startup time
;;
;; PLEASE DO NOT ADD ANY CODE `BEFORE' THIS SECTION
;;
;; Avoid garbage collection during startup. The GC eats up quite a bit
;; of time, easily doubling the startup time. The trick is to turn up
;; the memory threshold (512 MB should be sufficient) in order to
;; prevent it from running during startup.
(setq gc-cons-threshold (* 512 1024 1024 1024)
      gc-cons-percentage 0.6)

;; After Emacs startup has been completed, set `gc-cons-threshold' to
;; 128 MB and reset `gc-cons-percentage' to its original value.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 128 1024 1024)
                  gc-cons-percentage 0.1)))


;;; General configuration section

;; Configure Emacs package manager. Not required anymore on Emacs > 27
(if (version< emacs-version "27")
    (package-initialize))
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

;; Some combination of GNU TLS and Emacs fail to retrieve archive
;; contents over https.
;; https://www.reddit.com/r/emacs/comments/cdei4p/failed_to_download_gnu_archive_bad_request/etw48ux
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341
(if (and (version< emacs-version "26.3") (>= libgnutls-version 30600))
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; Enable packages signature verification only if GPG is installed
;; (setq package-check-signature (when (executable-find "gpg") 'allow-unsigned))
;;
;; Temporary `disable' packages signature verification
(setq package-check-signature nil)

;; Change the below priorities if you prefer melpa-stable packages.
;; Higher is better.
(setq package-archive-priorities
      '(("melpa" .  4)
        ("melpa-stable" . 3)
        ("org" . 2)
        ("gnu" . 1)))

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(use-package use-package-ensure-system-package
  :ensure t)
(setq package-enable-at-startup nil)
;; Enable use-package statistics
;;
;; Before exiting call `use-package-report'. This will display a buffer
;; with all the packages you've declared with use-package and whether
;; or not they've been loaded this session (along with some other
;; useful info.
(setq use-package-compute-statistics t)

;; Bootstrap `diminish'
(unless (package-installed-p 'diminish)
  (package-refresh-contents)
  (package-install 'diminish))
(eval-when-compile
  (require 'diminish))

;; system-packages
(use-package system-packages
  :ensure t
  :config
  (when (string= system-type "darwin")
    (setq system-packages-use-sudo nil)
    (setq system-packages-package-manager 'brew))
  (when (string= system-type "gnu/linux")
    (setq system-packages-use-sudo t)))

(require 'bind-key)

;; Tell Emacs where is your personal elisp lib directory
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Tell Emacs where is your personal theme directory
(add-to-list 'custom-theme-load-path (expand-file-name "themes"
                                                       user-emacs-directory))

;; Save custom variables to custom.el
(setq custom-file (expand-file-name "custom.el"
                                    user-emacs-directory))
;; Create empty custom file if it does not exists
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(when (file-exists-p custom-file)
  (load custom-file 'noerror))


;; Personal Information
(load-file (expand-file-name "personal.el"
                             user-emacs-directory))

;; Core settings
(load-file (expand-file-name "conf/core.el"
                             user-emacs-directory))

;; Load helper functions
(load-file (expand-file-name "conf/helper-functions.el"
                             user-emacs-directory))

;; Load auto-backup packages and settings
(load-file (expand-file-name "conf/auto-backup.el"
                             user-emacs-directory))

;; Load org mode packages and settings
(load-file (expand-file-name "conf/org.el"
                             user-emacs-directory))

;; Load shell packages and settings
(load-file (expand-file-name "conf/shell.el"
                             user-emacs-directory))

;; Load narrowing packages and settings
(load-file (expand-file-name "conf/narrowing.el"
                             user-emacs-directory))

;; Load networking packages and settings
(load-file (expand-file-name "conf/networking.el"
                             user-emacs-directory))

;; Load networking packages and settings
(load-file (expand-file-name "conf/programming.el"
                             user-emacs-directory))

;; Load spell-checking packages and settings
(load-file (expand-file-name "conf/spell-checking.el"
                             user-emacs-directory))

;; Load syntax-checking packages and settings
(load-file (expand-file-name "conf/syntax-checking.el"
                             user-emacs-directory))

;; Load various packages and settings
(load-file (expand-file-name "conf/various.el"
                             user-emacs-directory))

;; Load visual packages and settings
(load-file (expand-file-name "conf/visual.el"
                             user-emacs-directory))


;;; init.el ends here
