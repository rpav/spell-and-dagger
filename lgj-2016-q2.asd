(defpackage :lgj-2016-q2.asdf
  (:use #:cl #:asdf))

(in-package :lgj-2016-q2.asdf)

(defsystem :lgj-2016-q2
  :description "Lisp Game Jam 2016 Q2 entry"
  :author "Ryan Pavlik"
  :license "GPL2"
  :version "0.0"

  :depends-on (:alexandria :defpackage-plus
               :cl-json :cl-ppcre :sdl2kit :gamekernel)
  :serial t

  :components
  ((:module #:src
    :pathname "src"
    :components
    ((:file "util.rpav-1")
     (:file "package")
     (:file "util")
     (:file "proto")

     (:file "entity")
     (:file "physics")
     (:file "anim")
     (:file "tilemap")
     (:file "game-map")

     (:module #:entities
      :pathname "entity"
      :components
      ((:file "actor")
       (:file "simple")
       (:file "simple-mob")
       (:file "spawner")
       (:file "game-char")
       (:file "powerup")
       (:file "spell")))

     (:file "phase")
     (:module #:phases
      :pathname "phases"
      :components
      ((:file "map-phase")
       (:file "text-phase")
       (:file "game-over")))

     (:file "ui")
     (:module #:uis
      :pathname "ui"
      :components
      ((:file "textbox")
       (:file "map-screen")
       (:file "hud")
       (:file "game-over-screen")))


     (:file "sprite")
     (:file "assets")
     (:file "window")
     (:file "quadtree")))

   (:module #:assets
    :pathname "assets"
    :components
    ((:module #:image
      :pathname "image"
      :components
      ((:static-file "spritesheet.json")
       (:static-file "spritesheet.png")))
     (:module #:font
      :pathname "font"
      :components
      ((:static-file "hardpixel.ttf")))
     (:module #:maps
      :pathname "map"
      :components
      ((:static-file "tm-town.json")
       (:static-file "tm-indoor.json")
       (:static-file "test.json")
       (:static-file "test2.json")))))))
