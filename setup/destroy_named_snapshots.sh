#!/bin/sh

snapname=$1
shift

if [ -z "$snapname" ] ; then
    echo "Usage: $0 <snapname_to_be_destroyed>"
fi

zfs list -t snapshot -H -o name | grep "@${snapname}" | xargs -n1 zfs destroy
