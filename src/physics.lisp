;;; Physics! .. I use that term _very_ loosely.

(in-package :game)

(defclass physics ()
  ((last-time :initform 0.0)
   (timestep :initform (/ 1.0 60.0))
   (objects :initform (make-hash-table))))

(defun physics-add (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob in list
          do (setf (gethash ob objects) t))))

(defun physics-remove (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob in list
          do (remhash ob objects))))

(defun physics-clear (phys)
  (declare (type physics phys))
  (with-slots (objects) phys
    (setf objects nil)))

(defun physics-start (phys)
  (declare (type physics phys))
  (with-slots (last-time) phys
    (setf last-time (current-time))))

(defun physics-update (phys)
  (declare (type physics phys))
  (with-slots (last-time timestep) phys
    (let* ((diff (- *time* last-time))
           (steps (truncate diff timestep)))
      ;; Just let this depend on vsync for now, which isn't ideal, but
      ;; whatever
      (physics-step phys)
      (setf last-time *time*))))

(defun physics-step (phys)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob being each hash-key of objects
          do (entity-update ob))))
