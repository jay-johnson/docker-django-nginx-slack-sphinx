#!/bin/bash

source ./properties.sh .

echo "Cleaning up Docker image($maintainer/$imagename)"
docker stop $imagename >> /dev/null
docker rm $imagename >> /dev/null
docker rmi $imagename >> /dev/null

exit 0
