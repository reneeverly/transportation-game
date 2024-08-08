#!/bin/bash

# Create directory to dump all of the dependencies into
mkdir dep

# fetch Raylib 5.0 WASM
curl -L -o ./dep/raylib.zip https://github.com/raysan5/raylib/releases/download/5.0/raylib-5.0_webassembly.zip
unzip ./dep/raylib.zip -d ./dep
rm ./dep/raylib.zip

# fetch interkosmos bindings
curl -L -o ./dep/interkosmos.zip https://github.com/interkosmos/fortran-raylib/archive/refs/heads/master.zip
unzip ./dep/interkosmos.zip -d ./dep
rm ./dep/interkosmos.zip

# Generate the C shim
node ./lib/patch_prototype.js
# Produces:
# shim_raylib50.c
# shim_raylib50_affect.txt

# Patch interkosmos to to use the shim
INTERKOSMOS=$(cat ./dep/fortran-raylib-master/src/raylib.f90)
while read f; do
   INTERKOSMOS=`sed "s/[\"|']$f[\"|']/'shim_$f'/g" <<< "$INTERKOSMOS"`
done < "./lib/shim_raylib50_affect.txt"

# fix implicit none (type, external)
INTERKOSMOS=`sed 's/implicit none (type, external)/implicit none/g' <<< "$INTERKOSMOS"`

# Write out the patched bindings
echo "! Patched at `date` by reneeverly/raylib-fortran-wasm/init.sh" > ./lib/patched_raylib.f90
echo "$INTERKOSMOS" >> ./lib/patched_raylib.f90
