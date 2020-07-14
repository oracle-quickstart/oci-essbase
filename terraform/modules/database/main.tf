## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  use_existing_db = var.database_id != ""
}

data "oci_identity_compartment" "db_compartment" {
  count      = var.enabled && !local.use_existing_db ? 1 : 0
  id         = var.compartment_id
}

data "oci_kms_decrypted_data" "decrypted_db_admin_password" {
  count           = var.enabled && !local.use_existing_db ? 1 : 0
  ciphertext      = var.db_admin_password_encrypted
  crypto_endpoint = var.kms_crypto_endpoint
  key_id          = var.kms_key_id
}

resource "oci_database_autonomous_database" "autonomous_database" {
  count                    = var.enabled && !local.use_existing_db ? 1 : 0
  admin_password           = chomp(base64decode(join("", data.oci_kms_decrypted_data.decrypted_db_admin_password.*.plaintext)))
  compartment_id           = join("", data.oci_identity_compartment.db_compartment.*.id)
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = var.db_name
  db_version               = "19c"
  db_workload              = "OLTP"
  is_auto_scaling_enabled  = true

  whitelisted_ips = var.whitelisted_ips

  display_name  = "${var.display_name_prefix}-database"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  license_model = var.license_model

  timeouts {
    create = "30m"
  }
}

data "oci_database_autonomous_database" "autonomous_database" {
  count                  = var.enabled && local.use_existing_db ? 1 : 0
  autonomous_database_id = var.database_id
}

locals {
  db_name = join("", concat(data.oci_database_autonomous_database.autonomous_database.*.db_name, oci_database_autonomous_database.autonomous_database.*.db_name))
  is_dedicated_values = compact(concat(data.oci_database_autonomous_database.autonomous_database.*.is_dedicated, oci_database_autonomous_database.autonomous_database.*.is_dedicated))
  is_dedicated = var.enabled && length(local.is_dedicated_values) > 0 ? tobool(join("", local.is_dedicated_values)) : false
  tns_alias = var.enabled ? lower(local.is_dedicated ? "${local.db_name}_low_tls" : "${local.db_name}_low") : ""
}
