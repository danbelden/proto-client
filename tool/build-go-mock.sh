#!/usr/bin/env bash

## Terminate if an error is encountered
set -e

## If no path is given as arg 1 error
if [[ -z $1 || ! -f $1 ]]; then
  echo "[Error] First argument should be a path to a go file"
  exit 1
fi

## Import the helper methods
SCRIPT_DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd`
source "${SCRIPT_DIR}/helpers.sh"

## Generic vars
ROOT_DIR=`dirname ${SCRIPT_DIR}`
ROOT_DIR_FULL=`realpath ${ROOT_DIR}`

# If the given path is outside of the root throw an error
GO_FILE_PATH=$1
GO_FILE_PATH_FULL=`realpath ${GO_FILE_PATH}`
if [[ ! ${GO_FILE_PATH_FULL} == ${ROOT_DIR_FULL}* ]]; then
  echo "[Error] First argument should be a path in the project root"
  exit 1
fi

# Mock vars
GO_PACKAGE=`grep "^package " ${GO_FILE_PATH_FULL} | head -1 | cut -d' ' -f2`
GO_FILE_DIR=`dirname ${GO_FILE_PATH_FULL}`
GO_FILE_NAME=`basename ${GO_FILE_PATH_FULL}`
GO_MOCK_FILE_PATH="${GO_FILE_DIR}/mock_${GO_FILE_NAME}"

# Convert vars to relative relative for docker use
GO_FILE_PATH_REL=".${GO_FILE_PATH_FULL#"${ROOT_DIR_FULL}"}"
GO_MOCK_FILE_REL=".${GO_MOCK_FILE_PATH#"${ROOT_DIR_FULL}"}"

## Ensure docker containers run as host user
USER_ID=$(id -u)
GROUP_ID=$(id -g)

## Generate the mock file with docker
docker run --user ${USER_ID}:${GROUP_ID} -v ${ROOT_DIR}:/tmp/workspace -w /tmp/workspace jare/go-tools mockgen \
  -source=${GO_FILE_PATH_REL} \
  -package=${GO_PACKAGE} \
  -destination=${GO_MOCK_FILE_REL}
