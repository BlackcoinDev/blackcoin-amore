#!/bin/bash

BASE_DIR=$(dirname $(realpath $0 ))
moreBuilder=${BASE_DIR}/moreBuilder
rm -fr ${moreBuilder}/*

export SYSTYPE=x86_64
export DockerHub=blackcoindev  
export HUBLAB=github
export GITNAME=blackcoindev
export BRANCH=latest
sed -i "s|BRANCH=latest|BRANCH=${BRANCH}|" ${BASE_DIR}/Dockerfile.ubase
sed -i "s|BRANCH=latest|BRANCH=${BRANCH}|" ${BASE_DIR}/Dockerfile.ubuntu
export TZ=Etc/UTC

echo "${GITHUB_ENV} = GITHUB_ENV"
echo "DockerHub Account: ${DockerHub}"
echo "Git Account: ${GITNAME}"
echo ${BRANCH}
echo ${SYSTYPE}
echo ${TZ}

# tag names
base="${DockerHub}/blackcoin-amore-base-${SYSTYPE}:${BRANCH}"
minimal="${DockerHub}/blackcoin-amore-minimal-${SYSTYPE}:${BRANCH}"
ubuntu="${DockerHub}/blackcoin-amore-ubuntu-${SYSTYPE}:${BRANCH}"

# build
# ubase (base using ubuntu)
# ubuntu (package with full ubuntu distro)
docker build -t ${base} - --network=host < ${BASE_DIR}/Dockerfile.ubase
docker build -t ${ubuntu} - --network=host < ${BASE_DIR}/Dockerfile.ubuntu
docker image push ${ubuntu}

# minimal (only package binaries and scripts)
docker run -itd  --network=host --name base ${base} bash
docker cp base:/parts ${moreBuilder}
cd ${moreBuilder}
tar -c . | docker import - ${minimal} &&  docker image push ${minimal}
