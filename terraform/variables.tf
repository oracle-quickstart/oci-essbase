## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

// General settings
variable "service_name" {
  type    = string
  default = ""
}

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

variable "application_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "create_private_application_subnet" {
  type    = bool
  default = false
}

variable "existing_vcn_compartment_id" {
  type    = string
  default = ""
}

variable "existing_vcn_id" {
  type    = string
  default = ""
}

variable "existing_application_subnet_compartment_id" {
  type    = string
  default = ""
}

variable "existing_application_subnet_id" {
  type    = string
  default = ""
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

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

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
variable "mp_listing_id" {
  type = string
  default = ""
}

variable "mp_listing_resource_version" {
  type = string
  default = "" 
}

variable "mp_listing_resource_id" {
  description = "Target image id"
  type        = string
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard2.4"
}

variable "instance_availability_domain" {
  type = string
}

variable "ssh_public_key" {
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
  default = 512
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

variable "assign_instance_public_ip" {
  type    = bool
  default = true
}

// Security configuration
variable "security_mode" {
  // "embedded" or "idcs"
  type    = string
  default = "idcs"
}

variable "idcs_client_tenant" {
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

variable "existing_oci_db_system_id" {
  type    = string
  default = ""
}

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

