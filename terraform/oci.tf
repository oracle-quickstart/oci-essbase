## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
  default = ""
}

variable "private_key_path" {
  default = ""
}

provider "oci" {
  version = "~> 3.36.0"
  tenancy_ocid     = "${var.tenancy_ocid}"
  region           = "${var.region}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}
