/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

output "database_id" {
  value = "${data.oci_database_autonomous_database.autonomous_database.id}"
}

output "db_name" {
  value = "${data.oci_database_autonomous_database.autonomous_database.db_name}"
}
