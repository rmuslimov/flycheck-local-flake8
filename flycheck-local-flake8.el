;;; flycheck-local-flake8.el --- Flycheck plugin for flake8 to use venv and local setup.cfg

;; Copyright © 2015 Rustem Muslimov
;;
;; Author:     Rustem Muslimov <r.muslimov@gmail.com>
;; Version:    0.0.1
;; Keywords:   flycheck, flake8, virtualenv
;; Package-Requires: ((f "0.17.2") (flycheck "0.23-cvs"))

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

(require 'f)
(require 'flycheck)


(defun flycheck-local-flake8/get-venv-from-project-path (projectpath)
  "Get env path based on folder, of no venv, assume that venv name same as foldername."
  (if (f-exists? (f-join projectpath "venv"))
	  (f-join projectpath "venv")
	(let ((workon-home (or (getenv "WORKON_HOME") "~/.virtualenvs")))
	  (f-join (expand-file-name workon-home)
			  (car (last (split-string projectpath "/")))))))

(defun flycheck-local-flake8--get-flake8-from-envpath (envpath)
  (let ((local-flake8 (f-join envpath "bin" "flake8")))
	(if (f-exists? local-flake8) local-flake8 (executable-find "flake8"))))

;;;###autoload
(defun flycheck-local-flake8/flycheck-virtualenv-set-python-executables ()
  (let* ((venv (expand-file-name
                (or (vc-git-root (buffer-file-name)) (f-dirname (buffer-file-name)))))
         (envpath (flycheck-local-flake8/get-venv-from-project-path (substring venv 0 -1))))
    (if (f-exists? envpath)
        (progn
          (setq-local flycheck-python-flake8-executable (flycheck-local-flake8--get-flake8-from-envpath envpath))
          (if (f-exists? (concat venv "setup.cfg"))
              (setq-local flycheck-flake8rc (concat venv "setup.cfg"))))
      (progn
		(executable-find "flake8")
        (if (f-exists? (expand-file-name "~/.config/flake8"))
            (setq-local flycheck-flake8rc (expand-file-name "~/.config/flake8")))))))

(provide 'flycheck-local-flake8)

;;; flycheck-local-flake8.el ends here
