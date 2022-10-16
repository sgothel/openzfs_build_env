#!/bin/sh

mkdir -p build

cd zfs
# select branch/tag ..
./autogen.sh
# ./configure --with-config=srpm
./configure --enable-systemd
# make pkg-utils deb-dkms
make -j$(nproc)
make -j1 deb-utils deb-dkms
mv *.tar.gz *.deb ../build
make clean
rm -f *.rpm
cd ..


