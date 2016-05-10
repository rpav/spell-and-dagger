(defpackage #:build
  (:use #:cl))
(in-package :build)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun setup-library-paths ()
    (let* ((argv0 (first sb-ext:*posix-argv*))
           (path (directory-namestring argv0)))
      (format t "Adding ~A~%" path)
      (push path cffi:*foreign-library-directories*))))
