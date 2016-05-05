(in-package :game)

(defclass map-phase (game-phase)
  ((map-screen :initform (make-instance 'map-screen))))

(defmethod initialize-instance :after ((p map-phase) &key &allow-other-keys)
  (with-slots ((ms map-screen)) p
    (let* ((sprite
             (make-instance 'sprite
               :pos (gk-vec4 0 0 0 1)
               :sheet (asset-sheet *assets*)
               :key 1
               :index (find-anim-frame (asset-anims *assets*) "ranger-f/walk-down" 1))))
      (setf (current-char)
            (make-instance 'game-char :sprite sprite))
      (map-change "test"))))

(defmethod phase-resume ((p map-phase))
  (ps-incref *ps*)
  (with-slots (map-screen) p
    (setf (ui-visible map-screen) t)))

(defmethod phase-pause ((p map-phase))
  (clear-motion-bits (current-char)))

(defmethod phase-show-textbox ((phase map-phase) text)
  (ps-push (make-instance 'text-phase :text text))
  (ps-decref))

(defun show-textbox (text)
  (phase-show-textbox (ps-cur-phase) text))
