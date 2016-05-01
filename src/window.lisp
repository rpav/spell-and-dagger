(in-package :game)

(defclass game-lists ()
  ((pass-list :initform (make-instance 'cmd-list :subsystem :config))
   (pre-list :initform (make-instance 'cmd-list :prealloc 100 :subsystem :config))
   (sprite-list :initform (make-instance 'cmd-list :prealloc 100 :subsystem :gl))
   (ui-list :initform (make-instance 'cmd-list :subsystem :nvg))))

(defun game-lists-clear (game-lists)
  (with-slots (pre-list sprite-list ui-list) game-lists
    (cmd-list-clear pre-list)
    (cmd-list-clear sprite-list)
    (cmd-list-clear ui-list)))

(defclass game-window (kit.sdl2:gl-window)
  (gk assets
   (screen :accessor game-window-screen)
   (phase-stack :initform (make-instance 'phase-stack))
   (render-bundle :initform (make-instance 'bundle))
   (render-lists :initform (make-instance 'game-lists))))

(defun current-screen ()
  (and *window* (game-window-screen *window*)))

(defun (setf current-screen) (v)
  (when *window*
    (setf (game-window-screen *window*) v)))

(defmethod initialize-instance :after ((win game-window) &key w h &allow-other-keys)
  (with-slots (gk assets screen render-bundle render-lists) win
    (with-slots (pass-list pre-list sprite-list ui-list) render-lists
      (setf gk (gk:create :gl3))
      (setf assets (load-assets gk))

      (let ((*assets* assets)
            (*window* win))
        (setf screen (make-instance 'test-screen :w w :h h)))

      (let ((pre-pass (pass 1))
            (sprite-pass (pass 2 :asc))
            (ui-pass (pass 3)))
        (cmd-list-append pass-list pre-pass sprite-pass ui-pass)
        (bundle-append render-bundle
                       pass-list        ; 0
                       pre-list         ; 1
                       sprite-list      ; 2
                       ui-list          ; 3
                       ))
      (sdl2:gl-set-swap-interval 1)
      (setf (kit.sdl2:idle-render win) t))))

(defmethod kit.sdl2:close-window :before ((w game-window))
  (with-slots (gk) w
    (gk:destroy gk)))

(defmethod kit.sdl2:render ((w game-window))
  (gl:clear-color 0.0 0.0 0.0 1.0)
  (gl:clear :color-buffer-bit :stencil-buffer-bit)
  (with-slots (gk assets screen render-bundle render-lists) w
    (game-lists-clear render-lists)
    (let* ((*assets* assets)
           (*time* (current-time))
           (*window* w))
      (draw screen render-lists (asset-proj *assets*))
      (gk:process gk render-bundle))))

(defgeneric key-event (ob key state) (:method (ob key state)))

(defmethod kit.sdl2:keyboard-event ((window game-window) state ts repeat-p keysym)
  (let ((*window* window)
        (scancode (sdl2:scancode keysym)))
    (when (or (eq :scancode-escape scancode)
              (eq :scancode-q scancode))
      (kit.sdl2:close-window window))
    (unless repeat-p
      (when-let (screen (current-screen))
        (key-event screen scancode state)))))

(defun run (&key (w 1280) (h 720))
  (kit.sdl2:start)
  (sdl2:in-main-thread ()
    (sdl2:gl-set-attr :context-major-version 3)
    (sdl2:gl-set-attr :context-minor-version 3)
    (sdl2:gl-set-attr :context-profile-mask 1)
    (sdl2:gl-set-attr :stencil-size 8))
  (make-instance 'game-window :w w :h h))

;;; (run)
