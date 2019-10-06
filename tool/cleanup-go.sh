#!/usr/bin/env bash

## Terminate if an error is encountered
set -e

## Config vars
PROTO_REPO="git@github.com:danbelden/proto-client.git"
CLEANUP_REPO="git@github.com:danbelden/proto-client-go.git"
GIT_WORKSPACE="/tmp/workspace-git"

## Find the branch names on the proto-client repo
echo "[Debug] Branches in ${PROTO_REPO}"
PROTO_BRANCHES=()
PROTO_BRANCHES_RAW=`git ls-remote --head ${PROTO_REPO} | cut -f2 | sed 's/refs\/heads\///g' | sort`
for BRANCH_NAME in ${PROTO_BRANCHES_RAW}; do
  echo ${BRANCH_NAME}
  PROTO_BRANCHES+=(${BRANCH_NAME})
done

## List the current branches in the clean-up repo
echo "[Debug] Branches in ${CLEANUP_REPO}"
CLEANUP_BRANCHES=()
CLEANUP_BRANCHES_RAW=`git ls-remote --head ${CLEANUP_REPO} | cut -f2 | sed 's/refs\/heads\///g' | sort`
for BRANCH_NAME in ${CLEANUP_BRANCHES_RAW}; do
  echo ${BRANCH_NAME}
  CLEANUP_BRANCHES+=(${BRANCH_NAME})
done

## Calculate the branches that need to be deleted
DELETE_BRANCHES=()
for BRANCH_NAME in ${CLEANUP_BRANCHES[@]}; do
  if [[ ! " ${PROTO_BRANCHES[@]} " =~ " ${BRANCH_NAME} " ]]; then
    DELETE_BRANCHES+=(${BRANCH_NAME})
  fi
done

## If there are no branches to delete terminate early
if [[ ${#DELETE_BRANCHES[@]} == 0 ]]; then
  echo "[Debug] No branches to delete"
  exit 0
fi

## Setup ready to perform deletes
BACKUP_PWD=${PWD}
CLEANUP_REPO_DIR=$(basename ${CLEANUP_REPO} .git)
if [[ ! -d ${GIT_WORKSPACE} ]]; then
  mkdir -p ${GIT_WORKSPACE}
fi
cd ${GIT_WORKSPACE}
if [[ ! -d ${CLEANUP_REPO_DIR} ]]; then
    git clone ${CLEANUP_REPO} > /dev/null 2>&1
fi
cd ${CLEANUP_REPO_DIR}
git fetch > /dev/null 2>&1

## Loop the delete branches and git push delete them
echo "[Debug] Deleting non-sync branches in ${CLEANUP_REPO} ..."
for BRANCH_NAME in ${DELETE_BRANCHES[@]}; do
  if [[ ${BRANCH_NAME} == "master" ]]; then
    echo "[Warn] Skipping delete of master branch"
    continue
  fi
  echo "[Debug] Removing branch ${BRANCH_NAME} ..."
  git push origin --delete ${BRANCH_NAME}
done

## Switch back to previous pwd
cd ${BACKUP_PWD}
