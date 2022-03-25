#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

# build the libpng library
cd "$TARGET/repo"
autoreconf -f -i
emconfigure ./configure --with-libpng-prefix=MAGMA_ --disable-shared CFLAGS="-s USE_ZLIB=1 -g"
emmake make -j$(nproc) clean
emmake make -j$(nproc) libpng16.la

cp .libs/libpng16.a "$OUT/"

# use emcc to build fuzzer
emcc -s USE_ZLIB=1 -g -std=c++11 -I. \
     contrib/oss-fuzz/libpng_read_fuzzer.cc \
     -o $OUT/libpng_read_fuzzer.html \
     .libs/libpng16.a -lz \
	 $TARGET/../../common/main.cpp -D__WASM__
