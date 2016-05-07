(in-package :game)

 ;; simple-entity

(defclass simple-entity (entity)
  ((box :initform nil)))

(defmethod initialize-instance :after ((e simple-entity) &key &allow-other-keys)
  (with-slots (box) e
    (setf box (cons (entity-pos e) (entity-size e)))))

(defmethod entity-box ((e simple-entity)) (slot-value e 'box))

 ;; simple-text

(defclass simple-text (simple-entity)
  ((text :initform "")))

(defmethod initialize-instance :after ((e simple-text) &key props &allow-other-keys)
  (with-slots (text) e
    (if-let (str (aval :text props))
      (setf text str)
      (format t "Warning: String not specified for ~A"
              (class-name (class-of e))))))

(defmethod entity-solid-p ((e simple-text)) nil)

(defmethod entity-interact ((e simple-text) a)
  (with-slots (text) e
    (show-textbox text)))

 ;; simple-blocker

(defclass simple-blocker (simple-text) ())
(defmethod entity-solid-p ((e simple-blocker)) t)

 ;; link

(defclass link (simple-entity) ())

 ;; breakable

(defclass breakable (simple-entity)
  ((brokenp :initform nil :reader breakable-brokenp)))

(defmethod initialize-instance :after ((e breakable) &key sprite-name props &allow-other-keys)
  (with-slots (pos sprite) e
    ;; For some bizarre and unknown reason, sprites in an object layer---
    ;; nothing else---have their origin at the _lower left_ corner.
    (incf (vy pos) 16.0)
    (setf sprite (make-instance 'sprite :key -1 :name sprite-name))))

(defmethod entity-solid-p ((e breakable)) (not (breakable-brokenp e)))

(defmethod entity-break ((e breakable))
  (with-slots (sprite brokenp) e
    (unless brokenp
      (let ((break-name (entity-property e :broken)))
        (setf (sprite-name sprite) break-name
              brokenp t)))))
