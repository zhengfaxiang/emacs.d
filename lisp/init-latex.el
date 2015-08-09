(setq LaTeX-indent-level 4)
(setq-default TeX-master nil)
(setq-default TeX-newline-function 'newline-and-indent)
(setq-default TeX-engine 'xetex)
(setq-default TeX-auto-untabify t
              TeX-show-compilation t
              TeX-auto-save t
              TeX-parse-self t
              LaTeX-syntactic-comments t
              TeX-save-query nil
              reftex-plug-into-AUCTeX t)

(cond
     ((executable-find "okular")
      (setq TeX-view-program-selection
            '((output-pdf "Okular")
              (output-dvi "Okular"))))
     ((executable-find "evince")
      (setq TeX-view-program-selection
            '((output-pdf "Evince")
              (output-dvi "Evince"))))
     (t
      (setq TeX-view-program-selection
            '((output-pdf "xdg-open")
              (output-dvi "xdg-open")))))

(add-hook 'LaTeX-mode-hook
	  (lambda ()
            (imenu-add-menubar-index)
            (LaTeX-math-mode t)
            (flycheck-mode -1)
            (reftex-mode t)))

(add-hook 'TeX-mode-hook
	  (lambda ()
	    (outline-minor-mode t)
	    (flyspell-mode t)
	    (TeX-interactive-mode t)
	    (TeX-PDF-mode t)
	    (TeX-fold-mode t)
	    (visual-line-mode t)))

(provide 'init-latex)