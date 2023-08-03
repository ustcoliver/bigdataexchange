#!/bin/bash

. scripts/env.sh

function createChannel() {
  echo -e "\n generate $channel_name.block ... \n"
  echo -e "\n sleep $DELAY seconds, wait for RAFT consensus to start... \n"
  sleep $DELAY
  set -x
  peer channel create -o $ORDERER_ADDRESS:7050 -c $channel_name -f ./channel-artifacts/$channel_name.tx --outputBlock ./channel-artifacts/$channel_name.block --tls --cafile $ORDERER_CA -t 60s
  set +x
}

function joinChannel() {
  # 检查$channel_name.block 文件是否存在，若不存在则推出
  if [ ! -f "./channel-artifacts/$channel_name.block" ]; then
    echo -e "\n ./channel-artifacts/$channel_name.block not found !!! \n"
    exit 1
  fi
  peer channel join -b ./channel-artifacts/$channel_name.block
}


command=$1
channel_name=$2

if [ "$command" == "create" ]; then
    createChannel
elif [ "$command" == "join" ]; then
    joinChannel
else 
    echo "wrong command !!!"
fi