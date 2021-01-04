## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Get Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "bastion_image_agreement" {
  listing_id               = var.listing_id
  listing_resource_version = var.listing_resource_version
}

# Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "bastion_image_subscription" {
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.bastion_image_agreement.time_retrieved

  timeouts {
    create = "20m"
  }
}

resource "oci_core_instance" "bastion-instance" {

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

  instance_options {
    are_legacy_imds_endpoints_disabled = true
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
    source_id   = oci_core_app_catalog_subscription.bastion_image_subscription.listing_resource_id
  }

  timeouts {
    create = "10m"
  }
}

