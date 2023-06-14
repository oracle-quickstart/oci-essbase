## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
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
  description = "The availability domain for the Essbase nodes."
  type        = string
}

variable "subnet_id" {
  description = "The subnet id for the Essbase node."
  type        = string
}

variable "enable_storage_vnic" {
  type    = bool
  default = true
}

variable "storage_subnet_id" {
  type    = string
  default = ""
}

variable "enable_cluster" {
  type    = bool
  default = false
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "metadata_bucket" {
  type = object({
    id        = string
    namespace = string
    name      = string
  })
}

variable "backup_bucket" {
  type = object({
    id        = string
    namespace = string
    name      = string
  })
}

variable "catalog_bucket" {
  type = object({
    id        = string
    namespace = string
    name      = string
  })
}

variable "instance_catalog_storage" {
  type    = string
  default = ""
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

variable "admin_password_id" {
  description = "The administrator password secret id"
  type        = string
}

variable "identity_provider" {
  type    = string
  default = "embedded"
}

variable "idcs_config" {
  type = object({
    tenant           = string,
    client_id        = string,
    client_secret_id = string
  })
  default = null
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

variable "db_admin_password_id" {
  description = "Database admin password secret id"
  type        = string
}

variable "db_bootstrap_password" {
  description = "Database admin password used to bootstrap a newly created db"
  type        = string
  default     = null
  sensitive   = true
}

variable "db_database_id" {
  type = string
}

variable "db_alias_name" {
  type    = string
  default = null
}

variable "db_connect_string" {
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

// Notification settings
variable "notification_topic_id" {
  type    = string
  default = ""
}

variable "additional_host_mappings" {
  type = list(object({
    host       = string
    ip_address = string
  }))
  default = []
}

// Sidecar proxy
variable "enable_embedded_proxy" {
  type    = bool
  default = true
}

variable "timezone" {
  type    = string
  default = ""
}

variable "catalog_storage" {
  type    = string
  default = ""
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

