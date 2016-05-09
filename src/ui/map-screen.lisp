(in-package :game)

 ;; MAP-SCREEN

(defclass map-screen (screen)
  ((hud :initform (make-instance 'hud))))

(defmethod initialize-instance :after ((ms map-screen) &key &allow-other-keys)
  (with-slots (hud) ms
    (ui-add ms hud)))

(defmethod draw :after ((s map-screen) lists m)
  (when-let (map (current-map))
    (map-update map)
    (draw map lists m)))

(defmethod key-event ((w map-screen) key state)
  (when-let (char (current-char))
    (if (eq state :keydown)
        (progn
          (case key
            (:scancode-right (set-motion-bit char +motion-right+))
            (:scancode-left (set-motion-bit char +motion-left+))
            (:scancode-up (set-motion-bit char +motion-up+))
            (:scancode-down (set-motion-bit char +motion-down+))
            (:scancode-z (entity-action char :btn1))
            (:scancode-a (entity-action char :btn2))
            (:scancode-x (entity-action char :btn3))
            (:scancode-s (entity-action char :btn4))))
        (progn
          (case key
            (:scancode-right (clear-motion-bit char +motion-right+))
            (:scancode-left (clear-motion-bit char +motion-left+))
            (:scancode-up (clear-motion-bit char +motion-up+))
            (:scancode-down (clear-motion-bit char +motion-down+)))))))

 ;; TEXT-SCREEN

;;; Note this is a different screen, but we still render--but not
;;; update--the map, because we don't want action happening while
;;; there's reading.  But doing so would be easy.  In fact, in that
;;; case, we'd probably just subclass MAP-SCREEN here.

;;; This could probably have been handled in MAP-SCREEN, but that
;;; would require special state handling, and we already *have* state
;;; handling.

(defclass text-screen (screen)
  ((textbox :initform (make-instance 'textbox))
   (draw-map-p :initarg :map :initform t)))

(defmethod initialize-instance :after ((ts text-screen) &key text &allow-other-keys)
  (with-slots (textbox) ts
    (setf (textbox-text textbox) text)
    (ui-add ts textbox)))

(defmethod draw :after ((s text-screen) lists m)
  ;; The textbox is a child, so it automatically gets rendered.
  (with-slots (draw-map-p) s
    (when draw-map-p
      (when-let (map (current-map))
        (draw map lists m)))))

(defmethod key-event ((w text-screen) key state)
  (when (eq state :keydown)
    (case key
      (:scancode-z (ps-back))
      (:scancode-a (ps-back))
      (:scancode-x (ps-back))
      (:scancode-s (ps-back)))))
