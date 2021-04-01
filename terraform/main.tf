## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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
  generated_vcn_dns_label        = format("ess%s", random_string.instance_uuid.result)
  generated_rcu_schema_prefix    = format("ESS%s", upper(random_string.instance_uuid.result))
  generated_atp_db_name          = format("ess%s", random_string.instance_uuid.result)
  generated_instance_hostname_prefix = format("essbase%s", random_string.instance_uuid.result)

  stack_id     = format("essbase.stack.%s", random_string.instance_uuid.result)
  resource_name_prefix = var.stack_display_name != "" ? var.stack_display_name : local.generated_name_prefix
  rcu_schema_prefix    = var.rcu_schema_prefix != "" ? var.rcu_schema_prefix : local.generated_rcu_schema_prefix

  vcn_dns_label                  = var.vcn_dns_label != "" ? var.vcn_dns_label : local.generated_vcn_dns_label
  instance_hostname_label_prefix = var.instance_hostname_label_prefix != "" ? var.instance_hostname_label_prefix : local.generated_instance_hostname_prefix

  create_bastion = !var.create_public_essbase_instance && var.create_bastion

  db_type_map = {
     "Autonomous Database" = "adb"
     "Database System" = "oci"
     "Manual" = "manual"
  }

  db_type = !var.use_existing_db || var.existing_db_type == "" ? "adb" : local.db_type_map[var.existing_db_type]

  freeform_tags = {
     "essbase_stack_id"           = local.stack_id
     "essbase_stack_display_name" = local.resource_name_prefix
  }

  defined_tags = null
}

data "oci_identity_compartment" "compartment" {
  id         = var.compartment_ocid
  depends_on = [null_resource.input_validation]
}

module "notification" {
  source = "./modules/notification"
  topic_id = var.notification_topic_id
}

module "network" {
  source = "./modules/network"

  existing_vcn_id     = var.use_existing_vcn ? var.existing_vcn_id : ""
  compartment_id      = data.oci_identity_compartment.compartment.id
  vcn_cidr            = var.vcn_cidr
  dns_label           = local.vcn_dns_label
  display_name_prefix = local.resource_name_prefix
  enable_nat_gateway  = !var.create_public_essbase_instance
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
  route_table_id        = var.create_public_essbase_instance ? module.network.internet_route_table_id : module.network.nat_route_table_id
  create_private_subnet = !var.create_public_essbase_instance
  display_name_prefix   = local.resource_name_prefix
  freeform_tags         = local.freeform_tags
  defined_tags          = local.defined_tags
  instance_listen_port  = var.enable_embedded_proxy ? 443 : 9001
}

module "load-balancer-subnet" {
  source = "./modules/load-balancer-subnet"

  enabled             = var.create_load_balancer
  existing_subnet_ids = compact(
    [
      var.use_existing_vcn ? var.existing_load_balancer_subnet_id : "",
      var.use_existing_vcn && !var.create_public_load_balancer ? var.existing_load_balancer_subnet_id_2 : "",
    ],
  )
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.load_balancer_subnet_cidr
  target_cidr_block   = module.application-subnet.cidr_block
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id        = var.create_public_load_balancer ? module.network.internet_route_table_id : ""
  create_private_subnet = !var.create_public_load_balancer
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

module "bastion-subnet" {
  source = "./modules/bastion-subnet"

  enabled             = local.create_bastion
  existing_subnet_id  = var.use_existing_vcn ? var.existing_bastion_subnet_id : ""
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.bastion_subnet_cidr
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id      = module.network.internet_route_table_id
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

module "bastion" {
  source = "./modules/bastion"

  enabled             = local.create_bastion
  compartment_id      = data.oci_identity_compartment.compartment.id
  availability_domain = var.bastion_availability_domain != "" ? var.bastion_availability_domain : var.instance_availability_domain
  subnet_id           = module.bastion-subnet.id
  ssh_authorized_keys = var.ssh_authorized_keys
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
  instance_shape      = var.bastion_instance_shape
  listing_id          = var.bastion_listing_id
  listing_resource_version = var.bastion_listing_resource_version
  listing_resource_id = var.bastion_listing_resource_id
  notification_topic_id = module.notification.topic_id
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

  db_type_admin_password_encrypted = {
     "adb" = var.db_admin_password_encrypted 
     "oci" = var.oci_db_admin_password_encrypted
     "manual" = var.oci_db_admin_password_encrypted
  }

  db_type_alias_name = {
     "adb" = module.database.tns_alias
  }

  db_type_connect_string = {
     "oci" = module.database-oci.connect_string
     "manual" = var.existing_db_connect_string
  }

  db_type_host_mappings = {
    "adb"  = module.database.private_endpoint == "" ? [] : [{ host = module.database.private_endpoint,
                                                              ip_address = module.database.private_endpoint_ip
                                                            }]
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

  ssh_authorized_keys = var.ssh_authorized_keys

  hostname_label_prefix = local.instance_hostname_label_prefix
  shape                 = var.instance_shape
  shape_ocpus           = var.instance_shape_ocpus
  subnet_id             = module.application-subnet.id
  assign_public_ip      = var.create_public_essbase_instance

  config_volume_size = var.config_volume_size
  data_volume_size   = var.data_volume_size
  temp_volume_size   = var.temp_volume_size
  rcu_schema_prefix  = local.rcu_schema_prefix

  admin_username = var.essbase_admin_username
  admin_password_encrypted = var.essbase_admin_password_encrypted

  listing_id        = var.essbase_listing_id
  listing_resource_version = var.essbase_listing_resource_version
  listing_resource_id = var.essbase_listing_resource_id

  kms_key_id          = var.kms_key_id
  kms_crypto_endpoint = var.kms_crypto_endpoint

  db_type           = local.db_type
  db_database_id    = lookup(local.db_type_database_id, local.db_type, "")
  db_admin_username = lookup(local.db_type_admin_username, local.db_type, "")
  db_admin_password_encrypted = lookup(local.db_type_admin_password_encrypted, local.db_type, "")
  db_alias_name     = lookup(local.db_type_alias_name, local.db_type, "")
  db_connect_string = lookup(local.db_type_connect_string, local.db_type, "")

  db_backup_bucket_namespace = module.database-backup-bucket.bucket_namespace
  db_backup_bucket_name      = module.database-backup-bucket.bucket_name

  additional_host_mappings = lookup(local.db_type_host_mappings, local.db_type, [])

  security_mode                = var.security_mode
  idcs_tenant                  = var.security_mode == "idcs" ? var.idcs_tenant : null
  idcs_client_id               = var.security_mode == "idcs" ? var.idcs_client_id : null
  idcs_client_secret_encrypted = var.security_mode == "idcs" ? var.idcs_client_secret_encrypted : null
  external_admin_username      = var.security_mode == "idcs" ? var.idcs_external_admin_username : null

  enable_embedded_proxy = var.enable_embedded_proxy

  enable_monitoring     = var.enable_essbase_monitoring
  stack_id              = local.stack_id
  stack_display_name    = local.resource_name_prefix

  notification_topic_id = module.notification.topic_id
}

module "load-balancer" {
  source = "./modules/load-balancer"

  enabled             = var.create_load_balancer
  compartment_id      = data.oci_identity_compartment.compartment.id
  subnet_ids          = module.load-balancer-subnet.subnet_ids
  subnet_count        = module.load-balancer-subnet.subnet_count
  shape               = var.load_balancer_shape
  backend_node        = { ip_address = module.essbase.node.private_ip,
                          port = module.essbase.node.listen_port }
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

  is_private          = !var.create_public_load_balancer
}

