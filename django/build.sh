#!/bin/bash

source ./properties.sh .

echo "Building new Docker image($registry/$maintainer/$imagename)"
docker build --rm -t $maintainer/$imagename --build-arg registry=$registry --build-arg maintainer=$maintainer --build-arg imagename=$imagename .

exit 0
