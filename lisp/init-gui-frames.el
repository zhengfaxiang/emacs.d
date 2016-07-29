;;; init-gui-frames.el --- Emacs configuration for graphics display
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

;; Some configuration for graphics display.

;;; Code:

;; Supress GUI features
(setq ring-bell-function 'ignore)
(setq use-file-dialog nil
      visible-bell nil
      use-dialog-box nil
      inhibit-startup-screen t)

;; https://www.masteringemacs.org/article/disabling-prompts-emacs
(eval-after-load "startup"
  '(fset 'display-startup-echo-area-message (lambda ())))

(when (fboundp 'blink-cursor-mode)
  (blink-cursor-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '("Emacs  "
        (:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; (setq initial-major-mode 'org-mode)
(setq initial-scratch-message
      (concat
       "\n"
       ";;         ::::::::::   :::   :::       :::      ::::::::   ::::::::\n"
       ";;        :+:         :+:+: :+:+:    :+: :+:   :+:    :+: :+:    :+:\n"
       ";;       +:+        +:+ +:+:+ +:+  +:+   +:+  +:+        +:+\n"
       ";;      +#++:++#   +#+  +:+  +#+ +#++:++#++: +#+        +#++:++#++\n"
       ";;     +#+        +#+       +#+ +#+     +#+ +#+               +#+\n"
       ";;    #+#        #+#       #+# #+#     #+# #+#    #+# #+#    #+#\n"
       ";;   ########## ###       ### ###     ###  ########   ########\n\n\n"))


;; time display
(setq display-time-default-load-average nil)
(display-time)

;; http://andrewjamesjohnson.com/suppressing-ad-handle-definition-warnings-in-emacs/
(setq ad-redefinition-action 'accept)

;; draw underline lower
(setq x-underline-at-descent-line t)

;; Toggle line highlighting in all buffers
(global-hl-line-mode t)

;; pretty symbols
(when (fboundp 'global-prettify-symbols-mode)
  (global-prettify-symbols-mode))

;; don't let the cursor go into minibuffer prompt
;; Tip taken from Xah Lee: http://ergoemacs.org/emacs/emacs_stop_cursor_enter_prompt.html
(setq minibuffer-prompt-properties
      '(read-only
        t
        point-entered
        minibuffer-avoid-prompt
        face
        minibuffer-prompt))

;; remove annoying ellipsis when printing sexp in message buffer
(setq eval-expression-print-length nil
      eval-expression-print-level nil)

;; remove prompt if the file is opened in other clients
(defun server-remove-kill-buffer-hook ()
  (remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function))
(add-hook 'server-visit-hook 'server-remove-kill-buffer-hook)

;; Show a marker in the left fringe for lines not in the buffer
(setq-default indicate-empty-lines t)
(define-fringe-bitmap 'tilde [0 0 0 113 219 142 0 0] nil nil 'center)
(setcdr (assq 'empty-line fringe-indicator-alist) 'tilde)
(set-fringe-bitmap-face 'tilde 'font-lock-type-face)

;; adjust opacity
(defun adjust-opacity (frame incr)
  (let* ((oldalpha (or (frame-parameter frame 'alpha) 100))
         (newalpha (+ incr oldalpha)))
    (when (and (<= frame-alpha-lower-limit newalpha) (>= 100 newalpha))
      (modify-frame-parameters frame (list (cons 'alpha newalpha))))))

(global-set-key (kbd "C-M-8") (lambda ()
                                (interactive)
                                (adjust-opacity nil -5)))
(global-set-key (kbd "C-M-9") (lambda ()
                                (interactive)
                                (adjust-opacity nil 5)))
(global-set-key (kbd "C-M-0") (lambda ()
                                (interactive)
                                (modify-frame-parameters
                                 nil
                                 `((alpha . 100)))))

(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame
              (unless window-system
                (set-frame-parameter nil 'menu-bar-lines 0)))))

(global-set-key (kbd "<f11>") 'toggle-frame-fullscreen)
(global-set-key (kbd "M-<f11>") 'toggle-frame-maximized)

;; https://gist.github.com/3402786
(defun fx/toggle-maximize-buffer ()
  "Toggle maximize buffer."
  (interactive)
  (if (and (= 1 (length (window-list)))
           (assoc ?_ register-alist))
      (jump-to-register ?_)
    (progn
      (window-configuration-to-register ?_)
      (delete-other-windows))))
(global-set-key (kbd "<f12>") #'fx/toggle-maximize-buffer)

(provide 'init-gui-frames)
;;; init-gui-frames.el ends here
