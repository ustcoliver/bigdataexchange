#!/bin/bash

. scripts/env.sh
. scripts/utils.sh

# 利用rsync远程同步文件，将日志记录到sync.log中
function syncFiles() {
  DATE_STR=$(date +"%F, %T.%3N")
  echo -e "\n\n $DATE_STR \n\n" >> sync.log
  PARA=$*
  set -x
  rsync -av $PARA >> sync.log 
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    fatalln "Failed to Sync Files: $PARA..."
  fi
}

# 同步区块链参数和配置到机器中
function syncConfig(){
  infoln "=============================================="
  infoln "Sync the Configurations of Fabric to hosts ..."
  infoln "=============================================="

  docker_dst="~/${PROJECT_NAME}/docker/docker-compose-up.yaml"
  for ((i=1;i<=$HOSTS;i++));
  do  
    eval host_ip="\$HOST$i"
    infoln "\n Sync to $host_ip ... \n"

    eval ssh_host="\$SSH_HOST$i"
    syncFiles channel-artifacts organizations system-genesis-block scripts remote-scripts chaincode $ssh_host:~/${PROJECT_NAME}

    eval docker_file="docker/host$i.yaml"
    syncFiles $docker_file $ssh_host:$docker_dst
  done

}