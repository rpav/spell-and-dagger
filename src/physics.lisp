;;; Physics! .. I use that term _very_ loosely.

(in-package :game)

(defclass physics ()
  ((last-time :initform 0.0)
   (timestep :initform (/ 1.0 60.0))
   (objects :initform (make-hash-table))
   (rect :initform (box 0 0 0 0))
   (quadtree :initform nil :initarg :quadtree)))

(defun physics-add (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects quadtree) phys
    (loop for ob in list
          do (quadtree-add quadtree ob)
             (setf (gethash ob objects) t))))

(defun physics-remove (phys &rest list)
  (declare (type physics phys))
  (with-slots (objects quadtree) phys
    (loop for ob in list
          do (when (quadtree-contains quadtree ob)
               (quadtree-delete quadtree ob))
             (remhash ob objects))))

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
  (unless (v2= +motion-none+ (entity-motion ob))
    (with-slots (objects quadtree rect) physics
      (let* ((rect rect)
             (solidp (entity-solid-p ob)))
        (quadtree-delete quadtree ob)
        ;; check to see if anything is at the new position
        (multiple-value-bind (box offs) (entity-box ob)
          (set-vec2 (car rect) (car box))
          (set-vec2 (cdr rect) (cdr box))
          (gk:nv2+ (car rect) (entity-motion ob))
          (let ((collisions (quadtree-select quadtree rect offs))
                (collides-p nil))
            (loop for c in collisions
                  do (if (and solidp (entity-solid-p c))
                         (progn
                           (setf collides-p t)
                           (entity-collide ob c))
                         (entity-touch ob c)))
            ;; Only move it if it didn't collide, and hasn't
            ;; been removed in the interim
            (when (gethash ob objects)
              (unless (or collides-p)
                (gk:nv2+ (entity-pos ob) (entity-motion ob)))
              (quadtree-add quadtree ob))))))))

(defun physics-step (phys)
  (declare (type physics phys))
  (with-slots (objects) phys
    (loop for ob being each hash-key of objects
          do (physics-move-object phys ob)
             (entity-update ob))))

(defun physics-map (function phys)
  (with-slots (objects) phys
    (loop for ob being each hash-key of objects
          do (funcall function ob))))

(defun physics-find (phys box &optional offs)
  (with-slots (quadtree) phys
    (quadtree-select quadtree box offs)))
