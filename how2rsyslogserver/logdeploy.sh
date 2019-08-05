#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Checks your privileges.
if [ "$EUID" -ne 0 ]; then
  echo "Please run me as root."
  exit 1
fi;

if [ $# -eq 2 ]; then
  serverip=$1
  serverport=$2
  config=/etc/rsyslog.conf
else
  echo "Please provide your desired server IP and port."
  echo "As root user, like this:"
  echo "./logdeploy.sh 10.15.10.23 515"
  exit 1
fi;

truncEmpty() {
  ## Remove redundant newlines at EOF. Leave only a single one.
  if [ -s ${config} ]; then
    while [[ $(tail -n 1 ${config}) == "" ]]; do
      truncate -cs -1 ${config};
    done;
  else
    echo "File does not exist or is empty."
    exit 1
  fi;
}

# Install dependency. Show only errors.
apt-get install -y rsyslog > /dev/null

# Remove previous entries.
while read -r line
do
  [[ ! $line =~ "*.*            @@" ]] && echo "$line"
done <${config} > o
mv o ${config}

# Append updated server address.
truncEmpty
printf "\n" >> ${config}
printf "*.*            @@$serverip:$serverport" >> ${config}
printf "\n" >> ${config}
truncEmpty

systemctl restart rsyslog

exit 0
