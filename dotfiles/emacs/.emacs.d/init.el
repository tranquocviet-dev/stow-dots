;; -*- lexical-binding: t -*-
(setq create-lockfiles nil) ; Set to t if you want locks, but storing them centrally requires extra setup
(setq backup-directory-alist `(("." . ,(expand-file-name "emacs/backups" user-emacs-directory))))
(setq auto-save-default t)
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "emacs/autosaves/" user-emacs-directory) t)))

;; 1 package setup

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t) ; Automatically install missing packages via MELPA

;; visual

(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 200
                    :weight 'normal)
(set-face-attribute 'variable-pitch nil
  		    :family "Iosevka Aile"
  		    :height 1.0
  		    :weight 'normal)
(set-face-attribute 'fixed-pitch nil
  		    :inherit 'default)
(set-face-attribute 'line-number nil :inherit 'default :height 1.0)
(set-face-attribute 'line-number-current-line nil :inherit 'default :height 1.0)
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))
(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode))

;; 2 emacs command handling

(use-package savehist
  :init
  (savehist-mode 1))
(fido-mode 1)
(use-package minibuffer
  :ensure nil
  :custom
  (completion-show-help nil)
  (completion-show-inline-help nil)
  (completions-detailed t)
  (completion-auto-help t)
  (completion-auto-update t)
  (completions-format 'one-column)          ; Renders a clean single vertical column
  (completions-max-height 12)
  (completion-auto-select nil)
  (completions-sort 'historical)
  (minibuffer-visible-completions t))

;; 3 completion suite
;; 3.1 completion-preview-mode (native)

(use-package completion-preview
  :ensure nil ; Built-in to Emacs 30+
  :demand t
  :bind
  (:map completion-preview-active-mode-map
        ("<tab>" . completion-preview-complete)
        ("M-n" . completion-preview-next-candidate)
        ("M-p" . completion-preview-prev-candidate)
        ("M-<return>" . completion-preview-insert)
        ("M-i" . completion-preview-insert-word))
  :config
  (setq completion-preview-minimum-symbol-length 2)
  (global-completion-preview-mode 1))
(use-package cape
  :ensure t
  :init
  ;; Add useful CAPFs to the global completion list
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; 3.2 company-mode

;; (use-package company
;;   :ensure t
;;   :config
;;   (global-company-mode nil))

;; 4 format-on-save

;; (use-package apheleia
;;   :config
;;   (setf (alist-get 'alejandra apheleia-formatters)
;;         '("alejandra" "--quiet" "-"))
;;   (setf (alist-get 'nix-mode apheleia-mode-alist) '(alejandra))
;;   (setf (alist-get 'simpc-mode apheleia-mode-alist) '(clang-format))
;;   (apheleia-global-mode 1))

;; 5 language support
(use-package web-mode
  :ensure t
  :mode
  (("\\.phtml\\'" . web-mode)
   ("\\.php\\'" . web-mode)
   ("\\.tpl\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)))
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(defalias 'c-mode 'simpc-mode)
(defalias 'c++-mode 'simpc-mode)
(use-package sql
  :custom
  (sql-mysql-program "mariadb")
  (sql-connection-alist
   '((sql-conn
      (sql-product 'mysql)
      (sql-user "root")
      (sql-database "joke_basic")
      (sql-options '("--table" "--unbuffered")))))
  :config
  (sql-set-product-feature 'mysql :prompt-regexp "^\\(MariaDB\\|MySQL\\) \\[[^]]*\\]> *")
  (add-hook 'sql-interactive-mode-hook
            (lambda ()
	      (setq-local comint-process-echoes t)
	      (setq truncate-lines t))))
(use-package org
  :ensure nil
  :hook ((org-mode . auto-fill-mode)
         (org-mode . (lambda () (setq fill-column 80))))
  :bind
  (("C-c a" . org-agenda)))
(use-package nix-mode
  :mode "\\.nix\\'")
(use-package typst-ts-mode
  :ensure t
  :mode "\\.typ\\'")
(use-package qml-mode
  :mode "\\.qml$")
(use-package go-mode
  :ensure t
  :mode "\\.go\\'")

;; 5.1 lsp

;; (use-package eglot
;;   :hook (((prog-mode) . (lambda ()
;;                           (unless (derived-mode-p 'emacs-lisp-mode)
;;                             (eglot-ensure))))
;;          (typst-ts-mode . eglot-ensure))
;;   :config
;;   (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
;;   (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist" "lsp")))
;;   (add-to-list 'eglot-server-programs '((qml-mode qml-ts-mode) . ("qmlls" "-E")))
;;   (add-to-list 'eglot-server-programs '(simpc-mode . ("clangd"))))

;; 6 misc

(use-package pdf-tools
  :init
  (pdf-tools-install :no-query)
  :hook (pdf-view-mode . (lambda() (display-line-numbers-mode -1)))
  :config
  (setq-default pdf-view-display-size 'fit-page))
(use-package magit
  :bind
  ("C-x g" . magit-status))
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/notess"))
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-db-autosync-mode))
(use-package move-text
  :ensure t
  :bind
  (("M-p" . move-text-up)
   ("M-n" . move-text-down)))
(use-package envrc
  :hook (after-init . envrc-global-mode))
(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (require 'emms-tag-editor)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))
(defun rc/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (duplicate-line)
  (next-line))
(global-set-key (kbd "C-,") 'rc/duplicate-line)
(setq custom-file "~/.emacs.d/custom.el")
(setq org-agenda-files '("~/notess/"))
(setq make-backup-files nil)
(setq ido-auto-merge-work-directories-length -1)
(setq emms-volume-change-function #'emms-volume-mpv-change)
(with-eval-after-load 'emms-playlist-mode
  (keymap-set emms-playlist-mode-map "C-<wheel-up>" #'emms-volume-raise)
  (keymap-set emms-playlist-mode-map "C-<wheel-down>" #'emms-volume-lower)
  (keymap-set emms-playlist-mode-map "C-<mouse-4>" #'emms-volume-raise)
  (keymap-set emms-playlist-mode-map "C-<mouse-5>" #'emms-volume-lower))
(setq-default fill-column 80)
(use-package autorevert
  :ensure nil
  :custom
  (global-auto-revert-non-file-buffers t)
  (auto-revert-verbose nil)
  :config
  (global-auto-revert-mode 1))
(use-package project
  :custom
  (project-switch-commands #'project-dired))
(setq read-buffer-completion-ignore-case t)
(setq completion-ignore-case t)
;; Keep case when replacing/completing if uppercase letters are typed
(setq search-upper-case t)
(setq dired-dwim-target t)
(use-package elfeed
  :ensure t
  :config
  (setq elfeed-feeds
        '("https://lwn.net/headlines/newrss"
          "https://www.phoronix.com/phoronix-rss-feed.xml"
          "https://www.omgubuntu.co.uk/feed"
          "https://itsfoss.com/feed/"
          "https://www.gamingonlinux.com/article_rss.php"
          "https://www.redhat.com/en/blog/rss.xml"
          "https://archlinux.org/news/news.xml")))
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  ;; Match as prefix first; if space-separated words are given, match out-of-order
  (orderless-matching-styles '(orderless-initialism
			       orderless-prefixes
			       orderless-regexp)))
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))
(defun kill-other-buffers ()
  "Kill all buffers except the current one."
  (interactive)
  (mapc #'kill-buffer (delq (current-buffer) (buffer-list))))

(add-hook 'before-save-hook #'delete-trailing-whitespace)

(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode t))
(setq modus-themes-italic-constructs t)
(setq modus-themes-bold-constructs t)
(setq modus-themes-mixed-fonts t) ; Helps when mixing fixed-pitch and variable-pitch fonts in Org mode
(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-auto-links t
        org-appear-auto-emphasis t
        org-appear-auto-entities t
        org-appear-auto-keywords t))
(use-package dumb-jump
  :ensure t
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  :config
  (setq dumb-jump-prefer-searcher 'rg))
;; Global indentation settings
(setq-default tab-width 4)          ; Change 4 to your preferred width (e.g., 2 or 8)
(setq-default indent-tabs-mode t)   ; Set to t to use actual tabs, or nil to use spaces
(use-package nerd-icons)
(use-package neotree
  :ensure t
  :config
  (setq neo-theme 'nerd-icons)
  (setq neo-vc-integration '(face char)))
(add-hook 'neo-after-create-hook
          (lambda (_string)
            (save-selected-window
              (neo-global--select-window)
              (neotree-refresh))))
