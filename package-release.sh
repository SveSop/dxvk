#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: package-release.sh version destdir [--no-winelib || --no-dll] [--no-package]"
  exit 1
fi

DXVK_VERSION="$1"
DXVK_SRC_DIR=`dirname $(readlink -f $0)`
DXVK_BUILD_DIR=$(realpath "$2")"/dxvk-$DXVK_VERSION"
DXVK_ARCHIVE_PATH=$(realpath "$2")"/dxvk-$DXVK_VERSION.tar.gz"

if [ -e "$DXVK_BUILD_DIR" ]; then
  echo "Build directory $DXVK_BUILD_DIR already exists"
  exit 1
fi

function build_winelib {
  export WINEARCH="win$1"
  export WINEPREFIX="$DXVK_BUILD_DIR/wine.$1"
  
  cd "$DXVK_SRC_DIR"

  meson --cross-file "$DXVK_SRC_DIR/build-wine$1.txt"  \
        --buildtype "release"                         \
        --prefix "$DXVK_BUILD_DIR"	              \
        -Dlib_dir="x$1"			      \
	--strip                                       \
        -Denable_tests=false                          \
        "$DXVK_BUILD_DIR/build.$1"

  cd "$DXVK_BUILD_DIR/build.$1"
  ninja install

  rm -R "$DXVK_BUILD_DIR/build.$1"
}

function build_arch {
  export WINEARCH="win$1"
  export WINEPREFIX="$DXVK_BUILD_DIR/wine.$1"
  
  cd "$DXVK_SRC_DIR"

  meson --cross-file "$DXVK_SRC_DIR/build-win$1.txt"  \
        --buildtype "release"                         \
        --prefix "$DXVK_BUILD_DIR"	              \
        -Dlib_dir="x$1"			      \
	--strip                                       \
        -Denable_tests=false                          \
        "$DXVK_BUILD_DIR/build.$1"

  cd "$DXVK_BUILD_DIR/build.$1"
  ninja install

  rm -R "$DXVK_BUILD_DIR/build.$1"
  cd "$DXVK_BUILD_DIR/x$1" && rm *.a
}

function build_verb {
  cp "$DXVK_SRC_DIR/utils/setup_dxvk.verb" "$DXVK_BUILD_DIR/setup_dxvk.verb"
}

function package {
  cd "$DXVK_BUILD_DIR/.."
  tar -czf "$DXVK_ARCHIVE_PATH" "dxvk-$DXVK_VERSION"
  rm -R "dxvk-$DXVK_VERSION"
}

if [ "$3" != "--no-dll" ]; then
  build_arch 64
  build_arch 32
fi

if [ "$3" != "--no-winelib" ]; then
  build_winelib 64
  build_winelib 32
fi

build_verb

if [ "$3" != "--no-package" ] && [ "$4" != "--no-package" ]; then
  package
fi
