(in-package :game)

(defclass spawner (entity)
  ((last-dead-time :initform nil)
   (did-spawn-p :initform nil)
   (type :initform nil)
   (mob :initform nil)))

(defparameter +spawner-bbox+
  (cons (gk-vec2 4 4)
        (gk-vec2 8 8)))

(defmethod initialize-instance :after ((s spawner) &key props &allow-other-keys)
  (with-slots ((_type type) size) s
    (let* ((type (aval :type props))
           (anim (find-anim (asset-anims *assets*) type)))
      (if anim
          (setf _type type)
          (format t "Warning: spawner can't find type ~S~%" type)))))

(defmethod entity-box ((e spawner))
  (with-slots (pos) e
    (values +spawner-bbox+ pos)))

(defmethod entity-solid-p ((e spawner)) nil)

(defun spawner-spawn (s)
  (with-slots (last-dead-time mob type) s
    (if (delete s (map-find-in-box (current-map) (entity-box s) (entity-pos s)))
        (progn
          (setf last-dead-time *time*)) ; Don't continuously try
        (when type
          (setf last-dead-time nil)
          (setf mob (make-instance 'simple-mob
                      :sprite (make-instance 'sprite
                                :index (find-anim-frame (asset-anims *assets*) type 0)
                                :key 1)
                      :name type
                      :pos (entity-pos s)))
          (map-add (current-map) mob)))))

(defmethod entity-update ((e spawner))
  (with-slots (type did-spawn-p mob) e
    (when type
      (unless did-spawn-p
        (if (not mob)
            (spawner-spawn e))))))
