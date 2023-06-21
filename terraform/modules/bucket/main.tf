## Copyright (c) 2019-2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "user" {
  # TODO Enable  # compartment_id = "${var.compartment_id}"
}

resource "oci_objectstorage_bucket" "data" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.user.namespace
  name           = var.bucket_name
  access_type    = "NoPublicAccess"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

