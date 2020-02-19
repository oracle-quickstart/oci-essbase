#!/bin/bash
#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
#

endtime=$(date -ud "10 minute" +%s)
while [[ $(date -u +%s) -le $endtime ]]
do
  if [ -e "/var/run/essbase/.configure_essbase.completed" ]; then
     break
  fi

  if [ -e "/var/run/essbase/configure_essbase.pid" ]; then
     break
  fi

  if [ -e "/var/log/essbase/configure_essbase.out" ]; then
     break
  fi

  echo Waiting for configure_essbase script to start...
  sleep 5
done


configurepid=$(cat /var/run/essbase/configure_essbase.pid 2> /dev/null || echo -1)
if [ "$configurepid" -ne "-1" ]; then
  echo pid for configure process is $configurepid
  tail -f -n +1 --pid=$configurepid /var/log/essbase/configure_essbase.out
else
  cat /var/log/essbase/configure_essbase.out 2> /dev/null
fi

while [[ ! -e /var/run/essbase/.configure_essbase.completed ]]
do
  sleep 5
done

rv=$(cat /var/run/essbase/.configure_essbase.completed)
if [ "$rv" -ne "0" ]; then
   exit $rv
fi

