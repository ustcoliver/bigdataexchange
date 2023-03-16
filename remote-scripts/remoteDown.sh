#!/bin/bash

. scripts/utils.sh
. scripts/env.sh

IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)

println "\n remove blockchain config and cert files on ${IP} ... \n" 

removeDir ${HOME}/${PROJECT_NAME}/channel-artifacts

removeDir ${HOME}/${PROJECT_NAME}/system-genesis-block

removeDir ${HOME}/${PROJECT_NAME}/organizations

removeDir ${HOME}/${PROJECT_NAME}/scripts

removeDir ${HOME}/${PROJECT_NAME}/remote-scripts

removeContainer

removeFile ${HOME}/${PROJECT_NAME}/docker/docker-compose-up.yaml

removeFile ${HOME}/${PROJECT_NAME}/${CC_NAME}.tar.gz

