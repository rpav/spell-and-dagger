(in-package :cl-user)
(defpackage :build
  (:use #:cl)
  (:export *name* *system* *binary* *startup*))

(in-package :build)
(defvar *name* nil)
(defvar *system* nil)
(defvar *binary* nil)
(defvar *startup* nil)


(in-package :cl-user)
(defpackage+-1:defpackage+ :game
  (:use #:cl #:alexandria #:util.rpav-1)
  (:import-except #:gk #:create #:process #:destroy)
  (:export #:run))

(in-package :game)

 ;; Variables

