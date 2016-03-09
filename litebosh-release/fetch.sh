#!/bin/bash

if [ $# -lt 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: fetch.sh {module} | [version]\e[0m"
    exit 1
fi

MOD=$1
VER=$2

REPO=http://172.16.4.5:8765/release

SHELL_PATH=$(dirname $(readlink -f $0))
cd $SHELL_PATH

if [ -z $LITEBOSH_FETCH_TARGET ]; then
  echo -e "\e[1;31mLITEBOSH_FETCH_TARGET unset!\e[0m"
  exit 1
fi

obj=`grep "^$MOD" ./releases/litebosh-$VER | awk {'print $2'}`
depend=`grep "^$MOD" ./releases/litebosh-$VER | awk {'print $3'}`

#wget $REPO/$obj -q -P $LITEBOSH_FETCH_TARGET
curl -s $REPO/$obj | tar xzf - -C $LITEBOSH_FETCH_TARGET
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m##Fetch package for $MOD failed, please check!\e[0m"
  exit 1
fi

# 下载依赖的模块，后续需要支持多依赖
if [ -n "$depend" ]; then
  obj=`grep "^$depend" ./releases/litebosh-$VER | awk {'print $2'}`
  #wget $REPO/$obj -q -P $LITEBOSH_FETCH_TARGET
  curl -s $REPO/$obj | tar xzf - -C $LITEBOSH_FETCH_TARGET  

  if [ $? -ne 0 ]; then
    echo -e "\e[1;31m##Fetch depend package for $MOD failed, please check!\e[0m"
  fi
fi

