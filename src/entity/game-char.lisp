(in-package :game)

 ;; Quick take on character

;;; We'll generate these later for actions, but we don't want to cons
;;; up new strings everytime an action changes
(defparameter *walking*
  '((:up . "ranger-f/walk-up")
    (:down . "ranger-f/walk-down")
    (:left . "ranger-f/walk-left")
    (:right . "ranger-f/walk-right")))

(defparameter *attacking*
  '((:up . "ranger-f/atk-up")
    (:down . "ranger-f/atk-down")
    (:left . "ranger-f/atk-left")
    (:right . "ranger-f/atk-right")))

(defparameter *weapon*
  '((:up . "weapon/sword_up.png")
    (:down . "weapon/sword_down.png")
    (:left . "weapon/sword_left.png")
    (:right . "weapon/sword_right.png")))

(defparameter +game-char-bbox+
  (cons (gk-vec2 4 1)
        (gk-vec2 8 14)))

(defparameter +motion-mask+
  '((:left  . #b1000)
    (:right . #b0001)
    (:up    . #b0100)
    (:down  . #b0010)))

;;; Note how trivial it is to add diagonals here
(defparameter +motion-mask-to-vector+
  `((#b1000 . ,+motion-left+)
    (#b0001 . ,+motion-right+)
    (#b0100 . ,+motion-up+)
    (#b0010 . ,+motion-down+)))

(defclass game-char (entity)
  ((pos :initform (gk-vec2 0 0))
   (facing :initform :down)
   (state :initform :moving)
   (motion-mask :initform 0)
   wpn-sprite anim anim-state))

(defmethod initialize-instance :after ((g game-char) &key &allow-other-keys)
  (with-slots (sprite wpn-sprite anim anim-state) g
    (setf anim (make-instance 'anim-sprite :name (aval :down *walking*)))
    (setf anim-state (animation-instance anim nil))
    (setf wpn-sprite (make-instance 'sprite :sheet (asset-sheet *assets*) :index 0 :key 2))))

(defmethod entity-box ((e game-char))
  (with-slots (pos) e
    (values +game-char-bbox+ pos)))

(defmethod entity-action ((e game-char) (a (eql :btn1)))
  (with-slots () e
    (setf (entity-state e) :attacking)
    (game-char-play-attack e)))

(defmethod entity-action ((e game-char) (a (eql :btn2)))
  (multiple-value-bind (b o) (entity-box e)
    (let* ((map (current-map))
           (matches (delete e (map-find-in-box map b o))))
      (if matches
          (loop for ob in matches
                do (entity-interact ob e))
          (show-textbox "Nothing here.")))))

(defmethod entity-motion ((e game-char))
  (with-slots (state motion) e
    (case state
      (:attacking +motion-none+)
      (otherwise motion))))

(defmethod (setf entity-motion) :after (m (e game-char))
  (game-char-play-motion e m))

(defmethod draw ((e game-char) lists m)
  (with-slots (sprite wpn-sprite) e
    (draw sprite lists m)
    (case (entity-state e)
      (:attacking (draw wpn-sprite lists m)))))

(defmethod entity-collide ((e game-char) (c link))
  (let ((map (entity-property c :map))
        (target (entity-property c :target)))
    (format t "Move to ~S@~S~%" map target)
    (map-change map target)))

(defun game-char-update-motion (e)
  (with-slots (motion-mask) e
    (setf (entity-motion e)
          (or (aval motion-mask +motion-mask-to-vector+)
              +motion-none+))))

(defun set-motion-bit (e direction)
  (with-slots (motion-mask) e
    (let ((mask (aval direction +motion-mask+)))
      (setf motion-mask (logior motion-mask mask)))
    (game-char-update-motion e)))

(defun clear-motion-bit (e direction)
  (with-slots (motion-mask) e
    (let ((mask (aval direction +motion-mask+)))
      (setf motion-mask (logandc2 motion-mask mask)))
    (game-char-update-motion e)))

(defun clear-motion-bits (e)
  (setf (slot-value e 'motion-mask) 0)
  (game-char-update-motion e))

 ;; util

(defun game-char-play-motion (e m)
  (with-slots (sprite facing anim anim-state) e
    (switch (m)
      (+motion-none+ nil)
      (+motion-up+ (setf facing :up))
      (+motion-down+ (setf facing :down))
      (+motion-left+ (setf facing :left))
      (+motion-right+ (setf facing :right)))
    (setf (anim-sprite-anim anim) (find-anim (asset-anims *assets*)
                                             (aval facing *walking*))
          (anim-sprite-frame-length anim) (/ 180 1000.0)
          (anim-sprite-count anim) nil
          (anim-state-object anim-state) sprite)
    (anim-stop *anim-manager* anim-state)
    (if (eq +motion-none+ m)
        (setf (sprite-index sprite)
              (find-anim-frame (asset-anims *assets*)
                               (aval facing *walking*) 1))
        (anim-run *anim-manager* anim-state))))

(defun game-char-play-attack (e)
  (with-slots (sprite facing wpn-sprite anim anim-state) e
    (setf (anim-sprite-count anim) 1
          (anim-sprite-frame-length anim) (/ 20 1000.0)
          (anim-sprite-anim anim) (find-anim (asset-anims *assets*)
                                             (aval facing *attacking*))
          (anim-state-on-stop anim-state) (lambda (s)
                                            (declare (ignore s))
                                            (game-char-end-attack e)))
    (setf (sprite-index wpn-sprite) (find-frame (asset-sheet *assets*)
                                                (aval facing *weapon*)))
    (set-vec2 (sprite-pos wpn-sprite) (sprite-pos sprite))
    (anim-run *anim-manager* anim-state)))

(defun game-char-end-attack (e)
  (with-slots () e
    (setf (entity-state e) :moving)
    (game-char-update-motion e)))
