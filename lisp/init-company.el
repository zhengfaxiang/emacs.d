;;; init-company.el --- Emacs configuration for company-mode
;; -*- coding: utf-8 -*-
;;
;; Copyright (c) 2015-2021 Faxiang Zheng
;;
;; Author: Faxiang Zheng <fxzheng0906@outlook.com>
;; URL: https://github.com/zhengfaxiang/emacs.d
;;
;; This file is not part of GNU Emacs.
;;
;; License: GPLv3

;;; Commentary:

;; Some configuration for automatic completion using company-mode.

;;; Code:

(use-package company
  :diminish company-mode
  :init
  (progn
    (setq company-idle-delay 0.2
          company-minimum-prefix-length 2
          company-require-match nil
          company-dabbrev-ignore-case nil
          company-dabbrev-downcase nil
          company-show-numbers t
          company-auto-complete nil
          company-tooltip-align-annotations t)
    (setq company-backends '(company-capf
                             company-files
                             (company-dabbrev-code
                              company-etags
                              company-keywords)
                             company-dabbrev))
    (make-variable-buffer-local 'company-backends)
    (global-company-mode))
  :config
  (progn
    (define-key company-active-map (kbd "C-h") 'company-abort)
    (defun fx/toggle-shell-auto-completion-based-on-path ()
      "Suppress automatic completion on remote paths."
      (if (file-remote-p default-directory)
          (setq-local company-idle-delay nil)
        (setq-local company-idle-delay 0.2)))
    (add-hook 'eshell-directory-change-hook
              'fx/toggle-shell-auto-completion-based-on-path)))

(use-package company-quickhelp
  :if (display-graphic-p)
  :after company
  :config
  (progn
    (add-hook 'company-mode-hook 'company-quickhelp-mode)
    (setq company-frontends
          (delq 'company-echo-metadata-frontend company-frontends))))

(use-package company-statistics
  :after company
  :config
  (progn
    (setq company-statistics-file (concat fx-cache-directory
                                          "company-statistics-cache.el"))
    (add-hook 'company-mode-hook 'company-statistics-mode)))

(defun fx/company-for-tex ()
  (use-package company-auctex
    :after company
    :config
    (progn
      (add-to-list 'company-backends
                   '(company-auctex-labels :with company-yasnippet))
      (add-to-list 'company-backends
                   '(company-auctex-bibs :with company-yasnippet))
      (add-to-list 'company-backends
                   '(company-auctex-macros
                     company-auctex-symbols
                     company-auctex-environments
                     :with company-yasnippet))
      )))

(defun fx/company-for-python ()
  (use-package company-jedi
    :after company
    :config
    (progn
      (add-to-list 'company-backends
                   '(company-jedi :with company-yasnippet)))))

(defun fx/company-for-c-c++ ()
  (use-package company-irony
    :after company
    :config
    (progn
      (require 'company-irony-c-headers)
      (add-to-list 'company-backends
                   '(company-irony-c-headers
                     company-irony
                     :with company-yasnippet)))))

(defun fx/company-for-css ()
  (add-to-list 'company-backends
               '(company-css :with company-yasnippet)))

(defun fx/company-for-nxml ()
  (add-to-list 'company-backends '(company-nxml :with company-yasnippet)))

(defun fx/company-ispell-setup ()
  (add-to-list 'company-backends 'company-ispell)
  (setq ispell-complete-word-dict
        (file-truename "~/.emacs.d/misc/english-words.txt")))

(add-hook 'text-mode-hook #'fx/company-ispell-setup)

(add-hook 'css-mode-hook #'fx/company-for-css)

(add-hook 'nxml-mode-hook #'fx/company-for-nxml)

(dolist (hook '(LaTeX-mode-hook TeX-mode-hook))
  (add-hook hook 'fx/company-for-tex))

(add-hook 'python-mode-hook 'fx/company-for-python)

(dolist (hook '(c-mode-hook c++-mode-hook objc-mode-hook))
  (add-hook hook 'fx/company-for-c-c++))

(provide 'init-company)
;;; init-company.el ends here
