## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "database_id" {
  value = local.use_existing_db ? join("", data.oci_database_autonomous_database.autonomous_database.*.id) : join("", oci_database_autonomous_database.autonomous_database.*.id)
}

output "db_name" {
  value = local.use_existing_db ? join("", data.oci_database_autonomous_database.autonomous_database.*.db_name) : join("", oci_database_autonomous_database.autonomous_database.*.db_name)
}

output "compartment_id" {
  value = local.use_existing_db ? join("", data.oci_database_autonomous_database.autonomous_database.*.compartment_id) : join("", oci_database_autonomous_database.autonomous_database.*.compartment_id)
}

