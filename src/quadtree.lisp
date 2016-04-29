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
    `(let ((,x0 (caar ,box))
           (,y0 (cdar ,box))
           (,x1 (cadr ,box))
           (,y1 (cddr ,box)))
       ,@body)))

(defmacro with-int-box ((x0 y0 x1 y1) box &body body)
  (once-only (box)
    `(let ((,x0 (truncate (caar ,box)))
           (,y0 (truncate (cdar ,box)))
           (,x1 (truncate (cadr ,box)))
           (,y1 (truncate (cddr ,box))))
       ,@body)))

(defmacro with-point ((x y) point &body body)
  (once-only (point)
    `(let ((,x (car ,point))
           (,y (cdr ,point)))
       ,@body)))

(declaim (inline box box/16))
(defun box (x0 y0 x1 y1)
  (cons (cons x0 y0) (cons x1 y1)))

(defun box/16 (x0 y0 x1 y1)
  "Like BOX, but scaled to 0..16 so pixels may be specified instead
of 0..1.0"
  (box (/ x0 16.0) (/ y0 16.0) (/ x1 16.0) (/ y1 16.0)))

(defun box+ (box offset)
  (incf (caar box) (car offset))
  (incf (cadr box) (car offset))
  (incf (cdar box) (cdr offset))
  (incf (cddr box) (cdr offset)))

(defun box- (box offset)
  (decf (caar box) (car offset))
  (decf (cadr box) (car offset))
  (decf (cdar box) (cdr offset))
  (decf (cddr box) (cdr offset)))

(defun box-intersect-p (box-a box-b)
  (with-box (ax0 ay0 ax1 ay1) box-a
    (with-box (bx0 by0 bx1 by1) box-b
      (and (<  ax0 bx1) (<  ay0 by1)
           (>= ax1 bx0) (>= ay1 by0)))))

 ;; Points

(declaim (inline x< y<))

(defun x< (point-a point-b &optional (test #'<))
  "Test whether the `X` of `POINT-A` is less than the `X` of `POINT-B`."
  (funcall test (car point-a) (car point-b)))

(defun y< (point-a point-b &optional (test #'<))
  "Test whether the `Y` of `POINT-A` is less than the `Y` of `POINT-B`."
  (funcall test (cdr point-a) (cdr point-b)))

(defun point+ (point offset)
  (let ((x (car offset))
        (y (cdr offset)))
    (incf (car point) x)
    (incf (cdr point) y)
    point))

(defun point- (point offset)
  (let ((x (car offset))
        (y (cdr offset)))
    (decf (car point) x)
    (decf (cdr point) y)
    point))

(defun point-delta (point1 point2)
  (cons (- (car point2) (car point1))
        (- (cdr point2) (cdr point1))))

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
    (setf top-node (make-instance 'qt-node :at (cons x y) :size size))))

(defgeneric quadtree-add (quadtree item)
  (:documentation "Add `ITEM` to `QUADTREE`."))

(defgeneric quadtree-delete (quadtree item)
  (:documentation "Delete `ITEM` from `QUADTREE`."))

(defun point-quad (point qt-node &optional (test #'<))
  "Return the quadrant `POINT` would occupy."
  (with-slots ((c center-point)) qt-node
    (let ((x< (x< point c test))
          (y< (y< point c test)))
      (cond
        ((and x< y<) 0)
        (y< 1)
        (x< 2)
        (t 3)))))

(defun rect-quad (rect qt-node)
  "Return the quadrant `RECT` should occupy, or `NIL` if it does not
fit into any single quad"
  (let ((q1 (point-quad (car rect) qt-node))
        (q2 (point-quad (cdr rect) qt-node #'<=)))
    (if (= q1 q2)
        q1
        nil)))

(defun qn-pos (qn qt-node)
  (with-slots ((at center-point) size) qt-node
    (let ((offset (/ size 4.0))
          (x (car at))
          (y (cdr at)))
      (ecase qn
        (0 (cons (- x offset) (- y offset)))
        (1 (cons (+ x offset) (- y offset)))
        (2 (cons (- x offset) (+ y offset)))
        (3 (cons (+ x offset) (+ y offset)))))))

(defun ensure-rect-quad (rect qt-node)
  (let ((qn (rect-quad rect qt-node)))
    (if qn
        (with-slots (quads size) qt-node
          (or (aref quads qn)
              (setf (aref quads qn)
                    (make-instance 'qt-node
                                   :at (qn-pos qn qt-node)
                                   :size (/ size 2.0)))))
        qt-node)))

(defun next-node (rect qt-node)
  "Return the next (child) node that `RECT` fits into in `QT-NODE`,
or `NIL`"
  (with-slots (quads) qt-node
    (let ((qn (rect-quad rect qt-node)))
      (when qn (aref quads qn)))))

(defmethod quadtree-add ((qt quadtree) item)
  (with-slots (top-node object-node max-depth key-fun) qt
    (let ((rect (funcall key-fun item)))
      (loop for depth from 0 below max-depth
            as last-node = nil then node
            as node = top-node then (ensure-rect-quad rect node)
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

(defun map-matching-subtrees (box function qt-node)
  "Call `FUNCTION` on `QT-NODE` and any children of `QT-NODE` which
`BOX` fits in exactly.  Return the last node `BOX` fits in."
  (funcall function (slot-value qt-node 'objects))
  (if-let ((next-node (next-node box qt-node)))
    (map-matching-subtrees box function next-node)
    qt-node))

(defmethod quadtree-select ((qt quadtree) box)
  "Select all objects which overlap with `BOX`"
  (let (overlaps)
    (with-slots (top-node object-node key-fun) qt
      (flet ((select (objects)
               (loop for object in objects
                     when (box-intersect-p box (funcall key-fun object))
                       do (push object overlaps))))
        (let ((subtree (map-matching-subtrees box #'select top-node)))
          (map-all-subtrees #'select subtree))
        overlaps))))
