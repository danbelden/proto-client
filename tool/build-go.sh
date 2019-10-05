#!/usr/bin/env bash

## Helper vars
CPUS=`getconf _NPROCESSORS_ONLN`

## Reset the build directory
mkdir -p build/go && rm -rf build/go/*

## Generate proto to go files
echo "Running protoc ..."
find ./proto -name '*.proto' -print0 | xargs -0 -I{} -P${CPUS} \
    docker run -v $(PWD):/work -w /work namely/protoc-all:1.23_0 -f {} -o build/go -l go
mv build/go/proto/* build/go/
rm -rf build/go/proto

## Generate mock go files for testing
echo "Running mockgen ..."
find ./build/go -name '*.pb.go' -print0 | xargs -0 -I{} -P${CPUS} ./tool/build-go-mock.sh {}

## Run goimports to cleanup the generated go files
echo "Running goimports ..."
docker run -it -v $(PWD)/build/go:/work -w /work unibeautify/goimports -w .
