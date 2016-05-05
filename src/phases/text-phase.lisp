(in-package :game)

(defclass text-phase (game-phase)
  ((text-screen :initform nil)))

(defmethod initialize-instance :after ((p text-phase) &key text &allow-other-keys)
  (with-slots (text-screen) p
    (setf text-screen
          (make-instance 'text-screen :text text))))

(defmethod phase-resume ((p text-phase))
  (ps-incref *ps*)
  (with-slots (text-screen) p
    (setf (ui-visible text-screen) t)))

(defmethod phase-back ((p text-phase))
  (ps-decref *ps*))
