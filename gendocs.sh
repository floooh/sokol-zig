#!/bin/bash
set -e
zig build-lib src/sokol/sokol.zig -femit-docs -fno-emit-bin
cd docs
mkdir sources && tar -xf sources.tar -C sources
cd sources && tar -cf sources.tar sokol
cd .. && mv sources/sources.tar . && rm -rf sources
