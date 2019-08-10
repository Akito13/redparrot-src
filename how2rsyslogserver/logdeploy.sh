#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

## Requires root permissions.
## Takes IPv4 address + port as 2 arguments.
## Installs `rsyslog` package from standard APT repository.
## Replaces old syslog server address with the given one.
## Prettifies `rsyslog.conf` by removing redundant
## newlines at EOF.


if [[ "$EUID" != 0 ]]; then
  ## Check your privilege.
  echo "Please run me as root.";
  exit 1;
elif                                                              \
     [[ $# == 2 ]]                                                \
&&                                                                \
     [[ $2 =~ ^[0-9]{2,5}$ ]]                                     \
&&                                                                \
     [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] \
||                                                                \
     [[ $1 =~ ^[0-9A-Za-z]*\.?[0-9A-Za-z]+\.[A-Za-z]+$ ]];
then
  serverip=$1
  serverport=$2
  config=/etc/rsyslog.conf
  apt-get install -y rsyslog > /dev/null
else
  echo "Please provide your desired server IP and port."
  echo "As root user, like this:"
  echo "$0 10.15.10.23 515"
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

while read -r line; do
  ## Remove previous entries.
  [[ ! $line =~ "*.*            @@" ]] && echo "$line"
done <${config} > o
mv o ${config}

# Append updated server address.
truncEmpty
printf "\n"                                     >> ${config}
printf "*.*            @@$serverip:$serverport" >> ${config}
printf "\n"                                     >> ${config}
truncEmpty

systemctl restart rsyslog

exit 0
