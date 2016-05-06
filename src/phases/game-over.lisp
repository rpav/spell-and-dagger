(in-package :game)

(defclass game-over-phase (game-phase)
  ((screen :initform (make-instance 'game-over-screen))))

(defmethod phase-resume ((p game-over-phase))
  (ps-incref)
  (with-slots (screen) p
    (setf (ui-visible screen) t)))
