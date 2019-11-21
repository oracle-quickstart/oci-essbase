/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
output "subnet_id" {
  value = "${data.oci_core_subnet.application.id}"
}

output "is_private_subnet" {
  value = "${data.oci_core_subnet.application.prohibit_public_ip_on_vnic ? 1 : 0}"
}
