(in-package :game)

(defvar *assets* nil
  "This should be set to ASSETS when any game logic stuff is called")

(defvar *time* nil
  "This should be set to the current frame time during game logic")

(defvar *ps* nil
  "This should be set to the game's phase stack")

(defvar *window* nil
  "The current game-window")

(defvar *ps* nil
  "The phase stack")

(defvar *anim-manager* nil
  "The animation manager")

(defgeneric draw (thing lists matrix)
  (:documentation "Draw `THING` given `LISTS` and prior transformation `MATRIX`"))
