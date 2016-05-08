(in-package :game)

(defun breakable-do-break (e)
  (with-slots (sprite brokenp) e
    (unless brokenp
      (let ((break-name (entity-property e :broken)))
        (setf (sprite-name sprite) break-name
              brokenp t)))))

 ;; breakable-base

(defclass breakable-base (simple-text)
  ((brokenp :initform nil :reader breakable-brokenp)))

(defmethod initialize-instance :after ((e breakable-base) &key sprite-name &allow-other-keys)
  (with-slots (pos sprite) e
    ;; For some bizarre and unknown reason, sprites in an object layer---
    ;; nothing else---have their origin at the _lower left_ corner.
    (incf (vy pos) 16.0)
    (setf sprite (make-instance 'sprite :key -1 :name sprite-name))))

(defmethod entity-solid-p ((e breakable-base)) (not (breakable-brokenp e)))

(defmethod entity-interact ((e breakable-base) a)
  (with-slots (brokenp props) e
    (if brokenp
        (show-textbox (aval :btext props))
        (call-next-method))))

 ;; breakable

(defclass breakable (breakable-base) ())

(defmethod entity-magic-hit ((e breakable) (m spell-explode))
  (breakable-do-break e)
  (map-add (current-map)
           (if (< (random 1.0) 0.5)
               (if (< (random 1.0) 0.5)
                   (make-instance 'powerup-life :pos (entity-pos e))
                   (make-instance 'powerup-magic :pos (entity-pos e))))))

 ;; fireball-breakable

(defclass fireball-breakable (breakable-base) ())

(defmethod entity-magic-hit ((e fireball-breakable) (m spell-fireball))
  (breakable-do-break e))
