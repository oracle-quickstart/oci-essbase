## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

# Output the private and public IPs of the instance

output "display_name" {
  value = join(",", oci_core_instance.bastion-instance.*.display_name)
}

output "id" {
  value = join(",", oci_core_instance.bastion-instance.*.id)
}

output "public_ip" {
  value = join(",", oci_core_instance.bastion-instance.*.public_ip)
}

