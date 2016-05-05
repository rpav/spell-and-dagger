# Lisp Game Jam 2016 Q2 entry

Current status:

* A fair bit of internal structure
* Animations
* Test entity with sprite, walking around and swinging arm on input
* Tilemaps load and render from Tiled (http://www.mapeditor.org/) .json files
* Renders weapon
* Collision and callbacks
* Phases and map transitions, though map/char will probably remain global
* Map transitions
* Interactions: simple textboxes.

Up next:

* Monsters, more interactions, actual gameplay, UI.

Needs work:

* Should abstract keybindings at least slightly.

Current screenshot:

<img src="http://ogmo.mephle.net/lgj/current-20160505-1009.png">

## Building

This requires the *absolute latest* of the following:

* cl-autowrap        (https://github.com/rpav/cl-autowrap)
* GameKernel         (https://github.com/rpav/GameKernel)
* cl-gamekernel      (https://github.com/rpav/cl-gamekernel)

Everything else can be quickloaded.

## Running

Load it, then `(game:run)`.
