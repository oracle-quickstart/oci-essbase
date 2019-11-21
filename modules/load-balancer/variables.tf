/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

variable "enabled" {
  default = true
}

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the loadbalancer VCN is created."
}

variable "subnet_count" {}

variable "subnet_ids" {
  description = "The subnet id for the Essbase node."
  type        = "list"
}

variable "node_count" {
  description = "The number of nodes in the cluster...workaround for count issue"
}

variable "node_ip_addresses" {
  description = "The target ip addresses of the Essbase nodes"
  type        = "list"
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "shape" {
  description = "Shape of the load balancer"
  default     = "100Mbps"
}

variable "idle_timeout" {
  default = 300
}

variable "enable_https" {
  default = true
}

variable "demo_ca" {
  default = {}
  type    = "map"
}
