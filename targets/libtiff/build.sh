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

WORK="$TARGET/work"
rm -rf "$WORK"
mkdir -p "$WORK"
mkdir -p "$WORK/lib" "$WORK/include"

cd "$TARGET/repo"
./autogen.sh
emconfigure ./configure --disable-shared --prefix="$WORK"
emmake make -j$(nproc) clean
emmake make -j$(nproc)
emmake make install

cp "$TARGET/repo/tools/tiffcp.wasm" "$OUT/"
emcc -g -std=c++11 -I$WORK/include \
    contrib/oss-fuzz/tiff_read_rgba_fuzzer.cc -o $OUT/tiff_read_rgba_fuzzer.html \
    $WORK/lib/libtiffxx.a $WORK/lib/libtiff.a -lz \
    $LDFLAGS $LIBS
