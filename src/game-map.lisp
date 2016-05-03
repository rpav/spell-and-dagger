(in-package :game)

(defclass game-map ()
  ((tilemap :initform nil)
   (gktm :initform nil)
   (physics :initform (make-instance 'physics))
   (quadtree :initform nil)))

(defmethod initialize-instance :after ((gm game-map) &key map)
  (with-slots (tilemap physics quadtree gktm) gm
    (let* ((tm (load-tilemap map))
           (size (tilemap-size tm))
           (max (max (vx size) (vy size)))
           (qt (make-instance 'quadtree :size max :x 0 :y 0)))
      (setf tilemap tm
            quadtree qt
            gktm (make-instance 'gk-tilemap :tilemap tm))
      (physics-start physics))))

(defun map-add (map &rest objects)
  (with-slots (physics) map
    (loop for ob in objects
          do (physics-add physics ob))))

(defun map-update (map)
  (with-slots (physics) map
    (physics-update physics)))

(defmethod draw ((gm game-map) lists m)
  (with-slots (gktm) gm
    (draw gktm lists m)))
