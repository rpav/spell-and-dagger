;;; - NOTICE - NOTICE - NOTICE -
;;;
;;; This was taken from some other code I had laying around for a
;;; quadtree; it was not written during the jam.  It may have been
;;; modified though.
;;;
;;; - NOTICE - NOTICE - NOTICE -

(in-package :game)

 ;; Box shortcut

(defmacro with-box ((x0 y0 x1 y1) box &body body)
  (once-only (box)
    `(let* ((,x0 (vx (car ,box)))
            (,y0 (vy (car ,box)))
            (,x1 (+ ,x0 (vx (cdr ,box))))
            (,y1 (+ ,y0 (vy (cdr ,box)))))
       ,@body)))

(defmacro with-int-box ((x0 y0 x1 y1) box &body body)
  (once-only (box)
    `(let* ((,x0 (truncate (vx (car ,box))))
            (,y0 (truncate (vy (car ,box))))
            (,x1 (truncate (+ ,x0 (vx (cdr ,box)))))
            (,y1 (truncate (+ ,y0 (vy (cdr ,box))))))
       ,@body)))

(defmacro with-point ((x y) point &body body)
  (once-only (point)
    `(let ((,x (vx ,point))
           (,y (vy ,point)))
       ,@body)))

(declaim (inline box box/16))
(defun box (x0 y0 x1 y1)
  (cons (gk-vec2 x0 y0) (gk-vec2 x1 y1)))

(defun box/16 (x0 y0 x1 y1)
  "Like BOX, but scaled to 0..16 so pixels may be specified instead
of 0..1.0"
  (box (/ x0 16.0) (/ y0 16.0) (/ x1 16.0) (/ y1 16.0)))

(defun box+ (box offset)
  (incf (vx (car box)) (vx offset))
  (incf (vy (car box)) (vy offset)))

(defun box- (box offset)
  (decf (vx (car box)) (vx offset))
  (decf (vy (car box)) (vy offset)))

(defun box-intersect-p (box-a box-b offs-a offs-b)
  (with-box (ax0 ay0 ax1 ay1) box-a
    (when offs-a
      (incf ax0 (vx offs-a))
      (incf ay0 (vy offs-a))
      (incf ax1 (vx offs-a))
      (incf ay1 (vy offs-a)))
    (with-box (bx0 by0 bx1 by1) box-b
      (when offs-b
        (incf bx0 (vx offs-b))
        (incf by0 (vy offs-b))
        (incf bx1 (vx offs-b))
        (incf by1 (vy offs-b)))
      (and (<  ax0 bx1) (<  ay0 by1)
           (>= ax1 bx0) (>= ay1 by0)))))

 ;; Quadtree

(defclass qt-node ()
  ((size :initform nil :initarg :size)
   (center-point :initform nil :initarg :at)
   (quads :initform (make-array 4 :initial-element nil))
   (objects :initform nil)))

(defclass quadtree ()
  ((top-node)
   (max-depth :initform 3 :initarg :max-depth)
   (object-node :initform (make-hash-table))
   (key-fun :initform #'identity :initarg :key)))

(defmethod initialize-instance :after
    ((qt quadtree) &key x y size &allow-other-keys)
  (with-slots (top-node) qt
    (let ((x (or x (/ size 2.0)))
          (y (or y (/ size 2.0))))
      (setf top-node (make-instance 'qt-node :at (gk-vec2 x y) :size size)))))

(defgeneric quadtree-add (quadtree item)
  (:documentation "Add `ITEM` to `QUADTREE`."))

(defgeneric quadtree-delete (quadtree item)
  (:documentation "Delete `ITEM` from `QUADTREE`."))

(defgeneric quadtree-select (quadtree box &optional offs)
  (:documentation "Select items from `QUADTREE` inside `BOX` with
optional offset, `OFFS`"))

(defun point-quad (x y qt-node &optional (test #'<))
  "Return the quadrant `POINT` would occupy."
  (with-slots ((c center-point)) qt-node
    (let ((x< (funcall test x (vx c)))
          (y< (funcall test y (vy c))))
      (cond
        ((and x< y<) 0)
        (y< 1)
        (x< 2)
        (t 3)))))

(defun rect-quad (rect offs qt-node)
  "Return the quadrant `RECT` should occupy, or `NIL` if it does not
fit into any single quad"
  (with-box (x0 y0 x1 y1) rect
    (when offs
      (incf x0 (vx offs))
      (incf y0 (vy offs))
      (incf x1 (vx offs))
      (incf y1 (vy offs)))
    (let ((q1 (point-quad x0 y0 qt-node))
          (q2 (point-quad x1 y1 qt-node #'<=)))
      (if (= q1 q2)
          q1
          nil))))

(defun qn-pos (qn qt-node)
  (with-slots ((at center-point) size) qt-node
    (let ((offset (/ size 4.0))
          (x (vx at))
          (y (vy at)))
      (ecase qn
        (0 (gk-vec2 (- x offset) (- y offset)))
        (1 (gk-vec2 (+ x offset) (- y offset)))
        (2 (gk-vec2 (- x offset) (+ y offset)))
        (3 (gk-vec2 (+ x offset) (+ y offset)))))))

(defun ensure-rect-quad (rect offs qt-node)
  (let ((qn (rect-quad rect offs qt-node)))
    (if qn
        (with-slots (quads size) qt-node
          (or (aref quads qn)
              (setf (aref quads qn)
                    (make-instance 'qt-node
                                   :at (qn-pos qn qt-node)
                                   :size (/ size 2.0)))))
        qt-node)))

(defun next-node (rect offs qt-node)
  "Return the next (child) node that `RECT` fits into in `QT-NODE`,
or `NIL`"
  (with-slots (quads) qt-node
    (let ((qn (rect-quad rect offs qt-node)))
      (when qn (aref quads qn)))))

(defmethod quadtree-add ((qt quadtree) item)
  (with-slots (top-node object-node max-depth key-fun) qt
    (multiple-value-bind (rect offs)
        (funcall key-fun item)
      (loop for depth from 0 below max-depth
            as last-node = nil then node
            as node = top-node then (ensure-rect-quad rect offs node)
            while (not (eq node last-node))
            finally (push item (slot-value node 'objects))
                    (setf (gethash item object-node) node))))
  item)

(defmethod quadtree-delete ((qt quadtree) item)
  (with-slots (object-node) qt
    (let ((node (gethash item object-node)))
      (if node
          (progn
            (deletef (slot-value node 'objects) item)
            (remhash item object-node))
          (error "Object ~S not in tree" item)))))

(defun map-all-subtrees (function qt-node)
  "Call `FUNCTION` on all children of `QT-NODE`, but not `QT-NODE`
itself."
  (loop for child across (slot-value qt-node 'quads)
        when child do
          (funcall function (slot-value child 'objects))
          (map-all-subtrees function child)))

(defun map-matching-subtrees (box offs function qt-node)
  "Call `FUNCTION` on `QT-NODE` and any children of `QT-NODE` which
`BOX` fits in exactly.  Return the last node `BOX` fits in."
  (funcall function (slot-value qt-node 'objects))
  (if-let ((next-node (next-node box offs qt-node)))
    (map-matching-subtrees box offs function next-node)
    qt-node))

(defmethod quadtree-select ((qt quadtree) box &optional offs)
  "Select all objects which overlap with `BOX`"
  (let (overlaps)
    (with-slots (top-node object-node key-fun) qt
      (flet ((select (objects)
               (loop for object in objects
                     when
                     (multiple-value-bind (box1 offs1) (funcall key-fun object)
                       (box-intersect-p box box1 offs offs1))
                     do (push object overlaps))))
        (let ((subtree (map-matching-subtrees box offs #'select top-node)))
          (map-all-subtrees #'select subtree))
        overlaps))))
