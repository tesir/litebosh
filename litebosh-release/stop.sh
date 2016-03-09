#!/bin/bash

if [ $# -lt 1 ] ; then
    echo -e "\e[1;33m!!!USEAGE: stop.sh {module}\e[0m"
    exit 1
fi

MOD=$1

echo -e "\e[1;33mWaiting for $MOD processes to stop...\e[0m"

monit stop $MOD
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m##monit stop exec failed!\e[0m"
  exit 1
fi

for ((i=0; i < 12; i++)); do
  if (monit summary | grep $MOD | grep -q "Not monitored" > /dev/null); then
    echo -e "\e[1;32m$MOD stopped OK.\e[0m"
    break
  fi  
  sleep 3
done

if !(monit summary | grep $MOD | grep -q "Not monitored" > /dev/null); then
   echo -e "\e[1;31mUnable to stop $MOD processes\e[0m"  
fi

