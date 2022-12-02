## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  enable_subscription = var.listing_id != ""
}

# Get Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "essbase_image_agreement" {
  count = local.enable_subscription ? 1 : 0

  listing_id               = var.listing_id
  listing_resource_version = var.listing_resource_version
}

# Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "essbase_image_subscription" {
  count                    = local.enable_subscription ? 1 : 0
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

locals {
  image_id = local.enable_subscription ? join("", oci_core_app_catalog_subscription.essbase_image_subscription.*.listing_resource_id) : var.listing_resource_id
}

data "oci_core_subnet" "application" {
  subnet_id = var.subnet_id
}

data "oci_core_subnet" "storage" {
  count     = var.enable_storage_vnic ? 1 : 0
  subnet_id = var.storage_subnet_id
}

locals {
  use_hostnames = data.oci_core_subnet.application.dns_label != null && data.oci_core_subnet.application.dns_label != ""
  node_count    = var.enable_cluster ? var.instance_count : 1
}

data "oci_identity_fault_domains" "fault_domains" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
}

resource "random_shuffle" "node_fault_domains" {
  input = data.oci_identity_fault_domains.fault_domains.fault_domains.*.name
}


#
# Volumes
#
resource "oci_core_volume" "essbase_data" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = format("%s-data-volume", var.display_name_prefix)
  size_in_gbs         = var.data_volume_size
  vpus_per_gb         = var.data_volume_vpus_per_gb
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_config" {
  count               = local.node_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = format("%s-config-volume-%s", var.display_name_prefix, count.index + 1)
  size_in_gbs         = var.config_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_temp" {
  count               = local.node_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = format("%s-temp-volume-%s", var.display_name_prefix, count.index + 1)
  size_in_gbs         = var.temp_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

module "essbase-node" {

  source = "../essbase-node"

  count          = local.node_count
  compartment_id = var.compartment_id
  display_name   = format("%s-node-%s", var.display_name_prefix, count.index + 1)

  availability_domain = var.availability_domain
  fault_domain        = random_shuffle.node_fault_domains.result[count.index % length(random_shuffle.node_fault_domains.result)]

  image_id    = local.image_id
  shape       = var.shape
  shape_ocpus = var.shape_ocpus
  timezone    = var.timezone
  
  ssh_authorized_keys = var.ssh_authorized_keys

  subnet_id        = data.oci_core_subnet.application.id
  assign_public_ip = var.assign_public_ip
  hostname_label   = local.use_hostnames ? format("%s-%s", var.hostname_label_prefix, count.index + 1) : null

  stack_id              = var.stack_id
  stack_display_name    = var.stack_display_name
  enable_monitoring     = var.enable_monitoring
  enable_embedded_proxy = var.enable_embedded_proxy
  notification_topic_id = var.notification_topic_id

  admin_username    = var.admin_username
  admin_password_id = var.admin_password_id
  rcu_schema_prefix = var.rcu_schema_prefix

  secure_mode             = false
  identity_provider       = var.identity_provider
  idcs_config             = var.idcs_config
  external_admin_username = var.external_admin_username

  enable_cluster      = var.enable_cluster
  enable_storage_vnic = var.enable_storage_vnic
  storage_subnet_id   = var.enable_storage_vnic ? data.oci_core_subnet.storage[0].id : null
  node_index          = count.index + 1

  config_volume = oci_core_volume.essbase_config[count.index]
  temp_volume   = oci_core_volume.essbase_temp[count.index]
  data_volume   = oci_core_volume.essbase_data

  metadata_bucket = var.metadata_bucket
  backup_bucket   = var.backup_bucket

  db_type               = var.db_type
  db_database_id        = var.db_database_id
  db_alias_name         = var.db_alias_name
  db_connect_string     = var.db_connect_string
  db_admin_username     = var.db_admin_username
  db_admin_password_id  = var.db_admin_password_id
  db_bootstrap_password = var.db_bootstrap_password

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

locals {

  nodes = [for i in range(local.node_count) : {
    id             = module.essbase-node[i].id,
    display_name   = module.essbase-node[i].display_name,
    hostname       = module.essbase-node[i].hostname_label,
    domain_name    = local.use_hostnames ? format("%s.%s", module.essbase-node[i].hostname_label, data.oci_core_subnet.application.subnet_domain_name) : null
    public_ip      = module.essbase-node[i].public_ip,
    private_ip     = module.essbase-node[i].private_ip,
    storage_ip     = module.essbase-node[i].storage_ip,
    listen_port    = module.essbase-node[i].listen_port,
    listen_address = module.essbase-node[i].listen_address,
    node_index     = module.essbase-node[i].node_index,
  }]

  cluster_nodes = [for i in range(local.node_count) : {
    id             = module.essbase-node[i].id,
    hostname       = module.essbase-node[i].hostname_label,
    domain_name    = local.use_hostnames ? format("%s.%s", module.essbase-node[i].hostname_label, data.oci_core_subnet.application.subnet_domain_name) : null
    private_ip     = module.essbase-node[i].private_ip,
    storage_ip     = module.essbase-node[i].storage_ip,
    listen_port    = module.essbase-node[i].listen_port,
    listen_address = module.essbase-node[i].listen_address,
    node_index     = module.essbase-node[i].node_index,
  }]

  external_urls = [for i in range(local.node_count) : module.essbase-node[i].external_url]
}

#
# Cluster information
#
resource "oci_objectstorage_object" "essbase_cluster_metadata" {
  bucket       = var.metadata_bucket.name
  namespace    = var.metadata_bucket.namespace
  object       = "cluster-info.dat"
  storage_tier = "InfrequentAccess"
  content      = jsonencode(local.cluster_nodes)
}

locals {
  external_url = length(local.external_urls) == 0 ? "" : local.external_urls[0]
}

