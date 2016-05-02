(in-package :game)

(defvar +motion-none+  (gk-vec2  0  0))
(defvar +motion-up+    (gk-vec2  0  1))
(defvar +motion-down+  (gk-vec2  0 -1))
(defvar +motion-left+  (gk-vec2 -1  0))
(defvar +motion-right+ (gk-vec2  1  0))

;;; May convert this to be prototypey later
(defclass entity ()
  ((pos :initform (gk-vec2 0 0) :initarg :pos :reader entity-pos)
   (motion :initform (gk-vec2 0 0) :accessor entity-motion)
   (sprite :initform nil :initarg :sprite :accessor entity-sprite)))

(defgeneric entity-update (entity)
  (:method (e)
    (with-slots (pos motion sprite) e
      (gk:nv2+ pos motion)
      (when sprite
        (setf (sprite-pos sprite) pos)))))

(defgeneric entity-move (entity move)
  (:method ((e entity) move)
    (with-slots (motion) e
      (gk:set-vec2 motion move)
      #++(gk:nv2* motion 2))))

(defgeneric entity-action (entity action)
  (:method (e a)))

 ;; Quick take on character

;;; We'll generate these later for actions, but we don't want to cons
;;; up new strings everytime an action changes
(defparameter *walking*
  '((:up . "ranger-f/walk-up")
    (:down . "ranger-f/walk-down")
    (:left . "ranger-f/walk-left")
    (:right . "ranger-f/walk-right")))

(defparameter *attacking*
  '((:up . "ranger-f/atk-up")
    (:down . "ranger-f/atk-down")
    (:left . "ranger-f/atk-left")
    (:right . "ranger-f/atk-right")))

(defclass game-char (entity)
  ((pos :initform (gk-vec2 10 10))
   (facing :initform :down)
   anim anim-state))

(defmethod initialize-instance :after ((g game-char) &key &allow-other-keys)
  (with-slots (anim anim-state) g
    (setf anim (make-instance 'anim-sprite :name (aval :down *walking*)))
    (setf anim-state (animation-instance anim nil))))

(defmethod entity-action ((e game-char) (a (eql :btn1)))
  (with-slots (facing anim anim-state) e
    (setf (anim-sprite-count anim) 1
          (anim-sprite-frame-length anim) (/ 20 1000.0)
          (anim-sprite-anim anim) (find-anim (asset-anims *assets*)
                                             (aval facing *attacking*))
          (anim-state-on-stop anim-state)
          (lambda (s)
            (entity-move e +motion-none+)))
    (anim-run *anim-manager* anim-state)))

(defmethod entity-move ((e game-char) m)
  (call-next-method)
  (with-slots (sprite facing anim anim-state) e
    (switch (m)
      (+motion-none+ nil)
      (+motion-up+ (setf facing :up))
      (+motion-down+ (setf facing :down))
      (+motion-left+ (setf facing :left))
      (+motion-right+ (setf facing :right)))
    (setf (anim-sprite-anim anim) (find-anim (asset-anims *assets*)
                                             (aval facing *walking*))
          (anim-sprite-frame-length anim) (/ 180 1000.0)
          (anim-sprite-count anim) nil
          (anim-state-object anim-state) sprite)
    (anim-stop *anim-manager* anim-state)
    (if (eq +motion-none+ m)
        (setf (sprite-index sprite)
              (find-anim-frame (asset-anims *assets*)
                               (aval facing *walking*) 1))
        (anim-run *anim-manager* anim-state))))
