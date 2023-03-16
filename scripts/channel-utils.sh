#!/bin/bash

. scripts/env.sh

function generateChannel() {
  channel_name=$1
  echo -e "\n generate $channel_name.block ... \n"
  echo -e "\n sleep $DELAY seconds, wait for RAFT consensus to start... \n"
  sleep $DELAY
  set -x
  peer channel create -o $ORDERER_ADDRESS:7050 -c $channel_name -f ./channel-artifacts/$channel_name.tx --outputBlock ./channel-artifacts/$channel_name.block --tls --cafile $ORDERER_CA
  set +x
}

function joinChannel() {
  channel_name=$1
  peer channel join -b ./channel-artifacts/$channel_name.block
}