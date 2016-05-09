(in-package :game)

(defparameter +powerup-bounce+
  (make-instance 'anim-function
    :duration 0.2
    :function
    (lambda (o d)
      (if (< d 1.0)
          ;; Cheap/fake bounce; we could increase the bounces by
          ;; increasing the muliplier and time but this should be
          ;; short.  Could even do falloff, but useless with 1 bounce.
          (if (evenp (truncate (* d 2)))
              (setf (vy (entity-motion o)) 1.0)
              (setf (vy (entity-motion o)) -1.0))
          (setf
           (vx (entity-motion o)) 0.0
           (vy (entity-motion o)) 0.0)))))

(defclass powerup (entity)
  ((anim-state :initform nil)))

(defmethod initialize-instance :after ((p powerup) &key bounce-in &allow-other-keys)
  (when bounce-in
    (with-slots (anim-state) p
      (setf (vx (entity-motion p)) (if (< (random 1.0) 0.5) -1.0 1.0))
      (setf anim-state (animation-instance +powerup-bounce+ p))
      (anim-play *anim-manager* anim-state))))

(defmethod entity-solid-p ((e powerup)) nil)

(defmethod entity-touch :after ((g game-char) (e powerup))
  (map-remove (current-map) e))

 ;; POWERUP-LIFE

(defclass powerup-life (powerup)
  ((sprite :initform (make-instance 'sprite :key 0 :name "powerup/crystal-red.png"))))

(defmethod entity-touch ((g game-char) (e powerup-life))
  (incf (char-life g) 2))

 ;; POWERUP-MAGIC

(defclass powerup-magic (powerup)
  ((sprite :initform (make-instance 'sprite :key 0 :name "powerup/crystal-blue.png"))))

(defmethod entity-touch ((g game-char) (e powerup-magic))
  (incf (char-magic g) 2))
