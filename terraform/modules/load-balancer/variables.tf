## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "enabled" {
  type    = bool
  default = true
}

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the loadbalancer VCN is created."
  type        = string
}

variable "subnet_count" {
  type = number
}

variable "subnet_ids" {
  description = "The subnet id for the Essbase node."
  type        = list(string)
}

variable "node_count" {
  description = "The number of nodes in the cluster...workaround for count issue"
  type        = number
}

variable "node_ip_addresses" {
  description = "The target ip addresses of the Essbase nodes"
  type        = list(string)
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
  type        = string
}

variable "shape" {
  description = "Shape of the load balancer"
  type        = string
  default     = "100Mbps"
}

variable "idle_timeout" {
  type    = number
  default = 300
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
