#!/bin/bash
if [ $# -lt 1 ] ; then
    echo -e "\e[1;33m!!!USEAGE: release.sh [VERSION]\e[0m"
    exit 1
fi

VER=$1
KEY="liteboshblob"
RELEASE_FILE=./litebosh-release/releases/litebosh-$VER

if [ -f $RELEASE_FILE ]; then
  echo -e "\e[1;31m!!!Version $VER is already released!\e[0m"
  exit 1
fi

echo -e "\e[1;33mNow begin release for version ${VER}...\e[0m"

MODULE_LIST=`grep ARTIFACTS_LIST ./config |awk -F "=" '{print $2}'`
LOCAL_REPO=`grep CONFIG_REPO_LOCAL ./config |awk -F "=" '{print $2}'`

echo "#Release for verion $VER" > $RELEASE_FILE

for mod in $MODULE_LIST
do
  sha1=`cat $LOCAL_REPO/release/last/$mod | openssl sha1 -hmac $KEY | awk -F "= " '{print $2}'`
  objfile=$LOCAL_REPO/release/$sha1

  if [ -f $objfile ]; then
    echo -e "\e[1;33mWARN: $mod not changed after last released!\e[0m" 
  else
    cp $LOCAL_REPO/release/last/$mod $objfile
    echo -e "\e[1;32m$mod released, SHA1 is $sha1\e[0m"
  fi

  depend=""
  if [ $mod == "web-login" ];then
    depend="login"
  fi

  if [ $mod == "web-middle" ];then
    depend="evenstone"
  fi

  if [ $mod == "web-back" ];then
    depend="solrock"
  fi

  printf "%-20s%-45s%s\n" "$mod" "$sha1" "$depend" >> $RELEASE_FILE
done

echo -e "\e[1;32mRelease succeed. Please check release file:\e[0m"
cat $RELEASE_FILE

echo -e "\e[1;33mUpdate to repo...\e[0m"
./update.sh
echo -e "\e[1;32mDone\e[0m"
