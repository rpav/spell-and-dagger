;;; This was also taken conceptually from how I've done things elsewhere.

(in-package :game)

 ;; UI

(defclass ui ()
  ((visible :initform nil :accessor ui-visible)
   (children :initform (make-hash-table))))

(defmethod ui-add ((ui ui) &rest children)
  (with-slots ((c children)) ui
    (loop for child in children
          do (setf (gethash child c) t))))

(defmethod ui-remove ((ui ui) &rest children)
  (with-slots ((c children)) ui
    (loop for child in children
          do (remhash child c))))

(defmethod ui-clear ((ui ui))
  (with-slots ((c children)) ui
    (clrhash c)))

(defmethod draw ((ui ui) lists m)
  (with-slots ((c children)) ui
    (loop for child being each hash-key in c
          do (draw c lists m))))

 ;; SCREEN

(defclass screen (ui) ())

(defmethod screen-opening ((s screen)))
(defmethod screen-closing ((s screen)))

(defmethod (setf ui-visible) (v (s screen))
  (call-next-method)
  (if v
      (unless (and *screen* (eq s *screen*))
        (screen-opening s)
        (setf *screen* s))
      (when (and *screen* (eq s *screen*))
        (screen-closing s)
        (setf *screen* nil))))


(defclass test-screen (screen)
  (sprite))

(defmethod initialize-instance :after ((s test-screen) &key w h &allow-other-keys)
  (with-slots (sprite) s
    (setf sprite
          (make-instance 'sprite
            :pos (gk-vec4 (/ w 2.0) (/ h 2.0) 0 1)
            :sheet (asset-sheet *assets*)
            :size (gk-vec3 4 4 1)
            :index 0))))

(defmethod draw :after ((s test-screen) lists m)
  (with-slots (sprite) s
    (draw sprite lists m)))
