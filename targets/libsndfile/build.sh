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

cd "$TARGET/repo"
./autogen.sh
emconfigure ./configure --disable-shared --enable-ossfuzzers
emmake make -j$(nproc) clean
emmake make -j$(nproc) ossfuzz/sndfile_fuzzer

cp -v src/.libs/libsndfile.a $OUT/
emcc -o $OUT/sndfile_fuzzer.html ./ossfuzz/sndfile_fuzzer-sndfile_fuzzer.o \
		./ossfuzz/.libs/libstandaloneengine.a ./src/.libs/libcommon.a ./src/.libs/libsndfile.a \
		$TARGET/../../common/main.cpp -D__WASM__

