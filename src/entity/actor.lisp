(in-package :game)

 ;; ACTOR

(defclass actor (entity)
  ((life :initform 1 :accessor actor-life)
   (facing :initform +motion-down+ :reader actor-facing)
   (hit-time :initform nil))
  (:documentation "An actor is something that can move with animation,
attack, take damage, etc., i.e. the character or a mob."))

(defmethod entity-motion ((e actor))
  (with-slots (state motion) e
    (case state
      (:attacking +motion-none+)
      (otherwise motion))))

(defmethod entity-attacked ((e actor) a w)
  (with-slots (hit-time) e
    (setf hit-time *time*)
    (setf (entity-motion e) (actor-facing a))
    (nv2* (entity-motion e) 8.0)))

(defmethod entity-update :after ((e actor))
  (with-slots (hit-time) e
    (when hit-time
      (let ((delta (- *time* hit-time)))
        (when (> delta 0.005)
          (setf (entity-motion e) +motion-none+))))))
