(in-package :game)

(defclass spawner (entity)
  ((mob :initform nil)))

(defmethod entity-solid-p ((e spawner)) nil)

(defmethod entity-update ((e spawner))
  (with-slots (mob) e
    (unless mob
      (setf mob (make-instance 'simple-mob
                  :sprite (make-instance 'sprite :name "rpg_enemies/shroom_00.png" :key 1)
                  :pos (entity-pos e)))
      (map-add (current-map) mob))))
