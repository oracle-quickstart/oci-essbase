## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

output "node_name" {
  value = oci_core_instance.essbase.display_name
}

output "node_id" {
  value = oci_core_instance.essbase.id
}

output "node_domain_name" {
  value = local.node_domain_name
}

output "node_public_ip" {
  value = oci_core_instance.essbase.public_ip
}

output "node_private_ip" {
  value = oci_core_instance.essbase.private_ip
}

output "rcu_schema_prefix" {
  value = var.rcu_schema_prefix
}

output "external_url" {
  value = local.external_url
}

