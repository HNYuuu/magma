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
emconfigure ./autogen.sh \
	--with-http=no \
	--with-python=no \
	--with-lzma=yes \
	--with-threads=no \
	--disable-shared
emmake make -j$(nproc) clean
emmake make -j$(nproc) all

cp .libs/libxml2.a "$OUT/"

for fuzzer in libxml2_xml_read_memory_fuzzer libxml2_xml_reader_for_file_fuzzer; do
  emcc -g -std=c++11 -Iinclude/ -I"$TARGET/src/" \
      "$TARGET/src/$fuzzer.cc" -o "$OUT/$fuzzer.html" \
      .libs/libxml2.a $LDFLAGS $LIBS -lz \
	  "$TARGET/../../common/main.cpp" -D__WASM__
done
