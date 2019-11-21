/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
}

variable "bucket_name" {
  description = "Name of the bucket to create"
}

variable "enabled" {
  default = true
}
