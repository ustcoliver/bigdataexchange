#!/bin/bash

. scripts/env.sh

# 远程初始化，创建一些必要文件夹，减少同步文件时需要创建文件夹的操作
function remoteInit() {

  if [ "${IPHOST_DISTRIBUTED}" == "true" ]; then
    infoln "\n ip-hosts already distributed, skip ... \n"
  else
    addIpHost
  fi
  ssh ${SSH_HOST_VM1} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
  ssh ${SSH_HOST_VM2} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
  ssh ${SSH_HOST_VM3} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
}

function addIpHost(){
  infoln "================================================"
  infoln "distribute ip hosts and insert to /etc/hosts ..."
  infoln "================================================"
  scp iphosts ${SSH_HOST_VM1}:~/${PROJECT_NAME} 
  scp iphosts ${SSH_HOST_VM2}:~/${PROJECT_NAME}
  scp iphosts ${SSH_HOST_VM3}:~/${PROJECT_NAME}
  ssh -t  ${SSH_HOST_VM1} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
  ssh -t  ${SSH_HOST_VM2} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
  ssh -t  ${SSH_HOST_VM3} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
}
