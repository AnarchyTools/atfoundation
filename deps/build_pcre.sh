#!/bin/bash
if [ ! -e "bin/pcre/include/pcre.h" ] ; then
    rm -rf bin/pcre
    mkdir -p bin/pcre
    pushd bin/pcre
    ../../deps/pcre-8.38/configure --prefix=/ --enable-utf8 --enable-static=pcre --disable-shared --disable-cpp --enable-unicode-properties
    # --enable-jit
    popd
fi

pushd bin/pcre
make
make install DESTDIR=$(pwd)
popd

if [ ! -e ".atllbuild/products/pcre.a" ] ; then
    mkdir -p .atllbuild/products
    ln -s ../../bin/pcre/lib/libpcre.a .atllbuild/products/pcre.a
fi
