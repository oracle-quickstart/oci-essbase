## Copyright (c) 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

output "database_id" {
  value = join("", data.oci_database_database.database.*.id) 
}

output "pdb_name" {
  value = local.pdb_name
}

output "connect_string" {
  value = local.pdb_connect_string
}

