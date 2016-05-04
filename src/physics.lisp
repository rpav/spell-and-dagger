;;; Physics! .. I use that term _very_ loosely.

(in-package :game)

(defclass physics ()
  ((last-time :initform 0.0)
   (timestep :initform (/ 1.0 60.0))
   (objects :initform (make-hash-table))
   (quadtree :initform nil :initarg :quadtree)))

(defun physics-add (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects quadtree) phys
    (loop for ob in list
          do (quadtree-add quadtree ob)
             (setf (gethash ob objects) t))))

(defun physics-remove (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob in list
          do (remhash ob objects))))

(defun physics-clear (phys)
  (declare (type physics phys))
  (with-slots (objects) phys
    (setf objects nil)))

(defun physics-start (phys)
  (declare (type physics phys))
  (with-slots (last-time) phys
    (setf last-time (current-time))))

(defun physics-update (phys)
  (declare (type physics phys))
  (with-slots (last-time timestep) phys
    (let* ((diff (- *time* last-time))
           (steps (truncate diff timestep)))
      ;; Just let this depend on vsync for now, which isn't ideal, but
      ;; whatever
      (physics-step phys)
      (setf last-time *time*))))

;;; This is probably horribly inefficient.
(defun physics-move-object (physics ob)
  (unless (eq +motion-none+ (entity-motion ob))
    (with-slots (quadtree) physics
      (let* ((pos (entity-pos ob))
             (x (vx pos))
             (y (vy pos)))
        (quadtree-delete quadtree ob)
        (gk:nv2+ pos (entity-motion ob))
        ;; check to see if anything is at the new position
        (multiple-value-bind (box offs) (entity-box ob)
          (let ((collisions (quadtree-select quadtree box offs))
                (collides-p nil))
            (loop for c in collisions
                  do (when (entity-solid-p c)
                       (setf collides-p t)
                       (entity-collide ob c)))
            ;; If it can't move there, return it.
            (when collides-p
              (gk:set-vec2f pos x y))
            (quadtree-add quadtree ob)))))))

(defun physics-step (phys)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob being each hash-key of objects
          do (physics-move-object phys ob)
             (entity-update ob))))
