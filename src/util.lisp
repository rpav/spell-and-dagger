;;; Some of this may have been scraped from elsewhere

(in-package :game)

(defvar +time-units+ (coerce internal-time-units-per-second 'float))

(declaim (inline time-to-float))
(declaim (ftype (function (integer) float) time-to-float))
(defun time-to-float (time)
  (/ time +time-units+))

(defun current-time ()
  (time-to-float (get-internal-real-time)))

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

 ;; :say

(defvar *return-value* nil)
(defvar *say-io* *debug-io*)

(defmacro :say (&rest vars)
  (let (formats vals (tabbing 0))
    (labels
        ((join (&rest strings)
           (apply #'concatenate 'string strings))
         (format-expr (var more-exprs-p)
           (push (join (format nil "~~~A,0T" tabbing)
                       (if more-exprs-p "~A = ~S, " "~A = ~S"))
                 formats)
           (if (symbolp var)
               (push (symbol-name var) vals)
               (push `',var vals))
           (push var vals))
         (format-val (val &optional (with-space-p nil))
           (if with-space-p
               (push "~S " formats)
               (push "~S" formats))
           (push val vals))
         (format-str (val &optional (with-space-p nil))
           (if with-space-p
               (push "~A " formats)
               (push "~A" formats))
           (push val vals)))
      (loop for x on vars
            as var = (car x)
            as next = (cdr x)
            as next-expr-p = (and next (not (stringp (car next))))
            do (typecase var
                 ((or string number) (format-str var))
                 (keyword
                  (case var
                    (:br (push "~%" formats))))
                 (list
                  (case (car var)
                    (:tab (setf tabbing (cadr var)))
                    ((:val :vals)
                     (mapcar #'format-val (cdr var)
                             (maplist (lambda (x) (and (cdr x) t))
                                      (cdr var))))
                    (t (format-expr var next-expr-p))))
                 (t (format-expr var next-expr-p))))
      `(let ((*return-value*))
         (format *say-io*
                 ,(join "~&" (apply #'join (nreverse formats)) "~%")
                 ,@(nreverse vals))
         *return-value*))))
