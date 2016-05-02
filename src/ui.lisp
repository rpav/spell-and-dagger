;;; This was also taken conceptually from how I've done things elsewhere.

(in-package :game)

 ;; UI

(defclass ui ()
  ((visible :initform nil :accessor ui-visible)
   (children :initform (make-hash-table))))

(defmethod ui-add ((ui ui) &rest children)
  (with-slots ((c children)) ui
    (loop for child in children
          do (setf (gethash child c) t))))

(defmethod ui-remove ((ui ui) &rest children)
  (with-slots ((c children)) ui
    (loop for child in children
          do (remhash child c))))

(defmethod ui-clear ((ui ui))
  (with-slots ((c children)) ui
    (clrhash c)))

(defmethod draw ((ui ui) lists m)
  (with-slots ((c children)) ui
    (loop for child being each hash-key in c
          do (draw c lists m))))

 ;; SCREEN

(defclass screen (ui) ())

(defmethod screen-opening ((s screen)))
(defmethod screen-closing ((s screen)))

(defmethod (setf ui-visible) (v (s screen))
  (call-next-method)
  (if v
      (unless (and (current-screen) (eq s (current-screen)))
        (screen-opening s)
        (setf (current-screen) s))
      (when (and (current-screen) (eq s (current-screen)))
        (screen-closing s)
        (setf (current-screen) nil))))

(defclass test-screen (screen)
  ((char :initform (make-instance 'game-char))
   (physics :initform (make-instance 'physics))))

(defmethod initialize-instance :after ((s test-screen) &key w h &allow-other-keys)
  (with-slots (char physics) s
    (let ((sprite
            (make-instance 'sprite
              :pos (gk-vec4 0 0 0 1)
              :sheet (asset-sheet *assets*)
              :key 1
              :index 0)))
      (setf (entity-sprite char) sprite))
    (physics-add physics char)
    (physics-start physics)))

(defmethod draw :after ((s test-screen) lists m)
  (with-slots (char physics) s
    (physics-update physics)
    (draw (entity-sprite char) lists m)
    (draw (asset-tm *assets*) lists m)))

(defmethod key-event ((w test-screen) key state)
  (with-slots (char) w
    (if (eq state :keydown)
        (progn
          (case key
            (:scancode-right (entity-move char +motion-right+))
            (:scancode-left (entity-move char +motion-left+))
            (:scancode-up (entity-move char +motion-up+))
            (:scancode-down (entity-move char +motion-down+))
            (:scancode-z (entity-action char :btn1))
            (:scancode-a (entity-action char :btn2))))
        (progn
          (case key
            (:scancode-right (entity-move char +motion-none+))
            (:scancode-left (entity-move char +motion-none+))
            (:scancode-up (entity-move char +motion-none+))
            (:scancode-down (entity-move char +motion-none+)))))))
