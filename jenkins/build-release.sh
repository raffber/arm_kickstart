#!/bin/bash

set -euxfo pipefail

curdir=$(dirname "$0")
cd "$curdir/.."

mkdir -p build

build_and_collect() {
    bd="$1"
    shift
    rm -rf build/"$bd" && mkdir -p build/"$bd"
    cmake -S . -B build/"$bd" -DCMAKE_BUILD_TYPE=Release $@
    cmake --build build/"$bd" -j 20
    cp CHANGELOG.md build/"$bd"
    cd build/"$bd"
    find . -maxdepth 1 -name "*.gctbtl" -or -name "app" -or -name "btl" -or -name "*.hex" -or -name "info.json" -or -name "CHANGELOG.md" > archive.txt
    cat archive.txt | zip -@ "$bd"
    cp "$bd.zip" ..
    cd ../..
}

# cleanup all build archives
find build -maxdepth 1 -name "*.zip" | while read line; do
  rm "$line"
done

build_and_collect release
