## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

variable "enabled" {
  type    = bool
  default = false
}

variable "compartment_id" {
  type = string
}

variable "display_name_prefix" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard2.1"
}

variable "ssh_authorized_keys" {
  type = string
}

variable "subnet_id" {
  description = "The subnet id for the bastion node."
  type        = string
}

variable "image_id" {
  description = "The OCID of the bastion image"
  type        = string
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
