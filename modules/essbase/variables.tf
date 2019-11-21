## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "image_id" {
  description = "The OCID of the Essbase node image"
}

# OCI Service
variable "compartment_id" {
  description = "Target compartment OCID to deploy the essbase resources."
}

variable "region" {
  description = "Region"
}

variable "availability_domain" {
  description = "The availability domain for the Essbase node."
}

variable "subnet_id" {
  description = "The subnet id for the Essbase node."
}

variable "node_count" {
  description = "The number of nodes to create.  Only supports up to 1 node."
  default     = 1
}

variable "node_hostname_prefix" {
  description = "The hostname for the essbase node"
  default     = ""
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "shape" {
  description = "Instance shape for the node instance to use."
  default     = "VM.Standard2.1"
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address."
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
}

variable "ssh_private_key" {
  description = "Private key to be used to access this instance"
}

variable "data_volume_device" {
  description = "Device path for the data block volume"
  default     = "/dev/oracleoci/oraclevdb"
}

variable "data_volume_size" {
  description = "The size of the data volume in gigabytes"
  default     = "1024"
}

variable "config_volume_device" {
  description = "Device path for the config block volume"
  default     = "/dev/oracleoci/oraclevdc"
}

variable "config_volume_size" {
  description = "The size of the config volume in gigabytes"
  default     = "256"
}

variable "admin_username" {
  description = "The administrator username"
}

variable "admin_password" {
  description = "The administrator password"
}

// Security configuration
variable "security_mode" {
  default = "embedded"
}

variable "idcs_client_tenant" {
  default = ""
}

variable "idcs_client_id" {
  default = ""
}

variable "idcs_client_secret" {
  default = ""
}

variable "idcs_external_admin_username" {
  default = ""
}

variable "external_url" {
  default = ""
}

// Database configuration
variable "db_admin_username" {
  description = "Database admin username"
}

variable "db_admin_password" {
  description = "Database admin password"
}

variable "db_database_id" {}

variable "db_connect_alias" {}

variable "db_backup_bucket_namespace" {
  default = ""
}

variable "db_backup_bucket_name" {
  default = ""
}

variable "rcu_schema_prefix" {
  description = "Schema prefix"
  default     = "ESS1"
}

variable "development_mode" {
  default = false
}

variable "reset_system" {
  default = false
}

// KMS Settings
variable "use_kms_provisioning_key" {}

variable "kms_key_id" {}

variable "kms_crypto_endpoint" {
  default = ""
}

// Bastion host settings
variable "bastion_host" {
  default = ""
}

variable "demo_ca" {
  default = {}
  type    = "map"
}
