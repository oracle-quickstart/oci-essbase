/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

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
