## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "display_name" {
  value = "${join(",", oci_core_instance.bastion-instance.*.display_name)}"
}

output "id" {
  value = "${join(",", oci_core_instance.bastion-instance.*.id)}"
}

output "public_ip" {
  value = "${join(",", oci_core_instance.bastion-instance.*.public_ip)}"
}
