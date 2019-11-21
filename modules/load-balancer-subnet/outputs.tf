/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
output "subnet_ids" {
  value = ["${data.oci_core_subnet.load-balancer.*.id}"]
}

output "subnet_count" {
  value = "${var.enabled ? local.lb_subnet_count : 0}"
}
