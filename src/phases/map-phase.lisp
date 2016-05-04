(in-package :game)

(defclass map-phase (game-phase)
  ((map-screen :initform (make-instance 'map-screen))
   (char :initform (make-instance 'game-char))
   (map :initform nil)))

(defmethod initialize-instance :after ((p map-phase) &key &allow-other-keys)
  (with-slots (char map (ms map-screen)) p
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
    (map-add map char)

    (setf (map-screen-map ms) map
          (map-screen-char ms) char)))

(defmethod phase-start ((p map-phase))
  (phase-resume p))

(defmethod phase-resume ((p map-phase))
  (ps-incref *ps*)
  (with-slots (map-screen) p
    (setf (ui-visible map-screen) t)))
