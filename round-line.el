;;; round-line.el --- Cool rounded modeline for emacs -*- lexical-binding:t -*-
;;
;; Author: pablololo12
;; URL: https://github.com/Pablololo12/round-line.el
;; Version: 0.1
;; Keywords: frames convenience terminals
;; Package-Requires: ((emacs "25.1"))
;;
;;; License
;; This file is not part of GNU Emacs.
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;; Term-control allows to easily handle pop-up vterm windows in your emacs.
;;
;;; Code:

(defface round-line-sep
  '((t (:inherit mode-line)))
  "Face for the leftmost separator in the mode line.")

(defun round-line-sep-update ()
  (let ((bg (face-background 'default nil t))
        (fg (face-background 'mode-line nil t)))
    (set-face-attribute 'round-line-sep nil
                        :background bg
                        :foreground fg)))

(defface round-line-empty
  '((t (:inherit mode-line)))
  "Face for the leftmost separator in the mode line.")

(defun round-line-empty-update ()
  (let ((bg (face-background 'default nil t))
        (fg (face-background 'mode-line nil t)))
    (set-face-attribute 'round-line-empty nil
                        :background bg
                        :foreground fg)))

(defun round-line-update-colors ()
  (round-line-sep-update)
  (round-line-empty-update))

(add-hook 'enable-theme-functions
          (lambda (_theme) (round-line-update-colors)))

(add-hook 'after-make-frame-functions
          (lambda (f) (with-selected-frame f (round-line-update-colors))))

(round-line-update-colors)

(setq mode-line-format-right-align
      '(:eval
        (propertize " "
                    'face 'round-line-empty
                    'display '(space :align-to (- right 0)))))


(column-number-mode 1)
(setq-default mode-line-format
  `(
    (:propertize " " face round-line-empty)
    (:propertize "" face round-line-sep)
    mode-line-modified mode-line-remote
    (:propertize "" face round-line-sep)
    (:propertize " " face round-line-empty)

    (:propertize "" face round-line-sep)
    mode-line-buffer-identification
    (:propertize "" face round-line-sep)
    (:propertize " " face round-line-empty)

    (:propertize "" face round-line-sep)
    mode-line-position
    (:propertize "" face round-line-sep)
    (:propertize " " face round-line-empty)

    (:eval
     (when vc-mode
       (concat
        (propertize "" 'face 'round-line-sep)
        (format "%s" vc-mode)
        (propertize "" 'face 'round-line-sep))))

    ;; right-align spacer with your face
    (:eval
     (propertize
      " "
      'display
      `(space :align-to
              (- (+ right right-fringe right-margin)
                 ,(+ 3 (string-width mode-name))))
      'face 'round-line-empty))

    (:propertize "" face round-line-sep)
    (:propertize "%m" 'face 'font-lock-string-face)
    (:propertize "" face round-line-sep)
    (:propertize " " face round-line-empty)
    ))

(advice-add #'vc-git-mode-line-string :filter-return #'round-line-git-status)
(defun round-line-git-status (tstr)
  (let* ((tstr (replace-regexp-in-string "Git" "" tstr))
         (first-char (substring tstr 0 1))
         (rest-chars (substring tstr 1)))
    (cond
     ((string= ":" first-char) ;;; Modified
      (replace-regexp-in-string "^:" "✗ " tstr))
     ((string= "-" first-char) ;; No change
      (replace-regexp-in-string "^-" "✔ " tstr))
     (t tstr))))

(setopt mode-line-modified
        '((:eval
           (cond
            (buffer-read-only (propertize "×" 'face 'error))
            ((buffer-modified-p) (propertize "●" 'face 'warning))
            (t (propertize "●" 'face 'success))))))

(setopt mode-line-remote
        '(:eval (if (file-remote-p default-directory) "☎" "")))

(setq-default mode-line-position
              '((line-number-mode ("%l"))
                (column-number-mode (":" "%c"))))

(setq evil-mode-line-format nil)
(setopt mode-line-right-align-edge 'window)

(provide 'round-line)
