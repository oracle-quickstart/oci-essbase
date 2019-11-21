## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_subnet" "application" {
  subnet_id = "${var.subnet_id}"
}

resource "oci_core_volume" "essbase_data" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "${var.display_name_prefix}-data-volume-1"
  size_in_gbs         = "${var.data_volume_size}"
}

resource "oci_core_volume" "essbase_config" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "${var.display_name_prefix}-config-volume-1"
  size_in_gbs         = "${var.config_volume_size}"
}

resource "oci_core_volume_group" "essbase_volume_group" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_id}"

  source_details {
    type = "volumeIds"

    volume_ids = ["${oci_core_volume.essbase_config.id}",
      "${oci_core_volume.essbase_data.id}",
    ]
  }

  display_name = "${var.display_name_prefix}-volume-group"
}

locals {
  assign_public_ip = "${!data.oci_core_subnet.application.prohibit_public_ip_on_vnic && var.assign_public_ip ? 1 : 0}"
  hostname_label   = "${data.oci_core_subnet.application.dns_label != "" ? format("%s-1", var.node_hostname_prefix) : ""}"
  node_domain_name = "${data.oci_core_subnet.application.subnet_domain_name != "" ? format("%s.%s", local.hostname_label, data.oci_core_subnet.application.subnet_domain_name) : ""}"
}

# This should not have any dependencies on created resources
# to allow for parallelization.  The prepare_vm script is called during
# cloud-init and will have enough logic to wait for dependent resources
# to be available.
resource "oci_core_instance" "essbase" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "${var.display_name_prefix}-node-1"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id = "${var.subnet_id}"

    # Temporary until we figure out how to update all of the metadata in the right order
    assign_public_ip = "${local.assign_public_ip}"
    hostname_label   = "${local.hostname_label}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.image_id}"
  }

  metadata = {
    ssh_authorized_keys  = "${var.ssh_authorized_keys}"
    system_mode          = "${var.development_mode ? "dev" : "prod"}"
    data_volume_ocid     = "${oci_core_volume.essbase_data.id}"
    config_volume_ocid   = "${oci_core_volume.essbase_config.id}"
    volume_group_ocid    = "${oci_core_volume_group.essbase_volume_group.id}"
    kms_key_ocid         = "${var.kms_key_id}"

    #database_ocid                    = "${var.db_database_id}"
    #database_backup_bucket_namespace = "${var.db_backup_bucket_namespace}"
    #database_backup_bucket_name      = "${var.db_backup_bucket_name}"
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume_attachment" "essbase_data" {
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.essbase.id}"
  volume_id       = "${oci_core_volume.essbase_data.id}"

  display_name = "${var.display_name_prefix}-data-volume-1-attachment"

  # Mount details
  connection {
    host        = "${local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip}"
    private_key = "${var.ssh_private_key}"
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"

    bastion_host = "${var.bastion_host}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /u01/data",
      "sudo mkdir -p /u01/data",
      "sudo /u01/vmtools/mount-iscsi-volume.sh ${self.iqn} ${self.ipv4} ${self.port} /u01/data",
      "sudo chown -R oracle:oracle /u01/data"
    ]
  }

  provisioner "remote-exec" {
    when       = "destroy"
    on_failure = "continue"
    inline = [
      "sudo -i -u oracle /u01/vmtools/shutdown.sh",
      "sudo /u01/vmtools/unmount-iscsi-volume.sh ${self.iqn} ${self.ipv4} ${self.port} /u01/data"
    ]
  }

}

resource "oci_core_volume_attachment" "essbase_config" {
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.essbase.id}"
  volume_id       = "${oci_core_volume.essbase_config.id}"

  display_name = "${var.display_name_prefix}-config-volume-1-attachment"

  # Mount details
  connection {
    host        = "${local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip}"
    private_key = "${var.ssh_private_key}"
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"

    bastion_host = "${var.bastion_host}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /u01/config",
      "sudo mkdir -p /u01/config",
      "sudo /u01/vmtools/mount-iscsi-volume.sh ${self.iqn} ${self.ipv4} ${self.port} /u01/config",
      "sudo chown -R oracle:oracle /u01/config"
    ]
  }

  provisioner "remote-exec" {
    when       = "destroy"
    on_failure = "continue"
    inline = [
      "sudo -i -u oracle /u01/vmtools/shutdown.sh",
      "sudo /u01/vmtools/unmount-iscsi-volume.sh ${self.iqn} ${self.ipv4} ${self.port} /u01/config"
    ]
  }


}

resource "tls_private_key" "demo_node_cert" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "demo_node_cert" {
  key_algorithm   = "${tls_private_key.demo_node_cert.algorithm}"
  private_key_pem = "${tls_private_key.demo_node_cert.private_key_pem}"

  ip_addresses = ["${compact(list(oci_core_instance.essbase.public_ip, oci_core_instance.essbase.private_ip))}"]

  subject {
    common_name         = "${local.node_domain_name != "" ? local.node_domain_name : "*.oraclevcn.com"}"
    organization        = "MyOrganization"
    organizational_unit = "FOR TESTING ONLY"
  }
}

resource "tls_locally_signed_cert" "demo_node_cert" {
  cert_request_pem = "${tls_cert_request.demo_node_cert.cert_request_pem}"

  ca_key_algorithm   = "${var.demo_ca["algorithm"]}"
  ca_private_key_pem = "${var.demo_ca["private_key_pem"]}"
  ca_cert_pem        = "${var.demo_ca["cert_pem"]}"

  validity_period_hours = "8760"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

locals {
  node_url     = "${local.assign_public_ip ? format("http://%s/essbase", oci_core_instance.essbase.public_ip) : format("http://%s/essbase", oci_core_instance.essbase.private_ip) }"
  external_url = "${var.external_url != "" ? var.external_url : local.node_url }"
}

locals {
  config_payload = <<JSON
{
   "system": {
      "mode": "${var.development_mode ? "dev" : "prod"}"
      "reset": ${var.development_mode == "dev" && var.reset_system ? true : false }
      "adminUsername": "${var.admin_username}"
      "adminPassword": "%s"
   }

   "kms": {
      "key_id": "${var.kms_key_id}"
      "crypto_endpoint": "${var.kms_crypto_endpoint}"
   }

   "database": {
      "type": "ADP"
      "alias": "${var.db_connect_alias}"
      "autonomousDatabaseID": "${var.db_database_id}"
      "adminUsername": "${var.db_admin_username}"
      "adminPassword": "%s"
      "schemaPrefix": "${var.rcu_schema_prefix}"
      "backupBucketName": "${var.db_backup_bucket_name}"
      "backupBucketNamespace": "${var.db_backup_bucket_namespace}"
   }

   "security": {
      "type": "${var.security_mode}"
      "idcs": {
         "clientTenant": "${var.idcs_client_tenant}"
         "clientId": "${var.idcs_client_id}"
         "clientSecret": "%s"
         "externalAdminUsername": "${var.idcs_external_admin_username}"
      }
   }

   "externalUrl": "${local.external_url}"
}
JSON

  encoded_admin_password    = "${var.use_kms_provisioning_key ? format("{KMS}%s", var.admin_password) : base64encode(var.admin_password)}"
  encoded_db_admin_password = "${var.use_kms_provisioning_key ? format("{KMS}%s", var.db_admin_password) : base64encode(var.db_admin_password)}"

  encoded_idcs_client_secret_1 = "${var.idcs_client_secret != "" ? format("{KMS}%s", var.idcs_client_secret) : "" }"
  encoded_idcs_client_secret_2 = "${var.idcs_client_secret != "" ? base64encode(var.idcs_client_secret) : "" }"
  encoded_idcs_client_secret   = "${var.use_kms_provisioning_key ? local.encoded_idcs_client_secret_1 : local.encoded_idcs_client_secret_2}"
}

resource "null_resource" "initializer" {
  triggers = {
    instance_id            = "${oci_core_instance.essbase.id}"
    autonomous_database_id = "${var.db_database_id}"
  }

  depends_on = [
    "oci_core_volume_attachment.essbase_data",
    "oci_core_volume_attachment.essbase_config",
  ]

  connection {
    host        = "${local.assign_public_ip ? oci_core_instance.essbase.public_ip : oci_core_instance.essbase.private_ip}"
    private_key = "${var.ssh_private_key}"
    type        = "ssh"
    user        = "opc"
    timeout     = "5m"

    bastion_host = "${var.bastion_host}"
  }

  # Adjust the system limits
  provisioner "remote-exec" {
    inline = [
      "sudo /u01/vmtools/adjust-limits.sh"
    ]
  }

  # Write the configuration file
  provisioner "remote-exec" {
    inline = <<EOT
echo '${format(local.config_payload,
               local.encoded_admin_password,
               local.encoded_db_admin_password,
               local.encoded_idcs_client_secret)}' > /etc/essbase/instance.conf
EOT
  }

  # Copy the certs over
  provisioner "file" {
    content     = "${var.demo_ca["cert_pem"]}"
    destination = "/etc/essbase/demo-ca.crt"
  }

  provisioner "file" {
    content     = "${tls_locally_signed_cert.demo_node_cert.cert_pem}"
    destination = "/etc/essbase/demo-cert.crt"
  }

  provisioner "file" {
    content     = "${tls_private_key.demo_node_cert.private_key_pem}"
    destination = "/etc/essbase/demo-cert.key"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/initialize.sh"
  }

  provisioner "remote-exec" {
    when       = "destroy"
    on_failure = "continue"
    inline = [
      "sudo -i -u oracle /u01/vmtools/shutdown.sh"
    ]
  }

}
