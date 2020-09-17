## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "enabled" {
  type = bool
  default = true
}

variable "compartment_id" {
  type = string
}

variable "display_name_prefix" {
  type = string
}

variable "database_id" {
  type    = string
  default = ""
}

variable "db_name" {
  type = string
}

variable "db_admin_username" {
  type    = string
  default = "ADMIN"
}

variable "db_admin_password_encrypted" {
  type = string
}

variable "kms_crypto_endpoint" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "license_model" {
  type    = string
  default = "LICENSE_INCLUDED"
}

variable "whitelisted_ips" {
  type    = list(string)
  default = null
}

// Tags
variable "freeform_tags" {
  type = map(string)
  default = null
}

variable "defined_tags" {
  type = map(string)
  default = null
}
