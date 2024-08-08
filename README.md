# raylib-fortran-wasm
Toolchain & template repository for projects developed in Fortran with Raylib targetting the web.

## References that helped me put this together
* https://github.com/interkosmos/fortran-raylib
* https://github.com/StarGate01/Full-Stack-Fortran
* https://github.com/michaelfiber/hello-raylib-wasm

## Getting Started

### Dependencies

The aforementioned `StarGate01/Full-Stack-Fortran` repository has a really nice Docker container containing all of the required dependencies, which I would highly recommend you use!  `./dbuild.sh` pulls that container to run the Makefile.

Otherwise, the version numbers for these dependencies are very important.  As explained at https://dragonegg.llvm.org/, only GCC 4.6 was fully supported as of the last version released before LLVM marked DragonEgg as obsolete.  As far as emscripten goes, https://github.com/StarGate01/Full-Stack-Fortran/issues/10 explains the incompatibility of LLVM 3.3 IR with versions of Emscripten past 3.1.3.

* DragonEgg LLVM 3.3
* Emscripten 3.1.3
* GFortran 4.6.4

For running my shim script, `Node.js` will have to be installed as well. The version of node I have didn't support `.matchAll`, so I added a polyfill for it.

### How It Works

#### Patching Interkosmos's Bindings

Run: `./init.sh`

Fetches both Raylib 5.0 WASM distribution zip as well as the latest source tree from interkosmos/fortran-raylib.

Interkosmos's bindings nearly work, but we need to patch them to compile with this ancient GCC 4.6 + DragonEgg setup.  It might be a compiler flag somewhere that would fix this more easily (It feels like some sort of premature/incorrect optimization happening), but I couldn't figure it out - so let's patch and shim the bindings!

Things that we can shim:
* GFortran 4.6 inserts an int as argument on functions that take no arguments
* GFortran 4.6 splits Vector3 as argument into three floats as arguments
* GFortran 4.6 can't understand `implicit none (type, external)`

How we fix this:
* Scan header file for `Vector3` and `(void)`
* For all instances of those, prepend the c bind names in Interkosmos's bindings with something (We'll use `shim_`).
* Create a `shim.c` file which implements the incorrect function signature (as `shim_%`) and remaps it to the correct signature.
* Cut out the `(type, external` part from the implicit none lines.

#### Building Your App

Edit the Makefile, then run `./dbuild.sh`.

One important thing to note is that wasm raylib builds are expected to use `emscripten_set_main_loop` rather than a while loop in main.
