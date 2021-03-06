(in-package :game)

 ;; SPELL

(defclass spell (entity)
  ((sprite :initform (make-instance 'sprite :key 0))
   (speed :initform 1.0)
   anim anim-state))

(defgeneric spell-icon (spell)
  (:documentation "Return the index for `SPELL`'s icon.")
  (:method (s) (find-frame (asset-sheet *assets*) "nosprite.png")))

;;; This is kinda dumb.  We need a real inventory system to keep spell
;;; instances.  Then it'll just be a slot value.
(defgeneric spell-cost (spell)
  (:method (s) 0.0))

(defmethod initialize-instance :after ((e spell) &key &allow-other-keys)
  (with-slots (anim anim-state sprite) e
    (setf anim-state (animation-instance anim sprite)
          (anim-state-on-stop anim-state)
          (lambda (s)
            (map-remove (current-map) e)))))

(defmethod entity-box ((e spell))
  (with-slots (pos) e
    (values +spell-bbox+ pos)))

(defmethod (setf entity-motion) :after (v (e spell))
  (with-slots (motion speed) e
    (nv2* motion speed)))

(defmethod entity-solid-p ((e spell)) nil)
(defmethod entity-added-to-map (map (e spell))
  (with-slots (anim anim-state) e
    (anim-play *anim-manager* anim-state)))

(defmethod entity-touch ((e spell) e2)
  #++
  (when (and (entity-solid-p e2)
             (not (eq (current-char) e2)))
    (map-remove (current-map) e)))

 ;; SPELL-EXPLODE

(defclass spell-explode (spell)
  ((speed :initform 1.2)
   (anim :initform (make-instance 'anim-sprite
                     :name "spell/explode"
                     :frame-length (/ 100 1000.0)
                     :count 1))))

(defmethod spell-icon ((s (eql 'spell-explode)))
  (find-anim-frame (asset-anims *assets*) "spell/explode" 3))

(defmethod entity-touch ((e1 spell-explode) o)
  (entity-magic-hit o e1)
  (call-next-method))

 ;; SPELL-FIREBALL

(defclass spell-fireball (spell)
  ((speed :initform 1.2)
   (anim :initform (make-instance 'anim-sprite
                     :name "spell/ias-fireball"
                     :frame-length (/ 100 1000.0)
                     :count 1))))

(defmethod spell-icon ((s (eql 'spell-fireball)))
  (find-anim-frame (asset-anims *assets*) "spell/ias-fireball" 0))

(defmethod spell-cost ((s (eql 'spell-fireball))) 2.0)

(defmethod entity-touch ((e1 spell-fireball) o)
  (entity-magic-hit o e1)
  (call-next-method))
