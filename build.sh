clear && cmake ../yunit && make -j 2 && make -j 2 package && make test ARGS=--output-on-failure
