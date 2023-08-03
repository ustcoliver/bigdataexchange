#!/bin/bash

# . scripts/env.sh
. scripts/utils.sh

#创建组织，根据配置生成密钥和证书文件
#基于organizations/cryptogen文件夹下所有文件
function createOrgs() {
  infoln "================================================"
  infoln "Generating certificates using cryptogen tool ..."
  infoln "================================================"

  config_path=organizations/cryptogen
  crypto_config=$(ls $config_path)
  for yaml in $crypto_config
  do
    infoln "\n Creating Identities according to $yaml ... \n"
    set -x
    cryptogen generate --config=$config_path/$yaml --output="organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate certificates according to $yaml"
    fi
  done
}

#创建系统通道，生成创世区块
#基于configtx/configtx.yaml
#接受参数：configPath, profile, channelID, outputBlock
function createConsortium() {
  infoln "======================================================="
  infoln "Create System Channel, Generating Orderer Genesis block ..."
  infoln "======================================================="
  config_path=$1
  profile=$2
  channel_ID=$3
  output_Block=$4
  set -x
  #configtxgen -configPath ./configtx -profile MultiNodeEtcdRaft -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
  configtxgen -version
  configtxgen -configPath $config_path -profile $profile -channelID $channel_ID -outputBlock $output_Block
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate orderer genesis block..."
  fi
}

#根据 $CHANNEL_PROFILE 生成创建通道交易 $CHANNEL_NAME.tx
function createChannelTx() {
  profile=$1
  channel_name=$2
  FABRIC_CFG_PATH=${PWD}/configtx
  infoln "==========================================================="
  infoln "generete create channel transaction ${CHANNEL_NAME}.tx ..."
  infoln "==========================================================="
  set -x
	configtxgen -configPath ./configtx -profile $profile -outputCreateChannelTx ./channel-artifacts/$channel_name.tx -channelID $channel_name
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

# 汇总以上函数，即本地生成证书和区块链配置
function localGenerate() {
  if [ -d "organizations/peerOrganizations" ]; then
    clean
  fi 
  createOrgs
  createConsortium ./configtx SystemChannel system-channel ./system-genesis-block/genesis.block
}

# 清理本地生成的文件
function clean(){
  infoln "========================================================================="
  infoln "remove local existed cert files, blockchain config and packaged chaincode"
  infoln "========================================================================="

  removeDir organizations/peerOrganizations
  removeDir organizations/ordererOrganizations
  removeDir channel-artifacts
  removeDir system-genesis-block
  removeFile ${CC_NAME}.tar.gz
  removeFile sync.log
}
