## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

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

  # prevent the bastion from destroying and recreating itself if the image ocid changes
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  timeouts {
    create = "10m"
  }
}

