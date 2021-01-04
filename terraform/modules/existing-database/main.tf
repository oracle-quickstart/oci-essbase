## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_database_autonomous_database" "autonomous_database" {
  autonomous_database_id = var.database_id
}

locals {
  db_name             = data.oci_database_autonomous_database.autonomous_database.db_name
  is_dedicated        = data.oci_database_autonomous_database.autonomous_database.is_dedicated
  tns_alias           = lower(local.is_dedicated ? "${local.db_name}_low_tls" : "${local.db_name}_low")
  private_endpoint    = data.oci_database_autonomous_database.autonomous_database.private_endpoint
  private_endpoint_ip = data.oci_database_autonomous_database.autonomous_database.private_endpoint_ip
}
