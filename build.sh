#!/bin/sh
CUR_DIR=$PWD
mkdir ../yunit_build
cd ../yunit_build
cmake $CUR_DIR && make cppunit cppunit.t && make test ARGS=--output-on-failure && make package package_source
cd $CUR_DIR

