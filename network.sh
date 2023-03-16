#!/bin/bash
export PATH=${PATH}:~/fabric-samples/bin

. remote-scripts/remoteInit.sh

# . scripts/env.sh
. scripts/generate.sh
. scripts/utils.sh
. scripts/sync.sh
. scripts/channel.sh
. scripts/deploy-utils.sh
. scripts/deploy.sh


function remoteNetworkUp() {
  infoln "==========================="
  infoln "Start the Network remotely "
  infoln "==========================="
  for ((i=1;i<=$HOSTS;i++));
  do 
    eval ssh_host="\$SSH_HOST$i"
    ssh $ssh_host "cd ~/${PROJECT_NAME} && bash remote-scripts/remoteUp.sh"
  done
  successln "\n Remote START network success ! \n"
}

# 远程清理机器中保存的区块链参数和配置， 关闭docker容器
function remoteNetworkDown() {
  infoln "==========================="
  infoln "Stop the Network remotely "
  infoln "==========================="
  for ((i=1;i<=$HOSTS;i++));
  do
    eval ssh_host="\$SSH_HOST$i"
    ssh $ssh_host "cd ~/${PROJECT_NAME} && bash remote-scripts/remoteDown.sh"
  done
  successln "\n Remote STOP network success ! \n"
}


#项目配置
# 项目名
PROJECT_NAME="fabric-template"
# 通道设置
CHANNEL_PROFILE="ThreeOrgsChannel"
# 通道名
CHANNEL_NAME="template-channel"

# 节点数量
# 使用eval进行变量名拼接
# 只需HOSTS的值与相应变量的数量统一，即可通过循环执行操作
HOSTS=3
# 节点ip
HOST1="10.1.2.11"
HOST2="10.1.2.12"
HOST3="10.1.2.13"
# 节点ssh host
SSH_HOST1="fabric-1"
SSH_HOST2="fabric-2"
SSH_HOST3="fabric-3"
# 组织名
ORG1="Org1"
ORG2="Org2"
ORG3="Org3"

COMMAND=$1

if [ "$COMMAND" == "" ]; then
  echo "help message"
elif [ "$COMMAND" == "init" ]; then
  remoteInit
elif [ "$COMMAND" == "generate" ]; then
  localGenerate
  createChannelTx $CHANNEL_PROFILE $CHANNEL_NAME
elif [ "$COMMAND" == "clean" ]; then
  clean
elif [ "$COMMAND" == "sync" ]; then
  syncConfig
elif [ "$COMMAND" == "up" ]; then
  clean
  localGenerate
  createChannelTx $CHANNEL_PROFILE $CHANNEL_NAME
  syncConfig
  remoteNetworkUp
elif [ "$COMMAND" == "down" ]; then
  remoteNetworkDown
elif [ "$COMMAND" == "channel" ]; then
  createChannel $CHANNEL_NAME 1 2 3
elif [ "$COMMAND" == "restart" ]; then
  remoteNetworkDown
  clean
  localGenerate 
  createChannelTx $CHANNEL_PROFILE $CHANNEL_NAME
  syncConfig
  remoteNetworkUp
  createChannel $CHANNEL_NAME 1 2 3
  updateAnchorPeer $CHANNEL_NAME
elif [ "$COMMAND" == "deploy" ]; then
  deploy $CHANNEL_NAME basic chaincode/asset-transfer-basic  1 2 3
elif [ "$COMMAND" == "update" ]; then
  updateAnchorPeer $CHANNEL_NAME
else
    errorln "wrong command !"
fi