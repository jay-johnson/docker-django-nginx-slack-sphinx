#!/bin/bash

echo ""

pushd django >> /dev/null
echo "Building the Django Container"
./build.sh
echo "Done Building the Django Container"
popd >> /dev/null

echo ""

pushd nginx >> /dev/null
echo "Building the nginx Container"
./build.sh
echo "Done Building the nginx Container"
popd >> /dev/null

exit 0
