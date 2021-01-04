## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
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
  generated_name_prefix              = format("essbase_%s", random_string.instance_uuid.result)
  generated_vcn_dns_label            = format("ess%s", random_string.instance_uuid.result)
  generated_rcu_schema_prefix        = format("ESS%s", upper(random_string.instance_uuid.result))
  generated_atp_db_name              = format("ess%s", random_string.instance_uuid.result)
  generated_instance_hostname_prefix = format("essbase%s", random_string.instance_uuid.result)

  stack_id             = format("essbase.stack.%s", random_string.instance_uuid.result)
  resource_name_prefix = var.stack_display_name != "" ? var.stack_display_name : local.generated_name_prefix
  rcu_schema_prefix    = var.rcu_schema_prefix != "" ? var.rcu_schema_prefix : local.generated_rcu_schema_prefix

  vcn_dns_label                  = var.vcn_dns_label != "" ? var.vcn_dns_label : local.generated_vcn_dns_label
  instance_hostname_label_prefix = var.instance_hostname_label_prefix != "" ? var.instance_hostname_label_prefix : local.generated_instance_hostname_prefix

  create_load_balancer = var.create_load_balancer
  create_bastion       = !var.use_existing_vcn && ! var.create_public_essbase_instance && var.create_bastion

  db_type_map = {
    "Autonomous Database" = "adb"
    "Database System"     = "oci"
    "Manual"              = "manual"
  }

  db_type = ! var.use_existing_db || var.existing_db_type == "" ? "adb" : local.db_type_map[var.existing_db_type]

  freeform_tags = {
    "essbase_stack_id"           = local.stack_id
    "essbase_stack_display_name" = local.resource_name_prefix
  }

  defined_tags = null
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

  load_balancer_subnet_cidr_block = var.load_balancer_subnet_cidr
  create_load_balancer_subnet = local.create_load_balancer
  create_private_load_balancer_subnet = !var.create_public_load_balancer

  bastion_subnet_cidr_block = var.bastion_subnet_cidr
  create_bastion_subnet = local.create_bastion

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
  existing_load_balancer_subnet_ids = local.create_load_balancer ? compact([ var.existing_load_balancer_subnet_id, var.existing_load_balancer_subnet_id_2 ]) : []
}


module "bastion" {
  source = "./modules/bastion"

  count                    = local.create_bastion ? 1 : 0
  compartment_id           = data.oci_identity_compartment.compartment.id
  availability_domain      = var.bastion_availability_domain != "" ? var.bastion_availability_domain : var.instance_availability_domain
  subnet_id                = join("", compact(concat(module.existing-network.*.bastion_subnet_id, module.network.*.bastion_subnet_id)))
  ssh_authorized_keys      = var.ssh_authorized_keys
  display_name_prefix      = local.resource_name_prefix
  freeform_tags            = local.freeform_tags
  defined_tags             = local.defined_tags
  instance_shape           = var.bastion_instance_shape
  listing_id               = var.bastion_listing_id
  listing_resource_version = var.bastion_listing_resource_version
  listing_resource_id      = var.bastion_listing_resource_id
  notification_topic_id    = var.notification_topic_id
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
    "adb" = join("", concat(module.database.*.database_id, module.existing-database.*.database_id))
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

  db_type_alias_name = {
    "adb" = join("", concat(module.database.*.tns_alias, module.existing-database.*.tns_alias))
  }

  db_type_connect_string = {
    "oci"    = join("", module.existing-database-oci.*.connect_string)
    "manual" = var.existing_db_connect_string
  }

  db_type_backup_bucket = {
    "adb"    = var.existing_db_id != "" ? null : { namespace = join("", module.database.*.backup_bucket_namespace),
                                                   name      = join("", module.database.*.backup_bucket_name) } 
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

  instance_uuid       = random_string.instance_uuid.result
  display_name_prefix = local.resource_name_prefix
  freeform_tags       = local.freeform_tags
  defined_tags        = local.defined_tags

  ssh_authorized_keys = var.ssh_authorized_keys

  hostname_label_prefix = local.instance_hostname_label_prefix
  shape                 = var.instance_shape
  shape_ocpus           = var.instance_shape_ocpus
  shape_memory          = var.instance_shape_memory
  subnet_id             = join("", concat(module.existing-network.*.application_subnet_id, module.network.*.application_subnet_id))
  assign_public_ip      = var.create_public_essbase_instance

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
  db_alias_name         = lookup(local.db_type_alias_name, local.db_type, null)
  db_connect_string     = lookup(local.db_type_connect_string, local.db_type, null)
  db_bootstrap_password = lookup(local.db_type_bootstrap_password, local.db_type, null)

  db_backup_bucket      = lookup(local.db_type_backup_bucket, local.db_type, null)

  additional_host_mappings = lookup(local.db_type_host_mappings, local.db_type, [])

  secure_mode = var.secure_mode

  identity_provider       = var.identity_provider
  idcs_tenant             = var.identity_provider == "idcs" ? var.idcs_tenant : null
  idcs_client_id          = var.identity_provider == "idcs" ? var.idcs_client_id : null
  idcs_client_secret_id   = var.identity_provider == "idcs" ? var.idcs_client_secret_id : null
  external_admin_username = var.identity_provider == "idcs" ? var.idcs_external_admin_username : null

  enable_embedded_proxy = var.enable_embedded_proxy

  enable_monitoring  = var.enable_essbase_monitoring
  stack_id           = local.stack_id
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

