#!/usr/bin/env bash

# Base configs
set -x
DOCKER_VER="17.03.0-ce"

# Install and move docker binary into bin dir
curl -L -o /tmp/docker-${DOCKER_VER}.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER}.tgz
tar -xz -C /tmp -f /tmp/docker-${DOCKER_VER}.tgz
mv /tmp/docker/* /usr/bin
