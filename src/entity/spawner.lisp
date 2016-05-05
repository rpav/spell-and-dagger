(in-package :game)

(defclass spawner (entity)
  ((last-dead-time :initform nil)
   (type :initform nil)
   (mob :initform nil)))

(defmethod initialize-instance :after ((s spawner) &key props &allow-other-keys)
  (with-slots ((_type type)) s
    (let* ((type (aval :type props))
           (anim (find-anim (asset-anims *assets*) type)))
      (if anim
          (setf _type type)
          (format t "Warning: spawner can't find type ~S~%" type)))))

(defmethod entity-solid-p ((e spawner)) nil)

(defun spawner-spawn (s)
  (with-slots (last-dead-time mob type) s
    (when type
      (setf last-dead-time nil)
      (setf mob (make-instance 'simple-mob
                  :sprite (make-instance 'sprite :index 0 :key 1)
                  :name type
                  :pos (entity-pos s)))
      (map-add (current-map) mob))))

(defmethod entity-update ((e spawner))
  (with-slots (type last-dead-time mob) e
    (when type
      (when (and mob (actor-dead-p mob) (not last-dead-time))
        (setf last-dead-time *time*))
      (if last-dead-time
          (let ((d (- *time* last-dead-time)))
            (when (> d 3) (spawner-spawn e)))
          (if (not mob)
              (spawner-spawn e))))))
