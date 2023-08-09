#!/bin/bash

. scripts/deploy-utils.sh
. scripts/env.sh




function deploy(){
  CHANNEL_NAME=$1
  CC_NAME=$2
  CC_SRC_PATH=$3
  host_package=$4
  shift 4
  host_install=$*
  infoln "============================="
  infoln "Deploy the Chaincode on Orgs"
  infoln "============================="
  prepare
  eval org_package="\$ORG$host_package"
  eval ssh_host_package="\$SSH_HOST$host_package"
  infoln "\n $org_package Package the Chaincode ... \n"
  ssh -t $ssh_host_package "docker exec -it cli bash remote-scripts/cli-deployCC.sh package" $CC_NAME ../$CC_SRC_PATH
  ssh -t $ssh_host_package "docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/$CC_NAME.tar.gz ~/$PROJECT_NAME"
  scp $ssh_host_package:~/$PROJECT_NAME/$CC_NAME.tar.gz .

  for host in $host_install
  do
    eval ssh_host="\$SSH_HOST$host"
    scp $CC_NAME.tar.gz $ssh_host:~/$PROJECT_NAME
    # eval docker_cp_command="~/$PROJECT_NAME/$CC_NAME.tar.gz cli:/opt/gopath/src/github.com/hyperledger/fabric/peer"
    echo "test"
    set -x
    ssh -t $ssh_host "docker cp ~/$PROJECT_NAME/$CC_NAME.tar.gz cli:/opt/gopath/src/github.com/hyperledger/fabric/peer"
    set +x
  done

  for ((i=1;i<=$HOSTS;i++));
  do
    eval ssh_host="\$SSH_HOST$i"
    eval org="\$ORG$i"
    set -x
    ssh -t $ssh_host "docker exec -it cli bash remote-scripts/cli-deployCC.sh install $CC_NAME $CHANNEL_NAME $org" 
    set +x
  done

  ssh -t $ssh_host_package "docker exec -it cli bash remote-scripts/cli-deployCC.sh commit $CC_NAME $CHANNEL_NAME 1 2 3 4 5 6"

  for ((i=1;i<=$HOSTS;i++));
  do
    eval ssh_host="\$SSH_HOST$i"
    eval org="\$ORG$i"
    set -x
    ssh -t $ssh_host "docker exec -it cli bash remote-scripts/cli-deployCC.sh query-commit $CC_NAME $CHANNEL_NAME $org" 
    set +x
  done

  ssh -t $ssh_host_package "docker exec -it cli bash remote-scripts/cli-deployCC.sh init $CC_NAME $CHANNEL_NAME 1 2 3 4 5 6"

  for ((i=1;i<=$HOSTS;i++));
  do
    eval ssh_host="\$SSH_HOST$i"
    eval org="\$ORG$i"
    set -x
    ssh -t $ssh_host "docker exec -it cli bash remote-scripts/cli-deployCC.sh query $CC_NAME $CHANNEL_NAME $org" 
    set +x
  done

}

