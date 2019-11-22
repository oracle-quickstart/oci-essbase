## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the subnet is created."
  type        = string
}

variable "use_existing_subnet" {
  type    = bool
  default = false
}

variable "existing_subnet_id" {
  type    = string
  default = ""
}

variable "vcn_id" {
  type = string
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "dhcp_options_id" {
  type = string
}

variable "route_table_id" {
  type = string
}

variable "create_private_subnet" {
  type    = bool
  default = false
}

