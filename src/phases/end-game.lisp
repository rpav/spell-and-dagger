(in-package :game)

 ;;

(defclass end-game-phase (game-phase) ())

(defmethod phase-start ((p end-game-phase))
  (setf (current-map) nil)
  (setf (current-char) nil)
  (show-textbox "You trudge north across a bridge and deep canyon you don't remember existing.  What has happened to your home?  To the world?  Perhaps answers lie in the world beyond..."))

(defmethod phase-resume ((p end-game-phase))
  (ps-incref)
  (let ((screen (make-instance 'the-end-screen)))
    (setf (ui-visible screen) t)))

(defmethod phase-show-textbox ((phase end-game-phase) text)
  (ps-interrupt (make-instance 'text-phase :map nil :text text)))
