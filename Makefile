SOURCE_FILES := ./lib/patched_raylib.f90 ./lib/emscripten.f90 ./lib/shim_raylib50.c ./src/camera3d.f90
LIB_FILES := ./dep/raylib-5.0_webassembly/lib/libraylib.a /app/lib/libgfortran.a
OBJ_FILES = $(patsubst %.f90, %.o, $(patsubst %.c, %.o, $(SOURCE_FILES)))

CC=emcc
FC=emfc.sh

CCFLAGS=-I./dep/raylib-5.0_webassembly/include/ -s USE_GLFW=3 --shell-file ./src/shell_minimal.html
FCFLAGS=-fno-range-check -ffree-line-length-none
WLDFLAGS=-s WASM=1

OUTDIR=./build

index.html: $(OBJ_FILES)
	mkdir -p $(OUTDIR)
	$(CC) -o $(OUTDIR)/$@ $^ $(WLDFLAGS) $(CCFLAGS) $(LIB_FILES)

%.o: %.c
	$(CC) -c -o $@ $< $(CCFLAGS)

%.o: %.f90
	$(FC) $(FCFLAGS) -o $@ -c $<

clean:
	rm *.o ./lib/*.o ./src/*.o *.mod
