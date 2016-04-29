;;; This was taken, conceptually, from how I do things in some other
;;; games.  But it was rewritten, since that was Lua and this is Lisp!

(in-package :game)

 ;; PHASE

(defclass game-phase () ())

;;; When the phase begins after being pushed or ends before being popped
(defgeneric phase-start (game-phase) (:method ((p game-phase))))
(defgeneric phase-finish (game-phase) (:method ((p game-phase))))

;;; When the phase is paused or resumed
(defgeneric phase-pause (game-phase) (:method ((p game-phase))))
(defgeneric phase-resume (game-phase) (:method ((p game-phase))))

;;; When something signals a phase it should probably quit
(defgeneric phase-back (game-phase) (:method ((p game-phase))))


 ;; PHASE-STACK

(defclass phase-stack ()
  ((phases :initform (make-array 10 :adjustable t :fill-pointer 0 :initial-element nil))
   (cur :initform -1 :reader ps-cur)
   (phase-refs :initform 0)))

(defun ps-top (ps)
  (aref (slot-value ps 'phases) (ps-cur ps)))

(defun ps-push (ps new-phase)
  (with-slots (phases cur) ps
    (vector-push-extend phases new-phase)))

(defun ps-pop (ps)
  (with-slots (phases cur) ps
    (vector-pop phases)))

