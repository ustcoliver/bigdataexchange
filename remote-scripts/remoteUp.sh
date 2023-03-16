#!/bin/bash

IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)

echo -e "\n start docker containers by docker-compose on ${IP} ... \n"

set -x
docker-compose -f docker/docker-compose-up.yaml up -d 
set +x 

sleep 3
echo -e "\n sleep 3 seconds for containers ...\n"

docker ps --format "{{.ID}}\t{{.Status}}\t{{.Names}}"
