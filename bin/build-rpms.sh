#!/bin/bash

[ ! -d rpms ] && mkdir rpms

pushd git/openshift-tools
for spec in `find . -name *.spec`; do
    pushd $(dirname $spec)
    tito build --rpm --output ../../../rpms
    popd
done
popd
