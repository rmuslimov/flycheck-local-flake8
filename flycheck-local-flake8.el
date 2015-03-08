;;; flycheck-local-flake8.el --- Flycheck plugin for flake8 to use venv and local setup.cfg

;; Copyright © 2015 Rustem Muslimov
;;
;; Author:     Rustem Muslimov <r.muslimov@gmail.com>
;; Version:    0.0.1
;; Keywords:   flycheck, flake8, virtualenv
;; Package-Requires: ((f "0.17.2") (exec-path-from-shell) (flycheck "0.23-cvs") (pyvenv "1.6"))

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Override default flychek-flake8 checker, and ability to use
;; configured virtualenv for existing project and setup.cfg if exists
;; Based on assumption that project's directory name matches virtualenv name
;; and WORKON_HOME variable from environment configured.

;;; Code:

(require 'exec-path-from-shell)
(require 'f)
(require 'flycheck)
(require 'pyvenv)

(defun flycheck-local-flake8/get-venv-from-project-path (projectpath)
  "Calc env path from project path"
  (f-join (expand-file-name (pyvenv-workon-home))
          (car (last (split-string projectpath "/")))))

;;;###autoload
(defun flycheck-local-flake8/flycheck-virtualenv-set-python-executables ()
  (let* ((venv (expand-file-name
                (or (vc-git-root (buffer-file-name)) (f-dirname (buffer-file-name)))))
         (envpath (flycheck-local-flake8/get-venv-from-project-path (substring venv 0 -1))))
    (if (file-exists-p envpath)
        (progn
          (pyvenv-activate envpath)
          (setq-local flycheck-python-flake8-executable (executable-find "flake8"))
          (if (f-exists? (concat venv "setup.cfg"))
              (setq-local flycheck-flake8rc (concat venv "setup.cfg"))))
      (progn
        (pyvenv-deactivate)
        (exec-path-from-shell-initialize)
        (setq-local flycheck-python-flake8-executable (executable-find "flake8"))
        (if (f-exists? (expand-file-name "~/.config/flake8"))
            (setq-local flycheck-flake8rc (expand-file-name "~/.config/flake8"))))
      )))

(provide 'flycheck-local-flake8)

;;; flycheck-local-flake8.el ends here
