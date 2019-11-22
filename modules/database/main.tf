## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "autonomous_database" {
  count = var.use_existing_db ? 0 : 1

  admin_password           = chomp(var.db_admin_password)
  compartment_id           = var.compartment_id
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = var.db_name
  is_auto_scaling_enabled  = true

  whitelisted_ips          = [ var.vcn_id ]

  display_name  = "${var.display_name_prefix}-database"
  license_model = var.license_model

  timeouts {
    create = "30m"
  }
}

locals {
  database_id = var.use_existing_db ? var.existing_db_id : join(
    ",",
    oci_database_autonomous_database.autonomous_database.*.id,
  )
}

data "oci_database_autonomous_database" "autonomous_database" {
  autonomous_database_id = local.database_id
}

