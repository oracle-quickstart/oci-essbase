## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "id" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.application.*.id) : join("", oci_core_subnet.application.*.id)
}

locals {
  af = [ false ]
  actual = compact(concat(data.oci_core_subnet.application.*.prohibit_public_ip_on_vnic, oci_core_subnet.application.*.prohibit_public_ip_on_vnic, local.af ))
}

output "is_private_subnet" {
  value = element(local.actual, 0)
}

output "cidr_block" {
  value = local.use_existing_subnet ? join("", data.oci_core_subnet.application.*.cidr_block) : join("", oci_core_subnet.application.*.cidr_block)
}
