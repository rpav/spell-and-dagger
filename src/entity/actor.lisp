(in-package :game)

 ;; ACTOR

(defclass actor (entity)
  ((life :initform 1 :accessor actor-life)
   (facing :initform +motion-down+ :reader actor-facing)
   (hit-time :initform nil))
  (:documentation "An actor is something that can move with animation,
attack, take damage, etc., i.e. the character or a mob."))

(defgeneric actor-died (actor)
  (:documentation "Called after `ENTITY-ATTACKED` when `(<= life 0)`.")
  (:method ((a actor))))

(defmethod entity-motion ((e actor))
  (with-slots (state motion) e
    (case state
      (:attacking +motion-none+)
      (otherwise motion))))

(defmethod entity-attacked ((e actor) a w)
  (with-slots (hit-time) e
    (setf hit-time *time*)
    (setf (entity-motion e) (actor-facing a))
    (nv2* (entity-motion e) 2.0)))

(defmethod entity-attacked :after ((e actor) a w)
  (with-slots (life) e
    (when (<= life 0)
      (actor-died e))))

(defmethod entity-update :after ((e actor))
  (with-slots (hit-time) e
    (when hit-time
      (let ((delta (- *time* hit-time)))
        (when (> delta 0.1)
          (setf (entity-motion e) +motion-none+))))))
