## Copyright (c) 2019-2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
  type        = string
}

variable "vcn_cidr_block" {
  type = string
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
  type        = string
}

variable "dns_label" {
  description = "DNS Label for the vcn"
  type        = string
}

// Application subnet
variable "application_subnet_cidr_block" {
  type = string
}

variable "instance_listen_port" {
  type = number
}

variable "create_private_application_subnet" {
  type    = bool
  default = true
}

// Storage subnet
variable "storage_subnet_cidr_block" {
  type    = string
  default = ""
}

variable "create_storage_subnet" {
  type    = bool
  default = false
}

// Load balancer subnet
variable "create_load_balancer_subnet" {
  type    = bool
  default = false
}

variable "load_balancer_subnet_cidr_block" {
  type = string
}

variable "create_private_load_balancer_subnet" {
  type    = bool
  default = false
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
