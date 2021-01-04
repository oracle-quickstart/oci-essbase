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

  validation {
    condition     = can(regex("^([a-zA-Z_][a-zA-Z0-9\\-_]*)?$", var.stack_display_name))
    error_message = "ESSPROV-00000 - Invalid input."
  }

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

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "vcn_dns_label" {
  type    = string
  default = ""

  validation {
    condition     = can(regex("^([a-zA-Z][a-zA-Z0-9]{0,14})?$", var.vcn_dns_label))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "application_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.application_subnet_cidr))
    error_message = "ESSPROV-00000 - Invalid input."
  }
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

  validation {
    condition     = var.bastion_listing_resource_id == "" || can(regex("^ocid1\\.image\\.[a-zA-Z0-9\\.\\-\\_]+$", var.bastion_listing_resource_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }

}

variable "bastion_availability_domain" {
  type    = string
  default = ""
}

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"

  validation {
    condition     = can(cidrnetmask(var.bastion_subnet_cidr))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "bastion_instance_shape" {
  type    = string
  default = "VM.Standard.E2.1"
}

variable "load_balancer_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"

  validation {
    condition     = can(cidrnetmask(var.load_balancer_subnet_cidr))
    error_message = "ESSPROV-00000 - Invalid input."
  }
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
  type    = string
  default = ""
}

variable "essbase_listing_resource_version" {
  type    = string
  default = ""
}

variable "essbase_listing_resource_id" {
  description = "Target image id"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.image\\.[a-zA-Z0-9\\.\\-\\_]+$", var.essbase_listing_resource_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard2.4"
}

variable "instance_shape_ocpus" {
  type    = number
  default = null
}

variable "instance_shape_memory" {
  type    = number
  default = null
}

variable "instance_availability_domain" {
  type = string
}

variable "instance_hostname_label_prefix" {
  type    = string
  default = ""

  validation {
    condition     = var.instance_hostname_label_prefix == "" || can(regex("^((?![0-9]+$)(?!.*-$)(?!-)[a-zA-Z0-9-]{1,60})?$", var.instance_hostname_label_prefix))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "ssh_authorized_keys" {
  type = string
}

variable "data_volume_size" {
  // (gigabytes)
  type    = number
  default = 1024

  validation {
    condition     = var.data_volume_size >= 256
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "config_volume_size" {
  // (gigabytes)
  type    = number
  default = 64

  validation {
    condition     = var.config_volume_size >= 64
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "temp_volume_size" {
  // (gigabytes)
  type    = number
  default = 64

  validation {
    condition     = var.temp_volume_size >= 64
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "essbase_admin_username" {
  type    = string
  default = "admin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{4,127}$", var.essbase_admin_username))
    error_message = "ESSPROV-00001 - Essbase System Admin username should be alphanumeric and length should be between 5 and 128 characters."
  }

}

variable "essbase_admin_password_id" {
  type = string

  validation {
    condition     = can(regex("^ocid1\\.vaultsecret\\.[a-zA-Z0-9\\.\\-\\_]+$", var.essbase_admin_password_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "rcu_schema_prefix" {
  type    = string
  default = ""

  validation {
    condition     = can(regex("^([a-zA-Z][a-zA-Z0-9]{0,11})?$", var.rcu_schema_prefix))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "enable_embedded_proxy" {
  type    = bool
  default = true
}

// Security configuration
variable "secure_mode" {
  type    = bool
  default = true
}

variable "identity_provider" {
  // "embedded" or "idcs"
  type    = string
  default = "idcs"
}

variable "idcs_tenant" {
  type    = string
  default = ""

  # validation {
  #   condition = var.identity_provider != "idcs" || var.idcs_tenant != ""
  #   error_message = "ESSPROV-00007 - Missing value for IDCS Instance GUID. The value has to set if using IDCS."
  # }
}

variable "idcs_client_id" {
  type    = string
  default = ""

  # validation {
  #   condition = var.identity_provider != "idcs" || var.idcs_client_id != ""
  #   error_message = "ESSPROV-00005 - Missing IDCS Application Client ID. The value has to set if using IDCS."
  # }
}

variable "idcs_client_secret_id" {
  type    = string
  default = ""

  validation {
    condition     = var.idcs_client_secret_id == "" || can(regex("^ocid1\\.vaultsecret\\.[a-zA-Z0-9\\.\\-\\_]+$", var.idcs_client_secret_id))
    error_message = "ESSPROV-00006 - Invalid IDCS Application Client Secret. The value has to set if using IDCS."
  }  
}

variable "idcs_external_admin_username" {
  type    = string
  default = ""

  # validation {
  #   condition = var.identity_provider != "idcs" || var.idcs_external_admin_username != ""
  #   error_message = "ESSPROV-00008 - Missing value for the IDCS Essbase Admin username. The value has to set if using IDCS."
  # }
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

variable "db_admin_password_id" {
  type    = string
  default = ""

  validation {
    condition     = var.db_admin_password_id == "" || can(regex("^ocid1\\.vaultsecret\\.[a-zA-Z0-9\\.\\-\\_]+$", var.db_admin_password_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }
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

  validation {
    condition     = var.existing_oci_db_system_database_pdb_name == "" || can(regex("^([a-zA-Z0-9][a-zA-Z0-9_]*)?$", var.existing_oci_db_system_database_pdb_name))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "oci_db_admin_username" {
  type    = string
  default = "SYS"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9$#_]{0,29}$", var.oci_db_admin_username))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "oci_db_admin_password_id" {
  type    = string
  default = ""

  validation {
    condition     = var.oci_db_admin_password_id == "" || can(regex("^ocid1\\.vaultsecret\\.[a-zA-Z0-9\\.\\-\\_]+$", var.oci_db_admin_password_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }
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

// Notification settings
variable "notification_topic_id" {
  type    = string
  default = ""

  validation {
    condition     = can(regex("^(ocid1\\.onstopic\\.[a-zA-Z0-9\\.\\-\\_]+)?$", var.notification_topic_id))
    error_message = "ESSPROV-00000 - Invalid input."
  }
}

variable "enable_essbase_monitoring" {
  type    = bool
  default = false
}
