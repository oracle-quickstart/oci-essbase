## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// General settings
variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "region" {
  type = string
}

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

variable "create_private_subnet" {
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

variable "existing_application_subnet_id" {
  type    = string
  default = ""
}

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
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

variable "existing_load_balancer_subnet_id" {
  type    = string
  default = ""
}

variable "existing_load_balancer_subnet_id_2" {
  type    = string
  default = ""
}

variable "enable_load_balancer_ssl" {
  type    = string
  default = true
}

// Essbase instance configuration
variable "mp_listing_id" {
  type    = string
  default = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
}

variable "mp_listing_resource_version" {
  type    = string
  default = "19.3.0.0.1-1910111603"
}

variable "mp_listing_resource_id" {
  description = "Target image id"
  type        = string
  default     = "ocid1.image.oc1..aaaaaaaa743guvcbuzeawbltxcesal53hxm6sxtkbduokarlhuf3fah7yvgq"
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

variable "essbase_admin_password" {
  type    = string
  default = ""
}

variable "essbase_admin_password_encrypted" {
  type    = string
  default = ""
}

variable "rcu_schema_prefix" {
  type    = string
  default = ""
}

variable "assign_public_ip" {
  type    = string
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

variable "idcs_client_secret" {
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

variable "existing_db_compartment_id" {
  type    = string
  default = ""
}

variable "existing_db_id" {
  type    = string
  default = ""
}

variable "db_admin_username" {
  type    = string
  default = "ADMIN"
}

variable "db_admin_password" {
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
variable "use_kms_provisioning_key" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "kms_crypto_endpoint" {
  type    = string
  default = ""
}

