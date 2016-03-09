#!/bin/bash

if [ $# -lt 1 ] ; then
    echo -e "\e[1;33m!!!USEAGE: clean.sh {module}\e[0m"
    exit 1
fi

MOD=$1

if ( monit summary | grep -q "$MOD"); then
  ./stop.sh $MOD
fi

rm -rf /var/litebosh/data/*/$MOD
rm -rf /var/litebosh/jobs/$MOD
rm -rf /var/litebosh/monit/job/${MOD}.monitrc
rm -rf /var/litebosh/packages/$MOD
rm -rf /var/litebosh/sys/run/$MOD
rm -rf /var/litebosh/sys/log/${MOD}

monit reload

sleep 2
