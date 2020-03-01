## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "id" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.bastion.*.id) : join("", oci_core_subnet.bastion.*.id)
}

output "cidr_block" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.bastion.*.cidr_block) : join("", oci_core_subnet.bastion.*.cidr_block)
}

