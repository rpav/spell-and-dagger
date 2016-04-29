(in-package :game)

(defclass gamechar ()
  ((x :initform 0)
   (y :initform 0)
   ))

(defclass game ()
  ())

(defun frame-update (game)
  )

(defmethod initialize-instance :after ((g game) &key &allow-other-keys)
  )

