#!/bin/bash
export PATH=${PATH}:~/fabric-samples/bin

source scripts/env.sh
. scripts/generate.sh
. scripts/utils.sh
. scripts/sync.sh
. scripts/channel.sh
. scripts/deploy-utils.sh
. scripts/deploy.sh

# 远程初始化项目，包括写入iphost，复制脚本到远程机器
function remoteNetworkInit() {
	infoln "==========================="
	infoln "Init the Project  "
	infoln "==========================="
	for ((i = 1; i <= $HOSTS; i++)); do
		eval ssh_host="\$SSH_HOST$i"
		set -x
		scp -r iphosts remote-scripts scripts $ssh_host:"~/$PROJECT_NAME"
		ssh -t $ssh_host "cd ~/${PROJECT_NAME} && bash remote-scripts/remote.sh init"
		set +x
	done
	successln "\n Remote Init network success ! \n"
}

# 远程启动机器中的docker容器，启动区块链网络
function remoteNetworkUp() {
	infoln "==========================="
	infoln "Start the Network remotely "
	infoln "==========================="
	for ((i = 1; i <= $HOSTS; i++)); do
		eval ssh_host="\$SSH_HOST$i"
		ssh $ssh_host "cd ~/${PROJECT_NAME} && bash remote-scripts/remote.sh up"
	done
	successln "\n Remote START network success ! \n"
}

# 远程清理机器中保存的区块链参数和配置， 关闭docker容器
function remoteNetworkDown() {
	infoln "==========================="
	infoln "Stop the Network remotely "
	infoln "==========================="
	for ((i = 1; i <= $HOSTS; i++)); do
		eval ssh_host="\$SSH_HOST$i"
		ssh $ssh_host "cd ~/${PROJECT_NAME} && bash remote-scripts/remote.sh down"
	done
	successln "\n Remote STOP network success ! \n"
}



COMMAND=$1

if [ "$COMMAND" == "" ]; then
	echo "help message"
elif [ "$COMMAND" == "init" ]; then
	remoteNetworkInit
elif [ "$COMMAND" == "generate" ]; then
	localGenerate
	createChannelTx  ChannelOne channelone
elif [ "$COMMAND" == "clean" ]; then
	clean
elif [ "$COMMAND" == "sync" ]; then
	syncConfig
elif [ "$COMMAND" == "up" ]; then
	clean
	remoteNetworkInit
	bash ./network.sh generate 
	syncConfig 
	remoteNetworkUp
elif [ "$COMMAND" == "down" ]; then
	remoteNetworkDown
elif [ "$COMMAND" == "reup" ]; then
	bash ./network.sh down
	bash ./network.sh up 
elif [ "$COMMAND" == "channel" ]; then
	channel $CHANNEL_NAME 1 2 3 4 5 6
	updateAnchorPeer $CHANNEL_NAME
elif [ "$COMMAND" == "restart" ]; then
	remoteNetworkDown
	clean
	localGenerate
	createChannelTx  ChannelOne channelone
	syncConfig
	remoteNetworkUp
	channel $CHANNEL_NAME 1 2 3 4 5 6
	updateAnchorPeer $CHANNEL_NAME
elif [ "$COMMAND" == "deploy" ]; then
	deploy $CHANNEL_NAME data chaincode/data-exchange 1 2 3 4 5 6
elif [ "$COMMAND" == "update" ]; then
	updateAnchorPeer $CHANNEL_NAME
else
	errorln "wrong command !"
fi
