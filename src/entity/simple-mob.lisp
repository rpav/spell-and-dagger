(in-package :game)

(defclass simple-mob (actor)
  ((life :initform 3)))

(defmethod entity-attacked ((e simple-mob) a w)
  (call-next-method)
  (with-slots (life) e
    (decf life)))

(defmethod actor-died ((a simple-mob))
  (map-remove (current-map) a))
