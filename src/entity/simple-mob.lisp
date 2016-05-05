(in-package :game)

(defparameter +motions+
  (list +motion-up+ +motion-down+ +motion-left+ +motion-right+))

(defclass simple-mob (actor)
  ((life :initform 3)
   (state :initform :starting)
   (act-start :initform 0)
   (anim :initform nil)
   (anim-state :initform nil)))

(defmethod initialize-instance :after ((a simple-mob) &key name &allow-other-keys)
  (with-slots (anim anim-state sprite) a
    (when name
      (setf anim (make-instance 'anim-sprite :name name))
      (setf anim-state (animation-instance anim sprite))
      (anim-run *anim-manager* anim-state))))

(defmethod entity-attacked ((e simple-mob) a w)
  (call-next-method)
  (with-slots (life) e
    (decf life)))

(defmethod actor-died ((a simple-mob))
  (map-remove (current-map) a))

(defun simple-mob-change-action (e)
  (with-slots (state) e
    (case state
      (:starting (setf (entity-state e) :waiting))
      (:waiting
       (setf (entity-motion e) (elt +motions+ (random 4)))
       (nv2* (entity-motion e) 0.5)
       (setf (entity-state e) :moving))
      (:moving
       (setf (entity-motion e) +motion-none+)
       (setf (entity-state e) :waiting))))
  (with-slots (act-start) e
    (setf act-start *time*)))

(defmethod entity-update ((e simple-mob))
  (call-next-method)
  (with-slots (act-start) e
    (let ((d (- *time* act-start)))
      (when (> d 1)
        (simple-mob-change-action e)))))
