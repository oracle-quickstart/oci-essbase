## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "random_password" "bootstrap_password_1" {
  length  = 1
  upper   = true
  lower   = true
  number  = false
  special = false
}

resource "random_password" "bootstrap_password_2" {
  length           = 24
  upper            = true
  min_upper        = 2
  lower            = true
  min_lower        = 2
  number           = true
  min_numeric      = 2
  special          = true
  override_special = "#_$"
  min_special      = 2
}

locals {
  bootstrap_password = "${random_password.bootstrap_password_1.result}${random_password.bootstrap_password_2.result}"
}

resource "oci_database_autonomous_database" "autonomous_database" {
  admin_password           = local.bootstrap_password
  compartment_id           = var.compartment_id
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = var.db_name
  db_workload              = "OLTP"
  is_auto_scaling_enabled  = true

  display_name  = "${var.display_name_prefix}-database"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  license_model = var.license_model

  timeouts {
    create = "30m"
  }
}


module "backup-bucket" {

  source = "../bucket"

  compartment_id = var.compartment_id

  # Bucket name needs to match a predefined patter
  bucket_name = format("backup_%s", oci_database_autonomous_database.autonomous_database.db_name)

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}


locals {
  db_name             = oci_database_autonomous_database.autonomous_database.db_name
  is_dedicated        = oci_database_autonomous_database.autonomous_database.is_dedicated
  tns_alias           = lower(local.is_dedicated ? "${local.db_name}_low_tls" : "${local.db_name}_low")
  private_endpoint    = oci_database_autonomous_database.autonomous_database.private_endpoint
  private_endpoint_ip = oci_database_autonomous_database.autonomous_database.private_endpoint_ip
}
