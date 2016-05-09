(in-package :game)

 ;; text-once

(defclass text-once (simple-entity)
  ((text :initform nil)
   (flag :initform nil)))

(defmethod initialize-instance :after ((e text-once) &key props &allow-other-keys)
  (with-slots (flag text) e
    (unless (aval :text props) (format t "Warning: Text not specified for ~A~%" (class-name (class-of e))))
    (unless (aval :flag props) (format t "Warning: Flag not specified for ~A~%" (class-name (class-of e))))
    (when-let (s (aval :text props)) (setf text s))
    (if-let (s (aval :flag props))
      (setf flag (make-keyword (string-upcase s)))
      (setf flag 'text-once))))

(defmethod entity-solid-p ((e text-once)) nil)
(defmethod entity-touch ((g game-char) (e1 text-once))
  (with-slots (text flag) e1
    (unless (game-value flag)
      (show-textbox text)
      (setf (game-value flag) t))))

 ;; end-game

(defclass end-game (simple-entity) ())

(defmethod entity-solid-p ((e1 end-game)) nil)
(defmethod entity-touch ((g game-char) (e1 end-game))
  (phase-to-endgame))
