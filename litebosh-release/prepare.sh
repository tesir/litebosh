#!/bin/bash

SHELL_PATH=$(dirname $(readlink -f $0))

if ! (which wget > /dev/null); then
  yum install -y wget
fi

# 如果没有安装monit，先安装之
if ! (which monit > /dev/null); then
  $SHELL_PATH/monit.sh
fi

# 启动monit
if !(systemctl status monit |grep -q "active (running)"); then
  service monit start
  monit start all
fi
