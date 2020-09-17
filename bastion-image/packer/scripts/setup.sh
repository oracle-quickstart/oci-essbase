#!/bin/bash -e
#
# Copyright (c) 2019, 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#

set +o history

# Update the firewall to enable masquerading and port forwarding
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o ens3 -j MASQUERADE
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ens3 -j ACCEPT

# Enable ip forwarding by setting sysctl kernel parameter
cat > /etc/sysctl.d/98-ip-forward.conf <<EOF
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/98-ip-forward.conf

# Disable root login
usermod --shell /usr/sbin/nologin root

# Harden SSHD
sed -i -e "s/#PermitRootLogin\syes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i -e "s/#PasswordAuthentication\syes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i -e "s/#HostbasedAuthentication\sno/HostbasedAuthentication no/g" /etc/ssh/sshd_config
sed -i -e "s/#MaxAuthTries\s6/MaxAuthTries 3/g" /etc/ssh/sshd_config
sed -i -e "s/#ClientAliveInterval\s0/ClientAliveInterval 300/g" /etc/ssh/sshd_config
sed -i -e "s/#ClientAliveCountMax\s3/ClientAliveCountMax 0/g" /etc/ssh/sshd_config

sed -i -e "s/X11Forwarding\syes/X11Forwarding no/g" /etc/ssh/sshd_config
sed -i -e "s/^#IgnoreRhosts\syes/IgnoreRhosts yes/g" /etc/ssh/sshd_config
systemctl restart sshd

# Cleanup 

# Run OCI cleanup utility
/usr/libexec/oci-image-cleanup -f

# Remove image backup
rm -rf /dev/shm/oci-utils

# Other cleanup
if [ -d /var/tmp ]; then
   rm -rf /var/tmp/*
fi
