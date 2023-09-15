## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type = string
}

variable "display_name_prefix" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_admin_username" {
  type    = string
  default = "ADMIN"
}

variable "db_admin_password_id" {
  type = string
}

variable "license_model" {
  type    = string
  default = "LICENSE_INCLUDED"
}

variable "subnet_id" {
  type    = string
  default = null
  
}

variable "nsg_ids" {
  type    = list(string)
  default = null
  
}

variable "create_secure_db" {
  type    = bool
  default = false
}

variable "db_workload" {
  type    = string
  default = "Autonomous Transaction Processing"
}

variable "whitelisted_ips" {
  type    = list(string)
  default = null
}

variable "vcn_id" {
  type = string
  default = null
}


// Tags
variable "freeform_tags" {
  type    = map(string)
  default = null
}

variable "defined_tags" {
  type    = map(string)
  default = null
}
