. scripts/utils.sh
. scripts/env.sh

function remoteDown(){
  IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)
  
  println "\n remove blockchain config and cert files on ${IP} ... \n" 
  
  removeDir ${HOME}/${PROJECT_NAME}/channel-artifacts
  
  removeDir ${HOME}/${PROJECT_NAME}/system-genesis-block
  
  removeDir ${HOME}/${PROJECT_NAME}/organizations
  
  removeDir ${HOME}/${PROJECT_NAME}/scripts
  
  removeDir ${HOME}/${PROJECT_NAME}/remote-scripts
  
  removeContainer
  
  removeFile ${HOME}/${PROJECT_NAME}/docker/docker-compose-up.yaml
  
  removeFile ${HOME}/${PROJECT_NAME}/*.tar.gz

  set -x
  rm -rf chaincode/*
  set +x
}

function remoteUp(){
  IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)

  echo -e "\n start docker containers by docker-compose on ${IP} ... \n"

  set -x
  docker-compose -f docker/docker-compose-up.yaml up -d 
  set +x 

  sleep 3
  echo -e "\n sleep 3 seconds for containers ...\n"

  docker ps --format "{{.ID}}\t{{.Status}}\t{{.Names}}"

}

function remoteInit() {

  if [ "${IPHOST_DISTRIBUTED}" == "true" ]; then
    infoln "\n ip-hosts already distributed, skip ... \n"
  else
    addIpHost
  fi
  ssh ${SSH_HOST_VM1} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
  ssh ${SSH_HOST_VM2} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
  ssh ${SSH_HOST_VM3} "mkdir -p ${PROJECT_NAME}/docker ${PROJECT_NAME}/chaincode"
}

function addIpHost(){
  infoln "================================================"
  infoln "distribute ip hosts and insert to /etc/hosts ..."
  infoln "================================================"
  scp iphosts ${SSH_HOST_VM1}:~/${PROJECT_NAME} 
  scp iphosts ${SSH_HOST_VM2}:~/${PROJECT_NAME}
  scp iphosts ${SSH_HOST_VM3}:~/${PROJECT_NAME}
  ssh -t  ${SSH_HOST_VM1} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
  ssh -t  ${SSH_HOST_VM2} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
  ssh -t  ${SSH_HOST_VM3} "cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null"
}


command=$1

if [ "$command" == "init" ]; then
  remoteInit
elif [ "$command" == "up" ]; then
  remoteUp
elif [ "$command" == "down" ]; then
  remoteDown
else
  echo "wrong input !!"
fi

