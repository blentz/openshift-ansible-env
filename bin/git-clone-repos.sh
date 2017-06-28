#!/bin/bash

function clone () {
    git clone git@github.com:openshift/${1}.git git/${1}
    pushd git/${1}
    ../../bin/git-create-branches.sh
    popd
}

[ ! -d git ] && mkdir git

clone ops-sop
clone openshift-ansible
clone openshift-ansible-ops
clone openshift-tools
