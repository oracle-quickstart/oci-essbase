## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
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

#
# Metadata bucket
# Stores metadata required for the compute instances that cannot be
# provided at instance creation time
#
data "oci_objectstorage_namespace" "user" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "essbase_metadata" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.user.namespace
  name           = "essbase_${var.instance_uuid}_metadata"
  access_type    = "NoPublicAccess"
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
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-config-volume"
  size_in_gbs         = var.config_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_temp" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-temp-volume"
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
      oci_core_volume.essbase_config.id,
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
runcmd:
%{ for mapping in var.additional_host_mappings ~}
- echo "${mapping.ip_address} ${mapping.host}" >> /etc/hosts
%{ endfor ~}
- /u01/vmtools/init/essbase-init.sh
--boundary-0123456789--
TMPL

   is_flex_shape = var.shape == "VM.Standard.E3.Flex" || var.shape == "VM.Standard.E4.Flex" ? [ var.shape_ocpus ] : []
}

#
# Essbase instance definition
#
resource "oci_core_instance" "essbase" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-node-1"
  shape               = var.shape

  dynamic "shape_config" {
    for_each = local.is_flex_shape
    content {
       ocpus = shape_config.value
    }
  }

  create_vnic_details {
    display_name = "primary"
    subnet_id = var.subnet_id
    assign_public_ip = var.assign_public_ip
    hostname_label   = data.oci_core_subnet.application.dns_label != "" ? format("%s-%s", var.hostname_label_prefix, 1) : ""
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  metadata = {
    ssh_authorized_keys        = var.ssh_authorized_keys
    user_data                  = base64gzip(local.cloud_init)

    stack_id                   = var.stack_id
    stack_display_name         = var.stack_display_name
    enable_monitoring          = var.enable_monitoring
    notification_topic_id      = var.notification_topic_id

    volume_group_id            = oci_core_volume_group.essbase_volume_group.id

    kms_key_id                 = var.kms_key_id
    kms_crypto_endpoint        = var.kms_crypto_endpoint

    admin_username             = var.admin_username
    admin_password_encrypted   = var.admin_password_encrypted
    rcu_schema_prefix          = var.rcu_schema_prefix

    security_mode              = var.security_mode
    external_admin_username    = var.external_admin_username

    enable_embedded_proxy      = var.enable_embedded_proxy

  }

  extended_metadata = {
    metadata_bucket = jsonencode({
       id        = oci_objectstorage_bucket.essbase_metadata.id,
       namespace = oci_objectstorage_bucket.essbase_metadata.namespace,
       name      = oci_objectstorage_bucket.essbase_metadata.name
    })
    volumes = jsonencode({
       config = {
          id = oci_core_volume.essbase_config.id,
          display_name = oci_core_volume.essbase_config.display_name,
          path = "/u01/config",
       },
       data = {
          id = oci_core_volume.essbase_data.id,
          display_name = oci_core_volume.essbase_data.display_name,
          path = "/u01/data",
       },
       temp = {
          id = oci_core_volume.essbase_temp.id,
          display_name = oci_core_volume.essbase_temp.display_name,
          path = "/u01/tmp"
       },
    })
    idcs = jsonencode({
       tenant = var.idcs_tenant,
       client_id = var.idcs_client_id,
       client_secret_encrypted = var.idcs_client_secret_encrypted,
    })
    database = jsonencode({
       type                     = var.db_type,
       id                       = var.db_database_id,
       alias_name               = var.db_alias_name,
       connect_string           = var.db_connect_string,
       admin_username           = var.db_admin_username,
       admin_password_encrypted = var.db_admin_password_encrypted,
       backup_bucket  = {
          name = var.db_backup_bucket_name,
          namespace = var.db_backup_bucket_namespace
       }
    })
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}



#
# Data volume attachment
#
resource "oci_core_volume_attachment" "essbase_data" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = oci_core_volume.essbase_data.id
  display_name    = "${oci_core_instance.essbase.display_name}-data-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_data_volume_metadata" {
  bucket    = oci_objectstorage_bucket.essbase_metadata.name
  namespace = oci_objectstorage_bucket.essbase_metadata.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase.id, oci_core_volume.essbase_data.id)
  content = jsonencode({
    "iqn"   = oci_core_volume_attachment.essbase_data.iqn,
    "ipv4"  = oci_core_volume_attachment.essbase_data.ipv4,
    "port"  = oci_core_volume_attachment.essbase_data.port,
  })
}

#
# Config volume attachment
#
resource "oci_core_volume_attachment" "essbase_config" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = oci_core_volume.essbase_config.id
  display_name    = "${oci_core_instance.essbase.display_name}-config-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_config_volume_metadata" {
  bucket    = oci_objectstorage_bucket.essbase_metadata.name
  namespace = oci_objectstorage_bucket.essbase_metadata.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase.id, oci_core_volume.essbase_config.id)
  content = jsonencode({
    "iqn"   = oci_core_volume_attachment.essbase_config.iqn,
    "ipv4"  = oci_core_volume_attachment.essbase_config.ipv4,
    "port"  = oci_core_volume_attachment.essbase_config.port,
  })
}

#
# Temp volume attachment
#
resource "oci_core_volume_attachment" "essbase_temp" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = oci_core_volume.essbase_temp.id
  display_name    = "${oci_core_instance.essbase.display_name}-temp-volume-attachment"
}

resource "oci_objectstorage_object" "essbase_temp_volume_metadata" {
  bucket    = oci_objectstorage_bucket.essbase_metadata.name
  namespace = oci_objectstorage_bucket.essbase_metadata.namespace
  object    = format("%s/%s.dat", oci_core_instance.essbase.id, oci_core_volume.essbase_temp.id)
  content = jsonencode({
    "iqn"   = oci_core_volume_attachment.essbase_temp.iqn,
    "ipv4"  = oci_core_volume_attachment.essbase_temp.ipv4,
    "port"  = oci_core_volume_attachment.essbase_temp.port,
  })
}

locals {
  listen_port = var.enable_embedded_proxy ? 443 : 9001
  listen_port_suffix = var.enable_embedded_proxy ? "" : ":9001"
  external_url = var.assign_public_ip ? format("https://%s%s/essbase", oci_core_instance.essbase.public_ip, local.listen_port_suffix) : format("https://%s%s/essbase", oci_core_instance.essbase.private_ip, local.listen_port_suffix)
}

