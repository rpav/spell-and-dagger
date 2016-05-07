# Lisp Game Jam 2016 Q2 entry

Current status:

* Basics: Structure, animations, render loop, "physics"/collision
* Tilemaps load and render from Tiled (http://www.mapeditor.org/) .json files
* Interactions: simple textboxes.
* Simple monster spawn / hit / death, now with effects.
* Player damage, hit effects, powerups, death
* Demo spell with cast animations

Up next:

* Map-state effects, spell interactions
* Death/continue/save
* Official name, title screen
* UI as necessary

Needs work:

* Should abstract keybindings at least slightly.
* Sprites handling their own animations
* Better weapon display handling
* Content!

Current screenshots:

<img src="http://ogmo.mephle.net/lgj/interact.gif"><br>
<img src="http://ogmo.mephle.net/lgj/mob-with-fx.gif"><br>
<img src="http://ogmo.mephle.net/lgj/powerups.gif">

## Building

This requires the *absolute latest* of the following:

* cl-autowrap        (https://github.com/rpav/cl-autowrap)
* GameKernel         (https://github.com/rpav/GameKernel)
* cl-gamekernel      (https://github.com/rpav/cl-gamekernel)

Everything else can be quickloaded.

## Running

Load it, then `(game:run)`.
