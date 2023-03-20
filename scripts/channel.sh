#!/bin/bash

. scripts/utils.sh
. scripts/env.sh
. scripts/channel-utils.sh


function channel() {
  channel_name=$1
  host_generate=$2
  shift 2
  host_join=$*
  infoln "================================================="
  infoln "remote Create and Join Channel $channel_name ..."
  infoln "================================================="

  eval org_generate="\$ORG$host_generate"
  eval ssh_host_generate="\$SSH_HOST$host_generate"
  infoln "\n $org_generate create the $channel_name ... \n"
  set -x
  ssh -t $ssh_host_generate "docker exec -it cli bash remote-scripts/cli-channel.sh create $channel_name"
  set +x

  scp $ssh_host_generate:"~/$PROJECT_NAME/channel-artifacts/$channel_name.block" ./channel-artifacts/


  for host in $host_join
  do
    eval org="\$ORG$host"
    eval ssh_host="\$SSH_HOST$host"
    infoln "\n Sync $channel_name.block to $org ... \n"
    scp ./channel-artifacts/$channel_name.block $ssh_host:"~/$PROJECT_NAME/channel-artifacts"
  done

  hosts=($host_generate ${host_join[@]})

  for host in ${hosts[@]}
  do
    eval ssh_host="\$SSH_HOST$host"
    set -x
    ssh -t $ssh_host "docker exec -it cli bash remote-scripts/cli-channel.sh join $channel_name"
    set +x
  done

  # for ((i=1;i<=$HOSTS;i++));
  # do
  #   eval org="\$ORG$i"
  #   eval ssh_host="\$SSH_HOST$i"
  #   if [ "$i" != $host_generate ]; then
  #     infoln "\n sync $channel_name.block to $org ...\n"
  #     scp ./channel-artifacts/$channel_name.block $ssh_host:"~/$PROJECT_NAME/channel-artifacts"
  #   fi
  # done

  #   infoln "\n $org join in $channel_name ...\n"
    

  # for host in $host_join
  # do 
  #   infoln "\n Sync the $channel_name.block to other Hosts ... \n"
  #   eval ssh_host_join="\$SSH_HOST$host"
  #   scp ./channel-artifacts/$channel_name.block $ssh_host_join:"~/$PROJECT_NAME/channel-artifacts"
  #   eval org_join="\$ORG$host"
  #   infoln "\n $org_join join in the $channel_name ... \n"
  #   set -x
  #   ssh -t $ssh_host_join "docker exec -it cli bash remote-scripts/cli-joinChannel.sh $channel_name"
  #   set +x
  # done

}

# 更新锚节点
function updateAnchorPeer() {
  channel_name=$1
  for ((i=1;i<=$HOSTS;i++));
  do 
    eval ssh_host="\$SSH_HOST$i"
    set -x
    ssh -t $ssh_host "docker exec -it cli bash remote-scripts/setAnchorPeer.sh" $channel_name
    set +x
  done 
  successln "\n Anchor Peer updated ! \n"
}
