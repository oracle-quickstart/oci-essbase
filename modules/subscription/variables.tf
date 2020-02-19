## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_id" {
  type = string
}

variable "enabled" {
  type = bool
  default = false
}

variable "mp_listing_id" {
  type = string
}

variable "mp_listing_resource_version" {
  type = string
}

variable "mp_listing_resource_id" {
  type = string
}

