## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "listing_id" {
  type        = string
  default     = ""
}

variable "listing_resource_version" {
  type        = string
  default     = ""
}

variable "listing_resource_id" {
  description = "The OCID of the Essbase node image"
  type        = string
}

# OCI Service
variable "compartment_id" {
  description = "Target compartment OCID to deploy the essbase resources."
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain for the Essbase node."
  type        = string
}

variable "subnet_id" {
  description = "The subnet id for the Essbase node."
  type        = string
}

variable "node_count" {
  description = "The number of nodes to create.  Only supports up to 1 node."
  type        = number
  default     = 1
}

variable "instance_uuid" {
  description = "The unique identifier for the stack"
  type        = string
}

variable "hostname_label_prefix" {
  description = "The hostname for the essbase node"
  type        = string
  default     = ""
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
  type        = string
}

variable "shape" {
  description = "Instance shape for the node instance to use."
  type        = string
  default     = "VM.Standard2.1"
}

variable "shape_ocpus" {
  description = "Number of OCPUs for the flexible shape."
  type        = number
  default     = null
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address."
  type        = string
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  type        = string
}

variable "data_volume_size" {
  description = "The size of the data volume in gigabytes"
  type        = number
  default     = 1024
}

variable "data_volume_vpus_per_gb" {
  description = "The performance units for the data volume"
  type        = number
  default     = 10
}

variable "config_volume_size" {
  description = "The size of the config volume in gigabytes"
  type        = number
  default     = 64
}

variable "temp_volume_size" {
  description = "The size of the temp volume in gigabytes"
  type        = number
  default     = 64
}


variable "admin_username" {
  description = "The administrator username"
  type        = string
}

variable "admin_password_encrypted" {
  description = "The administrator password"
  type        = string
}

// Security configuration
variable "security_mode" {
  type    = string
  default = "embedded"
}

variable "idcs_tenant" {
  type    = string
  default = ""
}

variable "idcs_client_id" {
  type    = string
  default = ""
}

variable "idcs_client_secret_encrypted" {
  type    = string
  default = ""
}

variable "external_admin_username" {
  type    = string
  default = ""
}

// Database configuration
variable "db_type" {
  type = string
}

variable "db_admin_username" {
  description = "Database admin username"
  type        = string
}

variable "db_admin_password_encrypted" {
  description = "Database admin password"
  type        = string
}

variable "db_database_id" {
  type = string
}

variable "db_alias_name" {
  type = string
}

variable "db_connect_string" {
  type = string
  default = ""
}

variable "db_backup_bucket_namespace" {
  type    = string
  default = ""
}

variable "db_backup_bucket_name" {
  type    = string
  default = ""
}

variable "rcu_schema_prefix" {
  description = "Schema prefix"
  type        = string
  default     = "ESS1"
}

variable "reset_system" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "stack_id" {
  type    = string
  default = ""
}

variable "stack_display_name" {
  type    = string
  default = ""
}

// KMS Settings
variable "kms_key_id" {
  type = string
}

variable "kms_crypto_endpoint" {
  type = string
}

// Notification settings
variable "notification_topic_id" {
  type = string
  default = ""
}

// Sidecar proxy
variable "enable_embedded_proxy" {
  type    = bool
  default = true
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

