#!/bin/bash

if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: delpoy.sh [{mod}|all] {version|--sync}\e[0m"
    exit 1
fi

MODULE=$1

if [ $# -eq 2 ]; then
  if [ "$2" == "--sync" ]; then
    echo -e "\e[1;33mSync package is request, now pulling...\e[0m"
    ./pull.sh $MODULE
  else
    VERSION=$2
  fi
fi

SHELL_PATH=$(dirname $(readlink -f $0))
cd $SHELL_PATH

function deploy_node() {
  echo -e "\e[1;33mBegin deploy $3, version $4 to $1 ...\e[0m"
  ./syncfile.sh $1 $2 ./liteangel.sh /tmp >/dev/null
  ./synccmd.sh $1 $2 "cd /tmp; ./liteangel.sh $3 $4"
}

function deploy_all() {
  while read line
  do
    if [[ $line =~ ^M ]]; then
      MOD=`echo $line | awk {'print $2'}`
      IP=`echo $line | awk {'print $3'}`
      PSW=`echo $line | awk {'print $4'}`

      deploy_node $IP $PSW $MOD $VERSION
    fi

  done < config
}

function deploy_single() {
  if !( cat ./config |grep -q $1 ); then
    echo "Not found $1 config!"
    exit 1
  fi

  while read line
  do 
    if [[ $line =~ ^M ]] && ( echo $line |grep -q $1); then
      MOD=`echo $line | awk {'print $2'}`
      IP=`echo $line | awk {'print $3'}`
      PSW=`echo $line | awk {'print $4'}`

      deploy_node $IP $PSW $MOD $VERSION
    fi

  done < config
}

# 开始部署
if [ "$MODULE" == "all" ]; then
  deploy_all
else
  deploy_single $MODULE
fi

TIME=`date "+%Y-%m-%d %H:%M:%S"`

echo "$TIME Deploy $@, status is $?" >> .deploy.log

