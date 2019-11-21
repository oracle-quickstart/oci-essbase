## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// General settings
variable "tenancy_ocid" {}

variable "compartment_ocid" {}

variable "region" {}

variable "service_name" {
  default = ""
}

variable "show_advanced_options" {
  default = false
}

// Network configuration
variable "use_existing_vcn" {
  default = false
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "application_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "create_private_subnet" {
  default = false
}

variable "existing_vcn_compartment_id" {
  default = ""
}

variable "existing_vcn_id" {
  default = ""
}

variable "existing_application_subnet_id" {
  default = ""
}

variable "bastion_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "existing_bastion_subnet_id" {
  default = ""
}

variable "bastion_instance_shape" {
  default = "VM.Standard.E2.1"
}

variable "load_balancer_subnet_cidr" {
  default = "10.0.4.0/24"
}

variable "existing_load_balancer_subnet_id" {
  default = ""
}

variable "existing_load_balancer_subnet_id_2" {
  default = ""
}

variable "enable_load_balancer_ssl" {
  default = true
}

// Essbase instance configuration
variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
}

variable "mp_listing_resource_version" {
  default = "19.3.0.0.1-1910111603"
}

variable "mp_listing_resource_id" {
  description = "Target image id"
  default     = "ocid1.image.oc1..aaaaaaaa743guvcbuzeawbltxcesal53hxm6sxtkbduokarlhuf3fah7yvgq"
}

variable "instance_shape" {
  default = "VM.Standard2.4"
}

variable "instance_availability_domain" {}

variable "ssh_public_key" {}

variable "data_volume_size" {
  // (gigabytes)
  default = 1024
}

variable "config_volume_size" {
  // (gigabytes)
  default = 512
}

variable "essbase_admin_username" {
  default = "admin"
}

variable "essbase_admin_password" {
  default = ""
}

variable "essbase_admin_password_encrypted" {
  default = ""
}

variable "rcu_schema_prefix" {
  default = ""
}

variable "assign_public_ip" {
  default = true
}

// Security configuration
variable "security_mode" {
  // "embedded" or "idcs"
  default = "idcs"
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

variable "idcs_client_secret_encrypted" {
  default = ""
}

variable "idcs_external_admin_username" {
  default = ""
}

// Database configuration
variable "use_existing_db" {
  default = false
}

variable "existing_db_compartment_id" {
  default = ""
}

variable "existing_db_id" {
  default = ""
}

variable "db_admin_username" {
  default = "ADMIN"
}

variable "db_admin_password" {
  default = ""
}

variable "db_admin_password_encrypted" {
  default = ""
}

variable "db_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "db_connection_type" {
  default = "low"
}

// Load Balancer configuration
variable "create_load_balancer" {
  default = false
}

variable "load_balancer_shape" {
  default = "100Mbps"
}

// KMS Settings
variable "use_kms_provisioning_key" {
  default = true
}

variable "kms_key_id" {
  default = ""
}

variable "kms_crypto_endpoint" {
  default = ""
}
