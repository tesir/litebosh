#!/bin/bash

litebosh_app_dir=/var/litebosh

yum install -y monit

rm -rf /etc/monitrc

cat <<EOF > /etc/monitrc
set daemon 10
set logfile /var/litebosh/monit/monit.log
set mmonit http://172.16.4.5:2812/monitcollector/collector
set httpd port 2822
  allow admin:admin123
include /var/litebosh/monit/*.monitrc
include /var/litebosh/monit/job/*.monitrc
EOF
chmod 0700 /etc/monitrc
mkdir -p $litebosh_app_dir/monit/job
touch $litebosh_app_dir/monit/empty.monitrc
