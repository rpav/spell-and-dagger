;;; Some of this may have been scraped from elsewhere

(in-package :game)

(defvar +time-units+ (coerce internal-time-units-per-second 'float))

(declaim (inline time-to-float))
(declaim (ftype (function (integer) float) time-to-float))
(defun time-to-float (time)
  (/ time +time-units+))

(defun current-time ()
  (time-to-float (get-internal-real-time)))
