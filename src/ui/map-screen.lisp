(in-package :game)

 ;; MAP-SCREEN

(defclass map-screen (screen)
  ((char :initform (make-instance 'game-char))
   (map :initform nil)))

(defmethod initialize-instance :after ((s map-screen) &key w h &allow-other-keys)
  (with-slots (char map) s
    (let ((sprite
            (make-instance 'sprite
              :pos (gk-vec4 0 0 0 1)
              :sheet (asset-sheet *assets*)
              :key 1
              :index 0)))
      (setf (entity-sprite char) sprite))
    (setf map (make-instance 'game-map
                :map (autowrap:asdf-path :lgj-2016-q2 :assets :maps "test.json")))
    (setf (entity-pos char) (map-find-start map))
    (map-add map char)))

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
