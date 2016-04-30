(in-package :game)

(defvar *assets* nil
  "This should be set to ASSETS when any game logic stuff is called")

(defvar *time* nil
  "This should be set to the current frame time during game logic")

(defvar *ps* nil
  "This should be set to the game's phase stack")

(defvar *screen* nil)

(defgeneric draw (thing lists matrix)
  (:documentation "Draw `THING` given `LISTS` and prior transformation `MATRIX`"))
