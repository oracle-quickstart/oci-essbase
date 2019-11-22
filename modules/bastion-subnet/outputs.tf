## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_id" {
  value = join(",", data.oci_core_subnet.bastion.*.id)
}

