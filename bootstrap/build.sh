#!/bin/bash
set -e

PLATFORM=macosx
SWIFT_BUILD_TOOL=`which swift-build-tool`

if [ -n "$1" ]; then
  PLATFORM=$1
fi

if [ -z "$SWIFT_BUILD_TOOL" ]; then
  echo "The build tool 'swift-build-tool' cannot be found."
  exit 1
fi

mkdir -p .atllbuild/products
mkdir -p .atllbuild/objects

deps/build_pcre.sh
$SWIFT_BUILD_TOOL -f bootstrap/bootstrap-$PLATFORM-atfoundation.swift-build --no-db
deps/merge_pcre.sh

if [ "0" = "$?" ]; then
  rm -rf bin
  mkdir -p bin
  cp .atllbuild/products/atfoundation.* bin/
fi