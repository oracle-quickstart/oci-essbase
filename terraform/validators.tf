## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#
# Essbase Administrator Validation
#

locals {
  # Essbase admin username
  check_essbase_admin_username = "${replace(var.essbase_admin_username,"/^[a-zA-Z][a-zA-Z0-9]{4,127}$/", "0")}"

  # Essbase admin password
  check_pattern_essbase_admin_password = "${replace(var.essbase_admin_password,"/^[a-zA-Z][a-zA-Z0-9$#_]{7,29}$/", "0")}"
  check_number_essbase_admin_password  = "${replace(var.essbase_admin_password,"/^.*[0-9].*/", "0")}"
  check_essbase_admin_password         = "${local.check_pattern_essbase_admin_password}${local.check_number_essbase_admin_password}"
}

resource "null_resource" "invalid_essbase_admin_username" {
  count                                                                                                                                = "${local.check_essbase_admin_username != "0" ? 1 : 0}"
  "ESSBASE-ERROR: Essbase Administrator admin user provided should be alphanumeric and length should be between 5 and 128 characters." = true
}

resource "null_resource" "invalid_essbase_admin_password" {
  count                                                                                                                                                                                                                                                              = "${!var.use_kms_provisioning_key && (local.check_essbase_admin_password != "00") ? 1 : 0}"
  "ESSBASE-ERROR: Essbase Administrator password provided should start with a letter and length should be between 8 and 30 characters, and should contain at least one number, and optionally, any number of the special characters ($ # _). For example, Ach1z0#d." = true
}

#
# Database validation
#
locals {
  # Database admin password
  check_pattern_db_admin_password = "${replace(var.db_admin_password,"/^[a-zA-Z][a-zA-Z0-9$#_]{11,29}$/", "0")}"
  check_number_db_admin_password  = "${replace(var.db_admin_password,"/^.*[0-9].*/", "0")}"
  check_special_db_admin_password = "${replace(var.db_admin_password,"/^.*[$#_].*/", "0")}"
  check_db_admin_password         = "${local.check_pattern_db_admin_password}${local.check_number_db_admin_password}${local.check_special_db_admin_password}"
}

resource "null_resource" "invalid_db_admin_password" {
  count                                                                                                                                                                                                                                                  = "${!var.use_kms_provisioning_key && (local.check_db_admin_password != "000") ? 1 : 0}"
  "ESSBASE-ERROR: Database Admin password provided should start with a letter and length should be between 12 and 30 characters, and should contain at least one number, and at least one of the special characters ($ # _). For example, BEstr0ng_#12." = true
}

#
# IDCS Validation
#
resource "null_resource" "missing_idcs_client_id" {
  count                                                                                                     = "${(var.security_mode == "idcs") && (var.idcs_client_id == "") ? 1 : 0 }"
  "ESSBASE-ERROR: The value for idcs_client_id has not been specified. The value has to set if using IDCS." = true
}

resource "null_resource" "missing_idcs_client_secret" {
  count                                                                                                         = "${(var.security_mode == "idcs") && !var.use_kms_provisioning_key && (var.idcs_client_secret == "") ? 1 : 0 }"
  "ESSBASE-ERROR: The value for idcs_client_secret has not been specified. The value has to set if using IDCS." = true
}

resource "null_resource" "missing_idcs_client_tenant" {
  count                                                                                                         = "${(var.security_mode == "idcs") && (var.idcs_client_tenant == "") ? 1 : 0 }"
  "ESSBASE-ERROR: The value for idcs_client_tenant has not been specified. The value has to set if using IDCS." = true
}

resource "null_resource" "missing_idcs_external_admin_username" {
  count                                                                                                                   = "${(var.security_mode == "idcs") && (var.idcs_external_admin_username == "") ? 1 : 0 }"
  "ESSBASE-ERROR: The value for idcs_external_admin_username has not been specified. The value has to set if using IDCS." = true
}
