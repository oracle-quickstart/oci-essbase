## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  config_volume_mount = "/u01/config"
  data_volume_mount   = "/u01/data"
}

data "oci_core_subnet" "application" {
  subnet_id = var.subnet_id
}

#
# Volumes
#
resource "oci_core_volume" "essbase_data" {
  count               = var.enable_data_volume ? 1 : 0
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-data-volume-1"
  size_in_gbs         = var.data_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume" "essbase_config" {
  count               = var.enable_config_volume ? 1 : 0
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-config-volume-1"
  size_in_gbs         = var.config_volume_size
  freeform_tags       = var.freeform_tags
  defined_tags        = var.defined_tags
}

resource "oci_core_volume_group" "essbase_volume_group" {
  count               = var.enable_data_volume || var.enable_config_volume ? 1 : 0
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  source_details {
    type = "volumeIds"

    volume_ids = concat(
      oci_core_volume.essbase_config.*.id,
      oci_core_volume.essbase_data.*.id,
    )
  }

  display_name  = "${var.display_name_prefix}-volume-group"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}


locals {
  assign_public_ip = (! data.oci_core_subnet.application.prohibit_public_ip_on_vnic) && var.assign_public_ip
  hostname_label   = data.oci_core_subnet.application.dns_label != "" ? format("%s-1", var.node_hostname_prefix) : ""
  node_domain_name = data.oci_core_subnet.application.subnet_domain_name != "" ? format(
    "%s.%s",
    local.hostname_label,
    data.oci_core_subnet.application.subnet_domain_name,
  ) : ""
}


#
# Cloud Init Script
#

locals {

  essbase_config = <<JSON
{
   "system": {
      "adminUsername": ${jsonencode(var.admin_username)},
      "adminPassword": ${jsonencode(format("{KMS}%s", var.admin_password))},
      "tempDir": "/u01/config/tmp",
   },

   "kms": {
      "keyId": ${jsonencode(var.kms_key_id)},
      "cryptoEndpoint": ${jsonencode(var.kms_crypto_endpoint)},
   },

   "database": {
      "type": ${jsonencode(var.db_type)},
%{if var.db_database_id != ""~}
      "databaseId": ${jsonencode(var.db_database_id)},
%{endif~}
%{if var.db_alias_name != ""~}
      "alias": ${jsonencode(var.db_alias_name)},
%{endif~}
%{if var.db_connect_string != ""~}
      "connectString": ${jsonencode(var.db_connect_string)},
%{endif~}
      "adminUsername": ${jsonencode(var.db_admin_username)},
      "adminPassword": ${jsonencode(format("{KMS}%s", var.db_admin_password))},
      "schemaPrefix": ${jsonencode(var.rcu_schema_prefix)},
%{if var.db_backup_bucket_name != ""~},
      "backupBucketName": ${jsonencode(var.db_backup_bucket_name)},
      "backupBucketNamespace": ${jsonencode(var.db_backup_bucket_namespace)},
%{endif~}
   },

   "security": {
      "type": ${jsonencode(var.security_mode)},
%{if var.security_mode == "idcs"~}
      "idcs": {
         "clientTenant": ${jsonencode(var.idcs_client_tenant)},
         "clientId": ${jsonencode(var.idcs_client_id)},
         "clientSecret": ${jsonencode(format("{KMS}%s", var.idcs_client_secret))},
         "externalAdminUsername": ${jsonencode(var.idcs_external_admin_username)}
      }
%{endif~}
   }
}
JSON


  cloud_init = <<TMPL
Content-Type: multipart/mixed; boundary="boundary-0123456789"
MIME-Version: 1.0

--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
# vim: syntax=yaml
write_files:
- path: /etc/essbase/instance.conf
  permissions: '0644'
  content: |
      ${indent(6, local.essbase_config)}

--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/x-shellscript

${file("${path.module}/scripts/configure_machine.sh")}
--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/x-shellscript

${file("${path.module}/scripts/configure_volumes.sh")}
--boundary-0123456789--
TMPL

}

#
# Essbase instance definition
#
resource "oci_core_instance" "essbase" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-node-1"
  shape               = var.shape

  create_vnic_details {
    subnet_id = var.subnet_id

    # Temporary until we figure out how to update all of the metadata in the right order
    assign_public_ip = local.assign_public_ip
    hostname_label   = local.hostname_label
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys  = var.ssh_authorized_keys
    user_data            = base64gzip(local.cloud_init)
    volume_group_ocid    = join("", oci_core_volume_group.essbase_volume_group.*.id)
    kms_key_ocid         = var.kms_key_id
  }

  extended_metadata = {
    volume_ocids = jsonencode(compact(concat(oci_core_volume.essbase_data.*.id, oci_core_volume.essbase_config.*.id)))
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
  count           = var.enable_data_volume ? 1 : 0
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = join("", oci_core_volume.essbase_data.*.id)

  display_name = "${var.display_name_prefix}-data-volume-1-attachment"

  connection {
    host        = local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip
    private_key = var.ssh_private_key
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"

    bastion_host = var.bastion_host
  }

  provisioner "file" {
    destination = format("/etc/essbase/%s.dat", self.volume_id)
    content = jsonencode({
      "path" = local.data_volume_mount,
      "iqn"  = self.iqn,
      "ipv4" = self.ipv4,
      "port" = self.port
    })
  }
}



#
# Config volume attachment
#
resource "oci_core_volume_attachment" "essbase_config" {
  count           = var.enable_config_volume ? 1 : 0
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.essbase.id
  volume_id       = join("", oci_core_volume.essbase_config.*.id)

  display_name = "${var.display_name_prefix}-config-volume-1-attachment"

  connection {
    host        = local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip
    private_key = var.ssh_private_key
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"
    bastion_host = var.bastion_host
  }

  provisioner "file" {
    destination = format("/etc/essbase/%s.dat", self.volume_id)
    content = jsonencode({
      "path" = local.config_volume_mount,
      "iqn"  = self.iqn,
      "ipv4" = self.ipv4,
      "port" = self.port
    })
  }

}


locals {
  external_url = local.assign_public_ip ? format("https://%s/essbase", oci_core_instance.essbase.public_ip) : format("https://%s/essbase", oci_core_instance.essbase.private_ip)
}

resource "null_resource" "initializer" {

  triggers = {
    instance_ocid = oci_core_instance.essbase.id
    data_volume_ocid = join("", oci_core_volume.essbase_data.*.id)
    config_volume_ocid = join("", oci_core_volume.essbase_config.*.id)
  }

  depends_on = [
    oci_core_instance.essbase,
    oci_core_volume_attachment.essbase_config,
    oci_core_volume_attachment.essbase_data,
  ]

  connection {
    host        = local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip
    private_key = var.ssh_private_key
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"

    bastion_host = var.bastion_host
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/configure_essbase.sh"
  }

}

