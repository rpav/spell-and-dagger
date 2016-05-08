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
