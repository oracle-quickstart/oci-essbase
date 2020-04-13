## Copyright (c) 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

## OCI Variables
variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "user_ocid" {
  type    = string
  default = ""
}

variable "fingerprint" {
  type    = string
  default = ""
}

variable "private_key_path" {
  type    = string
  default = ""
}

## Image variables
variable "instance_shape" {
  type    = string
  default = "VM.Standard2.1"
}

variable "base_image_ocid" {
  type = string
  default = ""
}

variable "availability_domain" {
  type = string
}

# Network details
variable "subnet_ocid" {
  type = string
}


