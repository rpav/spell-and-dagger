(in-package :game)

(defclass hud (ui)
  (health magic
   p1 fs1 p2 fs2
   (text-cmds :initform nil)
   (wpn-sprite :initform (make-instance 'sprite :key 9999))
   (spell-sprite :initform (make-instance 'sprite :key 9999))
   wpn-box spell-box))

(defmethod initialize-instance ((hud hud) &key &allow-other-keys)
  (call-next-method)
  (with-slots (health magic p1 fs1 p2 fs2 text-cmds wpn-box spell-box
               wpn-sprite spell-sprite)
      hud
    (multiple-value-bind (w h) (window-size)
      (declare (ignorable w h))
      (let* ((m (* *scale* 2.0))
             (fsize (/ h 15.0))
             (bar-x (* *scale* 11.0))
             (box-size (* *scale* 16.0))
             (health-offset (* 1.2 m))
             (magic-offset (+ (* 2.4 m) (* fsize 0.5))))
        ;; This is just a hack, we _could_ do this with multiple
        ;; commands and redraw the healthbar and shadow using the same
        ;; path command.  Or we could just draw it twice using 1.
        (setf health (cmd-path
                      (list
                       :begin
                       :rect bar-x health-offset 0 (* 4 *scale*)
                       :fill-color-rgba 255 0 0 255
                       :fill
                       :begin
                       :rect bar-x health-offset 0 (* 4 *scale*)
                       :stroke-color-rgba 255 255 255 255
                       :stroke-width *scale*
                       :stroke)))

        (setf magic (cmd-path
                     (list
                      :begin
                      :rect bar-x magic-offset 16 (* 4 *scale*)
                      :fill-color-rgba 0 0 255 255
                      :fill
                      :begin
                      :rect bar-x magic-offset 16 (* 4 *scale*)
                      :stroke-color-rgba 255 255 255 255
                      :stroke-width *scale*
                      :stroke)))

        (setf spell-box (cmd-path
                         (list
                          :begin
                          :rect (- w m box-size) m box-size box-size
                          :stroke-color-rgba 200 200 200 255
                          :stroke-width *scale*
                          :stroke)))

        (setf wpn-box (cmd-path
                       (list
                        :begin
                        :rect (- w m m (* 2 box-size)) m box-size box-size
                        :stroke-color-rgba 200 200 200 255
                        :stroke-width *scale*
                        :stroke)))

        (setf (sprite-pos spell-sprite) (gk-vec2 (- 256 2 16) (- 144 2 16)))
        (setf (sprite-name spell-sprite) "spell/ias_fireball_0.png")

        (setf (sprite-pos wpn-sprite) (gk-vec2 (- 256 4 32) (- 144 2 16)))
        (setf (sprite-name wpn-sprite) "weapon/dagger_icon.png")

        (setf p1 (cmd-path
                  (list
                   :fill-color-rgba 0 0 0 255
                   :tf-translate *scale* *scale*))
              fs1 (cmd-font-style :size fsize)
              p2 (cmd-path (list
                            :fill-color-rgba 255 255 255 255
                            :tf-identity))
              fs2 (cmd-font-style :size fsize))
        (appendf text-cmds
                 (list
                  (cmd-text "L" :x m :y (+ m (* fsize 0.5)))
                  (cmd-text "M" :x m :y (+ (* 2.2 m) fsize))))))))

(defun hud-update (hud)
  (with-slots (health magic) hud
    (let* ((c (current-char))
           (player-health (* *scale* (actor-life c)))
           (max-health (* *scale* (char-max-life c)))
           (player-magic (* *scale* (char-magic c)))
           (max-magic (* *scale* (char-max-magic c))))
      (setf (cmd-path-elt health 4) player-health
            (cmd-path-elt health 16) max-health)
      (setf (cmd-path-elt magic 4) player-magic
            (cmd-path-elt magic 16) max-magic))))

(defmethod draw ((hud hud) lists m)
  (hud-update hud)
  (with-slots (ui-list sprite-list) lists
    (with-slots (health magic p1 fs1 p2 fs2 text-cmds wpn-box spell-box
                 spell-sprite wpn-sprite)
        hud
      (cmd-list-append ui-list p1 fs1)
      (apply #'cmd-list-append ui-list text-cmds)
      (cmd-list-append ui-list p2 fs2)
      (apply #'cmd-list-append ui-list text-cmds)

      (cmd-list-append ui-list health magic wpn-box spell-box)

      (draw wpn-sprite lists m)
      (draw spell-sprite lists m))))
