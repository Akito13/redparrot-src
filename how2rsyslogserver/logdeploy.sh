#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Checks privileges.
if [ "$EUID" -ne 0 ]
  then echo "Please run me as root."
  exit 1
fi

if [ $# -eq 2 ]; then
  serverip=$1
  serverport=$2
  config=/etc/rsyslog.conf
else
  echo "Please provide your desired server IP and port."
  echo "As root user, like this:"
  echo "./logdeploy.sh 10.15.10.23 515"
  exit 1
fi

# Install dependency. Only errors are visible.
apt-get install -y rsyslog > /dev/null

# Remove previous entries.
while read -r line
do
  [[ ! $line =~ "*.*            @@" ]] && echo "$line"
done <${config} > o
mv o ${config}

# Remove redundant \n.
truncate -cs -1 ${config};
# Append updated server address.
printf "*.*            @@$serverip:$serverport\n" >> ${config}

# Leaves only a single newline at EOF.
while [[ \
        $(tail -n 2 ${config} | head -n 1) == "" && \
        $(tail -n 1 ${config}) == "" \
      ]]; do
  truncate -cs -1 ${config};
done;

systemctl restart rsyslog

exit 0
