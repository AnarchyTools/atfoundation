#!/bin/bash

pushd .atllbuild/products

rm atfoundation_unmerged.a
mv atfoundation.a atfoundation_unmerged.a

UNAME=`uname`
if [ "$UNAME" == "Darwin" ] ; then
    # osx
    libtool -static -o atfoundation.a  atfoundation_unmerged.a pcre.a
else
    # linux
    libtool --mode=link cc -static -o atfoundation.a atfoundation_unmerged.a pcre.a
fi

popd