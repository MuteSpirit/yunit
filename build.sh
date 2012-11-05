#!/bin/sh
CUR_DIR=$PWD
BUILD_DIR=../yunit_build

if [ ! -d $BUILD_DIR ]; then
    mkdir $BUILD_DIR;
fi

cd $BUILD_DIR
cmake $CUR_DIR && make yunit test ARGS=--output-on-failure
cd $CUR_DIR

