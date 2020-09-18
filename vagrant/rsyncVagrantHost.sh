#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

vagranthost=${1:-abr@abr-pc}


rsync -av $SCRIPT_DIR/* $vagranthost:$SCRIPT_DIR/


