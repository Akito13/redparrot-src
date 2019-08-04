#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

if [ "$EUID" -ne 0 ]
  then echo "Please run me as root."
  exit 1
fi

if [ $# -eq 2 ]; then
  serverip=$1
  serverport=$2
else
  echo "Please provide your desired server IP and port."
  echo "As root user, like this:"
  echo "./logdeploy.sh 10.15.10.23 515"
fi

apt-get install -y rsyslog > /dev/null

# Remove previous entries.
while read -r line
do
  [[ ! $line =~ "*.*            @@" ]] && echo "$line"
done </etc/rsyslog.conf > o
mv o /etc/rsyslog.conf

printf "\n*.*            @@$serverip:$serverport\n" >> /etc/rsyslog.conf

systemctl restart rsyslog

exit 0
