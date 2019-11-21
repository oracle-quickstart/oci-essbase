## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
}

variable "use_existing_vcn" {
  default = false
}

variable "existing_vcn_id" {
  default = ""
}

variable "vcn_cidr" {
  default = "10.1.0.0/16"
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "dns_label" {
  description = "DNS Label for the vcn"
}

variable "enable_internet_gateway" {
  default = true
}

variable "enable_nat_gateway" {
  default = false
}
