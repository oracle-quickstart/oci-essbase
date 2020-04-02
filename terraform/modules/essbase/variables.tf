## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

variable "image_id" {
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

variable "node_hostname_prefix" {
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

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address."
  type        = string
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  type        = string
}

variable "ssh_private_key" {
  description = "Private key to be used to access this instance"
  type        = string
}

variable "enable_data_volume" {
  description = "Enable the data volume for storing application data in an isolated volume"
  type        = bool
  default     = true
}

variable "data_volume_size" {
  description = "The size of the data volume in gigabytes"
  type        = number
  default     = 1024
}

variable "enable_config_volume" {
  description = "Enable the config volume to store configuraiton content in an isolated volume"
  type        = bool
  default     = true
}

variable "config_volume_size" {
  description = "The size of the config volume in gigabytes"
  type        = number
  default     = 256
}

variable "admin_username" {
  description = "The administrator username"
  type        = string
}

variable "admin_password" {
  description = "The administrator password"
  type        = string
}

// Security configuration
variable "security_mode" {
  type    = string
  default = "embedded"
}

variable "idcs_client_tenant" {
  type    = string
  default = ""
}

variable "idcs_client_id" {
  type    = string
  default = ""
}

variable "idcs_client_secret" {
  type    = string
  default = ""
}

variable "idcs_external_admin_username" {
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

variable "db_admin_password" {
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

// KMS Settings
variable "kms_key_id" {
  type = string
}

variable "kms_crypto_endpoint" {
  type = string
}

// Bastion host settings
variable "bastion_host" {
  type    = string
  default = ""
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
