;;; init-editing-utils.el --- Emacs configuration for editing
;;
;; Copyright (c) 2015-2016 Faxiang Zheng
;;
;; Author: Faxiang Zheng <fxzheng0906@outlook.com>
;; URL: https://github.com/zhengfaxiang/emacs.d
;;
;; This file is not part of GNU Emacs.
;;
;; License: GPLv3

;;; Commentary:

;; Some configuration for better editing experience.

;;; Code:

;; some basic preferences
(setq mouse-yank-at-point t
      buffers-menu-max-size 30
      case-fold-search t
      compilation-scroll-output 'first-error
      set-mark-command-repeat-pop t
      delete-selection-mode t
      kill-whole-line t)

;; no beep or visual blinking!
(setq ring-bell-function 'ignore
      visible-bell nil)

;; Hack to fix a bug with tabulated-list.el
;; see: http://redd.it/2dgy52
(defun tabulated-list-revert (&rest ignored)
  "The `revert-buffer-function' for `tabulated-list-mode'.
It runs `tabulated-list-revert-hook', then calls `tabulated-list-print'."
  (interactive)
  (unless (derived-mode-p 'tabulated-list-mode)
    (error "The current buffer is not in Tabulated List mode"))
  (run-hooks 'tabulated-list-revert-hook)
  ;; hack is here
  ;; (tabulated-list-print t)
  (tabulated-list-print))

;; cursor don't blink
(blink-cursor-mode -1)

;; Mouse cursor in terminal mode
(xterm-mouse-mode 1)

;; https://www.gnu.org/software/emacs/manual/html_node/emacs/General-VC-Options.html
(setq vc-follow-symlinks t)

;; persistent abbreviation file
(setq abbrev-file-name (concat fx-cache-directory "abbrev_defs"))

;; Text
(setq longlines-show-hard-newlines t)

;; Single space between sentences is more widespread than double
(setq-default sentence-end-double-space nil)

;; disable overwrite mode
(put 'overwrite-mode 'disabled t)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; seems pointless to warn. There's always undo.
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

(global-set-key (kbd "C-x f") nil)
(global-set-key (kbd "C-x f e") 'erase-buffer)

(global-set-key (kbd "M-u") 'upcase-dwim)
(global-set-key (kbd "M-l") 'downcase-dwim)

;; join line
(global-set-key (kbd "C-c j") 'join-line)
(global-set-key (kbd "C-c J") #'(lambda () (interactive) (join-line 1)))

;; Change "yes or no" to "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; doc view
(setq doc-view-continuous t)

;; http://emacswiki.org/emacs/RevertBuffer
(global-set-key
 (kbd "<f5>")
 (lambda (&optional force-reverting)
   "Interactive call to revert-buffer. Ignoring the auto-save
 file and not requesting for confirmation. When the current buffer
 is modified, the command refuses to revert it, unless you specify
 the optional argument: force-reverting to true."
   (interactive "P")
   ;;(message "force-reverting value is %s" force-reverting)
   (if (or force-reverting (not (buffer-modified-p)))
       (revert-buffer :ignore-auto :noconfirm)
     (error "The buffer has been modified"))))

;; Auto refresh
(global-auto-revert-mode t)
;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(defun fx/dos2unix ()
  "Convert the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))
(defun fx/unix2dos ()
  "Convert the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))
(global-set-key (kbd "C-x f c u") #'fx/dos2unix)
(global-set-key (kbd "C-x f c d") #'fx/unix2dos)

;; http://camdez.com/blog/2013/11/14/emacs-show-buffer-file-name/
(defun fx/show-and-copy-buffer-filename ()
  "Show the full path to the current file in the minibuffer."
  (interactive)
  ;; list-buffers-directory is the variable set in dired buffers
  (let ((file-name (or (buffer-file-name) list-buffers-directory)))
    (if file-name
        (message (kill-new file-name))
      (error "Buffer not visiting a file"))))
(global-set-key (kbd "C-x f y") #'fx/show-and-copy-buffer-filename)

;; fill column indicator
(use-package fill-column-indicator
  :init
  (progn
    (setq fci-rule-width 1)
    ;; (setq fci-rule-column 80)
    ;; (setq fci-rule-color "dimgray")
    (dolist (hook '(prog-mode-hook
                    markdown-mode-hook
                    git-commit-mode-hook))
      (add-hook hook 'fci-mode))
    ;; Regenerate fci-mode line images after switching themes
    (defun sanityinc/fci-enabled-p ()
      (bound-and-true-p fci-mode))
    (defadvice enable-theme (after recompute-fci-face activate)
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (sanityinc/fci-enabled-p)
            (turn-on-fci-mode)))))))

(use-package ediff
  :defer t
  :init
  (progn
    (setq-default
     ediff-window-setup-function 'ediff-setup-windows-plain
     ;; emacs is evil and decrees that vertical shall henceforth be horizontal
     ediff-split-window-function 'split-window-horizontally
     ediff-merge-split-window-function 'split-window-horizontally)
    (add-hook 'ediff-quit-hook #'winner-undo)))

;; page break lines
(use-package page-break-lines
  :diminish page-break-lines-mode
  :init
  (global-page-break-lines-mode))

(use-package expand-region
  :bind
  (("C-M-]" . er/expand-region)
   ("C-M-[" . er/contract-region)))

(use-package undo-tree
  :diminish undo-tree-mode
  :init
  (progn
    (defalias 'redo 'undo-tree-redo)
    (defalias 'undo 'undo-tree-undo)
    (global-undo-tree-mode))
  :config
  (progn
    (setq undo-tree-auto-save-history t)
    (let ((undo-dir (concat fx-cache-directory "undo/")))
      (setq undo-tree-history-directory-alist
            `(("." . ,undo-dir)))
      (unless (file-exists-p undo-dir)
        (make-directory undo-dir t)))))

(use-package highlight-symbol
  :diminish hi-lock-mode
  :diminish highlight-symbol-mode
  :defer t
  :init
  (dolist (hook '(prog-mode-hook html-mode-hook css-mode-hook))
    (add-hook hook 'highlight-symbol-mode)
    (add-hook hook 'highlight-symbol-nav-mode))
  :bind
  ("M-s r" . highlight-symbol-query-replace))

(use-package highlight-numbers
  :defer t
  :init
  (progn
    (add-hook 'prog-mode-hook 'highlight-numbers-mode)
    (add-hook 'asm-mode-hook (lambda () (highlight-numbers-mode -1)))))

(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package which-key
  :diminish which-key-mode
  :init
  (progn
    (setq which-key-use-C-h-for-paging t
          which-key-prevent-C-h-from-cycling t
          which-key-sort-order 'which-key-key-order-alpha
          which-key-popup-type 'side-window
          which-key-side-window-location 'bottom
          which-key-max-description-length 26
          which-key-side-window-max-height 0.4
          which-key-special-keys nil)
    (which-key-mode)))

;; anzu
(use-package anzu
  :defer t
  :init (global-anzu-mode t)
  :bind (("M-%" . anzu-query-replace)
         ("C-M-%" . anzu-query-replace-regexp))
  :config
  (custom-set-variables
   '(anzu-mode-lighter "")
   '(anzu-deactivate-region t)
   '(anzu-search-threshold 1000)
   '(anzu-replace-to-string-separator " => ")))

;; avy
(use-package avy
  :bind
  (("M-s s" . avy-goto-char)
   ("M-s w" . avy-goto-word-or-subword-1)
   ("M-s l" . avy-goto-line)
   ("M-s m" . avy-pop-mark)))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)
         ("C-c m r" . set-rectangular-region-anchor)
         ("C-c m c" . mc/edit-lines)
         ("C-c m e" . mc/edit-ends-of-lines)
         ("C-c m a" . mc/edit-beginnings-of-lines))
  :init
  (setq mc/list-file (concat fx-cache-directory "mc-lists.el")))

(use-package crux
  :init
  (progn
    (global-set-key [remap move-beginning-of-line]
                    #'crux-move-beginning-of-line)
    (global-set-key [remap kill-whole-line] #'crux-kill-whole-line)
    (global-set-key (kbd "C-x f o") #'crux-open-with)
    (global-set-key (kbd "C-o") #'crux-smart-open-line)
    (global-set-key (kbd "C-S-o") #'crux-smart-open-line-above)
    (global-set-key (kbd "C-<backspace>") #'crux-kill-line-backwards)
    (global-set-key (kbd "C-x f r") #'crux-rename-file-and-buffer)
    (global-set-key (kbd "C-x f d") #'crux-delete-file-and-buffer)
    (global-set-key (kbd "C-x f s") #'crux-sudo-edit)
    ))

(use-package hungry-delete
  :diminish hungry-delete-mode
  :defer t
  :init (global-hungry-delete-mode)
  :config
  (progn
    (setq-default hungry-delete-chars-to-skip " \t\f\v")
    (define-key hungry-delete-mode-map (kbd "DEL") 'hungry-delete-backward)
    (define-key hungry-delete-mode-map (kbd "S-DEL") 'delete-backward-char)))

(use-package adaptive-wrap
  :config
  (progn
    (add-hook 'visual-line-mode-hook 'adaptive-wrap-prefix-mode)))

(use-package iedit
  :commands (iedit-mode
             iedit-mode-toggle-on-function
             iedit-rectangle-mode)
  :bind (("C-;" . iedit-mode)
         ("C-h C-;" . iedit-mode-toggle-on-function)
         ("C-x r <return>" . iedit-rectangle-mode)))

(use-package info+
  :defer t
  :init
  (progn
    (with-eval-after-load 'info
      (require 'info+))
    (setq Info-fontify-angle-bracketed-flag nil)))

(provide 'init-editing-utils)
;;; init-editing-utils.el ends here
