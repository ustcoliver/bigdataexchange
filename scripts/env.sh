#!/bin/bash


#项目配置
# 项目名
PROJECT_NAME="fabric-template"
# 通道名
# CHANNEL_NAME="template-channel"
#等待raft选出leader
DELAY=3
# 尝试创建通道次数，防止raft还未选出leader就提交
MAX_RETRY=3
# 是否已经分发iphosts 到各个主机
# distributeHost 只需运行一次
IPHOST_DISTRIBUTED=true

# 此处存一些智能合约基础环境变量
# 默认所有智能合约都由go编写
CC_SRC_LANGUAGE=go
CC_RUNTIME_LANGUAGE=golang
CC_VERSION="1.0"
CC_SEQUENCE="1"
CC_INIT_FCN="InitLedger"
CC_END_POLICY="NA"
CC_COLL_CONFIG="NA"
VERBOSE="false"
CC_QUERY="GetAllAssets"



export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.template.com/peers/peer0.org1.template.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.template.com/peers/peer0.org2.template.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.template.com/peers/peer0.org3.template.com/tls/ca.crt

# 设置环境变量
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    # export CORE_PEER_LOCALMSPID="Org1MSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.template.com/users/Admin@org1.template.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.template.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    # export CORE_PEER_LOCALMSPID="Org2MSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.template.com/users/Admin@org2.template.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.template.com:7051
  elif [ $USING_ORG -eq 3 ]; then
    # export CORE_PEER_LOCALMSPID="Org3MSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_ADDRESS=peer0.org3.template.com:7051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.org1.template.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.org2.template.com:7051
  else
    errorln "ORG Unknown"
  fi
}


parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}