;;; init-modeline.el --- Emacs configuration for modeline
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

;; Some configuration for modeline with powerline.

;;; Code:

;; powerline
(use-package powerline
  :config
  (progn
    (setq powerline-default-separator 'wave)
    (powerline-default-theme)
    ))

(use-package diminish
  :init
  (progn
    (eval-after-load 'org-indent '(diminish 'org-indent-mode))
    (eval-after-load "eldoc" '(diminish 'eldoc-mode))
    (eval-after-load "abbrev" '(diminish 'abbrev-mode " Abv"))
    (eval-after-load "subword" '(diminish 'subword-mode))
    (eval-after-load "reftex" '(diminish 'reftex-mode))
    (eval-after-load "autorevert" '(diminish 'auto-revert-mode " AR"))
    (eval-after-load "outline" '(diminish 'outline-minor-mode))
    (eval-after-load "simple" '(diminish 'visual-line-mode " Vl"))
    (eval-after-load "simple" '(diminish 'auto-fill-function " Af"))
    ))

(add-hook 'lisp-interaction-mode-hook
          #'(lambda () (setq mode-name "λ")))

(add-hook 'emacs-lisp-mode-hook
          #'(lambda () (setq mode-name "EL")))

(add-hook 'python-mode-hook
          #'(lambda () (setq mode-name "Py")))

(provide 'init-modeline)
;;; init-modeline.el ends here
