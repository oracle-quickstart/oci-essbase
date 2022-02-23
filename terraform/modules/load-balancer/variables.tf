## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the loadbalancer VCN is created."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ids for the load balancer."
  type        = list(string)
}

variable "backend_nodes" {
  description = "The target Essbase backend nodes."
  type = list(object({
    ip_address = string
    port       = number
  }))
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

variable "is_private" {
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
