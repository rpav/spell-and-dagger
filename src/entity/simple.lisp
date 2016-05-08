(in-package :game)

 ;; simple-entity

(defclass simple-entity (entity)
  ((box :initform nil)))

(defmethod initialize-instance :after ((e simple-entity) &key &allow-other-keys)
  (with-slots (box) e
    (setf box (cons (entity-pos e) (entity-size e)))))

(defmethod entity-box ((e simple-entity)) (slot-value e 'box))

 ;; simple-text

(defclass simple-text (simple-entity) ())

(defmethod initialize-instance :after ((e simple-text) &key props &allow-other-keys)
  (with-slots (text) e
    (unless (aval :text props)
      (format t "Warning: String not specified for ~A~%"
              (class-name (class-of e))))))

(defmethod entity-solid-p ((e simple-text)) nil)

(defmethod entity-interact ((e simple-text) a)
  (with-slots (props) e
    (show-textbox (aval :text props))))

 ;; simple-blocker

(defclass simple-blocker (simple-text) ())
(defmethod entity-solid-p ((e simple-blocker)) t)

 ;; link

(defclass link (simple-entity) ())

 ;; map-link

(defclass map-link (simple-entity)
  ((map :initarg :map :initform nil :reader map-link-map)
   (direction :initarg :direction :initform nil :reader map-link-direction)))

 ;; breakable

(defclass breakable (simple-text)
  ((brokenp :initform nil :reader breakable-brokenp)))

(defmethod initialize-instance :after ((e breakable) &key sprite-name &allow-other-keys)
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
              brokenp t)
        (map-add (current-map) (make-instance 'powerup-life
                                 :pos (entity-pos e)))))))

(defmethod entity-interact ((e breakable) a)
  (with-slots (brokenp props) e
    (if brokenp
        (show-textbox (aval :btext props))
        (call-next-method))))
