;;; This was taken, conceptually, from how I do things in some other
;;; games.  But it was rewritten, since that was Lua and this is Lisp!

(in-package :game)

 ;; PHASE

(defclass game-phase () ())

;;; When the phase begins after being pushed or ends before being popped
(defgeneric phase-start (game-phase)
  (:method ((p game-phase))
    (phase-resume p)))
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

(defmethod print-object ((o phase-stack) s)
  (print-unreadable-object (o s :type t)
    (format s "CUR: ~A (~A) PHASE-REFS: ~A"
            (class-name (class-of (ps-cur-phase o)))
            (ps-cur o)
            (slot-value o 'phase-refs))))

(defun ps-incref (&optional (ps *ps*))
  (incf (slot-value ps 'phase-refs)))

(defun ps-decref (&optional (ps *ps*))
  (decf (slot-value ps 'phase-refs))
  (ps-update ps))

(defun ps-top (ps)
  (aref (slot-value ps 'phases) (ps-cur ps)))

(defun ps-cur-phase (&optional (ps *ps*))
  (with-slots (cur phases) ps
    (when (>= cur 0)
      (aref phases cur))))

(defun ps-push (new-phase &optional (ps *ps*))
  (with-slots (phases cur) ps
    (vector-push-extend new-phase phases)
    (ps-update ps)))

(defun ps-pop (&optional (ps *ps*))
  (with-slots (phases cur) ps
    (vector-pop phases)))

(defun ps-pop-to (type &optional (ps *ps*))
  (with-slots (phases phase-refs cur) ps
    (loop as phase = (vector-pop phases)
          do (decf cur)
             (when (typep phase type)
               (setf phase-refs 0)
               (ps-push phase ps)
               (return)))))

(defun ps-interrupt (new-phase &optional (ps *ps*))
  (with-slots (phase-refs) ps
    (setf phase-refs 0)
    (ps-push new-phase ps)))

(defun ps-replace (new-phase &optional (ps *ps*))
  (with-slots (phase-refs phases) ps
    (phase-finish (ps-cur-phase))
    (setf phase-refs 0)
    (setf (aref phases (ps-cur ps)) new-phase)
    (phase-start new-phase)))

(defun ps-has-up-phase (ps)
  (with-slots (cur phases) ps
    (< cur (1- (length phases)))))

(defun ps-has-down-phase (ps)
  (>= (ps-cur ps) 0))

(defun ps-step-up-phase (ps)
  (with-slots (cur phases) ps
    (when-let (phase (ps-cur-phase ps))
      (when phase
        (phase-pause phase)))
    (incf cur)
    (when-let (new-phase (ps-cur-phase ps))
      (phase-start new-phase))))

(defun ps-step-down-phase (ps)
  (with-slots (cur phases) ps
    (when-let (phase (ps-cur-phase ps))
      (decf cur)
      (vector-pop phases)
      (phase-finish phase))))

(defun ps-update (ps)
  (with-slots (phase-refs) ps
    (loop while (= 0 phase-refs)
          do (if (ps-has-up-phase ps)
                 (ps-step-up-phase ps)
                 (progn
                   (ps-step-down-phase ps)
                   (when (and (not (ps-has-up-phase ps))
                              (ps-has-down-phase ps))
                     (phase-resume (ps-cur-phase ps))))))))

(defun ps-back (&optional (ps *ps*))
  (phase-back (ps-cur-phase ps)))
