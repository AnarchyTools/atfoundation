#!/bin/bash

# configure pcre
if [ ! -e "bin/pcre/include/pcre.h" ] ; then
    rm -rf bin/pcre
    mkdir -p bin/pcre
    pushd bin/pcre
    ../../deps/pcre-8.38/configure --prefix=/ --enable-utf8 --enable-static=pcre --disable-shared --disable-cpp --enable-unicode-properties
    # --enable-jit
    popd
fi

# compile pcre
pushd bin/pcre
make
make install DESTDIR=$(pwd)
popd

# create a module map if not there
if [ ! -e ".atllbuild/include/module.modulemap" ] ; then
    mkdir -p ".atllbuild/include"
    cat >.atllbuild/include/module.modulemap <<EOF
        module atfoundation {
            umbrella header "Umbrella.h"
        }
EOF
    echo "#include <pcre.h>" >.atllbuild/include/Umbrella.h
fi


# link pcre.a to products dir
if [ ! -e ".atllbuild/products/pcre.a" ] ; then
    mkdir -p .atllbuild/products
    ln -s ../../bin/pcre/lib/libpcre.a .atllbuild/products/pcre.a
fi
