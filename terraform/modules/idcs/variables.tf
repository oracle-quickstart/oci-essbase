## Copyright (c) 2019-2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "idcs_tenant" {
  type    = string
  default = ""

  validation {
    condition     = var.idcs_tenant != ""
    error_message = "ESSPROV-00007 - Missing value for IDCS Instance GUID. The value has to set if using IDCS."
  }
}

variable "idcs_client_id" {
  type    = string
  default = ""

  validation {
    condition     = var.idcs_client_id != ""
    error_message = "ESSPROV-00005 - Missing IDCS Application Client ID. The value has to set if using IDCS."
  }
}

variable "idcs_client_secret_id" {
  type    = string
  default = ""

  validation {
    condition     = can(regex("^ocid1\\.vaultsecret\\.[a-zA-Z0-9\\.\\-\\_]+$", var.idcs_client_secret_id))
    error_message = "ESSPROV-00006 - Invalid IDCS Application Client Secret. The value has to set if using IDCS."
  }
}

variable "idcs_external_admin_username" {
  type    = string
  default = ""

  validation {
    condition     = var.idcs_external_admin_username != ""
    error_message = "ESSPROV-00008 - Missing value for the IDCS Essbase Admin username. The value has to set if using IDCS."
  }
}

