(in-package :game)

(defclass asset-pack ()
  ((title :reader asset-title)
   (proj :initform (gk-mat4) :reader asset-proj)
   (font :reader asset-font)
   (spritesheet :reader asset-sheet)
   (anims :reader asset-anims)))

(defun load-assets (gk)
  (let ((pack (make-instance 'asset-pack)))
    (with-slots (proj font title spritesheet anims tm) pack
      (with-bundle (b)
        (let* ((config (make-instance 'cmd-list :subsystem :config))
               (ortho (cmd-tf-ortho proj 0 256 0 144 -10000 10000))
               (load-title (cmd-image-create (autowrap:asdf-path :lgj-2016-q2 :assets :images "title.png")
                                             :mag :nearest))
               (load-sprites (cmd-spritesheet-create
                              (autowrap:asdf-path :lgj-2016-q2 :assets :images "spritesheet.json")
                              :gk-ssf-texturepacker-json
                              :flags '(:flip-y)))
               (load-font (cmd-font-create
                           "hardpixel"
                           (autowrap:asdf-path :lgj-2016-q2 :assets :fonts "hardpixel.ttf"))))
          (cmd-list-append config ortho load-title load-sprites load-font)
          (bundle-append b config)
          (gk:process gk b)

          (setf font (font-create-id load-font))
          (setf title (image-create-id load-title))
          (setf spritesheet (make-sheet load-sprites))
          (setf anims (make-instance 'sheet-animations :sheet spritesheet)))))
    pack))
