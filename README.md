# Spell & Dagger: Lisp Game Jam 2016 Q2 entry

<img src="http://ogmo.mephle.net/lgj/final.gif">

## Requirements

* SBCL (others might work, untested)
* SDL2
* GL 3.3

## Building

This requires the *absolute latest* of the following:

* cl-autowrap        (https://github.com/rpav/cl-autowrap)
* GameKernel         (https://github.com/rpav/GameKernel)
* cl-gamekernel      (https://github.com/rpav/cl-gamekernel)

Everything else can be quickloaded.

Build instructions for GameKernel are on its page; it requires CMake
and GLEW.

## Running

Make sure `spell-and-dagger.asd` is somewhere ASDF can find it, e.g.,
if you have QuickLisp set up, clone/untar the project in
`~/quicklisp/local-projects/`.  If you don't have QuickLisp set up,
[go do so](https://www.quicklisp.org/beta/).

Start your lisp, then run:

```lisp
(asdf:load-system :spell-and-dagger)
(game:run)
```

## Status

What got done:

* Basics: Structure, animations, render loop, "physics"/collision
* Tilemaps load and render from Tiled (http://www.mapeditor.org/) .json files
* Interactions: simple textboxes.
* Simple monster spawn / hit / death, now with effects.
* Player damage, hit effects, powerups, death
* Simple break spell, breakable objects
* "Demo content" .. i.e., there is a beginning, a few screens, and an
  ending.

Needs work:

* Should abstract keybindings at least slightly.
* Sprites handling their own animations
* Better weapon display handling

Current screenshots:
