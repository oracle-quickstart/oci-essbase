## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

// Random string to make things unique
resource "random_id" "instance_uuid" {
  byte_length = 32
}

locals {
  instance_uuid       = lower(random_id.instance_uuid.hex)
  instance_uuid_short = substr(local.instance_uuid, 0, 8)

  generated_name_prefix              = format("essbase_%s", local.instance_uuid_short)
  generated_vcn_dns_label            = format("ess%s", local.instance_uuid_short)
  generated_rcu_schema_prefix        = format("ESS%s", upper(local.instance_uuid_short))
  generated_atp_db_name              = format("ess%s", local.instance_uuid_short)
  generated_instance_hostname_prefix = format("essbase%s", local.instance_uuid_short)

  resource_name_prefix = var.stack_display_name != "" ? var.stack_display_name : local.generated_name_prefix
  rcu_schema_prefix    = var.rcu_schema_prefix != "" ? var.rcu_schema_prefix : local.generated_rcu_schema_prefix

  vcn_dns_label                  = var.vcn_dns_label != "" ? var.vcn_dns_label : local.generated_vcn_dns_label
  instance_hostname_label_prefix = var.instance_hostname_label_prefix != "" ? var.instance_hostname_label_prefix : local.generated_instance_hostname_prefix

  instance_count = var.enable_cluster ? var.instance_count : 1

  create_load_balancer = var.enable_cluster || var.create_load_balancer
  
  db_type_map = {
    "Autonomous Database" = "adb"
    "Database System"     = "oci"
    "Manual"              = "manual"
  }

  db_type = ! var.use_existing_db || var.existing_db_type == "" ? "adb" : local.db_type_map[var.existing_db_type]

  freeform_tags = {
    "essbase_stack_id"           = local.instance_uuid
    "essbase_stack_display_name" = local.resource_name_prefix
  }

  defined_tags = null
  enable_storage_vnic = var.enable_cluster && (!var.use_existing_vcn || (var.existing_storage_subnet_id != var.existing_application_subnet_id))
}

data "oci_identity_compartment" "compartment" {
  id = var.compartment_ocid
}

module "idcs" {
  source  = "./modules/idcs"
  count   = var.identity_provider == "idcs" ? 1 : 0

  idcs_tenant = var.idcs_tenant
  idcs_client_id = var.idcs_client_id
  idcs_client_secret_id = var.idcs_client_secret_id
  idcs_external_admin_username = var.idcs_external_admin_username
}

module "notification" {
  count    = var.notification_topic_id != "" ? 1 : 0
  source   = "./modules/notification"
  topic_id = var.notification_topic_id
}

#
# Metadata bucket
# Stores metadata required for the compute instances that cannot be
# provided at instance creation time
#
module "metadata-bucket" {
  source = "./modules/bucket"
  compartment_id = data.oci_identity_compartment.compartment.id
  bucket_name    = "essbase_${local.instance_uuid_short}_metadata"
  freeform_tags  = local.freeform_tags
  defined_tags   = local.defined_tags
}

#
# Backup bucket
# Stores Essbase backups
#
module "backup-bucket" {
  source = "./modules/bucket"
  compartment_id = data.oci_identity_compartment.compartment.id
  bucket_name    = "essbase_${local.instance_uuid_short}_backup"
  freeform_tags  = local.freeform_tags
  defined_tags   = local.defined_tags
}


#
# Creates a pre-defined network topology for quickstart
#
module "network" {
  source = "./modules/network"
  count  = !var.use_existing_vcn ? 1 : 0

  compartment_id = data.oci_identity_compartment.compartment.id
  display_name_prefix = local.resource_name_prefix

  dns_label           = local.vcn_dns_label
  vcn_cidr_block      = var.vcn_cidr

  application_subnet_cidr_block = var.application_subnet_cidr
  create_private_application_subnet = ! var.create_public_essbase_instance
  instance_listen_port  = var.enable_embedded_proxy ? 443 : 9001

  storage_subnet_cidr_block = var.storage_subnet_cidr

  load_balancer_subnet_cidr_block = var.load_balancer_subnet_cidr
  create_load_balancer_subnet = local.create_load_balancer
  create_private_load_balancer_subnet = !var.create_public_load_balancer

  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags
}

#
# Validates the provided network information
#
module "existing-network" {
  source = "./modules/existing-network"
  count  = var.use_existing_vcn ? 1 : 0

  existing_vcn_id = var.existing_vcn_id
  existing_application_subnet_id = var.existing_application_subnet_id
  existing_storage_subnet_id = local.enable_storage_vnic ? var.existing_storage_subnet_id : ""
  #existing_bastion_subnet_id = var.existing_bastion_subnet_id
  existing_load_balancer_subnet_ids = local.create_load_balancer ? compact([ var.existing_load_balancer_subnet_id, var.existing_load_balancer_subnet_id_2 ]) : []
}

module "database" {
  source = "./modules/database"

  count                = local.db_type == "adb" && var.existing_db_id == "" ? 1 : 0
  compartment_id       = data.oci_identity_compartment.compartment.id
  db_name              = local.generated_atp_db_name
  db_admin_password_id = var.db_admin_password_id
  license_model        = var.db_license_model
  display_name_prefix  = local.resource_name_prefix
  freeform_tags        = local.freeform_tags
  defined_tags         = local.defined_tags
}

module "existing-database" {
  source = "./modules/existing-database"

  count                = local.db_type == "adb" && var.existing_db_id != "" ? 1 : 0
  database_id          = var.existing_db_id
}

module "existing-database-oci" {
  source      = "./modules/existing-database-oci"
  count       = local.db_type == "oci" ? 1 : 0
  database_id = var.existing_oci_db_system_database_id
  pdb_name    = var.existing_oci_db_system_database_pdb_name
}

locals {

  db_type_database_id = {
    "adb" = join("", compact(concat(module.database.*.database_id, module.existing-database.*.database_id)))
    "oci" = join("", module.existing-database-oci.*.database_id)
  }

  db_type_admin_username = {
    "adb"    = "ADMIN"
    "oci"    = var.oci_db_admin_username
    "manual" = var.oci_db_admin_username
  }

  db_type_admin_password_id = {
    "adb"    = var.db_admin_password_id
    "oci"    = var.oci_db_admin_password_id
    "manual" = var.oci_db_admin_password_id
  }

  db_type_bootstrap_password = {
    "adb" = var.existing_db_id == "" ? join("", module.database.*.bootstrap_password) : null
  }

  db_type_connect_string = {
    "oci"    = join("", module.existing-database-oci.*.connect_string)
    "manual" = var.existing_db_connect_string
  }

  db_type_host_mappings = {
    "adb"    = flatten(concat(module.database.*.private_endpoint_mappings, module.existing-database.*.private_endpoint_mappings))
  }

}

module "essbase" {
  source = "./modules/essbase"

  compartment_id      = data.oci_identity_compartment.compartment.id
  region              = var.region
  availability_domain = var.instance_availability_domain

  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

  ssh_authorized_keys = var.ssh_authorized_keys

  enable_cluster        = var.enable_cluster
  instance_count        = local.instance_count
  hostname_label_prefix = local.instance_hostname_label_prefix
  shape                 = var.instance_shape
  shape_ocpus           = var.instance_shape_ocpus
  subnet_id             = join("", concat(module.existing-network.*.application_subnet_id, module.network.*.application_subnet_id))
  assign_public_ip      = var.create_public_essbase_instance

  enable_storage_vnic   = local.enable_storage_vnic
  storage_subnet_id     = var.use_existing_vcn ? join("", module.existing-network.*.storage_subnet_id) : join("", module.network.*.storage_subnet_id)

  config_volume_size = var.config_volume_size
  data_volume_size   = var.data_volume_size
  temp_volume_size   = var.temp_volume_size
  rcu_schema_prefix  = local.rcu_schema_prefix

  admin_username    = var.essbase_admin_username
  admin_password_id = var.essbase_admin_password_id

  listing_id               = var.essbase_listing_id
  listing_resource_version = var.essbase_listing_resource_version
  listing_resource_id      = var.essbase_listing_resource_id

  db_type               = local.db_type
  db_database_id        = lookup(local.db_type_database_id, local.db_type, "")
  db_admin_username     = lookup(local.db_type_admin_username, local.db_type, "")
  db_admin_password_id  = lookup(local.db_type_admin_password_id, local.db_type, "")
  db_connect_string     = lookup(local.db_type_connect_string, local.db_type, null)
  db_bootstrap_password = lookup(local.db_type_bootstrap_password, local.db_type, null)

  metadata_bucket       = module.metadata-bucket
  backup_bucket         = module.backup-bucket

  additional_host_mappings = lookup(local.db_type_host_mappings, local.db_type, [])

  identity_provider       = var.identity_provider
  idcs_config             = var.identity_provider != "idcs" ? null : { tenant = var.idcs_tenant,
                                                                       client_id = var.idcs_client_id,
                                                                       client_secret_id = var.idcs_client_secret_id,
                                                                     }
  external_admin_username = var.identity_provider == "idcs" ? var.idcs_external_admin_username : null

  timezone              = var.instance_timezone
  enable_embedded_proxy = var.enable_embedded_proxy

  enable_monitoring  = var.enable_essbase_monitoring
  stack_id           = local.instance_uuid
  stack_display_name = local.resource_name_prefix

  notification_topic_id = var.notification_topic_id
}

module "load-balancer" {

  source = "./modules/load-balancer"
  count  = local.create_load_balancer ? 1 : 0

  compartment_id      = data.oci_identity_compartment.compartment.id
  subnet_ids          = flatten([ module.existing-network.*.load_balancer_subnet_ids, module.network.*.load_balancer_subnet_ids])
  shape               = var.load_balancer_shape
  backend_nodes       = [for i in module.essbase.nodes : { ip_address = i.private_ip, port = i.listen_port }]
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

  is_private = ! var.create_public_load_balancer
}

