/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
# Output the private and public IPs of the instance

output "display_name" {
  value = "${join(",", oci_core_instance.bastion-instance.*.display_name)}"
}

output "id" {
  value = "${join(",", oci_core_instance.bastion-instance.*.id)}"
}

output "public_ip" {
  value = "${join(",", oci_core_instance.bastion-instance.*.public_ip)}"
}
