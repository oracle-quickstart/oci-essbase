#!/bin/bash
#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
#

# Add trap to create exit status file
onComplete() {
  rv=$?
  umask 022
  echo $rv > /var/run/essbase/.configure_essbase.completed
}

trap onComplete EXIT

scriptpid=$$
echo $scriptpid > /var/run/essbase/configure_essbase.pid

# Display version information
/u01/vmtools/version.sh

# Wait until flag has been created
echo Waiting for configure_volumes script to complete
endtime=$(date -ud "10 minute" +%s)

while [[ $(date -u +%s) -le $endtime ]]
do
  if [ -e "/var/run/essbase/.configure_volumes.completed" ]; then
     break
  fi

  echo Waiting for configure_volumes script to complete...
  sleep 20
done

if [ ! -e "/var/run/essbase/.configure_volumes.completed" ]; then
  echo "Timeout waiting for configure_volumes script to complete"
  exit 124
fi

rv=$(cat /var/run/essbase/.configure_volumes.completed)
if [ "$rv" -ne "0" ]; then
   exit $rv
fi

sudo /bin/bash -e <<EOF

# Update the essbase service configuration file for the mounts, but do not start
sed -i '/^After=.*/a RequiresMountsFor=/u01/config /u01/data' /etc/systemd/system/essbase.service
systemctl daemon-reload

EOF

echo Running vm configuration script
timeout -s SIGKILL 60m /u01/vmtools/configure.sh

