#!/bin/bash

RPMNAME="tito"
if [ "$(rpm -q ${RPMNAME})" == "package ${RPMNAME} is not installed" ]; then
    echo "**** ${RPMNAME} is required to build RPMs. Please install it. ****"
    exit 1
fi

[ ! -d rpms ] && mkdir rpms

pushd git/openshift-tools
for spec in `find . -name *.spec`; do
    pushd $(dirname $spec)
    tito build --rpm --output ../../../rpms
    popd
done
popd
