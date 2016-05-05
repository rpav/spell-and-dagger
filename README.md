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
* Simple monster spawn / hit / death.

Up next:

* UI, player stats.
* Player damage, death.

Needs work:

* Should abstract keybindings at least slightly.
* Sprites handling their own animations
* Better weapon display handling
* Hit/death visual effects.
* Content!

Current screenshots:

<img src="http://ogmo.mephle.net/lgj/interact.gif"><br>
<img src="http://ogmo.mephle.net/lgj/monsters.gif">

## Building

This requires the *absolute latest* of the following:

* cl-autowrap        (https://github.com/rpav/cl-autowrap)
* GameKernel         (https://github.com/rpav/GameKernel)
* cl-gamekernel      (https://github.com/rpav/cl-gamekernel)

Everything else can be quickloaded.

## Running

Load it, then `(game:run)`.
