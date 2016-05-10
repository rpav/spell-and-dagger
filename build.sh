#!/bin/sh

sbcl \
    --no-userinit \
    --load build.lisp \
    --name spell-and-dagger \
    --startup "game:run" \
    --non-interactive
