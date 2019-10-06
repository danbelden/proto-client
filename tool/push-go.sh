#!/usr/bin/env bash

## Terminate if an error is encountered
set -e

## Config vars
LAST_MODIFIED_TEST_FILE="echo/v1.pb.go"
BUILD_TIMETAMP_AGE_THRESHOLD=300
GIT_WORKSPACE="/tmp/workspace-git"

## Import the helper methods
SCRIPT_DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd`
source "${SCRIPT_DIR}/helpers.sh"

## Helper vars
ROOT_DIR=`dirname ${SCRIPT_DIR}`
ROOT_DIR_FULL=`realpath ${ROOT_DIR}`
PROTO_CLIENT_GIT_BRANCH=`git branch | grep \* | cut -d ' ' -f2`
BUILD_DIR_FULL="${ROOT_DIR}/build/go"

## If the test file is not modified recently throw an error
LAST_MODIFIED_TEST_FILE_PATH="${BUILD_DIR_FULL}/${LAST_MODIFIED_TEST_FILE}"
LAST_MODIFIED_TIMESTAMP=`stat -f "%B" "${LAST_MODIFIED_TEST_FILE_PATH}"`
CURRENT_TIMESTAMP=`date +%s`
TIMESTAMP_DIFF=$((${CURRENT_TIMESTAMP}-${LAST_MODIFIED_TIMESTAMP}))
if [[ ${TIMESTAMP_DIFF} -gt ${BUILD_TIMETAMP_AGE_THRESHOLD} ]]; then
  echo "[Error] Go build files are too old for push"
  exit 1
fi

## Switch to the git workplace, clone the platform-client-go repo and navigate into it
BACKUP_PWD=${PWD}
mkdir -p ${GIT_WORKSPACE}
cd ${GIT_WORKSPACE}
if [[ ! -d "proto-client-go" ]]; then
  echo "[Debug] Cloning git@github.com:danbelden/proto-client-go.git"
  git clone git@github.com:danbelden/proto-client-go.git
fi
cd proto-client-go

## Reset the active branch cleanly to master
git reset --hard HEAD > /dev/null 2>&1
git checkout master > /dev/null 2>&1
git reset --hard HEAD  > /dev/null 2>&1
git pull > /dev/null 2>&1

## Create a matching proto-client-go branch if it doesn't exist as a remote
if [[ ! `git branch --list ${PROTO_CLIENT_GIT_BRANCH}` ]]; then
  git branch ${PROTO_CLIENT_GIT_BRANCH} > /dev/null 2>&1
  echo "[Debug] Created branch ${PROTO_CLIENT_GIT_BRANCH}."
fi

## Switch to the relevant branch ahead of pushing files
git checkout ${PROTO_CLIENT_GIT_BRANCH} > /dev/null 2>&1
echo "[Debug] Checked out branch ${PROTO_CLIENT_GIT_BRANCH}."

## Reset the branch back to master status
git reset --hard origin/master > /dev/null 2>&1
echo "[Debug] Hard reset branch ${PROTO_CLIENT_GIT_BRANCH}."

## Copy the go build files into the `src` folder of the repo
mkdir -p src/
rm -rf src/*
cp -pr ${BUILD_DIR_FULL}/* src/
echo "[Debug] Copied build files to src directory"

## Check there are modified files or exit gracefully
git add .
GIT_MODIFIED_FILES=`git status -s | cut -d' ' -f3`
if [[ -z ${GIT_MODIFIED_FILES} ]]; then
  cd ${BACKUP_PWD}
  echo "[Debug] No modified files to commit commit"
  exit 0
fi

## Determine only files starting with `src/` are modified
INVALID_MODIFIED_FILES=false
for GIT_FILE_PATH in ${GIT_MODIFIED_FILES}; do
  echo "[Debug] Checking modified file ${GIT_FILE_PATH}"
  if [[ ! ${GIT_FILE_PATH} == "src/"* ]]; then
    INVALID_MODIFIED_FILES=true
    break
  fi
done

## Throw an error if any changes are not for the `src` folder
if [[ ${INVALID_MODIFIED_FILES} == true ]]; then
  cd ${BACKUP_PWD}
  echo "[Error] More than src folder is modified"
  exit 1
fi

## Switch the git context to a bot user
git config user.name bot_username
git config user.email bot_email

## Commit and push the changes to the remote repo
git commit -m "[Bot] Auto committed code changes" > /dev/null 2>&1
git push -f -u origin ${PROTO_CLIENT_GIT_BRANCH} > /dev/null 2>&1
echo "[Debug] Comitted changes to platform-client-go branch ${PROTO_CLIENT_GIT_BRANCH}"
echo "[Debug] https://github.com/danbelden/proto-client-go"

## Return to the previous workspace location
cd ${BACKUP_PWD}
