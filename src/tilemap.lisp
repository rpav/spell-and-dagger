(in-package :game)

(defparameter *tileset-cache* (make-hash-table :test 'equal))

 ;; TILE, TILESET

(defclass tile ()
  ((props :initform nil :accessor props)
   (image :initform nil :initarg :image :reader tile-image)))

(defclass tileset ()
  ((props :initform nil :accessor props)
   (tiles :initform nil :initarg :tiles :accessor tileset-tiles)))

(defmethod initialize-instance :after ((tm tileset) &key (tilecount 4) props)
  (with-slots (tiles (p props)) tm
    (setf tiles (make-array tilecount :adjustable t :initial-element nil :fill-pointer 0)
          p props)))

(defun tileset-append (ts tile)
  (with-slots (tiles) ts
    (vector-push-extend tile tiles)))

(defun tileset-tile (ts i)
  (with-slots (tiles) ts
    (aref tiles i)))

(defun translate-props (props)
  (mapcar
   (lambda (x)
     (cons (make-keyword (string-upcase (car x)))
           (cdr x)))
   props))

(defun tilemap-name-to-key (s)
  (or (parse-integer s :junk-allowed t)
      (make-keyword (string-upcase s))))

(defun load-tileset (path &key reload)
  (let ((oldset (gethash (namestring path) *tileset-cache*)))
    (if (or reload (not oldset))
        (with-open-file (s path)
          (let* ((json:*json-identifier-name-to-lisp* #'identity)
                 (json:*identifier-name-to-key* #'tilemap-name-to-key)
                 (json (json:decode-json s))
                 (tilecount (aval :tilecount json))
                 (ts (make-instance 'tileset
                       :tilecount tilecount
                       :props (translate-props (aval :properites json)))))
            (setf (fill-pointer (tileset-tiles ts)) tilecount)
            (loop for tile in (aval :tiles json)
                  as i = (car tile)
                  as img = (aval :image (cdr tile))
                  do (setf (aref (tileset-tiles ts) i)
                           (make-instance 'tile :image img)))
            (loop for prop in (aval :tileproperties json)
                  as i = (car prop)
                  do (setf (props (aref (tileset-tiles ts) i))
                           (translate-props (cdr prop))))
            (setf (gethash (namestring path) *tileset-cache*) ts)
            ts))
        oldset)))

 ;; TILE-MERGESET

(defclass tile-mergeset ()
  ((offsets :initform nil)
   (sets :initform nil)))

(defmethod initialize-instance :after ((tms tile-mergeset) &key sets &allow-other-keys)
  (let ((len (length sets))
        (sets (sort sets
                    (lambda (a b)
                      (< (aval :firstgid a)
                         (aval :firstgid b))))))
    (with-slots (offsets (s sets)) tms
      (setf offsets (make-array len :element-type '(unsigned-byte 16)
                                    :initial-contents
                                    (mapcar (lambda (x) (aval :firstgid x)) sets)))
      (setf s (make-array len
                          :initial-contents
                          (mapcar (lambda (x)
                                    (load-tileset (autowrap:asdf-path :lgj-2016-q2 :assets :map
                                                                      (aval :source x))))
                                  sets))))))

(defun tms-find (tms num)
  (if (= num 0)
      nil
      (with-slots (offsets sets) tms
        (loop for i from 0
              as offset = (aref offsets i)
              as next-offset = (and (< (1+ i) (length offsets))
                                    (aref offsets (1+ i)))
              when (or (not next-offset)
                       (< num next-offset))
                do (let ((set (aref sets i)))
                     (return-from tms-find (tileset-tile set (- num offset))))))))

#++
(let ((tms (make-instance 'tile-mergeset
             :sets '(((:FIRSTGID . 1) (:SOURCE . "tm-town.json"))
                     ((:FIRSTGID . 6) (:SOURCE . "tm-town-solid.json"))))))
  (tile-image (tms-find tms 11)))

 ;; TILEMAP

(defclass tile-layer ()
  ((props :initform nil :initarg :props :accessor props)
   (tiles :initform nil :reader tile-layer-tiles)))

(defun tile-layer-parse (json)
  (let ((layer (make-instance 'tile-layer
                 :props (aval :properties json)))
        (data (aval :data json)))
    (with-slots (tiles) layer
      (setf tiles (make-array (length data) :element-type '(unsigned-byte 16)
                                            :initial-contents data))
      layer)))

(defclass tilemap ()
  ((size :initform nil :reader tilemap-size :initarg :size)
   (layers :initform nil :reader tilemap-layers)
   (mergeset :initform nil :initarg :mergeset :reader tilemap-mergeset)
   (render-order :initform nil :initarg :render-order :reader tilemap-render-order)))

(defmethod initialize-instance :after ((tm tilemap) &key layercount)
  (with-slots (layers) tm
    (setf layers (make-array layercount))))

(defun load-tilemap (path)
  (with-open-file (s path)
    (let* ((json:*json-identifier-name-to-lisp* #'identity)
           (json:*identifier-name-to-key* #'tilemap-name-to-key)
           (json (json:decode-json s))
           (layers (aval :layers json))
           (mergeset (make-instance 'tile-mergeset
                       :sets (aval :tilesets json)))
           (tm (make-instance 'tilemap
                 :size (gk-vec2 (aval :width json)
                                (aval :height json))
                 :layercount (length layers)
                 :render-order (make-keyword (string-upcase (aval :renderorder json)))
                 :mergeset mergeset)))
      (loop for layer in layers
            for i from 0
            do (setf (aref (tilemap-layers tm) i)
                     (tile-layer-parse layer)))
      tm)))

(defun map-tilemap-layer (function tm layer)
  (with-slots (layers mergeset) tm
    (let ((layer (aref layers layer)))
      (with-slots (tiles) layer
        (loop for idx across tiles
              as tile = (tms-find mergeset idx)
              do (funcall function tile))))))

#++
(map-tilemap-layer
 (lambda (x)
   (when x
     (:say (tile-image x))))
 (load-tilemap (autowrap:asdf-path :lgj-2016-q2 :assets :map "test.json"))
 1)

 ;; GK-TILEMAP

(defclass gk-tilemap ()
  ((tilemap :initform nil :initarg :tilemap)
   (commands :initform nil))
  (:documentation "This takes a TILEMAP and produces a series of
quadsprite commands we can queue in GK each frame."))

(defmethod initialize-instance :after ((gktm gk-tilemap) &key &allow-other-keys)
  (with-slots (tilemap commands) gktm
    (let ((layer-count (length (tilemap-layers tilemap)))
          (tile-count 0))
      (loop for i from 0 below layer-count
            do (map-tilemap-layer (lambda (x)
                                    (when x (incf tile-count)))
                                  tilemap i)))))
