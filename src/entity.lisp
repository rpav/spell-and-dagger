(in-package :game)

(defvar +motion-none+  (gk-vec2  0  0))
(defvar +motion-up+    (gk-vec2  0  1))
(defvar +motion-down+  (gk-vec2  0 -1))
(defvar +motion-left+  (gk-vec2 -1  0))
(defvar +motion-right+ (gk-vec2  1  0))

;;; May convert this to be prototypey later
(defclass entity ()
  ((pos :initform (gk-vec2 0 0) :initarg :pos :reader entity-pos)
   (size :initform (gk-vec2 16 16) :initarg :size :reader entity-size)
   (box :initform nil :reader entity-box)
   (motion :initform +motion-none+ :accessor entity-motion)
   (sprite :initform nil :initarg :sprite :accessor entity-sprite)))

(defmethod initialize-instance :after ((e entity) &key &allow-other-keys)
  (with-slots (box pos size) e
    (setf box (cons pos size))))

(defgeneric entity-update (entity)
  (:method (e)
    (with-slots (pos box motion sprite) e
      (when sprite
        (setf (sprite-pos sprite) pos)))))

(defgeneric entity-action (entity action)
  (:method (e a)))

;;; A more complex system would allow channels or entity-entity tests
;;; or whatnot.  For now this is a simple boolean.  Default is T,
;;; because it it seems there are more solid than non-solid entities.
(defgeneric entity-solid-p (entity)
  (:documentation "Specialize to determine if `ENTITY` can be passed.")
  (:method (e) t))

(defmacro define-entity-solid-p (type val)
  `(defmethod entity-solid-p ((e ,type)) ,val))
