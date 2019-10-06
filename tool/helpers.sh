#!/usr/bin/env bash

## Hack for mac OSX
realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
