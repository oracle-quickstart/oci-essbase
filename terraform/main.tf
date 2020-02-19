## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Random suffix to make things unique
resource "random_string" "instance_uuid" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  generated_name_prefix          = format("essbase_%s", random_string.instance_uuid.result)
  generated_dns_label            = format("ess%s", random_string.instance_uuid.result)
  generated_rcu_schema_prefix    = format("ESS%s", upper(random_string.instance_uuid.result))
  generated_atp_db_name          = format("ess%s", random_string.instance_uuid.result)
  generated_node_hostname_prefix = format("essbase%s", random_string.instance_uuid.result)

  resource_name_prefix = var.service_name != "" ? var.service_name : local.generated_name_prefix
  rcu_schema_prefix    = var.rcu_schema_prefix != "" ? var.rcu_schema_prefix : local.generated_rcu_schema_prefix

  assign_public_ip = var.assign_public_ip && var.use_existing_vcn || (! var.use_existing_vcn) && (! var.create_private_subnet)

  enable_bastion = (! local.assign_public_ip)

  db_type_map = {
     "Autonomous Database" = "adb"
     "Database System" = "oci"
     "Manual" = "manual"
  }

  db_type = !var.use_existing_db || var.existing_db_type == "" ? "adb" : local.db_type_map[var.existing_db_type]

  freeform_tags = {
     "essbase_stack_id"   = random_string.instance_uuid.result
     "essbase_stack_name" = local.resource_name_prefix
  }

  defined_tags = null
}

resource "tls_private_key" "stack_management_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "oci_identity_compartment" "compartment" {
  id         = var.compartment_ocid
  depends_on = [null_resource.input_validation]
}

module "network" {
  source = "./modules/network"

  existing_vcn_id     = var.use_existing_vcn ? var.existing_vcn_id : ""
  compartment_id      = data.oci_identity_compartment.compartment.id
  vcn_cidr            = var.vcn_cidr
  dns_label           = local.generated_dns_label
  display_name_prefix = local.resource_name_prefix
  enable_nat_gateway  = local.enable_bastion
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

module "application-subnet" {
  source = "./modules/application-subnet"

  existing_subnet_id    = var.use_existing_vcn ? var.existing_application_subnet_id : ""
  compartment_id        = module.network.compartment_id
  vcn_id                = module.network.vcn_id
  cidr_block            = var.application_subnet_cidr
  dhcp_options_id       = module.network.default_dhcp_options_id
  route_table_id        = local.enable_bastion ? module.network.nat_route_table_id : module.network.internet_route_table_id
  create_private_subnet = var.create_private_subnet
  display_name_prefix   = local.resource_name_prefix
  freeform_tags         = local.freeform_tags
  defined_tags          = local.defined_tags
}

module "load-balancer-subnet" {
  source = "./modules/load-balancer-subnet"

  enabled             = var.create_load_balancer
  existing_subnet_ids = compact(
    [
      var.use_existing_vcn ? var.existing_load_balancer_subnet_id : "",
      var.use_existing_vcn ? var.existing_load_balancer_subnet_id_2 : "",
    ],
  )
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.load_balancer_subnet_cidr
  target_cidr_block   = module.application-subnet.cidr_block
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id      = module.network.internet_route_table_id
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

module "bastion-subnet" {
  source = "./modules/bastion-subnet"

  enabled             = local.enable_bastion
  existing_subnet_id  = var.use_existing_vcn ? var.existing_bastion_subnet_id : ""
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.bastion_subnet_cidr
  target_cidr_block   = module.application-subnet.cidr_block
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id      = module.network.internet_route_table_id
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

module "bastion" {
  source = "./modules/bastion"

  enabled             = local.enable_bastion
  compartment_id      = data.oci_identity_compartment.compartment.id
  region              = var.region
  availability_domain = var.instance_availability_domain
  subnet_id           = module.bastion-subnet.id
  ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.stack_management_key.public_key_openssh}"
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
  instance_shape      = var.bastion_instance_shape
}

module "database" {
  source = "./modules/database"

  enabled                     = local.db_type == "adb"
  database_id                 = var.existing_db_id
  compartment_id              = data.oci_identity_compartment.compartment.id
  db_name                     = local.generated_atp_db_name
  db_admin_password_encrypted = var.db_admin_password_encrypted
  kms_crypto_endpoint         = var.kms_crypto_endpoint
  kms_key_id                  = var.kms_key_id
  whitelisted_ips             = [ module.network.vcn_id ]
  license_model               = var.db_license_model
  display_name_prefix         = local.resource_name_prefix
  freeform_tags               = local.freeform_tags
  defined_tags                = local.defined_tags
}

module "database-backup-bucket" {
  source = "./modules/bucket"

  enabled        = !var.use_existing_db && var.existing_db_type == "Autonomous Database"
  compartment_id = module.database.compartment_id

  # Bucket name needs to match a predefined patter
  bucket_name = "backup_${module.database.db_name}"

  freeform_tags  = local.freeform_tags
  defined_tags   = local.defined_tags
}

module "database-oci" {
  source      = "./modules/database-oci"
  enabled     = local.db_type == "oci"
  database_id = var.existing_oci_db_system_database_id
  pdb_name    = var.existing_oci_db_system_database_pdb_name
}

module "subscription" {
  source = "./modules/subscription"

  compartment_id              = data.oci_identity_compartment.compartment.id
  enabled                     = var.mp_listing_id != ""
  mp_listing_id               = var.mp_listing_id
  mp_listing_resource_version = var.mp_listing_resource_version
  mp_listing_resource_id      = var.mp_listing_resource_id
}

locals {

  db_type_database_id = {
     "adb" = module.database.database_id
     "oci" = module.database-oci.database_id
  }

  db_type_admin_username = {
     "adb" = "ADMIN"
     "oci" = var.oci_db_admin_username
     "manual" = var.oci_db_admin_username
  }

  db_type_admin_password = {
     "adb" = var.db_admin_password_encrypted 
     "oci" = var.oci_db_admin_password_encrypted
     "manual" = var.oci_db_admin_password_encrypted
  }

  db_type_alias_name = {
     "adb" = "${module.database.db_name}_tp"
  }

  db_type_connect_string = {
     "oci" = module.database-oci.connect_string
     "manual" = var.existing_db_connect_string
  }

  

}

module "essbase" {
  source = "./modules/essbase"

  compartment_id      = data.oci_identity_compartment.compartment.id
  region              = var.region
  availability_domain = var.instance_availability_domain

  instance_uuid       = random_string.instance_uuid.result
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

  ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.stack_management_key.public_key_openssh}"
  ssh_private_key     = tls_private_key.stack_management_key.private_key_pem

  node_hostname_prefix = local.generated_node_hostname_prefix
  shape                = var.instance_shape
  subnet_id            = module.application-subnet.id
  assign_public_ip     = local.assign_public_ip
  bastion_host         = module.bastion.public_ip

  config_volume_size = var.config_volume_size
  data_volume_size   = var.data_volume_size
  rcu_schema_prefix  = local.rcu_schema_prefix

  admin_username = var.essbase_admin_username
  admin_password = var.essbase_admin_password_encrypted

  image_id = var.mp_listing_id != "" ? module.subscription.image_id : var.mp_listing_resource_id

  kms_key_id          = var.kms_key_id
  kms_crypto_endpoint = var.kms_crypto_endpoint

  db_type           = local.db_type
  db_database_id    = lookup(local.db_type_database_id, local.db_type, "")
  db_admin_username = lookup(local.db_type_admin_username, local.db_type, "")
  db_admin_password = lookup(local.db_type_admin_password, local.db_type, "")
  db_alias_name     = lookup(local.db_type_alias_name, local.db_type, "")
  db_connect_string = lookup(local.db_type_connect_string, local.db_type, "")

  db_backup_bucket_namespace = module.database-backup-bucket.bucket_namespace
  db_backup_bucket_name      = module.database-backup-bucket.bucket_name

  security_mode                = var.security_mode
  idcs_client_tenant           = var.security_mode == "idcs" ? var.idcs_client_tenant : ""
  idcs_client_id               = var.security_mode == "idcs" ? var.idcs_client_id : ""
  idcs_client_secret           = var.security_mode == "idcs" ? var.idcs_client_secret_encrypted : ""
  idcs_external_admin_username = var.security_mode == "idcs" ? var.idcs_external_admin_username : ""
}

module "load-balancer" {
  source = "./modules/load-balancer"

  enabled             = var.create_load_balancer
  compartment_id      = data.oci_identity_compartment.compartment.id
  subnet_ids          = module.load-balancer-subnet.subnet_ids
  subnet_count        = module.load-balancer-subnet.subnet_count
  shape               = var.load_balancer_shape
  node_count          = 1
  node_ip_addresses   = [ module.essbase.node_private_ip ]
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

}

