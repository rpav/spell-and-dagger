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
                      :quadtree (make-instance 'quadtree
                                  :key #'entity-box
                                  :size max))
            gktm (make-instance 'gk-tilemap :tilemap tm))
      (gm-setup-physics gm)
      (physics-start physics))))

(defun map-find-start (map &optional target)
  (with-slots (tilemap) map
    (let* ((ob (tilemap-find-object tilemap "objects" (or target "start"))))
      (gk-vec2 (aval :x ob) (aval :y ob)))))

(defun map-add (map &rest objects)
  (with-slots (physics) map
    (loop for ob in objects
          do (physics-add physics ob))))

(defun map-remove (map &rest objects)
  (with-slots (physics) map
    (apply 'physics-remove physics objects)))

(defun map-update (map)
  (with-slots (physics) map
    (physics-update physics)))

(defun map-find-in-box (map box &optional offs)
  (with-slots (physics) map
    (physics-find physics box offs)))

(defmethod draw ((gm game-map) lists m)
  (with-slots (gktm physics) gm
    (draw gktm lists m)
    (physics-map (lambda (ob) (draw ob lists m))
                 physics)))

 ;;

(defun gm-object-type (ob)
  (let ((type (aval :type ob)))
    (if (or (not type) (string= "" type))
        'simple-blocker
        (intern (string-upcase type) :game))))

(defun gm-make-instance (ob)
  (let* ((type (gm-object-type ob))
         (pos (gk-vec3 (aval :x ob) (aval :y ob) 0))
         (size (gk-vec2 (aval :width ob) (aval :height ob))))
    (and type
         (make-instance type
           :name (aval :name ob)
           :pos pos :size size
           :props (aval :properties ob)))))

(defun gm-add-object (gm ob)
  (with-slots (physics) gm
    (when-let (instance (gm-make-instance ob))
      (physics-add physics instance))))

(defun gm-setup-physics (gm)
  (with-slots ((tm tilemap) physics) gm
    (map-tilemap-objects (lambda (x) (gm-add-object gm x)) tm "collision")
    (map-tilemap-objects (lambda (x) (gm-add-object gm x)) tm "objects")
    (map-tilemap-objects (lambda (x) (gm-add-object gm x)) tm "interacts")
    (map-tilemap-objects (lambda (x) (gm-add-object gm x)) tm "spawners")

    ;; Map boundaries .. we should fill map/target props in from map props
    (physics-add physics (make-instance 'link
                           :pos (gk-vec3 -1 -1 0) :size (gk-vec2 256 1)))
    (physics-add physics (make-instance 'link
                           :pos (gk-vec3 -1 -1 0) :size (gk-vec2 1 144)))
    (physics-add physics (make-instance 'link
                           :pos (gk-vec3 -1 144 0) :size (gk-vec2 256 1)))
    (physics-add physics (make-instance 'link
                           :pos (gk-vec3 256 -1 0) :size (gk-vec2 1 144)))))
