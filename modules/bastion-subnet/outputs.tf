/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
output "subnet_id" {
  value = "${join(",", data.oci_core_subnet.bastion.*.id)}"
}
