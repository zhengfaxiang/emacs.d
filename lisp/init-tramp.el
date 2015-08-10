;; http://www.quora.com/Whats-the-best-way-to-edit-remote-files-from-Emacs
(setq-default tramp-default-method "ssh")
(setq-default tramp-auto-save-directory "~/.backups/tramp/")
(setq-default tramp-chunksize 8192)

;; https://github.com/syl20bnr/spacemacs/issues/1921
(setq-default tramp-ssh-controlmaster-options
              "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=no")

;; sudo save
(defun sudo-save ()
  (interactive)
  (if (not buffer-file-name)
      (write-file (concat "/sudo:root@localhost:" (ido-read-file-name "File:")))
    (write-file (concat "/sudo:root@localhost:" buffer-file-name))))
(global-set-key (kbd "C-x M-s") 'sudo-save)

(provide 'init-tramp)
