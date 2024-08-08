#!/bin/bash

# Let's use StarGate01's dockerized environment to build our project
docker run --rm -v `pwd`:/project stargate01/f90wasm bash -c 'cd /project && make'
