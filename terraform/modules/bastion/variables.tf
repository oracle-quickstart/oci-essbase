## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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

variable "notification_topic_id" {
  type = string
  default = ""
}

variable "listing_id" {
  description = "the OCID of the resource listing id"
  type = string
  default = ""
}

variable "listing_resource_version" {
  description = "Version of the resource listing to use"
  type = string
  default = ""
}

variable "listing_resource_id" {
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
