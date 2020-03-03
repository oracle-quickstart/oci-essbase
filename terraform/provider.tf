## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

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

provider "oci" {
  version = "~> 3.53.0"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
