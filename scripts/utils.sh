#!/bin/bash

C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'

function printHelp() {

  println "\n \t Hyperledger Fabric v2.2 Multihost Deployment Test Project\n"
  println "\n The following are the script parameters: \n "
  infoln "init"
  println "\t remote init project"
  infoln "up"
  println "\t generate and sync cert files and config to vms, start docker containers"
  infoln "channel"
  println "\t create channel, let peers join the channel"
  infoln "deploy"
  println "\t deploy Chaincode, query chaincode to check the chaincode deployment"
  infoln "generate"
  println "\t generate cert files and blockchain config"
  infoln "clean"
  println "\t remove all locally generated cert files and blockchain configs"
  infoln "createChannel"
  println "\t create Channel"
  infoln "down"
  println "\t remote stop all docker containers and remove all cert files and config"
}

# println echos string
function println() {
  echo -e "$1"
}

# errorln echos i red color
function errorln() {
  println "${C_RED}${1}${C_RESET}"
}

# successln echos in green color
function successln() {
  println "${C_GREEN}${1}${C_RESET}"
}

# infoln echos in blue color
function infoln() {
  println "${C_BLUE}${1}${C_RESET}"
}

# warnln echos in yellow color
function warnln() {
  println "${C_YELLOW}${1}${C_RESET}"
}

# fatalln echos in red color and exits with fail status
function fatalln() {
  errorln "$1"
  exit 1
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

function removeDir() {
    DIR=$1
    res=$(find $DIR 2>/dev/null)
    if [ "$res" != "" ]; then 
        set -x
        rm -rf $DIR
        set +x 
    else
        infoln "\n $DIR not exist, skip ... \n"
    fi
}
# 使用find判断文件是否存在，可以使用通配符删除文件
function removeFile() {
    FILE=$1
    res=$(find $FILE 2>/dev/null)
    if [ "$res" != "" ]; then 
        set -x
        rm $res
        set +x 
    else
        infoln "\n $FILE not exist, skip ... \n"
    fi
}

function removeContainer() {
    containers=$(docker ps -aq)

    if [ "$containers" != "" ]; then 
        println "\n remove all containers on ${IP} ... \n"
        set -x
        docker-compose -f docker/docker-compose-up.yaml down --volumes 
        set +x
    else
        println "\n no containers, skip ... \n"
    fi

}

export -f errorln
export -f successln
export -f infoln
export -f warnln
