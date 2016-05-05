(in-package :game)

(defclass simple-mob (actor)
  ())

(defmethod entity-attacked :after ((e simple-mob) a w)
  (:say "ouch"))
