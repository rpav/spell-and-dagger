(in-package :game)

(defvar +motion-none+  (gk-vec2  0  0))
(defvar +motion-up+    (gk-vec2  0  1))
(defvar +motion-down+  (gk-vec2  0 -1))
(defvar +motion-left+  (gk-vec2 -1  0))
(defvar +motion-right+ (gk-vec2  1  0))

(defparameter +motions+
  (list +motion-up+ +motion-down+ +motion-left+ +motion-right+))

(defparameter +reverse-motion+
  `((,+motion-none+ . ,+motion-none+)
    (,+motion-up+ . ,+motion-down+)
    (,+motion-down+ . ,+motion-up+)
    (,+motion-left+ . ,+motion-right+)
    (,+motion-right+ . ,+motion-left+)))

(defun relative-motion (a b)
  "Return the \"direction\" of `B` in relation to `A`, e.g.,
if `B` is \"left of\" `A`, return `+motion-left+`."
  (let ((dx (- (vx a) (vx b)))
        (dy (- (vy a) (vy b))))
    (if (< (abs dy) (abs dx))
        (if (< dx 0.0) +motion-right+ +motion-left+)
        (if (< dy 0.0) +motion-up+ +motion-down+))))

(defparameter +default-box+ (cons (gk-vec2 0 0) (gk-vec2 16 16)))

;;; May convert this to be prototypey later
(defclass entity ()
  ((name :initform nil :initarg :name :accessor entity-name)
   (pos :initform (gk-vec3 0 0 0) :reader entity-pos)
   (size :initform (gk-vec2 16 16) :reader entity-size)
   (motion :initform (gk-vec2 0 0) :reader entity-motion)
   (state :initform nil :accessor entity-state)
   (sprite :initform nil :initarg :sprite :accessor entity-sprite)
   (props :initform nil :initarg :props :reader entity-props)))

(defmethod initialize-instance :after ((e entity) &key pos size &allow-other-keys)
  (with-slots ((_pos pos) (_size size)) e
    ;; Using set-vec2 makes it so everyone can specify them.  We don't use Z.
    (when pos (set-vec2 _pos pos))
    (when size (set-vec2 _size size))))

(defmethod print-object ((e entity) s)
  (with-slots (name pos size) e
    (print-unreadable-object (e s :type t :identity t)
      (when name (format s "~A " name))
      (format s "[~S ~S ~S ~S]"
              (vx pos) (vy pos) (vx size) (vy size)))))

(defmethod (setf entity-pos) ((v gk-vec2) (e entity))
  (with-slots (pos) e
    (set-vec2 pos v)))

(defmethod (setf entity-pos) ((v gk-vec3) (e entity))
  (with-slots (pos) e
    (set-vec2 pos v)))

(defmethod (setf entity-motion) ((v gk-vec2) (e entity))
  (with-slots (motion) e
    (set-vec2 motion v)))

(defmethod (setf entity-motion) ((v gk-vec3) (e entity))
  (with-slots (motion) e
    (set-vec2 motion v)))

(defgeneric entity-box (entity)
  (:documentation "Return a `BOX` or `(values BOX OFFSET)` for `ENTITY`")
  (:method ((e entity))
    (with-slots (pos) e
      (values +default-box+ pos))))

(defgeneric entity-update (entity)
  (:method (e)
    (with-slots (pos sprite) e
      (when sprite
        (setf (sprite-pos sprite) pos)))))

(defgeneric entity-action (entity action)
  (:method (e a)))

(defun default-interact (e a)
  (declare (ignorable e a))
  (show-textbox "Nothing here."))

(defgeneric entity-interact (entity actor)
  (:method (e a) (default-interact e a))
  (:documentation "Called when `ACTOR` interacts with `ENTITY`."))

(defgeneric entity-attacked (entity actor weapon)
  (:method (e a w))
  (:documentation "Called when `ACTOR` attacks `ENTITY` with `WEAPON`"))

(defgeneric entity-collide (e1 e2)
  (:documentation "Called when `E1` moves and collides with `E2`.")
  (:method (e1 e2)))

(defgeneric entity-touch (e1 e2)
  (:documentation "Called when `E1` moves and touches `E2`.  This happens
only when `E2` is not `ENTITY-SOLID-P`.")
  (:method (e1 e2)))

(defgeneric entity-added-to-map (map entity)
  (:documentation "Called when `ENTITY` has been added to `MAP`")
  (:method (m e)))

(defgeneric entity-property (e name)
  (:method ((e entity) name)
    (aval name (slot-value e 'props))))

(defmethod draw ((e entity) lists m)
  (with-slots (sprite) e
    (when sprite (draw sprite lists m))))

;;; A more complex system would allow channels or entity-entity tests
;;; or whatnot.  For now this is a simple boolean.  Default is T,
;;; because it it seems there are more solid than non-solid entities.
(defgeneric entity-solid-p (entity)
  (:documentation "Specialize to determine if `ENTITY` can be passed.")
  (:method (e) t))

(defmacro define-entity-solid-p (type val)
  `(defmethod entity-solid-p ((e ,type)) ,val))
