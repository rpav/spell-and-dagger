(in-package :game)

(defclass spawner (entity)
  ((last-dead-time :initform nil)
   (mob :initform nil)))

(defmethod entity-solid-p ((e spawner)) nil)

(defun spawner-spawn (s)
  (with-slots (last-dead-time mob) s
    (setf last-dead-time nil)
    (setf mob (make-instance 'simple-mob
                :sprite (make-instance 'sprite
                          :name "rpg_enemies/shroom_00.png"
                          :key 1)
                :pos (entity-pos s)))
    (map-add (current-map) mob)))

(defmethod entity-update ((e spawner))
  (with-slots (last-dead-time mob) e
    (when (and mob (actor-dead-p mob) (not last-dead-time))
      (setf last-dead-time *time*))
    (if last-dead-time
        (let ((d (- *time* last-dead-time)))
          (when (> d 3) (spawner-spawn e)))
        (if (not mob)
            (spawner-spawn e)))))
