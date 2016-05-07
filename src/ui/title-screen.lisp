(in-package :game)

(defclass title-screen (screen)
  (text style img
   (text-visible :initform t)))

(defmethod initialize-instance ((s title-screen) &key &allow-other-keys)
  (call-next-method)
  (with-slots (text style img) s
    (multiple-value-bind (w h) (window-size)
      (declare (ignorable w))
      (setf img (make-instance 'image
                  :key 0
                  :tex (asset-title *assets*)
                  :size (gk-vec3 256 144 1.0)
                  :pos (gk-vec3 0 0 0)
                  :anchor (gk-vec2 0 0)))
      (ui-add s img)
      (setf style (cmd-font-style :size (/ h 15.0) :align '(:center)))
      (setf text (cmd-text "Press Z" :x (/ w 2.0) :y (* 3 (/ h 4.0)))))))

(defmethod key-event ((s title-screen) key state)
  (when (eq state :keyup)
    (case key
      (:scancode-z (title-start)))))

(defmethod draw ((s title-screen) lists m)
  (call-next-method)
  (with-slots (ui-list) lists
    (with-slots (text style text-visible) s
      (when text-visible
        (cmd-list-append ui-list style text)))))
