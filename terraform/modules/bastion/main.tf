## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


locals {

  cloud_init = <<TMPL
Content-Type: multipart/mixed; boundary="BASTION-BOUNDARY-0123456789"
MIME-Version: 1.0

--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="us-ascii"

${file("${path.module}/userdata/bastion-bootstrap")}
--boundary-0123456789--
TMPL

}

resource "oci_core_instance" "bastion-instance" {
  count = var.enabled ? 1 : 0

  //assumption: it is the same ad as essbase
  availability_domain = var.availability_domain

  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-bastion"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
  shape          = var.instance_shape

  create_vnic_details {
    subnet_id              = var.subnet_id
    skip_source_dest_check = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64gzip(local.cloud_init)
  }

  source_details {
    source_type = "image"
    source_id   = var.bastion_instance_image_ocid[var.region]
  }

  timeouts {
    create = "10m"
  }
}

