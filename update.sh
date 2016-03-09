#!/bin/bash

REPO_PATH=`grep CONFIG_REPO_LOCAL ./config |awk -F "=" '{print $2}'`

tar czf $REPO_PATH/litebosh-release.tar.gz ./litebosh-release
