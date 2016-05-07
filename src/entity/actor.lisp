(in-package :game)

 ;; ACTOR

(defclass actor (entity)
  ((life :initform 1 :accessor actor-life)
   (facing :initform +motion-down+ :reader actor-facing)
   (knockback-time :initform 0.3 :accessor actor-knockback-time)
   (knockback-speed :initform 2.0 :accessor actor-knockback-speed)
   (hit-start :initform nil))
  (:documentation "An actor is something that can move with animation,
attack, take damage, etc., i.e. the character or a mob."))

(defgeneric actor-dead-p (actor)
  (:documentation "True if `ACTOR` is dead and should be (or is) removed.")
  (:method ((a actor))
    (<= (slot-value a 'life) 0)))

(defgeneric actor-knockback-begin (actor) (:method ((a actor))))
(defgeneric actor-knockback-end (actor) (:method ((a actor))))

(defun actor-knock-back (actor pos)
  (with-slots (hit-start) actor
    (setf hit-start *time*)
    (setf (entity-motion actor) (relative-motion pos (entity-pos actor)))
    (nv2* (entity-motion actor) (actor-knockback-speed actor))
    (actor-knockback-begin actor)))

(defmethod entity-attacked ((e actor) a w)
  (actor-knock-back e (entity-pos a)))

(defmethod entity-update :after ((e actor))
  (with-slots (hit-start) e
    (when hit-start
      (let ((delta (- *time* hit-start)))
        (when (> delta 0.2)
          (setf (entity-motion e) +motion-none+
                hit-start nil)
          (actor-knockback-end e))))))

(defmethod entity-solid-p ((e actor))
  (unless (actor-dead-p e) t))
