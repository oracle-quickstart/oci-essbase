#!/bin/bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
#

# Trap for script exit
onComplete() {
  rv=$?
  echo "Oracle Essbase VM initialization finished with error code $rv"
  #sudo rm -rf /tmp/essbase_config.json
}

trap onComplete EXIT
set -e

# Read version file
image_version=`cat /etc/essbase/image_version.txt`
echo Using image ${image_version}

# Update the global env settings
sudo /bin/bash <<EOF
echo Updating the global env settings for this instance
echo 'DOMAIN_HOME=/u01/config/domains/essbase_domain' >> /etc/essbase/env
echo 'ARBORPATH=/u01/data/essbase' >> /etc/essbase/env
EOF

# Wait for 60 minutes for Essbase configuration to complete
# This is run as the oracle user
timeout -s SIGKILL 60m sudo -i -u oracle /bin/bash -e <<'EOF'

# Run the configuration script as oracle user
# This is needed to be done to make sure limits are applied
echo Running configuration script as oracle user
exec /u01/vmtools/configure.sh
EOF

# Run the post configuration script as root
sudo /bin/bash -e <<EOF

# Run the post configuration script
# Move the demo certs and enable in ssl.conf
echo Processing certificate files
cp /etc/essbase/demo-ca.crt   /etc/pki/tls/certs
cp /etc/essbase/demo-cert.crt /etc/pki/tls/certs
cp /etc/essbase/demo-cert.key /etc/pki/tls/private
sed -i 's|SSLCertificateFile .*$|SSLCertificateFile /etc/pki/tls/certs/demo-cert.crt|g' /etc/httpd/conf.d/ssl.conf
sed -i 's|SSLCertificateKeyFile .*$|SSLCertificateKeyFile /etc/pki/tls/private/demo-cert.key|g' /etc/httpd/conf.d/ssl.conf

# Run post configuration
/u01/vmtools/post-configure.sh

# Update the essbase service to include the mount information for reboot
sed -i 's|#RequiresMountsFor=.*$|RequiresMountsFor=/u01/config /u01/data|g' /etc/systemd/system/essbase.service
systemctl daemon-reload
EOF
