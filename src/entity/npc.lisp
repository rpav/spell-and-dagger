(in-package :game)

 ;; BEHAVIOR

(defclass behavior () ())

(defgeneric behavior-act (behavior npc interacting-entity)
  (:documentation "Called when `NPC` is interacted with by
`INTERACTING-ENTITY`.")
  (:method (b npc e)
    (if-let (text (entity-property npc :text))
      (show-textbox text)
      (show-textbox "..."))))

(defclass simple-behavior (behavior) ())


(defclass teacher-behavior (behavior) ())

(defmethod behavior-act ((b teacher-behavior) npc c)
  (if (game-value :has-spell)
      (show-textbox "Have you tried it?  It can break certain things.")
      (progn
        (show-textbox "Let me teach you a useful spell.  (Press A to use.)")
        (setf (game-value :has-spell) t))))

 ;; NPC

(defclass npc (actor move-manager)
  ((knockback-speed :initform 0.1)
   (behavior :initform nil)))

(defmethod initialize-instance :after ((e npc) &key props &allow-other-keys)
  (with-slots (behavior) e
    (let ((behavior-class (aval :behavior props)))
      (setf behavior (if behavior-class
                         (make-instance (intern (string-upcase behavior-class)
                                                :game))
                         (make-instance 'simple-behavior))))))

(defmethod entity-interact ((e npc) (g game-char))
  (setf (actor-facing e) (aval (actor-facing g) +reverse-motion+))

  (with-slots (behavior) e
    (behavior-act behavior e g)))
