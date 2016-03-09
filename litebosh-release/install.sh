#!/bin/bash

if [ $# -lt 1 ] && [ $# -lt 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: install.sh {module} | [version]\e[0m"
    exit 1
fi

MOD=$1
VER=$2

if  [ ! -n "$VER" ] ;then
  VER="latest"
fi

SHELL_PATH=$(dirname $(readlink -f $0))

cd $SHELL_PATH

if [ ! -d ./jobs/$MOD ]; then
  echo -e "\e[1;31m!!! Job with name $MOD not found, pls check!\e[0m"
  exit 1
fi

if [ ! -f ./releases/litebosh-$VER ]; then
  echo -e "\e[1;31m!!! Version litebosh-$VER not found, pls check!\e[0m"
  exit 1
fi

# 准备目录
mkdir -p /var/litebosh/data/packages/common
mkdir -p /var/litebosh/data/jobs

# 准备安装环境
./prepare.sh

if [ ! -f /var/litebosh/data/packages/common/utils.sh ]; then
  cp utils.sh /var/litebosh/data/packages/common/
fi

if [ ! -f /var/litebosh/packages/common/utils.sh ]; then
  mkdir -p /var/litebosh/packages
  ln -s /var/litebosh/data/packages/common/ /var/litebosh/packages/
fi

# 停止原来的服务
if ( monit summary | grep -q "$MOD"); then
  ./clean.sh $MOD
fi

objdir=v${VER}t`date "+%Y%m%d%H%M"`

mkdir -p /var/litebosh/data/jobs/$MOD/$objdir
mkdir -p /var/litebosh/data/packages/$MOD/$objdir

export LITEBOSH_FETCH_TARGET=$SHELL_PATH/.builds/$MOD
export LITEBOSH_INSTALL_TARGET=/var/litebosh/data/packages/$MOD/$objdir

rm -rf $LITEBOSH_FETCH_TARGET
mkdir -p $LITEBOSH_FETCH_TARGET

./fetch.sh $MOD $VER
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m##Fetch failed!\e[0m"
  exit 1
fi

source ./packages/$MOD/packaging
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m##Packageing failed!\e[0m"
  exit 1
fi

rm -rf $LITEBOSH_FETCH_TARGET

unset LITEBOSH_FETCH_TARGET
unset LITEBOSH_INSTALL_TARGET

cp -a ./jobs/$MOD/* /var/litebosh/data/jobs/$MOD/$objdir

mkdir -p /var/litebosh/jobs/$MOD
mkdir -p /var/litebosh/packages/$MOD

rm -rf /var/litebosh/jobs/$MOD
rm -rf /var/litebosh/monit/job/${MOD}.monitrc
rm -rf /var/litebosh/packages/$MOD

ln -s /var/litebosh/data/jobs/$MOD/$objdir /var/litebosh/jobs/$MOD
ln -s /var/litebosh/data/jobs/$MOD/$objdir/*.monitrc /var/litebosh/monit/job/${MOD}.monitrc
ln -s /var/litebosh/data/packages/$MOD/$objdir /var/litebosh/packages/$MOD

monit reload
sleep 3
./start.sh $MOD

echo -e "\e[1;32mDone.\e[0m"

