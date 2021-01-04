## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vcn_id" {
  value = data.oci_core_vcn.vcn.id
}

output "application_subnet_id" {
  value = data.oci_core_subnet.application.id
}

output "load_balancer_subnet_ids" {
  value = data.oci_core_subnet.load-balancer.*.id
}

output "bastion_subnet_id" {
  value = join("", data.oci_core_subnet.bastion.*.id)
}

