## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_cloudinit_config" "bastion-config" {
  count = "${var.enabled ? 1 : 0}"

  gzip          = true
  base64_encode = true

  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${file("${path.module}/userdata/bastion-bootstrap")}"
  }
}

resource "oci_core_instance" "bastion-instance" {
  count = "${var.enabled ? 1 : 0}"

  //assumption: it is the same ad as essbase
  availability_domain = "${var.availability_domain}"

  compartment_id = "${var.compartment_id}"
  display_name   = "${var.display_name_prefix}-bastion"
  shape          = "${var.instance_shape}"

  create_vnic_details {
    subnet_id              = "${var.subnet_id}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_authorized_keys}"
    user_data           = "${data.template_cloudinit_config.bastion-config.rendered}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.bastion_instance_image_ocid[var.region]}"
  }

  timeouts {
    create = "10m"
  }
}
