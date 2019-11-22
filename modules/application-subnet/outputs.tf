## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_id" {
  value = data.oci_core_subnet.application.id
}

output "is_private_subnet" {
  value = data.oci_core_subnet.application.prohibit_public_ip_on_vnic ? 1 : 0
}

