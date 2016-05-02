(in-package :game)

(defclass asset-pack ()
  ((proj :initform (gk-mat4) :reader asset-proj)
   (font :reader asset-font)
   (spritesheet :reader asset-sheet)
   (anims :reader asset-anims)
   (tm :reader asset-tm)))

(defun load-assets (gk)
  (let ((pack (make-instance 'asset-pack)))
    (with-slots (proj font spritesheet anims tm) pack
      (with-bundle (b)
        (let* ((config (make-instance 'cmd-list :subsystem :config))
               (ortho (cmd-tf-ortho proj 0 256 0 144 -10000 10000))
               (load-sprites (cmd-spritesheet-create
                              (autowrap:asdf-path :lgj-2016-q2 :assets :image "spritesheet.json")
                              :gk-ssf-texturepacker-json
                              :flags '(:flip-y)))
               (load-font (cmd-font-create
                           "hardpixel"
                           (autowrap:asdf-path :lgj-2016-q2 :assets :font "hardpixel.ttf"))))
          (cmd-list-append config ortho load-sprites load-font)
          (bundle-append b config)
          (gk:process gk b)

          (setf font (font-create-id load-font))
          (setf spritesheet (make-sheet load-sprites))
          (setf anims (make-instance 'sheet-animations :sheet spritesheet))

          (setf tm (make-instance 'gk-tilemap
                     :sheet spritesheet
                     :tilemap (load-tilemap (autowrap:asdf-path :lgj-2016-q2 :assets :map "test.json")))))))
    pack))
