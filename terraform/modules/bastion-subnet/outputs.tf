## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "id" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.bastion.*.id) : join("", oci_core_subnet.bastion.*.id)
}

output "cidr_block" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.bastion.*.cidr_block) : join("", oci_core_subnet.bastion.*.cidr_block)
}

