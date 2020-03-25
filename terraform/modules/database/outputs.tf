## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "database_id" {
  value = "${data.oci_database_autonomous_database.autonomous_database.id}"
}

output "db_name" {
  value = "${data.oci_database_autonomous_database.autonomous_database.db_name}"
}
