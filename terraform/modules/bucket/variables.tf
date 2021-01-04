## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
  type        = string
}

variable "bucket_name" {
  description = "Name of the bucket to create"
  type        = string
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
