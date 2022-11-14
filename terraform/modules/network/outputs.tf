## Copyright (c) 2019 - 2022, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "application_subnet_id" {
  value = oci_core_subnet.application.id
}

output "storage_subnet_id" {
  value = join("", oci_core_subnet.storage.*.id)
}

output "load_balancer_subnet_ids" {
  value = oci_core_subnet.load-balancer.*.id
}


