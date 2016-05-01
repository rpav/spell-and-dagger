;;; Physics! .. I use that term _very_ loosely.

(in-package :game)

(defclass physics ()
  ((last-time :initform 0.0)
   (timestep :initform (/ 1.0 60.0))
   (objects :initform nil)))

(defun physics-add (phys &rest list)
  (with-slots (objects) phys
    (loop for ob in list
          do (push ob objects))))

(defun physics-clear (phys)
  (with-slots (objects) phys
    (setf objects nil)))

(defun physics-start (phys)
  (with-slots (last-time) phys
    (setf last-time (current-time))))

(defun physics-update (phys)
  (with-slots (last-time timestep) phys
    (let* ((diff (- *time* last-time))
           (steps (truncate diff timestep)))
      ;; Just let this depend on vsync for now, which isn't ideal, but
      ;; whatever
      (physics-step phys)
      (setf last-time *time*))))

(defun physics-step (phys)
  (with-slots (objects) phys
    (loop for ob in objects
          do (entity-update ob))))
