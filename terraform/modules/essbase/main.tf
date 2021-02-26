## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  node_count          = 1
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

data "oci_identity_fault_domains" "fault_domains" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
}

resource "random_integer" "fault_domain_offset" {
  min = 0
  max = 2048
}


#
# Metadata bucket
# Stores metadata required for the compute instances that cannot be
# provided at instance creation time
#
module "metadata-bucket" {
  source = "../bucket"
  compartment_id = var.compartment_id
  bucket_name    = "essbase_${var.instance_uuid}_metadata"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

#
# Volumes
#
resource "oci_core_volume" "essbase_data" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-data-volume"
  size_in_gbs         = var.data_volume_size
  vpus_per_gb         = var.data_volume_vpus_per_gb
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_config" {
  count               = local.node_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-config-volume-${count.index + 1}"
  size_in_gbs         = var.config_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_temp" {
  count               = local.node_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-temp-volume-${count.index + 1}"
  size_in_gbs         = var.temp_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume_group" "essbase_volume_group" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  source_details {
    type = "volumeIds"

    volume_ids = [
      oci_core_volume.essbase_config[0].id,
      oci_core_volume.essbase_data.id,
    ]
  }

  display_name  = "${var.display_name_prefix}-volume-group"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

#
# Cloud Init Script
#
locals {

  cloud_init = <<TMPL
Content-Type: multipart/mixed; boundary="boundary-0123456789"
MIME-Version: 1.0

--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
# vim: syntax=yaml
%{ if var.timezone != "" ~}
timezone: ${var.timezone}
%{ endif ~}
runcmd:
%{ for mapping in var.additional_host_mappings ~}
- echo "${mapping.ip_address} ${mapping.host}" >> /etc/hosts
%{ endfor ~}
- /u01/vmtools/init/essbase-init.sh
--boundary-0123456789--
TMPL

  hostnames     = [for k in range(local.node_count) : format("%s-%s", var.hostname_label_prefix, k + 1)]
  is_flex_shape = var.shape == "VM.Standard.E3.Flex"

  flex_ocpus        = var.shape_ocpus == null ? 4 : var.shape_ocpus
  flex_shape_config = local.is_flex_shape ? [{ "ocpus" : local.flex_ocpus }] : []
}

#
# Essbase instance definition
#
resource "oci_core_instance" "essbase" {
  count               = local.node_count
  availability_domain = var.availability_domain
  fault_domain        = local.node_count > 1 ? data.oci_identity_fault_domains.fault_domains.fault_domains[(count.index + random_integer.fault_domain_offset.result) % length(data.oci_identity_fault_domains.fault_domains.fault_domains)].name : ""
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-node-${count.index + 1}"
  shape               = var.shape

  dynamic "shape_config" {
    for_each = local.flex_shape_config
    content {
      ocpus         = shape_config.value.ocpus
    }
  }

  create_vnic_details {
    display_name     = "primary"
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    hostname_label   = local.hostnames[count.index]
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64gzip(local.cloud_init)

    stack_id              = var.stack_id
    stack_display_name    = var.stack_display_name
    enable_monitoring     = var.enable_monitoring
    enable_embedded_proxy = var.enable_embedded_proxy
    notification_topic_id = var.notification_topic_id

    volume_group_id = oci_core_volume_group.essbase_volume_group.id

    admin_username    = var.admin_username
    admin_password_id = var.admin_password_id
    rcu_schema_prefix = var.rcu_schema_prefix

    secure_mode             = false
    identity_provider       = var.identity_provider
    external_admin_username = var.external_admin_username

    node_index = (count.index + 1)
    node_name  = local.hostnames[count.index]

    admin_node_name = local.hostnames[0]
    admin_hostname  = local.hostnames[0]

  }

  extended_metadata = {
    metadata_bucket = jsonencode({
      id        = module.metadata-bucket.id,
      namespace = module.metadata-bucket.namespace,
      name      = module.metadata-bucket.name,
    })
    volumes = jsonencode({
      config = {
        id           = oci_core_volume.essbase_config[count.index].id,
        display_name = oci_core_volume.essbase_config[count.index].display_name,
        path         = "/u01/config",
      },
      data = {
        id           = oci_core_volume.essbase_data.id,
        display_name = oci_core_volume.essbase_data.display_name,
        path         = "/u01/data",
      },
      temp = {
        id           = oci_core_volume.essbase_temp[count.index].id,
        display_name = oci_core_volume.essbase_temp[count.index].display_name,
        path         = "/u01/tmp"
      },
    })
    idcs = jsonencode({
      tenant           = var.idcs_tenant,
      client_id        = var.idcs_client_id,
      client_secret_id = var.idcs_client_secret_id,
    })
    database = jsonencode({
      type               = var.db_type,
      id                 = var.db_database_id,
      alias_name         = var.db_alias_name,
      connect_string     = var.db_connect_string,
      admin_username     = var.db_admin_username,
      admin_password_id  = var.db_admin_password_id,
      bootstrap_password = var.db_bootstrap_password != "" && var.db_bootstrap_password != null ? base64encode(var.db_bootstrap_password) : null,
      backup_bucket      = var.db_backup_bucket
    })
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  #prevent any metadata changes to destroy instance
  lifecycle {
    ignore_changes = [metadata, shape, shape_config]
  }

}

locals {

  nodes = [for i in range(local.node_count) : {
    id           = oci_core_instance.essbase[i].id,
    display_name = oci_core_instance.essbase[i].display_name,
    hostname     = local.hostnames[i],
    public_ip    = oci_core_instance.essbase[i].public_ip,
    private_ip   = oci_core_instance.essbase[i].private_ip,
    listen_port  = var.enable_embedded_proxy ? 443 : 9001,
    node_index   = oci_core_instance.essbase[i].metadata["node_index"],
    node_name    = oci_core_instance.essbase[i].metadata["node_name"],
  }]

}

#
# Cluster information
#
resource "oci_objectstorage_object" "essbase_cluster_metadata" {
  bucket    = module.metadata-bucket.name
  namespace = module.metadata-bucket.namespace
  object    = "cluster-info.dat"
  content   = jsonencode(local.nodes)
}

#
# Data volume attachment
#
resource "oci_core_volume_attachment" "essbase_data" {
  count           = local.node_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase[count.index].id
  volume_id       = oci_core_volume.essbase_data.id
  display_name    = "${oci_core_instance.essbase[count.index].display_name}-data-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_data_volume_metadata" {
  count     = local.node_count
  bucket    = module.metadata-bucket.name
  namespace = module.metadata-bucket.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase[count.index].id, oci_core_volume.essbase_data.id)
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_data[count.index].iqn,
    "ipv4" = oci_core_volume_attachment.essbase_data[count.index].ipv4,
    "port" = oci_core_volume_attachment.essbase_data[count.index].port,
  })
}

#
# Config volume attachment
#
resource "oci_core_volume_attachment" "essbase_config" {
  count           = local.node_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase[count.index].id
  volume_id       = oci_core_volume.essbase_config[count.index].id
  display_name    = "${oci_core_instance.essbase[count.index].display_name}-config-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_config_volume_metadata" {
  count     = local.node_count
  bucket    = module.metadata-bucket.name
  namespace = module.metadata-bucket.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase[count.index].id, oci_core_volume.essbase_config[count.index].id)
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_config[count.index].iqn,
    "ipv4" = oci_core_volume_attachment.essbase_config[count.index].ipv4,
    "port" = oci_core_volume_attachment.essbase_config[count.index].port,
  })
}

#
# Temp volume attachment
#
resource "oci_core_volume_attachment" "essbase_temp" {
  count           = local.node_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase[count.index].id
  volume_id       = oci_core_volume.essbase_temp[count.index].id
  display_name    = "${oci_core_instance.essbase[count.index].display_name}-temp-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_temp_volume_metadata" {
  count     = local.node_count
  bucket    = module.metadata-bucket.name
  namespace = module.metadata-bucket.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase[count.index].id, oci_core_volume.essbase_temp[count.index].id)
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_temp[count.index].iqn,
    "ipv4" = oci_core_volume_attachment.essbase_temp[count.index].ipv4,
    "port" = oci_core_volume_attachment.essbase_temp[count.index].port,
  })
}

locals {
  listen_port_suffix = var.enable_embedded_proxy ? "" : ":9001"
  external_url       = length(oci_core_instance.essbase) == 0 ? "" : (var.assign_public_ip ? format("https://%s%s/essbase", local.listen_port_suffix, oci_core_instance.essbase[0].public_ip) : format("https://%s%s/essbase", local.listen_port_suffix, oci_core_instance.essbase[0].private_ip))
}

