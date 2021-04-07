## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "database_id" {
  value = local.use_existing_db ? join("", compact(data.oci_database_autonomous_database.autonomous_database.*.id)) : join("", compact(oci_database_autonomous_database.autonomous_database.*.id))
}

output "db_name" {
  value = local.db_name
}

output "compartment_id" {
  value = local.use_existing_db ? join("", compact(data.oci_database_autonomous_database.autonomous_database.*.compartment_id)) : join("", compact(oci_database_autonomous_database.autonomous_database.*.compartment_id))
}

output "tns_alias" {
  value = local.tns_alias
}

output "private_endpoint" {
  value = local.private_endpoint
}

output "private_endpoint_ip" {
  value = local.private_endpoint_ip
}

