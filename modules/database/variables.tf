## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "vcn_id" {
  type = string
  default = ""
}

variable "compartment_id" {
  type = string
}

variable "display_name_prefix" {
  type = string
}

variable "use_existing_db" {
  type    = bool
  default = false
}

variable "existing_db_id" {
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

variable "db_admin_password" {
  type = string
}

variable "license_model" {
  type = string
}

