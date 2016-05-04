(in-package :game)

 ;; simple-entity

(defclass simple-entity (entity)
  ((box :initform nil)))

(defmethod initialize-instance :after ((e simple-entity) &key &allow-other-keys)
  (with-slots (box) e
    (setf box (cons (entity-pos e) (entity-size e)))))

(defmethod entity-box ((e simple-entity)) (slot-value e 'box))

 ;; simple-blocker

(defclass simple-blocker (simple-entity) ())

 ;; link

(defclass link (simple-entity) ())

