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
        (show-textbox "Let me teach you a useful spell.  (Press X to use.)")
        (setf (game-value :has-spell) t)
        (char-teach-spell c 'spell-explode))))

 ;; NPC

(defclass npc (actor move-manager)
  ((knockback-speed :initform 0.1)
   (state :initform :starting)
   (behavior :initform nil)
   (act-start :initform 0)))

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

;;; This should all be folded into an AI controller and shared with monster
(defun npc-change-action (e)
  (with-slots (state) e
    (case state
      (:starting (setf (entity-state e) :waiting))
      (:waiting
       (setf (entity-motion e) (elt +motions+ (random 4)))
       (nv2* (entity-motion e) 0.5)
       (setf (entity-state e) :moving))
      (:moving
       (setf (entity-motion e) +motion-none+)
       (setf (entity-state e) :waiting))))
  (with-slots (act-start) e
    (setf act-start *time*)))

(defmethod entity-update ((e npc))
  (call-next-method)
  (with-slots (act-start) e
    (let ((d (- *time* act-start)))
      (when (> d (+ 0.5 (random 2.0)))
        (simple-mob-change-action e)))))

 ;; fireball-teacher

(defclass fireball-teacher (simple-entity) ())

(defmethod initialize-instance :after ((e fireball-teacher) &key sprite-name &allow-other-keys)
  (with-slots (pos sprite) e
    (incf (vy pos) 16.0)
    (setf sprite (make-instance 'sprite :key -1 :name sprite-name))))

(defmethod entity-interact ((e fireball-teacher) (a game-char))
  (if (game-value :has-fireball)
      (show-textbox "Statue of Phoenix. This is where you learned how to cast Fireball. (Press S to switch spells.)")
      (progn
        (setf (game-value :has-fireball) t)
        (char-teach-spell (current-char) 'spell-fireball)
        (show-textbox "Statue of Phoenix ... you learn how to cast Fireball! (Press S to switch spells.)"))))
