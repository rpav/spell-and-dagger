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
      (gk:nv2* motion 2))))

(defgeneric entity-action (entity action)
  (:method (e a)))

 ;; Quick take on character

(defclass game-char (entity)
  ((pos :initform (gk-vec2 10 10))
   (facing :initform "hero/walk-down")))

(defmethod entity-move ((e game-char) m)
  (call-next-method)
  (let ((anims (asset-anims *assets*)))
    (with-slots (sprite facing) e
      (switch (m)
        (+motion-none+ nil)
        (+motion-up+ (setf facing "hero/walk-up"))
        (+motion-down+ (setf facing "hero/walk-down"))
        (+motion-left+ (setf facing "hero/walk-left"))
        (+motion-right+ (setf facing "hero/walk-right")))
      (setf (sprite-index sprite) (find-sheet-frame anims facing 0)))))
