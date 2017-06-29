#!/bin/bash

if [ ! -z $1 ]; then
    GIT_BRANCH=$1
else
    GIT_BRANCH='prod'
fi

[ ! -d roles ] && mkdir roles

pushd ./git
for repo in `ls -1 .`; do
    if [ -d ${repo} ]; then
        pushd ${repo}
        git checkout $GIT_BRANCh

        ROLEDIRS="roles ops_roles tools_roles private_roles"

        for roledir in $ROLEDIRS; do
            if [ -d ${roledir} ]; then
                pushd ${roledir}
                for role_dir in `ls -1 .`; do
                    # no periods in role names. that's special syntax
                    role=`echo ${role_dir} | tr -d '.'`

                    # if someone didn't use "ansible-galaxy init", fill in the
                    # gaps for them...
                    if [ ! -d ${role_dir}/meta ]; then
                        mkdir ${role_dir}/meta
                    fi
                    if [ ! -f ${role_dir}/meta/main.yml ]; then
                        cat > ${role_dir}/meta/main.yml <<EOF
---
galaxy_info:
  author: OpenShift
  description: ${role}
  company: Red Hat, Inc.
  license: Apache Software License 2.0
  min_ansible_version: 2.0
  galaxy_tags: []
dependencies: []
EOF
                    fi

                    tar czpf ../../../roles/${role}.tar.gz ${role_dir}
                    echo "- src: ./roles/${role}.tar.gz" >> ../../../roles.yml
                    echo "  name: ${role}" >> ../../../roles.yml
                    echo "" >> ../../../roles.yml
                done
                popd
            fi
        done
        popd
    fi
done
popd

# using the --ignore-errors to skip over various issues.
ansible-galaxy install --ignore-errors -p /usr/share/ansible/roles -r roles.yml

# clean up after ourselves
rm -rf ./roles roles.yml
