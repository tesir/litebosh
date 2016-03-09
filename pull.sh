#!/bin/bash

if [ $# -lt 1 ] ; then
    echo -e "\e[1;33m!!!USEAGE: pull.sh [MODULE]\e[0m"
    exit 1
fi

REPO=`grep ARTIFACTS_REPO ./config |awk -F "=" '{print $2}'`
REPO_PATH=`grep CONFIG_REPO_LOCAL ./config |awk -F "=" '{print $2}'`

function pull_one() {
  mod=$1
  
  echo -e "\e[1;33mPull $mod from repo...\e[0m"

  rm -rf $REPO_PATH/release/last/$mod

  if [ $mod == "solrock" ] || [ $mod == "evenstone" ] || [ $mod == "login" ]; then
    wget $REPO/${mod}.tar.gz -q -O ./${mod}.tar.gz
    tar czf $REPO_PATH/release/last/$mod ./${mod}.tar.gz
    rm -rf ./${mod}.tar.gz
  else
    wget $REPO/litebosh-${mod}-1.0-SNAPSHOT.jar -q -O ./${mod}.jar
    tar czf $REPO_PATH/release/last/$mod ./${mod}.jar
    rm -rf ./${mod}.jar
  fi
  if [ $? -eq 0 ]; then
    echo -e "\e[1;32mOK!\e[0m"
  else
    echo -e "\e[1;31mFailed!\e[0m"
  fi
}

function pull_all() {
  MODULE_LIST=`grep ARTIFACTS_LIST ./config |awk -F "=" '{print $2}'`

  for mod in $MODULE_LIST
  do
    pull_one $mod
  done 
}

if [ "$1" == "all" ]; then
  pull_all
else
  pull_one $1
fi
