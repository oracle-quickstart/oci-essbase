#!/bin/bash -e
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
#

# Add trap to create exit status file
sudo rm -rf /tmp/.prepare_vm.completed

onComplete() {
  rv=$?
  umask 022
  echo $rv > /tmp/.prepare_vm.completed
}

trap onComplete EXIT

echo "Preparing virtual machine for running Essbase"

# runtime metadata
data_volume_device=$(oci-metadata -g /instance/metadata/data_volume_device --value-only)
config_volume_device=$(oci-metadata -g /instance/metadata/config_volume_device --value-only)
system_mode=$(oci-metadata -g /instance/metadata/system_mode --value-only)

# Setup when system mode is dev
if [ "${system_mode}" == "dev" ]; then

  # Update the firewall ports
  echo Enabling firewall port 7001
  firewall-offline-cmd --add-port=7001/tcp --zone=public
  systemctl restart firewalld

fi

# setup the config volume
echo Config volume is enabled at ${config_volume_device}

# Wait for the device to be available
while [[ ! -e ${config_volume_device} ]]; do
   echo Waiting for config volume to ${config_volume_device} to be available
   sleep 1
done

echo Config volume ${config_volume_device} is attached

has_partition=$(partprobe -d -s ${config_volume_device} | wc -l)
if [ $has_partition -eq 0 ]; then
  echo Creating partition on config volume device
  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | fdisk ${config_volume_device}
  while [[ ! -e ${config_volume_device}1 ]] ; do sleep 1; done
  mkfs.xfs ${config_volume_device}1
fi

rm -rf /u01/config
mkdir -p /u01/config
echo "${config_volume_device}1 /u01/config xfs defaults,_netdev,nofail 0 2" | tee -a /etc/fstab
mount -a
chown -R oracle:oracle /u01/config

echo Mounted config volume at /u01/config

# setup the data volume
echo Data volume is enabled at ${data_volume_device}

# Wait for the device to be available
while [[ ! -e ${data_volume_device} ]]; do
   echo Waiting for data volume to ${data_volume_device} to be available
   sleep 1
done

echo Data volume ${data_volume_device} is attached

has_partition=$(partprobe -d -s ${data_volume_device} | wc -l)
if [ $has_partition -eq 0 ]; then
  echo Creating partition on data volume device
  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | fdisk ${data_volume_device}
  while [[ ! -e ${data_volume_device}1 ]] ; do sleep 1; done
  mkfs.xfs ${data_volume_device}1
fi

rm -rf /u01/data
mkdir -p /u01/data
echo "${data_volume_device}1 /u01/data xfs defaults,_netdev,nofail 0 2" | tee -a /etc/fstab
mount -a
chown -R oracle:oracle /u01/data

echo Mounted data volume at /u01/data

# Adjust the system limits if possible
if [ -e /u01/vmtools/adjust-limits.sh ]; then
  /u01/vmtools/adjust-limits.sh
fi

