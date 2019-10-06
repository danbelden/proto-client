#!/usr/bin/env bash

## Config vars
PROTO_REPO="git@github.com:danbelden/proto-client.git"
CLEANUP_REPO="git@github.com:danbelden/proto-client-go.git"

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

## Loop the delete branches and remove them
echo "[Debug] Deleting non-sync branches in ${CLEANUP_REPO} ..."
for BRANCH_NAME in ${DELETE_BRANCHES[@]}; do
  echo "[Debug] Removing branch ${BRANCH_NAME}"
done
