## Copyright (c) 2019-2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "database_id" {
  value = oci_database_autonomous_database.autonomous_database.id
}

output "db_name" {
  value = local.db_name
}

output "compartment_id" {
  value = var.compartment_id
}

output "bootstrap_password" {
  value     = local.bootstrap_password
  sensitive = true
}

output "private_endpoint_mappings" {
  value = local.private_endpoint != null && local.private_endpoint != "" ? [{ "host" = local.private_endpoint, "ip_address" = local.private_endpoint_ip }] : []
}

output "private_endpoint" {
  value = oci_database_autonomous_database.autonomous_database.private_endpoint
}

output "private_ip" {
  value = oci_database_autonomous_database.autonomous_database.private_endpoint_ip
}

output "db_workload" {
  value = oci_database_autonomous_database.autonomous_database.db_workload
}
