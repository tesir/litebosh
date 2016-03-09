#!/bin/bash

DEPOLY_REPO=http://172.16.4.5:8765

rm -rf /opt/litebosh-release

curl -s $DEPOLY_REPO/litebosh-release.tar.gz | tar xzf - -C /opt/

/opt/litebosh-release/install.sh $@


