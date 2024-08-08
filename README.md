# transportation-game
I don't really have a concept for this game yet, but it'll involve trains and it'll be written in Fortran.

## Dependencies
See my reneeverly/raylib-fortran-wasm repository for details on how this Fortran-to-Wasm pipeline works.  It involves an ancient GCC version and an abandoned LLVM module.

For building/running the game, all you need to know is:

```
./init.sh # download and patch libraries to work with ancient GCC version
./dbuild.sh # build using a docker container with correct versions of things
./server # use the python http.server module to locally host on port 8000
```
