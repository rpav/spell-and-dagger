(in-package :game)

(defclass textbox (ui)
  ((text :initform nil :initarg :text :accessor textbox-text)
   (margin :initform 50.0 :initarg :margin)
   (path-cmd :initform nil)
   (fontstyle-cmd :initform nil)
   (text-cmd :initform nil)))

(defmethod initialize-instance :after ((box textbox) &key &allow-other-keys)
  (with-slots (text path-cmd fontstyle-cmd text-cmd (m margin)) box
    (multiple-value-bind (w h)
        (window-size)
      (setf path-cmd
            (cmd-path
             (list
              :begin
              :rect m m (- w (* 2 m)) (/ h 3.0)
              :fill-color-rgba 0 0 128 200
              :stroke-color-rgba 255 255 255 255
              :stroke-width 5.0
              :line-join gk.raw:+gk-linecap-round+
              :fill
              :stroke
              :fill-color-rgba 255 255 255 255))

            fontstyle-cmd
            (cmd-font-style
             :size (/ h 15.0)
             :align '(:top :left))

            text-cmd
            (cmd-text text
                      :break-width (- w (* 4 m))
                      :x (* m 1.4)
                      :y (* m 1.2))))))

(defmethod (setf textbox-text) :after (v (box textbox))
  (with-slots (text-cmd) box
    (setf (text-string text-cmd) v)))

(defmethod draw ((box textbox) lists m)
  (with-slots (path-cmd fontstyle-cmd text-cmd) box
    (with-slots (ui-list) lists
      (cmd-list-append ui-list
                       path-cmd
                       fontstyle-cmd
                       text-cmd))))
