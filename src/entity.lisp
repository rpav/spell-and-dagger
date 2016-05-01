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

 ;; Quick take on character

(defclass game-char (entity) ())
