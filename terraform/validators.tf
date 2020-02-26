## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#
# Essbase Administrator Validation
#

locals {
  # Essbase admin username
  check_essbase_admin_username = "${replace(var.essbase_admin_username, "/^[a-zA-Z][a-zA-Z0-9]{4,127}$/", "0")}"

  # Essbase admin password
  check_pattern_essbase_admin_password = "${replace(var.essbase_admin_password, "/^[a-zA-Z][a-zA-Z0-9$#_]{7,29}$/", "0")}"
  check_number_essbase_admin_password  = "${replace(var.essbase_admin_password, "/^.*[0-9].*/", "0")}"
  check_essbase_admin_password         = "${local.check_pattern_essbase_admin_password}${local.check_number_essbase_admin_password}"
}

resource "null_resource" "invalid_essbase_admin_username" {
  count = "${local.check_essbase_admin_username != "0" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00001 - Essbase System Admin username should be alphanumeric and length should be between 5 and 128 characters.' && exit 1"
  }

}

resource "null_resource" "invalid_essbase_admin_password" {
  count = "${! var.use_kms_provisioning_key && (local.check_essbase_admin_password != "00") ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00002 - Essbase System Admin password should start with a letter and length should be between 8 and 30 characters, and should contain at least one number, and optionally, any number of the special characters ($ # _). For example, Ach1z0#d.' && exit 1"
  }

}

#
# Database validation
#
locals {
  # Database admin password
  check_pattern_db_admin_password = "${replace(var.db_admin_password, "/^[a-zA-Z][a-zA-Z0-9$#_]{11,29}$/", "0")}"
  check_number_db_admin_password  = "${replace(var.db_admin_password, "/^.*[0-9].*/", "0")}"
  check_special_db_admin_password = "${replace(var.db_admin_password, "/^.*[$#_].*/", "0")}"
  check_db_admin_password         = "${local.check_pattern_db_admin_password}${local.check_number_db_admin_password}${local.check_special_db_admin_password}"
}

resource "null_resource" "invalid_db_admin_password" {
  count = "${! var.use_kms_provisioning_key && (local.check_db_admin_password != "000") ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00003 - Database Admin password should start with a letter and length should be between 12 and 30 characters, and should contain at least one number, and at least one of the special characters ($ # _). For example, BEstr0ng_#12.' && exit 1"
  }
}

resource "null_resource" "missing_existing_db_id" {
  count = "${var.use_existing_db && var.existing_db_id == "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00004 - Missing Existing Database ID.' && exit 1"
  }
}

#
# IDCS Validation
#
resource "null_resource" "missing_idcs_client_id" {
  count = "${(var.security_mode == "idcs") && (var.idcs_client_id == "") ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00005 - Missing IDCS Application Client ID. The value has to set if using IDCS.' && exit 1"
  }
}

resource "null_resource" "missing_idcs_client_secret" {
  count = "${(var.security_mode == "idcs") && ! var.use_kms_provisioning_key && (var.idcs_client_secret == "") ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'ESSPROV-00006 - Missing IDCS Application Client Secret. The value has to set if using IDCS.' && exit 1"
  }
}

resource "null_resource" "missing_idcs_client_tenant" {
  count = "${(var.security_mode == "idcs") && (var.idcs_client_tenant == "") ? 1 : 0}"
  provisioner "local-exec" {
    command = "echo 'ESSPROV-00007 - Missing value for IDCS Instance GUID. The value has to set if using IDCS.' && exit 1"
  }
}

resource "null_resource" "missing_idcs_external_admin_username" {
  count = "${(var.security_mode == "idcs") && (var.idcs_external_admin_username == "") ? 1 : 0}"
  provisioner "local-exec" {
    command = "echo 'ESSPROV-00008 - Missing value for the IDCS Essbase Admin username. The value has to set if using IDCS.' && exit 1"
  }
}

resource "null_resource" "input_validation" {
  depends_on = [
    "null_resource.invalid_essbase_admin_username",
    "null_resource.invalid_essbase_admin_password",
    "null_resource.invalid_db_admin_password",
    "null_resource.missing_existing_db_id",
    "null_resource.missing_idcs_client_id",
    "null_resource.missing_idcs_client_secret",
    "null_resource.missing_idcs_client_tenant",
    "null_resource.missing_idcs_external_admin_username"
  ]

}

