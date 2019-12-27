#!/bin/bash

set -xe

# source params.sh

DBO=${DOCKER_BUILD_OPTS:---no-cache}

# build RDKit
docker build $DBO -f core.Dockerfile\
  -t $BASE/oss-stx-rdkit-core:$DOCKER_TAG\
  -t $BASE/oss-stx-rdkit-core:latest\
  --build-arg GIT_REPO=$GIT_REPO\
  --build-arg GIT_BRANCH=$GIT_BRANCH\
  --build-arg GIT_TAG=$GIT_TAG .

# copy the packages
rm -rf artifacts/debian/$DOCKER_TAG
mkdir -p artifacts/debian/$DOCKER_TAG
mkdir -p artifacts/debian/$DOCKER_TAG/debs
mkdir -p artifacts/debian/$DOCKER_TAG/java
docker run -it --rm -u $(id -u)\
  -v $PWD/artifacts/debian/$DOCKER_TAG:/tohere:Z\
  $BASE/oss-stx-rdkit-core:$DOCKER_TAG bash -c 'cp build/*.deb /tohere/debs && cp Code/JavaWrappers/gmwrapper/org.RDKit.jar /tohere/java && cp Code/JavaWrappers/gmwrapper/libGraphMolWrap.so /tohere/java'

# build image for python3 on debian
docker build $DBO -f python3.Dockerfile\
  -t $BASE/oss-stx-rdkit-python3:$DOCKER_TAG\
  -t $BASE/oss-stx-rdkit-python3:latest\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image $BASE/oss-stx-rdkit-python3:$DOCKER_TAG"

# build image for postgresql cartridge on debian
docker build $DBO -f cartridge.Dockerfile\
  -t $BASE/oss-stx-rdkit-cartridge:$DOCKER_TAG\
  -t $BASE/oss-stx-rdkit-cartridge:latest\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image $BASE/oss-stx-rdkit-cartridge:$DOCKER_TAG"

docker push $BASE/oss-stx-rdkit-core:$DOCKER_TAG
docker push $BASE/oss-stx-rdkit-core:latest
docker push $BASE/oss-stx-rdkit-python3:$DOCKER_TAG
docker push $BASE/oss-stx-rdkit-python3:latest
docker push $BASE/oss-stx-rdkit-cartridge:$DOCKER_TAG
docker push $BASE/oss-stx-rdkit-cartridge:latest
