## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "node_index" {
  value = oci_core_instance.essbase.metadata["node_index"]
}

output "id" {
  value = oci_core_instance.essbase.id
}

output "display_name" {
  value = oci_core_instance.essbase.display_name
}

output "hostname_label" {
  value = oci_core_instance.essbase.hostname_label
}

output "public_ip" {
  value = oci_core_instance.essbase.public_ip
}

output "private_ip" {
  value = oci_core_instance.essbase.private_ip
}

output "storage_ip" {
  value = var.enable_storage_vnic ? data.oci_core_vnic.storage_vnic[0].private_ip_address : null
}

output "listen_address" {
  value = oci_core_instance.essbase.hostname_label != null && oci_core_instance.essbase.hostname_label != "" ? oci_core_instance.essbase.hostname_label : oci_core_instance.essbase.private_ip
}

output "listen_port" {
  value = var.enable_embedded_proxy ? 443 : 9001
}

output "external_url" {
  value = local.external_url
}

