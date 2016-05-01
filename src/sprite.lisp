;;; Modified from the example in cl-gamekernel

(in-package :game)

(defclass sprite ()
  (qs trs))

(defmethod initialize-instance ((s sprite) &key sheet index pos size key)
  (with-slots (qs trs scale) s
    (setf qs (cmd-quadsprite sheet index))
    (setf trs (cmd-tf-trs :out (quadsprite-tfm qs)
                          :translate pos
                          :scale size
                          :key key))))

(defun sprite-pos (s)
  (tf-trs-translate (slot-value s 'trs)))

(defun (setf sprite-pos) (v s)
  (setf (tf-trs-translate (slot-value s 'trs)) v))

(defun sprite-index (s)
  (quadsprite-index (slot-value s 'qs)))

(defun (setf sprite-index) (v s)
  (with-slots (qs) s
    (setf (quadsprite-index qs) v)))

(defmethod draw ((sprite sprite) lists m)
  (with-slots (pre-list sprite-list) lists
    (with-slots (qs trs) sprite
      (setf (tf-trs-prior trs) m)
      (cmd-list-append pre-list trs)
      (cmd-list-append sprite-list qs))))

 ;; Spritesheet animations

(defclass sprite-anim ()
  ((count :initarg :count :initform 0 :accessor sprite-anim-count)
   (indexes :initform (make-array 2 :element-type '(unsigned-byte 8) :adjustable t :fill-pointer 0)
            :reader sprite-anim-indexes)))

(defun sprite-anim-append (sa index)
  (with-slots (indexes) sa
    (vector-push-extend index indexes)))

(defun sprite-anim-frame (sa frame)
  (with-slots (indexes) sa
    (aref indexes frame)))

(defclass sheet-animations ()
  ((sheet :initarg :sheet :initform nil)
   (anims :initform (make-hash-table :test 'equalp))))

(defmethod initialize-instance :after ((s sheet-animations) &key &allow-other-keys)
  (with-slots (sheet anims) s
    (map-spritesheet
     (lambda (x i)
       (let* ((m (nth-value 1 (ppcre:scan-to-strings "(.*)_(\\d+)\\.png$" x)))
              (name (ppcre:regex-replace-all "_" (aref m 0) "-"))
              #++(num (parse-integer (aref m 1)))
              (anim (ensure-gethash (nstring-upcase name) anims
                                    (make-instance 'sprite-anim))))
         (sprite-anim-append anim i)))
     sheet)))

(defun find-sheet-frame (sheet name frame)
  (with-slots (anims) sheet
    (sprite-anim-frame (gethash name anims) frame)))
