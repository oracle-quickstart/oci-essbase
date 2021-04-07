## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "subnet_ids" {
  value = data.oci_core_subnet.load-balancer.*.id
}

output "subnet_count" {
  value = var.enabled ? local.lb_subnet_count : 0
}

output "private_subnet" {
  value = false
}

