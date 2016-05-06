(in-package :game)

 ;; Quick take on character

;;; We'll generate these later for actions, but we don't want to cons
;;; up new strings everytime an action changes
(defparameter *walking*
  `((,+motion-up+ . "ranger-f/walk-up")
    (,+motion-down+ . "ranger-f/walk-down")
    (,+motion-left+ . "ranger-f/walk-left")
    (,+motion-right+ . "ranger-f/walk-right")))

(defparameter *attacking*
  `((,+motion-up+ . "ranger-f/atk-up")
    (,+motion-down+ . "ranger-f/atk-down")
    (,+motion-left+ . "ranger-f/atk-left")
    (,+motion-right+ . "ranger-f/atk-right")))

(defparameter *weapon*
  `((,+motion-up+ . "weapon/sword_up.png")
    (,+motion-down+ . "weapon/sword_down.png")
    (,+motion-left+ . "weapon/sword_left.png")
    (,+motion-right+ . "weapon/sword_right.png")))

(defparameter +game-char-bbox+
  (cons (gk-vec2 4 1)
        (gk-vec2 7 4)))

;;; Note how trivial it is to add diagonals here
(defparameter +motion-mask+
  `((,+motion-left+  . #b1000)
    (,+motion-right+ . #b0001)
    (,+motion-up+    . #b0100)
    (,+motion-down+  . #b0010)))

(defclass game-char (actor)
  ((life :initform 5 :reader char-life)
   (max-life :initform 5 :accessor char-max-life)
   (magic :initform 5 :reader char-magic)
   (max-magic :initform 5 :accessor char-max-magic)
   (state :initform :moving)
   (motion-mask :initform 0)
   (wpn-box :initform (box 4 4 8 8))
   (wpn-pos :initform (gk-vec2 0 0))
   wpn-sprite anim anim-state))

(defmethod initialize-instance :after ((g game-char) &key &allow-other-keys)
  (with-slots (sprite wpn-sprite anim anim-state) g
    (setf anim (make-instance 'anim-sprite :name (aval +motion-down+ *walking*)))
    (setf anim-state (animation-instance anim nil))
    (setf wpn-sprite (make-instance 'sprite
                       :sheet (asset-sheet *assets*)
                       :index 0
                       :key 2))))

(defmethod entity-box ((e game-char))
  (with-slots (pos) e
    (values +game-char-bbox+ pos)))

(defmethod entity-action ((e game-char) (a (eql :btn1)))
  (with-slots () e
    (setf (entity-state e) :attacking)
    (game-char-play-attack e)))

(defmethod entity-action ((e game-char) (a (eql :btn2)))
  (with-slots (wpn-box wpn-pos) e
    (game-char-update-wpn-box e)
    (let* ((map (current-map))
           (matches (delete e (map-find-in-box map wpn-box wpn-pos))))
      (if matches
          (loop for ob in matches
                do (entity-interact ob e))
          (show-textbox "Nothing here.")))))

(defmethod draw ((e game-char) lists m)
  (with-slots (sprite wpn-sprite wpn-box wpn-pos) e
    (draw sprite lists m)
    (case (entity-state e)
      (:attacking (draw wpn-sprite lists m)))))

(defmethod entity-collide ((e game-char) (c link))
  (let ((map (entity-property c :map))
        (target (entity-property c :target)))
    (when map
      (format t "Move to ~S@~S~%" map target)
      (map-change map target)
      (game-char-update-motion e))))

(defmethod entity-collide ((e game-char) (c simple-mob))
  (with-slots (life hit-start) e
    (unless hit-start
      (decf life)
      (if (actor-dead-p e)
          (game-over)
          (actor-knock-back e (entity-pos c))))))

(defmethod actor-knockback-end ((a game-char))
  (game-char-update-motion a))

(defun game-char-update-motion (e)
  (with-slots (motion-mask state) e
    (when (eq state :moving)
      (let ((motion (or (akey motion-mask +motion-mask+)
                        +motion-none+)))
        (setf (entity-motion e) motion)
        (game-char-play-motion e motion)))))

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

(defmethod (setf char-life) (v (c game-char))
  (with-slots (life max-life) c
    (setf life v)
    (when (> life max-life)
      (setf life max-life))
    life))

(defmethod (setf char-magic) (v (c game-char))
  (with-slots (magic max-magic) c
    (setf magic v)
    (when (> magic max-magic)
      (setf magic max-magic))
    magic))

 ;; util

(defun game-char-play-motion (e m)
  (with-slots (sprite facing anim anim-state) e
    (unless (eq m +motion-none+)
      (setf facing m))
    (setf (anim-sprite-anim anim) (find-anim (asset-anims *assets*)
                                             (aval facing *walking*))
          (anim-sprite-frame-length anim) (/ 180 1000.0)
          (anim-sprite-count anim) nil
          (anim-state-object anim-state) sprite
          (anim-state-on-stop anim-state) nil)
    (anim-stop *anim-manager* anim-state)
    (if (eq +motion-none+ m)
        (setf (sprite-index sprite)
              (find-anim-frame (asset-anims *assets*)
                               (aval facing *walking*) 1))
        (anim-play *anim-manager* anim-state))))

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
    (anim-play *anim-manager* anim-state)))

(defun game-char-update-wpn-box (e)
  (with-slots (wpn-box wpn-pos facing) e
    (set-vec2 wpn-pos facing)
    (nv2* wpn-pos 8)
    (nv2+ wpn-pos (entity-pos e))))

(defun game-char-do-attack (e)
  (game-char-update-wpn-box e)
  (with-slots (wpn-box wpn-pos) e
    (let* ((map (current-map))
           (hits (delete e (map-find-in-box map wpn-box wpn-pos))))
      (loop for ob in hits
            do (entity-attacked ob e nil)))))

(defun game-char-end-attack (e)
  (game-char-do-attack e)
  (setf (entity-state e) :moving)
  (game-char-update-motion e))
