;;; init-helm.el --- Helm stuff -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'helm)
(require 'subr-x)
(require 'evil-jumps)

(spacemacs/set-leader-keys "x r h" #'helm-regexp)

(defun mabo3n/helm-jump-in-buffer ()
  "Store `point' value then prompt."
  (interactive)
  (setq mabo3n/point-before-helm-jump-in-buffer (point))
  (lazy-helm/spacemacs/helm-jump-in-buffer))

(spacemacs/set-leader-keys "s j" #'mabo3n/helm-jump-in-buffer)

(defun mabo3n/set-evil-jump-previous-position ()
  "If `point' has changed, set an evil jump to its previous position."
  (when-let* ((prev-point mabo3n/point-before-helm-jump-in-buffer)
              (changedp (not (eq (point) prev-point))))
    (evil-set-jump prev-point)))

(add-hook 'imenu-after-jump-hook #'mabo3n/set-evil-jump-previous-position)

;; Make `helm-find-files' always expand symlinks to directories
;; This was the default behavior but now requires a prefix arg
;; https://github.com/emacs-helm/helm/issues/1121
(defun mabo3n/helm-ff-always-expand-symlink-dirs (fun &rest args)
  "Set `current-prefix-arg' if current selection is a dir symlink."
  (let ((candidate (car args)))
    (when (and candidate
               (not current-prefix-arg)
               (file-directory-p candidate)
               (file-symlink-p candidate))
      (message "Auto applying C-u to expand symlink")
      (setq current-prefix-arg '(4)))
    (apply fun args)))

(advice-add #'helm-find-files-persistent-action-if :around
            #'mabo3n/helm-ff-always-expand-symlink-dirs)

(provide 'init-helm)
;;; init-helm.el ends here
