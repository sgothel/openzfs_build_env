#!/bin/bash

export MYSWAPSIZE=33G
# export MYSWAPSIZE=1G

export POOL=tpool2

if [ ! -z "$MYSWAPSIZE" ]; then
    # SWAP
    zfs create -V ${MYSWAPSIZE} \
          -o volblocksize=16384 \
          -o compression=off \
          -o dedup=off \
          -o logbias=throughput -o sync=always \
          -o primarycache=metadata -o secondarycache=none \
          -o com.sun:auto-snapshot=false $POOL/swap

    zfs set checksum=off $POOL/swap

    mkswap -f /dev/zvol/$POOL/swap
    echo /dev/zvol/$POOL/swap none swap defaults 0 0 >> /etc/fstab
    # UUID=ee57ce05-7287-4b37-93c4-03aeaba756f1
    # /etc/fstab
    # /dev/zvol/$POOL/swap   none  		   swap    defaults  0  0
    # 
    # swapon /dev/zvol/$POOL/swap
    #
    echo "Swap: /etc/fstab modified"
    echo "Swap: Enable: swapon /dev/zvol/$POOL/swap"
fi

