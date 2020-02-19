## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
  type        = string
}

variable "existing_vcn_id" {
  type    = string
  default = ""
}

variable "vcn_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
  type        = string
}

variable "dns_label" {
  description = "DNS Label for the vcn"
  type        = string
}

variable "enable_internet_gateway" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
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
