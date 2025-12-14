#!/bin/sh

sdir=`dirname $(readlink -f $0)`
rootdir=`dirname $sdir`
bname=`basename $0 .sh`

if [ ! -d zfs ] ; then
    echo "Populate zfs subdir from openzfs git repo, see README.md"
    exit 1
fi

do_build()
{
    rm -rf build
    mkdir -p build

    cd zfs
    git clean -d -f -x
    # select branch/tag ..
    echo
    echo "MAKE ZFS: autogen"
    echo
    ./autogen.sh
    if [ $? -ne 0 ] ; then
        echo "MAKE ZFS: Error autogen"
        return 1
    fi

    echo
    echo "MAKE ZFS: configure"
    echo
    #DEBUG_OPTS="--enable-debug --enable-debuginfo --enable-debug-kmem --enable-debug-kmem-tracking"
    DEBUG_OPTS="--disable-debug --disable-debuginfo --disable-debug-kmem --disable-debug-kmem-tracking"
    ./configure --enable-systemd ${DEBUG_OPTS}
    if [ $? -ne 0 ] ; then
        echo "MAKE ZFS: Error configure"
        return 1
    fi

    echo
    echo "MAKE ZFS: build"
    echo
    make -j$(nproc)
    if [ $? -ne 0 ] ; then
        echo "MAKE ZFS: Error build"
        return 1
    fi

    echo
    echo "MAKE ZFS: build debian packages"
    echo
    # rm -f contrib/bash_completion.d/zpool
    # make -j1 native-deb
    #
    make -j1 deb
    if [ $? -ne 0 ] ; then
        echo "MAKE ZFS: Error deb"
        return 1
    fi

    echo
    echo "MAKE ZFS: move packages"
    echo
    mv *.tar.gz *.deb ../build
    echo
    echo "MAKE ZFS: clean"
    echo
    make clean

    echo
    echo "MAKE ZFS: done"
    echo
    cd ..
    mv *.tar.gz *.deb openzfs*.buildinfo openzfs*.changes ./build
}

echo "Logging to $bname.log"
do_build 2>&1 | tee $bname.log


