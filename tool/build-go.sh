#!/usr/bin/env bash

## Helper vars
CPUS=`getconf _NPROCESSORS_ONLN`

## Reset the build directory
mkdir -p build/go && rm -rf build/go/*

## Ensure docker containers run as host user
USER_ID=$(id -u)
GROUP_ID=$(id -g)

## Generate proto to go files
echo "Running protoc ..."
find ./proto -name '*.proto' -print0 | xargs -0 -I{} -P${CPUS} \
    docker run --user ${USER_ID}:${GROUP_ID} -v ${PWD}:/tmp/workspace -w /tmp/workspace namely/protoc-all:1.23_0 -f {} -o build/go -l go
mv build/go/proto/* build/go/
rm -rf build/go/proto

## Generate mock go files for testing
echo "Running mockgen ..."
find ./build/go -name '*.pb.go' -print0 | xargs -0 -I{} -P${CPUS} ./tool/build-go-mock.sh {}

## Run goimports to cleanup the generated go files
echo "Running goimports ..."
docker run --user ${USER_ID}:${GROUP_ID} -it -v ${PWD}/build/go:/tmp/workspace -w /tmp/workspace unibeautify/goimports -w .
