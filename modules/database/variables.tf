## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_id" {}

variable "display_name_prefix" {}

variable "use_existing_db" {
  default = "false"
}

variable "existing_db_id" {
  default = ""
}

variable "db_name" {}

variable "db_admin_username" {
  default = "ADMIN"
}

variable "db_admin_password" {}

variable "license_model" {
  default = "LICENSE_INCLUDED"
}
