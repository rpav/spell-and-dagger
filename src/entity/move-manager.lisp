(in-package :game)

 ;; MOVE-MANAGER

;;; This is a mixin for things that have complex "walk around"
;;; animations.
(defclass move-manager ()
  ((sprite-name :initform nil :initarg :sprite-name)
   sprite-anim sprite-anim-state))

(defun mm-move-name (mm move)
  (with-slots (sprite-name) mm
    (switch (move)
      (+motion-none+ (string+ sprite-name "walk-down"))
      (+motion-up+ (string+ sprite-name "walk-up"))
      (+motion-down+ (string+ sprite-name "walk-down"))
      (+motion-left+ (string+ sprite-name "walk-left"))
      (+motion-right+ (string+ sprite-name "walk-right")))))

(defun mm-play-facing (mm facing)
  (with-slots (sprite) mm
    (let ((move-name (mm-move-name mm facing)))
      (setf (sprite-index sprite)
            (find-anim-frame (asset-anims *assets*) move-name 1)))))

(defun mm-play-motion (mm motion)
  (with-slots (sprite facing sprite-anim sprite-anim-state) mm
    (unless (eq motion +motion-none+)
      (setf facing motion))
    (let ((move-name (mm-move-name mm motion)))
      (setf (anim-sprite-anim sprite-anim) (find-anim (asset-anims *assets*) move-name)
            (anim-sprite-frame-length sprite-anim) (/ 180 1000.0)
            (anim-sprite-count sprite-anim) nil
            (anim-state-object sprite-anim-state) sprite
            (anim-state-on-stop sprite-anim-state) nil)
      (anim-stop *anim-manager* sprite-anim-state)
      (if (v2= +motion-none+ motion)
          (mm-play-facing mm facing)
          (anim-play *anim-manager* sprite-anim-state)))))

(defmethod initialize-instance :after ((mm move-manager) &key props &allow-other-keys)
  (with-slots (sprite sprite-anim sprite-anim-state sprite-name) mm
    (unless sprite-name
      (setf sprite-name (aval :sprite-name props)))
    (let ((start-name (mm-move-name mm (actor-facing mm))))
      (setf sprite (make-instance 'sprite
                     :index (find-anim-frame (asset-anims *assets*)
                                             start-name 0)))
      (setf sprite-anim (make-instance 'anim-sprite :name start-name))
      (setf sprite-anim-state (animation-instance sprite-anim nil))
      (mm-play-motion mm +motion-none+))))

(defmethod (setf entity-motion) :before (v (mm move-manager))
  (mm-play-motion mm v))

(defmethod (setf actor-facing) :after (v (mm move-manager))
  (setf (entity-motion mm) +motion-none+)
  (mm-play-facing mm v))
