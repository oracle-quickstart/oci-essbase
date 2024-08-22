## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "listing_id" {
  type    = string
  default = ""
}

variable "listing_resource_version" {
  type    = string
  default = ""
}

variable "listing_resource_id" {
  description = "The OCID of the Essbase node image"
  type        = string
}

variable "sourceInstance_ocid" {
  default = ""
}

variable "sourceInstance_version" {
  type    = string
  default = ""
}

variable "sourceInstance_extendedMetadata"{
  type = string
  default = ""
}

variable "instanceImage_ocid" {
  type = string
  default = ""
}

variable "instanceSpecifyPrivateIP" {
  type = bool
  default = true
}

variable "instancePrivateIP" {
  type = string
  default = ""
}

variable "instanceBackupRestore"{
  type = bool
  default = false
}

variable "instanceUpgrade19c34"{
  type = bool
  default = false
}

variable "instanceUpgrade19c23"{
  type = bool
  default = false
}

variable "instanceUpgrade19c02"{
  type = bool
  default = false
}

variable "instanceUpgrade21c01"{
  type = bool
  default = false
}

variable "instanceSchemaPrefix" {
  description = "Schema prefix"
  type        = string
  default     = ""
}

variable "instanceIDCSPassword"{
  type = string
  default = ""
}

variable "instanceDBPassword"{
  type = string
  default = ""
}

variable "instanceEssbasePassword"{
  type = string
  default = ""
}

variable "compartment_ocid" {
	default = ""
}

variable "region" {
	default = ""
}

variable "localAD" {
    default = ""
}

variable "stack_resource_id" {
  type = string
  default = ""
}

variable "stack_id" {
  type = string
  default = ""
}

variable "bucket_name" {
  description = "Name of the bucket to create"
  type        = string
}

variable "source_instance_ocpus" {
  type = number
  default = 4
}

variable "instanceUpgradeShape" {
  type = string
  default = ""
}