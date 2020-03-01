## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_ids" {
  value = data.oci_core_subnet.load-balancer.*.id
}

output "subnet_count" {
  value = var.enabled ? local.lb_subnet_count : 0
}

