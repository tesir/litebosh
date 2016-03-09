#!/bin/bash

function show_status() {
  curl -s "http://admin:admin123@$1:2822/_status" > .curl
  base=`grep -n "$2" .curl | awk -F ":" '{print $1}'`

  status="None"
  time="-"
  mem="-"
  cpu="-"

  if test -n "$base"; then
    colr="32m"
    status_line=$[base+1]
    status=`cat .curl | awk -F "\t" 'NR=='${status_line}'{print substr($1, 37, 16)}'`
    if [ "$status" == "Running" ]; then
      time_line=$[base+8]
      mem_line=$[base+11]
      cpu_line=$[base+15]
      time=`cat .curl | awk -F "\t" 'NR=='${time_line}'{print substr($1, 37, 16)}'`
      mem=`cat .curl | awk -F "\t" 'NR=='${mem_line}'{print substr($1, 37, 10)}'` 
      cpu=`cat .curl | awk -F "\t" 'NR=='${cpu_line}'{print substr($1, 37, 10)}'`
    else
      colr="33m"
    fi
  else
    colr="37m"
  fi
  printf "\e[$colr%-20s%-16s%-16s%-14s%-12s%-10s\e[0m\n" "$2" "$1" "$status" "$time" "$mem" "$cpu"
}

echo -e '\033[47;30;1mMODULE              HOST            STATUS          UPTIME        MEMORY      CPU       \033[0m'

while read line
do
  if [[ $line =~ ^M ]]; then
    IP=`echo $line | awk {'print $3'}`
    MOD=`echo $line | awk {'print $2'}`
    show_status $IP $MOD
  fi

done < config
