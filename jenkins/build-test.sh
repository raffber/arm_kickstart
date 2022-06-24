#!/bin/bash

set -euxfo pipefail

curdir=$(dirname "$0")
cd "$curdir/.."


rm -rf build/test
cmake -S . -B build/test -DCMAKE_BUILD_TYPE=Debug -DTARGET=test
cmake --build build/test -j 20

