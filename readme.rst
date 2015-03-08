Use local flake8 for flycheck
=============================

This is plugin for popular emacs flycheck for python. Everytime check starts plugin calculates proper flake8 (from virtualenv), and sets project's setup.cfg if available. It works more proper way than default checker.

Installation
------------

Make sure that package avaialble for emacs, and to your init.el

::

  (require 'flycheck-local-flake8)
  (add-hook 'flycheck-before-syntax-check-hook
            #'flycheck-local-flake8/flycheck-virtualenv-set-python-executables 'local)

Check:
------

Run `C-c ! v` in python-file buffer and see that flake8 imported from virtualenv.
