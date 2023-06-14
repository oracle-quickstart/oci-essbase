## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "existing_vcn_id" {
  type = string
}

variable "existing_application_subnet_id" {
  type = string
}

variable "existing_storage_subnet_id" {
  type    = string
  default = ""
}

variable "existing_load_balancer_subnet_ids" {
  type    = list(string)
  default = []
}


