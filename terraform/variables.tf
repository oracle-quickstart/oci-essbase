## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

// General settings
variable "stack_version" {
  type    = string
  default = "unknown"
}

variable "stack_display_name" {
  type    = string
  default = ""
}

// USED ONLY FOR RESOURCE MANAGER
variable "show_advanced_options" {
  type    = bool
  default = false
}

// Network configuration
variable "use_existing_vcn" {
  type    = bool
  default = false
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  type    = string
  default = ""
}

variable "application_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "create_public_essbase_instance" {
  type    = bool
  default = false
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_vcn_compartment_id" {
  type    = string
  default = ""
}

variable "existing_vcn_id" {
  type    = string
  default = ""
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_application_subnet_compartment_id" {
  type    = string
  default = ""
}

variable "existing_application_subnet_id" {
  type    = string
  default = ""
}

// Bastion configuration
variable "create_bastion" {
  type    = bool
  default = false
}

variable "bastion_listing_id" {
  type    = string
  default = ""
}

variable "bastion_listing_resource_version" {
  type    = string
  default = ""
}

variable "bastion_listing_resource_id" {
  type    = string
  default = ""
}

variable "bastion_availability_domain" {
  type    = string
  default = ""
}

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_bastion_subnet_compartment_id" {
  type    = string
  default = ""
}

variable "existing_bastion_subnet_id" {
  type    = string
  default = ""
}

variable "bastion_instance_shape" {
  type    = string
  default = "VM.Standard.E2.1"
}

variable "load_balancer_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_load_balancer_subnet_compartment_id" {
  type    = string
  default = ""
}

variable "existing_load_balancer_subnet_id" {
  type    = string
  default = ""
}

variable "existing_load_balancer_subnet_id_2" {
  type    = string
  default = ""
}

// Essbase instance configuration
variable "essbase_listing_id" {
  type = string
  default = ""
}

variable "essbase_listing_resource_version" {
  type = string
  default = "" 
}

variable "essbase_listing_resource_id" {
  description = "Target image id"
  type        = string
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard2.4"
}

variable "instance_shape_ocpus" {
  type    = number
  default = null
}

variable "instance_availability_domain" {
  type = string
}

variable "instance_hostname_label_prefix" {
  type = string
  default = ""
}

variable "ssh_authorized_keys" {
  type = string
}

variable "data_volume_size" {
  // (gigabytes)
  type    = number
  default = 1024
}

variable "config_volume_size" {
  // (gigabytes)
  type    = number
  default = 64
}

variable "temp_volume_size" {
  // (gigabytes)
  type    = number
  default = 64
}

variable "essbase_admin_username" {
  type    = string
  default = "admin"
}

variable "essbase_admin_password_encrypted" {
  type    = string
}

variable "rcu_schema_prefix" {
  type    = string
  default = ""
}

variable "enable_embedded_proxy" {
  type    = bool
  default = true
}

// Security configuration
variable "security_mode" {
  // "embedded" or "idcs"
  type    = string
  default = "idcs"
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

variable "idcs_external_admin_username" {
  type    = string
  default = ""
}

// Database configuration
variable "use_existing_db" {
  type    = bool
  default = false
}

variable "existing_db_type" {
  type    = string
  default = "Autonomous Database"
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_db_compartment_id" {
  type    = string
  default = ""
}

variable "existing_db_id" {
  type    = string
  default = ""
}

variable "db_admin_password_encrypted" {
  type    = string
  default = ""
}

variable "db_license_model" {
  type    = string
  default = "LICENSE_INCLUDED"
}

variable "existing_db_connect_string" {
  type    = string
  default = ""
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_oci_db_system_id" {
  type    = string
  default = ""
}

// USED ONLY FOR RESOURCE MANAGER
variable "existing_oci_db_system_dbhome_id" {
  type    = string
  default = ""
}

variable "existing_oci_db_system_database_id" {
  type    = string
  default = ""
}

variable "existing_oci_db_system_database_pdb_name" {
  type    = string
  default = ""
}

variable "oci_db_admin_username" {
  type    = string
  default = "SYS"
}

variable "oci_db_admin_password_encrypted" {
  type    = string
  default = ""
}


// Load Balancer configuration
variable "create_load_balancer" {
  type    = bool
  default = false
}

variable "create_public_load_balancer" {
  type    = bool
  default = true
}

variable "load_balancer_shape" {
  type    = string
  default = "100Mbps"
}

// KMS Settings
variable "kms_key_id" {
  type    = string
}

variable "kms_crypto_endpoint" {
  type    = string
}

// Notification settings
variable "notification_topic_id" {
  type    = string
  default = ""
}

variable "enable_essbase_monitoring" {
  type    = bool
  default = false
}
