(in-package :game)

 ;; MAP-SCREEN

(defclass map-screen (screen)
  ((map :initform nil :initarg :map :accessor map-screen-map)
   (char :initform nil :initarg :map :accessor map-screen-char)))

(defmethod draw :after ((s map-screen) lists m)
  (with-slots (char map) s
    (map-update map)
    (draw char lists m)
    (when map
      (draw map lists m))))

(defmethod key-event ((w map-screen) key state)
  (with-slots (char) w
    (if (eq state :keydown)
        (progn
          (case key
            (:scancode-right (set-motion-bit char :right))
            (:scancode-left (set-motion-bit char :left))
            (:scancode-up (set-motion-bit char :up))
            (:scancode-down (set-motion-bit char :down))
            (:scancode-z (entity-action char :btn1))
            (:scancode-a (entity-action char :btn2))))
        (progn
          (case key
            (:scancode-right (clear-motion-bit char :right))
            (:scancode-left (clear-motion-bit char :left))
            (:scancode-up (clear-motion-bit char :up))
            (:scancode-down (clear-motion-bit char :down)))))))
