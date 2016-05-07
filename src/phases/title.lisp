(in-package :game)

(defclass title-phase (game-phase)
  ((screen :initform (make-instance 'title-screen))))

(defmethod phase-resume ((p title-phase))
  (ps-incref)
  (with-slots (screen) p
    (setf (ui-visible screen) t)))

(defun title-start ()
  (ps-push (make-instance 'map-phase))
  (ps-decref))
