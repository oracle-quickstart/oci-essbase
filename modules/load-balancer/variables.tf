## Copyright © 2019, Oracle and/or its affiliates. 
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
  type    = number
  default = 1
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet ids for the Essbase node."
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

variable "enable_https" {
  type    = bool
  default = true
}

variable "demo_ca" {
  type = object({
    algorithm       = string
    private_key_pem = string
    cert_pem        = string
  })
}

