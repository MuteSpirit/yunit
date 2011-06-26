clear && cmake ../yunit && make -j 2 && make -j 2 package && dpkg-deb -I yUnit-0.3.8-Linux.deb && dpkg-deb -c yUnit-0.3.8-Linux.deb
