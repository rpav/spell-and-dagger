(in-package :game)

(defclass game-lists ()
  ((pass-list :initform (make-instance 'cmd-list :subsystem :config))
   (pre-list :initform (make-instance 'cmd-list :prealloc 100 :subsystem :config))
   (sprite-list :initform (make-instance 'cmd-list :prealloc 100 :subsystem :gl))
   (ui-list :initform (make-instance 'cmd-list :subsystem :nvg))))

(defclass game-window (kit.sdl2:gl-window)
  (gk assets
   (render-bundle :initform (make-instance 'bundle))
   (render-lists :initform (make-instance 'game-lists))))

(defmethod initialize-instance :after ((w game-window) &key &allow-other-keys)
  (with-slots (gk assets render-bundle render-lists) w
    (with-slots (pass-list pre-list sprite-list ui-list) render-lists
      (setf gk (gk:create :gl3))
      (setf assets (load-assets gk))

      (let ((sprite (make-instance 'sprite
                      :pos (gk-vec4 100 100 0 1)
                      :sheet (asset-sheet assets)
                      :index 0)))
        (draw sprite render-lists (asset-proj assets)))

      (let ((pre-pass (pass 1))
            (sprite-pass (pass 2 :asc))
            (ui-pass (pass 3)))
        (cmd-list-append pass-list pre-pass sprite-pass ui-pass)
        (bundle-append render-bundle
                       pass-list        ; 0
                       pre-list         ; 1
                       sprite-list      ; 2
                       ui-list          ; 3
                       )))))

(defmethod kit.sdl2:close-window :before ((w game-window))
  (with-slots (gk) w
    (gk:destroy gk)))

(defmethod kit.sdl2:render ((w game-window))
  (gl:clear-color 0.0 0.0 0.0 1.0)
  (gl:clear :color-buffer-bit :stencil-buffer-bit)
  (with-slots (gk render-bundle) w
    (gk:process gk render-bundle)))

(defmethod kit.sdl2:textinput-event ((w game-window) ts text)
  (when (string= "Q" (string-upcase text))
    (kit.sdl2:close-window w)))

(defmethod kit.sdl2:keyboard-event ((window game-window) state ts repeat-p keysym)
  (let ((scancode (sdl2:scancode keysym)))
    (when (eq :scancode-escape scancode)
      (kit.sdl2:close-window window))))

(defun run (&key (w 1280) (h 720))
  (kit.sdl2:start)
  (sdl2:in-main-thread ()
    (sdl2:gl-set-attr :context-major-version 3)
    (sdl2:gl-set-attr :context-minor-version 3)
    (sdl2:gl-set-attr :context-profile-mask 1)
    (sdl2:gl-set-attr :stencil-size 8))
  (make-instance 'game-window :w w :h h))

;;; (run)
