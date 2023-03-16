#!/bin/bash

# . scripts/env.sh 
. scripts/channel-utils.sh

channel_name=$1

generateChannel $channel_name

joinChannel $channel_name

