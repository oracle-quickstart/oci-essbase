## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

output "database_id" {
  value = local.use_existing_db ? join("", data.oci_database_autonomous_database.autonomous_database.*.id) : join("", oci_database_autonomous_database.autonomous_database.*.id)
}

output "db_name" {
  value = local.db_name
}

output "compartment_id" {
  value = local.use_existing_db ? join("", data.oci_database_autonomous_database.autonomous_database.*.compartment_id) : join("", oci_database_autonomous_database.autonomous_database.*.compartment_id)
}

output "tns_alias" {
  value = local.tns_alias
}
