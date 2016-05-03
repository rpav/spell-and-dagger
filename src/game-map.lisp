(in-package :game)

(defclass game-map ()
  ((tilemap :initform nil)
   (gktm :initform nil)
   (physics :initform (make-instance 'physics))))

(defmethod initialize-instance :after ((gm game-map) &key map)
  (with-slots (tilemap physics gktm) gm
    (let* ((tm (load-tilemap map))
           (size (tilemap-size tm))
           (max (* 16.0 (max (vx size) (vy size)))))
      (setf tilemap tm
            physics (make-instance 'physics
                      :quadtree (make-instance 'quadtree :size max))
            gktm (make-instance 'gk-tilemap :tilemap tm))
      (gm-setup-physics gm)
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

 ;;

(defun gm-object-type (ob)
  (let ((type (aval :type ob)))
    (if (or (not type) (string= "" type))
        'simple-blocker
        (string-upcase type))))

(defun gm-add-object (gm ob)
  (with-slots (physics) gm
    (let* ((type (gm-object-type ob))
           (pos (gk-vec2 (aval :x ob) (aval :y ob)))
           (size (gk-vec2 (aval :width ob) (aval :height ob)))
           (ob (make-instance type :pos pos :size size)))
      (physics-add physics ob))))

(defun gm-setup-physics (gm)
  (with-slots ((tm tilemap) physics) gm
    (map-tilemap-objects 'gm-add-object tm "collision")))
