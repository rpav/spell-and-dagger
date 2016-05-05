(in-package :game)

 ;; simple-entity

(defclass simple-entity (entity)
  ((box :initform nil)))

(defmethod initialize-instance :after ((e simple-entity) &key &allow-other-keys)
  (with-slots (box) e
    (setf box (cons (entity-pos e) (entity-size e)))))

(defmethod entity-box ((e simple-entity)) (slot-value e 'box))

 ;; simple-blocker

(defclass simple-blocker (simple-entity) ())

 ;; simple-text

(defclass simple-text (simple-entity)
  ((text :initform "")))

(defmethod initialize-instance :after ((e simple-text) &key props &allow-other-keys)
  (with-slots (text) e
    (if-let (str (aval :text props))
      (setf text str)
      (format t "Warning: String not specified for SIMPLE-TEXT"))))

(defmethod entity-solid-p ((e simple-text)) nil)

(defmethod entity-interact ((e simple-text) a)
  (with-slots (text) e
    (show-textbox text)))

 ;; link

(defclass link (simple-entity) ())
