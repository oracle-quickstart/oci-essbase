## Copyright (c) 2019-2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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
%{if var.timezone != ""~}
timezone: ${var.timezone}
%{endif~}
runcmd:
%{for mapping in var.additional_host_mappings~}
- echo "${mapping.ip_address} ${mapping.host}" >> /etc/hosts
%{endfor~}
- /u01/vmtools/init/essbase-init.sh
--boundary-0123456789--
TMPL

  is_flex_shape     = (var.shape == "VM.Standard.E3.Flex" || var.shape == "VM.Standard.E4.Flex") || (var.shape == "VM.Optimized3.Flex" || var.shape == "VM.Standard3.Flex")
  flex_ocpus        = var.shape_ocpus == null ? 4 : var.shape_ocpus
  flex_shape_config = local.is_flex_shape ? [{ "ocpus" : local.flex_ocpus }] : []
}

#
# Essbase instance definition
#
resource "oci_core_instance" "essbase" {

  availability_domain = var.availability_domain
  fault_domain        = var.fault_domain
  compartment_id      = var.compartment_id
  display_name        = var.display_name

  shape = var.shape
  dynamic "shape_config" {
    for_each = local.flex_shape_config
    content {
      ocpus = shape_config.value.ocpus
    }
  }

  create_vnic_details {
    display_name     = "primary"
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.hostname_label
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64gzip(local.cloud_init)

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
    external_admin_username = var.external_admin_username

    enable_cluster      = var.enable_cluster
    enable_storage_vnic = var.enable_storage_vnic
    node_index          = var.node_index
  }

  extended_metadata = {
    metadata_bucket = jsonencode(var.metadata_bucket)
    backup_bucket   = jsonencode(var.backup_bucket)

    catalog_bucket  = jsonencode(var.catalog_bucket)
    catalog_storage = jsonencode(var.instance_catalog_storage)

    volumes = jsonencode({
      config = {
        path = "/u01/config",
        id   = var.config_volume.id
      },
      data = {
        path = "/u01/data",
        id   = var.data_volume.id
      },
      temp = {
        path = "/u01/tmp",
        id   = var.temp_volume.id
      },
    })
    idcs = jsonencode(var.idcs_config)
    database = jsonencode({
      type               = var.db_type,
      id                 = var.db_database_id,
      alias_name         = var.db_alias_name,
      connect_string     = var.db_connect_string,
      admin_username     = var.db_admin_username,
      admin_password_id  = var.db_admin_password_id,
      bootstrap_password = var.db_bootstrap_password != "" && var.db_bootstrap_password != null ? base64encode(var.db_bootstrap_password) : null,
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

# Secondary vnic for storage
resource "oci_core_vnic_attachment" "storage_vnic_attachment" {

  count        = var.enable_storage_vnic ? 1 : 0
  instance_id  = oci_core_instance.essbase.id
  display_name = "${oci_core_instance.essbase.display_name}-storage-vnic"

  create_vnic_details {
    display_name           = "storage"
    subnet_id              = var.storage_subnet_id
    assign_public_ip       = false
    skip_source_dest_check = false

    freeform_tags = var.freeform_tags
    defined_tags  = var.defined_tags
  }
}

data "oci_core_vnic" "storage_vnic" {
  count   = var.enable_storage_vnic ? 1 : 0
  vnic_id = oci_core_vnic_attachment.storage_vnic_attachment[count.index].vnic_id
}

#
# Data volume attachment
#
resource "oci_core_volume_attachment" "essbase_data" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = var.data_volume.id
  display_name    = "data-volume"
  is_shareable    = var.enable_cluster
}

resource "oci_objectstorage_object" "essbase_data_volume_metadata" {
  bucket       = var.metadata_bucket.name
  namespace    = var.metadata_bucket.namespace
  object       = format("%s/%s.dat", oci_core_instance.essbase.id, var.data_volume.id)
  storage_tier = "InfrequentAccess"
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_data.iqn,
    "ipv4" = oci_core_volume_attachment.essbase_data.ipv4,
    "port" = oci_core_volume_attachment.essbase_data.port,
  })
}


#
# Config volume attachment
#
resource "oci_core_volume_attachment" "essbase_config" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = var.config_volume.id
  display_name    = "config-volume"
}

resource "oci_objectstorage_object" "essbase_config_volume_metadata" {
  bucket       = var.metadata_bucket.name
  namespace    = var.metadata_bucket.namespace
  object       = format("%s/%s.dat", oci_core_instance.essbase.id, var.config_volume.id)
  storage_tier = "InfrequentAccess"
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_config.iqn,
    "ipv4" = oci_core_volume_attachment.essbase_config.ipv4,
    "port" = oci_core_volume_attachment.essbase_config.port,
  })
}


#
# Temp volume attachment
#
resource "oci_core_volume_attachment" "essbase_temp" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = var.temp_volume.id
  display_name    = "temp-volume"
}

resource "oci_objectstorage_object" "essbase_temp_volume_metadata" {
  bucket       = var.metadata_bucket.name
  namespace    = var.metadata_bucket.namespace
  object       = format("%s/%s.dat", oci_core_instance.essbase.id, var.temp_volume.id)
  storage_tier = "InfrequentAccess"
  content = jsonencode({
    "iqn"  = oci_core_volume_attachment.essbase_temp.iqn,
    "ipv4" = oci_core_volume_attachment.essbase_temp.ipv4,
    "port" = oci_core_volume_attachment.essbase_temp.port,
  })
}


locals {
  listen_port_suffix = var.enable_embedded_proxy ? "" : ":9001"
  external_url       = var.assign_public_ip ? format("https://%s%s/essbase", local.listen_port_suffix, oci_core_instance.essbase.public_ip) : format("https://%s%s/essbase", local.listen_port_suffix, oci_core_instance.essbase.private_ip)
}

