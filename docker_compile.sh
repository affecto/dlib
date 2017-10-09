#!/bin/bash
# Default build arguments
if [ -z "$TGTPLAT" ]
then
  TGTPLAT=1604
fi
if [ -z "$CUDA_VERSION" ]
then
  CUDA_VERSION=9.0
fi
if [ -z "$CUDNN_VERSION" ]
then
  CUDNN_VERSION=7
fi

# Image tag and container name
IMGTAG=dlib_$TGTPLAT:cuda$CUDA_VERSION-dnn$CUDNN_VERSION
CONTNAME=dlib_$TGTPLAT-cuda$CUDA_VERSION-dnn$CUDNN_VERSION

# Check that we can access docker
docker ps >/dev/null 2>&1
if [ "$?" != "0" ]
then
  echo "Can't access docker, maybe try 'sudo adduser `whoami` docker'"
  echo "You may need to logout and log in again for that to take effect"
  exit 1
fi

# Check if image is already built
docker inspect --type=image $IMGTAG >/dev/null 2>&1
if [ "$?" != "0" ]
then
  echo "No image found, building, this will take a while."
  set -ex
  docker build -t $IMGTAG -f Dockerfile_$TGTPLAT --build-arg CUDA_VERSION="$CUDA_VERSION" --build-arg CUDNN_VERSION="$CUDNN_VERSION" .
  set +x
fi
set -e
if [ "$(docker ps -a -f "name=$CONTNAME" --format '{{.Names}}')" != "$CONTNAME" ]
then
  echo "First run, map volumes"
	set -x
	docker run --name $CONTNAME -it -v `pwd -P`:/opt/compile/dlib $IMGTAG
  set +x
else
  set -x
  echo "Nth run, just do it"
	docker start -i $CONTNAME
  set +x
fi
