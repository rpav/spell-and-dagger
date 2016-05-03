(in-package :game)

(defclass simple-blocker (entity)
  ((box :initform nil)))

(defmethod initialize-instance :after ((e simple-blocker) &key &allow-other-keys)
  (with-slots (box) e
    (setf box (cons (entity-pos e) (entity-size e)))))

(defmethod entity-box ((e simple-blocker))
  (slot-value e 'box))
