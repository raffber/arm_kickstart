#!/bin/bash

set -euxfo pipefail

curdir=$(dirname "$0")
cd "$curdir/.."

build/test/app --gtest_output=xml:build/app-test.xml

cmake --build build/test --target app-coverage
