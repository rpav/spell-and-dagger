(defpackage :lgj-2016-q2.asdf
  (:use #:cl #:asdf))

(in-package :lgj-2016-q2.asdf)

(defsystem :lgj-2016-q2
  :description "Lisp Game Jam 2016 Q2 entry"
  :author "Ryan Pavlik"
  :license "GPL2"
  :version "0.0"

  :depends-on (:alexandria :defpackage-plus :sdl2kit :gamekernel)
  :serial t

  :components
  ((:module #:src
    :pathname "src"
    :components
    ((:file "util.rpav-1")
     (:file "package")
     (:file "util")
     (:file "proto")

     (:file "game")
     (:file "phase")
     (:module #:phases
      :pathname "phases"
      :components
      ((:file "map-phase")))

     (:file "ui")
     (:module #:uis
      :pathname "ui"
      :components nil)

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
      ((:static-file "hardpixel.ttf")))))))
