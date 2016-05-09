(in-package :game)

;;; Entity
(defvar +motion-none+)
(defvar +motion-up+)
(defvar +motion-down+)
(defvar +motion-left+)
(defvar +motion-right+)

(defvar +motions+)
(defvar +reverse-motion+)

(defvar +default-box+)

;;; Character
(defvar *walking*)
(defvar *attacking*)
(defvar *casting*)
(defvar *weapon*)

(defvar +game-char-bbox+)

(defvar +interact-box-left+)
(defvar +interact-box-right+)

(defvar +interact-box-up+)
(defvar +interact-box-down+)

(defvar +motion-mask+)

;;; simple-mob
(defvar +simple-mob-bbox+)

;;; Spells
(defvar +spell-bbox+)

;;; spawner
(defvar +spawner-bbox+)

;;; Static startup initialization

(defun static-startup ()
  (setf +motion-none+  (gk-vec2  0  0))
  (setf +motion-up+    (gk-vec2  0  1))
  (setf +motion-down+  (gk-vec2  0 -1))
  (setf +motion-left+  (gk-vec2 -1  0))
  (setf +motion-right+ (gk-vec2  1  0))

  (setf +motions+ (list +motion-up+ +motion-down+ +motion-left+ +motion-right+))
  (setf +reverse-motion+
        `((,+motion-none+ . ,+motion-none+)
          (,+motion-up+ . ,+motion-down+)
          (,+motion-down+ . ,+motion-up+)
          (,+motion-left+ . ,+motion-right+)
          (,+motion-right+ . ,+motion-left+)))

  (setf +default-box+ (cons (gk-vec2 0 0) (gk-vec2 16 16)))

  ;; We'll generate these later for actions, but we don't want to cons
  ;; up new strings everytime an action changes
  (setf *walking*
        `((,+motion-up+ . "ranger-f/walk-up")
          (,+motion-down+ . "ranger-f/walk-down")
          (,+motion-left+ . "ranger-f/walk-left")
          (,+motion-right+ . "ranger-f/walk-right")))
  (setf *attacking*
        `((,+motion-up+ . "ranger-f/atk-up")
          (,+motion-down+ . "ranger-f/atk-down")
          (,+motion-left+ . "ranger-f/atk-left")
          (,+motion-right+ . "ranger-f/atk-right")))
  (setf *casting*
        `((,+motion-up+ . "ranger-f/cast-up")
          (,+motion-down+ . "ranger-f/cast-down")
          (,+motion-left+ . "ranger-f/cast-left")
          (,+motion-right+ . "ranger-f/cast-right")))
  (setf *weapon*
        `((,+motion-up+ . "weapon/sword_up.png")
          (,+motion-down+ . "weapon/sword_down.png")
          (,+motion-left+ . "weapon/sword_left.png")
          (,+motion-right+ . "weapon/sword_right.png")))

  (setf +game-char-bbox+
        (cons (gk-vec2 4 1)
              (gk-vec2 7 4)))

  (setf +interact-box-left+ (box -1 7 4 2))
  (setf +interact-box-right+ (box 2 7 14 2))

  (setf +interact-box-up+ (box 7 0 2 16))
  (setf +interact-box-down+ (box 7 -4 2 16))

  (setf +motion-mask+
        `((,+motion-left+  . #b1000)
          (,+motion-right+ . #b0001)
          (,+motion-up+    . #b0100)
          (,+motion-down+  . #b0010)))

  (setf +simple-mob-bbox+
        (cons (gk-vec2 2 2)
              (gk-vec2 14 12)))

  (setf +spell-bbox+
        (cons (gk-vec2 4 4) (gk-vec2 8 8)))

  (setf +spawner-bbox+
        (cons (gk-vec2 4 4)
              (gk-vec2 8 8))))
