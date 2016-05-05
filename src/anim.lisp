(in-package :game)

;;; Animation defines parameters for a particular animation, e.g. length,
;;; implements "doing" the animation, etc
(defclass animation () ())

(defclass animation-periodic (animation)
  ((duration :initform 0 :initarg :duration)))

(defgeneric animation-instance (animation object &key &allow-other-keys)
  (:documentation "Create an appropriate ANIM-STATE for ANIMATION,
given `OBJECT` to be animated and any other optional parameters.")
  (:method (a o &key on-stop &allow-other-keys)
    (make-instance 'anim-state
      :animation a :object o
      :on-stop on-stop)))

;;; ANIM-STATE keeps the _state_ of any active animation, so you can
;;; use the same ANIMATION instance for multiple different ongoing
;;; animations
(defclass anim-state ()
  ((animation :initarg :animation)
   (object :initarg :object :accessor anim-state-object)
   (start-time :initform 0 :accessor anim-state-start-time)
   (on-stop :initform nil :initarg :on-stop :accessor anim-state-on-stop)))

(defgeneric animation-begin (anim anim-state)
  (:documentation "Called when the animation ANIM is started by ANIM-RUN.")
  (:method ((a animation) state)
    (setf (slot-value state 'start-time) *time*)))

(defgeneric animation-update (anim anim-state)
  (:documentation "Perform any updates for ANIMATION given ANIM-STATE.
Specialize on one or both."))

(defgeneric animation-stopped (anim anim-state)
  (:documentation "Called when an animation is stopped, naturally
or manually.")
  (:method ((a animation) s)
    (with-slots (on-stop) s
      (when on-stop
        (funcall on-stop s)))))

 ;; ANIM-MANAGER

(defclass anim-manager ()
  ((animations :initform (make-hash-table))))

(defun anim-run (manager &rest anim-states)
  (let ((*anim-manager* manager))
    (with-slots (animations) manager
      (loop for as in anim-states
            do (with-slots (animation) as
                 (setf (gethash as animations) t)
                 (animation-begin animation as))))))

(defun anim-update (manager)
  (let ((*anim-manager* manager))
    (with-slots (animations) manager
      (loop for as being each hash-key in animations
            for i from 0
            do (with-slots (animation) as
                 (animation-update animation as))))))

(defun anim-stop (manager &rest anim-states)
  (let ((*anim-manager* manager))
    (with-slots (animations) manager
      (loop for as in anim-states
            do (when (remhash as animations)
                 (animation-stopped (slot-value as 'animation) as))))))

 ;; spritesheet-anim

;;; If this were all really proper we'd keep a ref to the spritesheet.

(defclass anim-sprite (animation)
  ((anim :initform nil :accessor anim-sprite-anim)
   (frame-length :initarg :frame-length :initform (/ 180.0 1000) :accessor anim-sprite-frame-length)
   (count :initform nil :initarg :count :accessor anim-sprite-count)
   (debug :initform nil :accessor anim-sprite-debug))
  (:documentation "OBJECT should be a SPRITE."))

(defmethod initialize-instance :after ((a anim-sprite) &key name &allow-other-keys)
  (with-slots (anim) a
    (setf anim (find-anim (asset-anims *assets*) name))))

(defmethod animation-update ((a anim-sprite) state)
  (with-slots (anim count frame-length debug) a
    (with-slots (object start-time) state
      (when object
        (let* ((frame-count (sprite-anim-length anim))
               (delta (- *time* start-time))
               (frame
                 (truncate
                  (* frame-count
                     (mod (/ delta (* frame-count frame-length)) 1.0))))
               (c (truncate (/ delta (* frame-count frame-length)))))
          (when debug
            (:say frame))
          (if (and count (>= c count))
              (anim-stop *anim-manager* state)
              (setf (sprite-index object)
                    (sprite-anim-frame anim frame))))))))
