#!/bin/bash -e
#
# Copyright (c) 2019, 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

mkdir -p /var/log/essbase /var/run/essbase
chown opc:opc /var/log/essbase /var/run/essbase

log_file=/var/log/essbase/configure_volumes.out
touch $log_file
exec > >(tee -i $log_file) 2>&1

# Add trap to create exit status file
onComplete() {
  rv=$?
  umask 022
  echo $rv > /var/run/essbase/.configure_volumes.completed
}

trap onComplete EXIT

# Run this with a timeout of 20 mins
timeout -s SIGKILL 20m /bin/bash -e <<'EOF'

# Needed to connect to OCI APIs
export OCI_CLI_AUTH=instance_principal

# Metadata information
instance_metadata=$(oci-metadata -j)
compute_ocid=$(echo $instance_metadata | jq -r '.instance.id')
metadata_bucket_ns=$(echo $instance_metadata | jq -r ".instance.metadata.metadata_bucket_ns")
metadata_bucket_name=$(echo $instance_metadata | jq -r ".instance.metadata.metadata_bucket_name")

echo "Preparing volumes for running Essbase to ${compute_ocid}"

attach_volume() {
  local volume_ocid=$1

  # Wait until the metadata artifact is available where we expect it
  echo "Attaching volume ${volume_ocid}"
  local object_name="${compute_ocid}/${volume_ocid}.dat"
  local data_file="/etc/essbase/${volume_ocid}.dat"
  until $(oci os object get -ns ${metadata_bucket_ns} -bn ${metadata_bucket_name} --name ${object_name} --file ${data_file}); do
    echo "Waiting for ${volume_ocid} attachment metadata contents"
    sleep 5
  done

  mount=$(cat "$data_file" | jq -r ".path")
  iqn=$(cat "$data_file" | jq -r ".iqn")
  ipv4=$(cat "$data_file" | jq -r ".ipv4")
  port=$(cat "$data_file" | jq -r ".port")

  DEVICE_ID=ip-${ipv4}:${port}-iscsi-${iqn}-lun-1
  echo Connecting to iSCSI block volume ${DEVICE_ID}

  # Register and connect the iSCSI block volume
  iscsiadm -m node -o new -T ${iqn} -p ${ipv4}:${port}
  iscsiadm -m node -o update -T ${iqn} -n node.startup -v automatic
  iscsiadm -m node -T ${iqn} -p ${ipv4}:${port} -l

  # Wait for the device to be available
  while [[ ! -e "/dev/disk/by-path/${DEVICE_ID}" ]]; do
    echo Waiting for disk device /dev/disk/by-path/${DEVICE_ID} to be available
    sleep 1
  done

  # initialize partition and file system
  export HAS_PARTITION=$(partprobe -d -s /dev/disk/by-path/${DEVICE_ID} | wc -l)
  if [ $HAS_PARTITION -eq 0 ] ; then
    echo Creating partition
    (echo g; echo n; echo ''; echo ''; echo ''; echo w) | fdisk /dev/disk/by-path/${DEVICE_ID}

    while [[ ! -e "/dev/disk/by-path/${DEVICE_ID}-part1" ]]; do
      echo Waiting for disk device /dev/disk/by-path/${DEVICE_ID}-part1 to be available
      sleep 1
    done

    echo Formatting partition to xfs
    mkfs.xfs /dev/disk/by-path/${DEVICE_ID}-part1
  fi

  # mount the partition
  export UUID=$(/usr/sbin/blkid -s UUID -o value /dev/disk/by-path/${DEVICE_ID}-part1)
  echo Mounting iSCSI block volume ${DEVICE_ID} ${UUID} at ${mount}
  mkdir -p ${mount}
  echo "UUID=${UUID} ${mount} xfs defaults,_netdev,nofail 0 2" | sudo tee -a /etc/fstab
  mount -a

  # Update the permissions
  chown -R oracle:oracle ${mount}

  echo Complete mount of iSCSI block volume ${DEVICE_ID} to ${mount}
}

for volume_ocid in $(echo $instance_metadata | jq -r ".instance.metadata.volume_ocids[]"); do
  attach_volume ${volume_ocid}
done

EOF
